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
#import "MTULayer.h"
#import "MTUDevice.h"

const static NSUInteger MAX_BUFFERS_IN_FLIGHT = 3;

const static MTUVertexPT QuadVertices[] = {
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
    
    MTUMesh *_postProcess;
    id <MTLRenderPipelineState> _postProcessRenderState;
    
    MTKView *_view;
    MTLViewport _viewPort;
    MTKTextureLoader *_textureLoader;
    
    NSUInteger _inFlightBufferIndex;
    dispatch_semaphore_t _inFlightSemaphore;
}

- (void) resetPostProcess;
- (void) resetDefaultLayerWithSize:(CGSize)size;

@end

@implementation MTUDevice

// temporary render variable
static MTULayer *targetLayer_ = nil;
static id <MTLCommandBuffer> commandBuffer_ = nil;
static id <MTLRenderCommandEncoder> renderCommandEncoder_ = nil;

+ (nonnull MTUDevice *) sharedInstance {
    static MTUDevice *instance = nil;
    if (instance == nil) {
        instance = [[MTUDevice alloc] init];
    }
    return instance;
}

- (id <MTLDevice>) mtlDevice {
    return _device;
}

- (nonnull instancetype) init {
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _library = [_device newDefaultLibrary];
        _commandQueue = [_device newCommandQueue];
        _textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
        _inFlightSemaphore = dispatch_semaphore_create(MAX_BUFFERS_IN_FLIGHT);
        
        _default3DLayerName = @"MTUDevice 3D Layer";
    }
    return self;
}

- (void) resetPostProcess {
    if (_postProcess) {
        _postProcess = nil;
    }
    
    NSData *vertexData = [NSData dataWithBytes:QuadVertices length:sizeof(QuadVertices)];
    _postProcess = [[MTUMesh alloc] initWithVertexData:vertexData andVertexFormat:MTUVertexFormatPT];
    _postProcess.name = @"post process of view";
    
    MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.label = @"Post process render pipeline state";
    renderPipelineDescriptor.vertexFunction = [self shaderFunctionWithName:@"vertPostProcess"];
    renderPipelineDescriptor.fragmentFunction = [self shaderFunctionWithName:@"fragPostProcess"];
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    renderPipelineDescriptor.inputPrimitiveTopology = MTLPrimitiveTopologyClassTriangle;
    
    MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
    vertexDescriptor.attributes[1].offset = 12;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    vertexDescriptor.layouts[0].stride = 20;
    vertexDescriptor.layouts[0].stepFunction = MTLStepFunctionPerVertex;
    vertexDescriptor.layouts[0].stepRate = 1;
    renderPipelineDescriptor.vertexDescriptor = vertexDescriptor;
    
    _postProcessRenderState = [_device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:nil];
}

- (void) resetDefaultLayerWithSize:(CGSize)size {
    if (size.width < 1 || size.height < 1) {
        return;
    }
    
    MTULayerConfig *config = [[MTULayerConfig alloc] init];
    config.name = self.default3DLayerName;
    config.size = size;
    config.colorFormats = @[@(MTLPixelFormatBGRA8Unorm)];
    config.depthFormat = MTLPixelFormatDepth32Float;
    [MTULayer createLayerToCache:config];
}

- (void) setView:(MTKView *)view {
    _view = view;
    _view.device = _device;
    _view.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    
    CGSize viewSize = _view.drawableSize;
    _viewPort = (MTLViewport){0.0, 0.0, viewSize.width, viewSize.height, -1.0, 1.0};
    [self resetDefaultLayerWithSize:viewSize];
    [self resetPostProcess];
}

- (id <MTLFunction>) shaderFunctionWithName:(NSString *)name {
    return name ? [_library newFunctionWithName:name] : nil;
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
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    
    _inFlightBufferIndex = (_inFlightBufferIndex + 1) % MAX_BUFFERS_IN_FLIGHT;
    
    commandBuffer_ = [_commandQueue commandBuffer];
    commandBuffer_.label = @"MTU CommandBuffer";
    
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer_ addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        dispatch_semaphore_signal(block_sema);
    }];
}

- (void) setTargetLayer:(nonnull MTULayer *)layer {
    targetLayer_ = layer;
    
    if (targetLayer_ != nil) {
        renderCommandEncoder_ = [commandBuffer_ renderCommandEncoderWithDescriptor:targetLayer_.renderPass];
        renderCommandEncoder_.label = @"MTU RenderCommandEncoder";
        
        // view port
        [renderCommandEncoder_ setViewport:_viewPort];
    }
}

- (void) targetLayerEnded {
    if (renderCommandEncoder_ != nil) {
        [renderCommandEncoder_ endEncoding];
    }
    renderCommandEncoder_ = nil;
    
    targetLayer_ = nil;
}

- (void) drawMesh:(nonnull MTUMesh *)mesh {
    if (renderCommandEncoder_ == nil || mesh.material == nil) {
        return;
    }
    
    MTUMaterial *material = mesh.material;
    
    [material setRenderLayer:targetLayer_ andMeshVertexFormat:mesh.vertexFormat];
    
    [renderCommandEncoder_ setCullMode:material.config.cullMode];
    [renderCommandEncoder_ setFrontFacingWinding:material.config.winding];
    
    // render state
    [renderCommandEncoder_ setRenderPipelineState:material.renderPipelineState];
    if (material.depthStencilState) {
        [renderCommandEncoder_ setDepthStencilState:material.depthStencilState];
    }
    
    // vertices
    [renderCommandEncoder_ setVertexBuffer:mesh.vertexBuffer offset:0 atIndex:0];
    
    // transform
    if (material.config.transformType != MTUTransformTypeInvalid) {
        id <MTLBuffer> transform = [self currentInFlightBuffer:material.transformBuffers];
        [renderCommandEncoder_ setVertexBuffer:transform offset:0 atIndex:1];
    }
    
    NSUInteger bufferOffset = 2;
    if (material.config.cameraParamsUsage != MTUCameraParamsNotUse) {
        id <MTLBuffer> cameraParams = [self currentInFlightBuffer:material.cameraBuffers];
        switch (material.config.cameraParamsUsage) {
            case MTUCameraParamsForVertexShader:
                [renderCommandEncoder_ setVertexBuffer:cameraParams offset:0 atIndex:2];
                break;

            case MTUCameraParamsForFragmentShader:
                [renderCommandEncoder_ setFragmentBuffer:cameraParams offset:0 atIndex:2];
                break;

            case MTUCameraParamsForBothShaders:
                [renderCommandEncoder_ setVertexBuffer:cameraParams offset:0 atIndex:2];
                [renderCommandEncoder_ setFragmentBuffer:cameraParams offset:0 atIndex:2];
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
            [renderCommandEncoder_ setVertexBuffer:buffer offset:0 atIndex:i + bufferOffset];
        }
    }
    NSArray <NSNumber *> *fsBufferIndices = material.bufferIndexOfFragmentShader;
    if (buffers != nil && fsBufferIndices != nil) {
        for (NSUInteger i = 0; i < fsBufferIndices.count; ++i) {
            NSNumber *number = fsBufferIndices[i];
            id <MTLBuffer> buffer = buffers[number.unsignedIntegerValue];
            [renderCommandEncoder_ setFragmentBuffer:buffer offset:0 atIndex:i + bufferOffset];
        }
    }
    
    // textures
    NSArray *textures = material.textures;
    for (NSUInteger i = 0; i < textures.count; ++i) {
        [renderCommandEncoder_ setFragmentTexture:textures[i] atIndex:i];
    }
    
    // draw call
    [renderCommandEncoder_ drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:mesh.vertexCount];
}

- (void) presentToView {
    if (commandBuffer_ == nil) {
        return;
    }
    
    MTLRenderPassDescriptor *finalPassDescriptor = _view.currentRenderPassDescriptor;
    if (finalPassDescriptor) {
        renderCommandEncoder_ = [commandBuffer_ renderCommandEncoderWithDescriptor:finalPassDescriptor];
        renderCommandEncoder_.label = @"MTU PostProcessEncoder";
        
        [renderCommandEncoder_ setViewport:_viewPort];
        
        [renderCommandEncoder_ setRenderPipelineState:_postProcessRenderState];
        
        [renderCommandEncoder_ setVertexBuffer:_postProcess.vertexBuffer offset:0 atIndex:0];
        
        MTULayer *deviceLayer = [MTULayer layerFromCache:self.default3DLayerName];
        [renderCommandEncoder_ setFragmentTexture:deviceLayer.colorAttachments[0] atIndex:0];
        
        [renderCommandEncoder_ drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_postProcess.vertexCount];
        
        [renderCommandEncoder_ endEncoding];
        
        renderCommandEncoder_ = nil;
    }
    
    [commandBuffer_ presentDrawable:_view.currentDrawable];
    
    [commandBuffer_ commit];
    
    commandBuffer_ = nil;
}

@end
