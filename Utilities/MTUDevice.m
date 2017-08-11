//
//  MTUDevice.m
//  MetalSample
//
//  Created by zhuwei on 7/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "MTUMath.h"
#import "MTUNode.h"
#import "MTUMesh.h"
#import "MTUMaterial.h"
#import "MTUCamera.h"
#import "MTUShaderTypes.h"
#import "MTUDevice.h"

const static NSUInteger MAX_BUFFERS_IN_FLIGHT = 3;

static const MTUVertexPT QuadVertices[] = {
    // Pixel Positions,  Texture Coordinates
    { { 1.f,-1.f, 0.f }, { 1.f, 1.f } },
    { {-1.f,-1.f, 0.f }, { 0.f, 1.f } },
    { {-1.f, 1.f, 0.f }, { 0.f, 0.f } },
    
    { { 1.f,-1.f, 0.f }, { 1.f, 1.f } },
    { {-1.f, 1.f, 0.f }, { 0.f, 0.f } },
    { { 1.f, 1.f, 0.f }, { 1.f, 0.f } },
};

@interface MTUDevice () {
    id <MTLDevice> _device;
    id <MTLLibrary> _library;
    id <MTLCommandQueue> _commandQueue;
    
    id <MTLTexture> _renderTargetColor;
    id <MTLTexture> _renderTargetDepth;
    MTLRenderPassDescriptor *_renderTargetPass;
    
    // post process
    MTUMesh *_postProcess;
    
    // re-alloc before render
    id <MTLCommandBuffer> _commandBuffer;
    id <MTLRenderCommandEncoder> _renderCommandEncoder;
    
    MTKView *_view;
    MTLViewport _viewPort;
    MTKTextureLoader *_textureLoader;
    
    NSUInteger _inFlightBufferIndex;
    dispatch_semaphore_t _inFlightSemaphore;
    
    NSMutableDictionary <NSString *, id <MTLRenderPipelineState> > *_renderPipelineStateCache;
    NSMutableDictionary <NSString *, id <MTLDepthStencilState> > *_depthStencilStateCache;
}

- (void) resetPostProcess;
- (void) resetRenderTargetWithViewSize:(CGSize)viewSize;

- (id <MTLFunction>) getShaderFunctionWithName:(NSString *)name;
- (NSString *) renderPipelineStateIdentityFromConfig:(MTUMaterialConfig *)config andMeshVertexFormat:(MTUVertexFormat)meshVertexFormat;
- (NSString *) depthStencilStateIdentityFromConfig:(MTUMaterialConfig *)config;

@end

@implementation MTUDevice

static MTUDevice *instance = nil;

+ (nonnull MTUDevice *) sharedInstance {
    if (instance == nil) {
        instance = [[MTUDevice alloc] init];
    }
    return instance;
}

- (nonnull instancetype) init {
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _library = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
        _textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
        _inFlightSemaphore = dispatch_semaphore_create(MAX_BUFFERS_IN_FLIGHT);
        _renderPipelineStateCache = [NSMutableDictionary dictionary];
        _depthStencilStateCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) resetPostProcess {
    if (_renderTargetColor == nil) {
        return;
    }
    
    if (_postProcess) {
        _postProcess = nil;
    }
    
    NSData *vertexData = [NSData dataWithBytes:QuadVertices length:sizeof(QuadVertices)];
    _postProcess = [[MTUMesh alloc] initWithVertexData:vertexData andVertexFormat:MTUVertexFormatPT];
    _postProcess.name = @"post process of view";
    
    MTUMaterialConfig *materialConfig = [[MTUMaterialConfig alloc] init];
    materialConfig.name = @"post process material";
    materialConfig.vertexShader = @"vertPostProcess";
    materialConfig.fragmentShader = @"fragPostProcess";
    materialConfig.depthFormat = MTLPixelFormatInvalid;
    materialConfig.vertexFormat = MTUVertexFormatPT;
    [_postProcess resetMaterialFromConfig:materialConfig];
}

- (void) resetRenderTargetWithViewSize:(CGSize)viewSize {
    if (viewSize.width < 1 || viewSize.height < 1) {
        return;
    }
    
    if (_renderTargetPass) {
        _renderTargetPass = nil;
    }
    if (_renderTargetColor) {
        _renderTargetColor = nil;
    }
    if (_renderTargetDepth) {
        _renderTargetDepth = nil;
    }
    
    
    MTLTextureDescriptor *colorDescriptor =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm
                                                           width:viewSize.width
                                                          height:viewSize.height
                                                          mipmapped:NO];
    colorDescriptor.storageMode = MTLStorageModePrivate;
    colorDescriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
    _renderTargetColor = [_device newTextureWithDescriptor:colorDescriptor];
    
    MTLTextureDescriptor *depthDescriptor =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                                           width:viewSize.width
                                                           height:viewSize.height
                                                           mipmapped:NO];
    depthDescriptor.storageMode = MTLStorageModePrivate;
    depthDescriptor.usage = MTLTextureUsageRenderTarget;
    _renderTargetDepth = [_device newTextureWithDescriptor:depthDescriptor];
    
    _renderTargetPass = [MTLRenderPassDescriptor renderPassDescriptor];
    _renderTargetPass.colorAttachments[0].texture = _renderTargetColor;
    _renderTargetPass.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    _renderTargetPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    _renderTargetPass.depthAttachment.texture = _renderTargetDepth;
    _renderTargetPass.depthAttachment.clearDepth = 1.0;
    _renderTargetPass.depthAttachment.loadAction = MTLLoadActionClear;
}

- (void) setView:(MTKView *)view {
    _view = view;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    
    CGSize viewSize = view.drawableSize;
    _viewPort = (MTLViewport){0.0, 0.0, viewSize.width, viewSize.height, -1.0, 1.0};
    [self resetRenderTargetWithViewSize:viewSize];
    [self resetPostProcess];
}

- (id <MTLFunction>) getShaderFunctionWithName:(NSString *)name {
    return name ? [_library newFunctionWithName:name] : nil;
}

- (NSString *) renderPipelineStateIdentityFromConfig:(MTUMaterialConfig *)config andMeshVertexFormat:(MTUVertexFormat)meshVertexFormat {
    if (config == nil) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"RenderPipelineState#%@#%@#%lu#%lu#%lu#%u#%u",
                                      config.vertexShader,
                                      config.fragmentShader,
                                      config.colorFormat,
                                      config.depthFormat,
                                      config.stencilFormat,
                                      config.vertexFormat,
                                      meshVertexFormat];
}

- (NSString *) depthStencilStateIdentityFromConfig:(MTUMaterialConfig *)config {
    if (config == nil) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"DepthStencilState#%lu#%hhd",
                                      config.depthCompareFunction,
                                      config.depthWritable];
}

- (id <MTLRenderPipelineState>) renderPipelineStateWithConfig:(MTUMaterialConfig *)config andMeshVertexFormat:(MTUVertexFormat)meshVertexFormat {
    if (config.vertexFormat > meshVertexFormat) {
        NSLog(@"Create render pipeline state failed! Vertex fromat not match!");
        return nil;
    }
    
    NSString *renderPipelineStateId = [self renderPipelineStateIdentityFromConfig:config andMeshVertexFormat:meshVertexFormat];
    if (renderPipelineStateId == nil) {
        return nil;
    }
    
    id <MTLRenderPipelineState> renderPipelineState = [_renderPipelineStateCache objectForKey:renderPipelineStateId];
    if (renderPipelineState) {
        return renderPipelineState;
    }
    
    id <MTLFunction> vertexFunction = [self getShaderFunctionWithName:config.vertexShader];
    id <MTLFunction> fragmentFunction = [self getShaderFunctionWithName:config.fragmentShader];
    if (vertexFunction == nil || fragmentFunction == nil) {
        return nil;
    }
    
    MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.label = config.name;
    renderPipelineDescriptor.vertexFunction = vertexFunction;
    renderPipelineDescriptor.fragmentFunction = fragmentFunction;
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = config.colorFormat;
    renderPipelineDescriptor.depthAttachmentPixelFormat = config.depthFormat;
    renderPipelineDescriptor.inputPrimitiveTopology = MTLPrimitiveTopologyClassTriangle;
    
    MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    // position
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    switch (config.vertexFormat) {
        case MTUVertexFormatPT:
            // texture coord
            vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
            vertexDescriptor.attributes[1].offset = 12;
            vertexDescriptor.attributes[1].bufferIndex = 0;
            break;
        case MTUVertexFormatPTN:
            // texture coord
            vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
            vertexDescriptor.attributes[1].offset = 12;
            vertexDescriptor.attributes[1].bufferIndex = 0;
            // normal
            vertexDescriptor.attributes[2].format = MTLVertexFormatFloat3;
            vertexDescriptor.attributes[2].offset = 20;
            vertexDescriptor.attributes[2].bufferIndex = 0;
            break;
        case MTUVertexFormatPTNTB:
            // texture coord
            vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
            vertexDescriptor.attributes[1].offset = 12;
            vertexDescriptor.attributes[1].bufferIndex = 0;
            // normal
            vertexDescriptor.attributes[2].format = MTLVertexFormatFloat3;
            vertexDescriptor.attributes[2].offset = 20;
            vertexDescriptor.attributes[2].bufferIndex = 0;
            // tangent
            vertexDescriptor.attributes[3].format = MTLVertexFormatFloat3;
            vertexDescriptor.attributes[3].offset = 32;
            vertexDescriptor.attributes[3].bufferIndex = 0;
            // binormal
            vertexDescriptor.attributes[4].format = MTLVertexFormatFloat3;
            vertexDescriptor.attributes[4].offset = 44;
            vertexDescriptor.attributes[4].bufferIndex = 0;
            break;
        default:
            break;
    }
    switch (meshVertexFormat) {
        case MTUVertexFormatP:
            vertexDescriptor.layouts[0].stride = 12;
            break;
        case MTUVertexFormatPT:
            vertexDescriptor.layouts[0].stride = 20;
            break;
        case MTUVertexFormatPTN:
            vertexDescriptor.layouts[0].stride = 32;
            break;
        case MTUVertexFormatPTNTB:
            vertexDescriptor.layouts[0].stride = 56;
            break;
        default:
            break;
    }
    vertexDescriptor.layouts[0].stepFunction = MTLStepFunctionPerVertex;
    vertexDescriptor.layouts[0].stepRate = 1;
    
    renderPipelineDescriptor.vertexDescriptor = vertexDescriptor;
    
    NSError *error = nil;
    renderPipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:&error];
    if (renderPipelineState == nil) {
        NSLog(@"Failed to created render pipeline state, error %@", error);
    } else {
        [_renderPipelineStateCache setObject:renderPipelineState forKey:renderPipelineStateId];
    }
    return renderPipelineState;
}

- (id <MTLDepthStencilState>) depthStencilStateWithConfig:(MTUMaterialConfig *)config {
    if (config.depthFormat == MTLPixelFormatInvalid) {
        return nil;
    }
    
    NSString *depthStencilStateId = [self depthStencilStateIdentityFromConfig:config];
    if (depthStencilStateId == nil) {
        return nil;
    }
    
    id <MTLDepthStencilState> depthStencilState = [_depthStencilStateCache objectForKey:depthStencilStateId];
    if (depthStencilState!= nil) {
        return depthStencilState;
    }
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
    depthStencilDescriptor.label = config.name;
    depthStencilDescriptor.depthCompareFunction = config.depthCompareFunction;
    depthStencilDescriptor.depthWriteEnabled = config.depthWritable;
    
    depthStencilState = [_device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    [_depthStencilStateCache setObject:depthStencilState forKey:depthStencilStateId];
    return depthStencilState;
}

- (id <MTLBuffer>) newBufferWithRawData:(NSData *)data {
    if (data.length == 0) {
        return nil;
    }
#ifdef TARGET_IOS
    return [_device newBufferWithBytes:data.bytes length:data.length options:MTLResourceStorageModeShared];
#else
    return [_device newBufferWithBytes:data.bytes length:data.length options:MTLResourceStorageModeManaged];
#endif
}

- (nullable NSArray <id <MTLBuffer> > *) newInFlightBuffersWithSize:(size_t)size {
    if (size == 0) {
        return nil;
    }
    
    id <MTLBuffer> inFlightBuffers[MAX_BUFFERS_IN_FLIGHT];
    for (NSUInteger i = 0; i < MAX_BUFFERS_IN_FLIGHT; ++i) {
        inFlightBuffers[i] = [_device newBufferWithLength:size options:MTLResourceStorageModeShared];
    }
    return [NSArray arrayWithObjects:inFlightBuffers count:MAX_BUFFERS_IN_FLIGHT];
}

- (id <MTLBuffer>) currentInFlightBuffer:(NSArray <id <MTLBuffer> > *)buffers {
    if (buffers.count != MAX_BUFFERS_IN_FLIGHT) {
        return nil;
    }
    
    return buffers[_inFlightBufferIndex];
}

- (id <MTLTexture>) newTextureWithFilename:(NSString *)filename {

    NSURL *fileurl = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:filename];
    NSDictionary *loadOptions = @{MTKTextureLoaderOptionSRGB: @NO,
                                  MTKTextureLoaderOptionOrigin: MTKTextureLoaderOriginBottomLeft,
                                  MTKTextureLoaderOptionTextureUsage: @(MTLTextureUsageShaderRead),
                                  MTKTextureLoaderOptionTextureStorageMode: @(MTLStorageModePrivate)};
    NSError *error = nil;
    id <MTLTexture> texture = [_textureLoader newTextureWithContentsOfURL:fileurl
                                                                   options:loadOptions
                                                                     error:&error];
    if (texture == nil) {
        NSLog(@"Failed to load texture %@, error %@", fileurl, error);
    }
    return texture;
}

- (nullable id <MTLTexture>) newTextureWithAssetset:(nonnull NSString *)assetset {
    NSDictionary *loadOptions = @{MTKTextureLoaderOptionTextureUsage: @(MTLTextureUsageShaderRead),
                                  MTKTextureLoaderOptionTextureStorageMode: @(MTLStorageModePrivate)};
    NSError *error = nil;
    id <MTLTexture> texture = [_textureLoader newTextureWithName:assetset
                                                     scaleFactor:1.0
                                                          bundle:nil
                                                         options:loadOptions
                                                           error:&error];
    
    if (texture == nil) {
        NSLog(@"Failed to load texture %@, error %@", assetset, error);
    }
    return texture;
}

- (void) startDraw {
    if (_renderTargetColor == nil
        || _renderTargetDepth == nil
        || _renderTargetPass == nil
        || _postProcess == nil) {
        return;
    }
    
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    
    _inFlightBufferIndex = (_inFlightBufferIndex + 1) % MAX_BUFFERS_IN_FLIGHT;
    
    _commandBuffer = [_commandQueue commandBuffer];
    _commandBuffer.label = @"MTU CommandBuffer";
    
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [_commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        dispatch_semaphore_signal(block_sema);
    }];
    
    _renderCommandEncoder = nil;

    _renderCommandEncoder = [_commandBuffer renderCommandEncoderWithDescriptor:_renderTargetPass];
    _renderCommandEncoder.label = @"MTU RenderCommandEncoder";
    
    // view port
    [_renderCommandEncoder setViewport:_viewPort];
}

- (void) drawMesh:(nonnull MTUMesh *)mesh withMaterial:(nonnull MTUMaterial *)material {
    if (_renderCommandEncoder == nil) {
        return;
    }
    
    [_renderCommandEncoder setCullMode:material.cullMode];
    [_renderCommandEncoder setFrontFacingWinding:material.winding];
    
    // render state
    [_renderCommandEncoder setRenderPipelineState:material.renderPipelineState];
    if (material.depthStencilState) {
        [_renderCommandEncoder setDepthStencilState:material.depthStencilState];
    }
    
    // vertices
    [_renderCommandEncoder setVertexBuffer:mesh.vertexBuffer offset:0 atIndex:0];
    
    // transform
    if (material.transformType != MTUTransformTypeInvalid) {
        id <MTLBuffer> transform = [self currentInFlightBuffer:material.transformBuffers];
        [_renderCommandEncoder setVertexBuffer:transform offset:0 atIndex:1];
    }
    
    NSUInteger bufferOffset = 2;
    if (material.cameraParamsUsage != MTUCameraParamsNotUse) {
        id <MTLBuffer> cameraParams = [self currentInFlightBuffer:material.cameraBuffers];
        switch (material.cameraParamsUsage) {
            case MTUCameraParamsForVertexShader:
                [_renderCommandEncoder setVertexBuffer:cameraParams offset:0 atIndex:2];
                break;

            case MTUCameraParamsForFragmentShader:
                [_renderCommandEncoder setFragmentBuffer:cameraParams offset:0 atIndex:2];
                break;

            case MTUCameraParamsForBothShaders:
                [_renderCommandEncoder setVertexBuffer:cameraParams offset:0 atIndex:2];
                [_renderCommandEncoder setFragmentBuffer:cameraParams offset:0 atIndex:2];
                break;

            default:
                break;
        }
        ++bufferOffset;
    }
    
    // Other buffers for vertex shader and fragment shader
    NSArray <id <MTLBuffer> > *buffers = material.buffers;
    NSArray <NSNumber *> *vsBufferIndices = material.bufferIndexOfVertexShader;
    if (buffers != nil && vsBufferIndices != nil) {
        for (NSUInteger i = 0; i < vsBufferIndices.count; ++i) {
            NSNumber *number = vsBufferIndices[i];
            id <MTLBuffer> buffer = buffers[number.unsignedIntegerValue];
            [_renderCommandEncoder setVertexBuffer:buffer offset:0 atIndex:i + bufferOffset];
        }
    }
    NSArray <NSNumber *> *fsBufferIndices = material.bufferIndexOfFragmentShader;
    if (buffers != nil && fsBufferIndices != nil) {
        for (NSUInteger i = 0; i < fsBufferIndices.count; ++i) {
            NSNumber *number = fsBufferIndices[i];
            id <MTLBuffer> buffer = buffers[number.unsignedIntegerValue];
            [_renderCommandEncoder setFragmentBuffer:buffer offset:0 atIndex:i + bufferOffset];
        }
    }
    
    // textures
    NSArray *textures = material.textures;
    for (NSUInteger i = 0; i < textures.count; ++i) {
        [_renderCommandEncoder setFragmentTexture:textures[i] atIndex:i];
    }
    
    // draw call
    [_renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:mesh.vertexCount];
}

- (void) commit {
    [_renderCommandEncoder endEncoding];
    
    MTLRenderPassDescriptor *postProcessPassDescriptor = _view.currentRenderPassDescriptor;
    if (postProcessPassDescriptor) {
        id <MTLRenderCommandEncoder> postProcessEncoder =
            [_commandBuffer renderCommandEncoderWithDescriptor:postProcessPassDescriptor];
        postProcessEncoder.label = @"MTU PostProcessEncoder";
        
        [postProcessEncoder setViewport:_viewPort];
        
        [postProcessEncoder setRenderPipelineState:_postProcess.material.renderPipelineState];
        
        [postProcessEncoder setVertexBuffer:_postProcess.vertexBuffer offset:0 atIndex:0];
        [postProcessEncoder setFragmentTexture:_renderTargetColor atIndex:0];
        
        [postProcessEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_postProcess.vertexCount];
        
        [postProcessEncoder endEncoding];
    }
    
    [_commandBuffer presentDrawable:_view.currentDrawable];
    
    [_commandBuffer commit];
}

@end
