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
#import "MTUShaderTypes.h"
#import "MTUDevice.h"


const static NSUInteger MAX_BUFFERS_IN_FLIGHT = 3;

@interface MTUDevice () {
    id <MTLDevice> _device;
    id <MTLLibrary> _library;
    id <MTLCommandQueue> _commandQueue;
    
    id <MTLCommandBuffer> _commandBuffer;
    id <MTLRenderCommandEncoder> _renderCommandEncoder;
    
    MTKView *_view;
    MTKTextureLoader *_textureLoader;
    
    NSUInteger _inFlightBufferIndex;
    dispatch_semaphore_t _inFlightSemaphore;
    
    NSMutableDictionary <NSString *, id <MTLRenderPipelineState> > *_renderPipelineStateCache;
    NSMutableDictionary <NSString *, id <MTLDepthStencilState> > *_depthStencilStateCache;
}

- (id <MTLFunction>) getShaderFunctionWithName:(NSString *)name;
- (NSString *) renderPipelineStateIdentityFromConfig:(MTUMaterialConfig *)config;
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

- (id <MTLFunction>) getShaderFunctionWithName:(NSString *)name {
    return name ? [_library newFunctionWithName:name] : nil;
}

- (NSString *) renderPipelineStateIdentityFromConfig:(MTUMaterialConfig *)config {
    if (config == nil) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"RPS_%@_%@_%lu_%lu_%lu",
                                      config.vertexShader,
                                      config.fragmentShader,
                                      config.colorFormat,
                                      config.depthFormat,
                                      config.stencilFormat];
}

- (NSString *) depthStencilStateIdentityFromConfig:(MTUMaterialConfig *)config {
    if (config == nil) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"DSS_%lu_%hhd",
                                      config.depthCompareFunction,
                                      config.depthWritable];
}

- (id <MTLRenderPipelineState>) renderPipelineStateWithConfig:(MTUMaterialConfig *)config {
    NSString *renderPipelineStateId = [self renderPipelineStateIdentityFromConfig:config];
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

- (nullable NSArray <id <MTLBuffer> > *) newInFlightBuffersWithTransformType:(MTUTransformType)type {
    size_t bufferLenght = 0;
    switch (type) {
        case MTUTransformTypeMvp: bufferLenght = sizeof(MTUTransformMvp); break;
        case MTUTransformTypeMvpMN: bufferLenght = sizeof(MTUTransformMvpMN); break;
        case MTUTransformTypeMvpMNP: bufferLenght = sizeof(MTUTransformMvpMNP); break;
        case MTUTransformTypeMvpMNPD: bufferLenght = sizeof(MTUTransformMvpMNPD); break;
        default: break;
    }
    if (bufferLenght == 0) {
        return nil;
    }
    
    id <MTLBuffer> inFlightBuffers[MAX_BUFFERS_IN_FLIGHT];
    for (NSUInteger i = 0; i < MAX_BUFFERS_IN_FLIGHT; ++i) {
        inFlightBuffers[i] = [_device newBufferWithLength:bufferLenght options:MTLResourceStorageModeShared];
    }
    return [NSArray arrayWithObjects:inFlightBuffers count:MAX_BUFFERS_IN_FLIGHT];
}

- (void) updateInFlightBuffersWithNode:(MTUNode *)node andCamera:(MTUCamera *)camera {
    MTUPoint3 position = node.position;
    MTUPoint3 rotation = node.rotation;
    MTUPoint3 scale = node.scale;
    
    matrix_float4x4 translateMatrix = matrix4x4_translation(position.x, position.y, position.z);
    matrix_float4x4 scaleMatrix = matrix4x4_scale(scale.x, scale.y, scale.z);
    quaternion_float rotate = quaternion_multiply(quaternion_normalize(quaternion(rotation.x, vector3(1.0f, 0.0f, 0.0f))),
                                                  quaternion_normalize(quaternion(rotation.z, vector3(0.0f, 0.0f, 1.0f))));
    matrix_float4x4 rotateMatrix = matrix4x4_from_quaternion(rotate);
    matrix_float4x4 modelMatrix = matrix_multiply(translateMatrix, matrix_multiply(rotateMatrix, scaleMatrix));
    
    vector_float3 cameraPosition = {camera->position.x, camera->position.y, camera->position.z};
    vector_float3 cameraTarget = {camera->target.x, camera->target.y, camera->target.z};
    vector_float3 cameraUp = {camera->up.x, camera->up.y, camera->up.z};
    matrix_float4x4 viewMatrix = matrix_look_at_right_hand(cameraPosition, cameraTarget, cameraUp);
    
    CGSize viewSize = _view.drawableSize;
    matrix_float4x4 projectionMatrix = matrix_perspective_right_hand(radians_from_degrees(camera->fovy),
                                                                     viewSize.width / viewSize.height,
                                                                     0.01f, 10000.0f);
    
    matrix_float4x4 modelview_projection = matrix_multiply(projectionMatrix, matrix_multiply(viewMatrix, modelMatrix));
    
    matrix_float3x3 normal_matrix = matrix3x3_upper_left(modelMatrix);
    
    id <MTLBuffer> buffer = node.material.transformBuffers[_inFlightBufferIndex];
    switch (node.material.transformType) {
        case MTUTransformTypeMvp: {
            MTUTransformMvp transform;
            transform.modelview_projection = modelview_projection;
            memcpy(buffer.contents, &transform, sizeof(MTUTransformMvp));
            break;
        }
        case MTUTransformTypeMvpMN: {
            MTUTransformMvpMN transform;
            transform.modelview_projection = modelview_projection;
            transform.model_matrix = modelMatrix;
            transform.normal_matrix = normal_matrix;
            memcpy(buffer.contents, &transform, sizeof(MTUTransformMvpMN));
            break;
        }
        case MTUTransformTypeMvpMNP: {
            MTUTransformMvpMNP transform;
            transform.modelview_projection = modelview_projection;
            transform.model_matrix = modelMatrix;
            transform.normal_matrix = normal_matrix;
            transform.camera_position = cameraPosition;
            memcpy(buffer.contents, &transform, sizeof(MTUTransformMvpMNP));
            break;
        }
        case MTUTransformTypeMvpMNPD: {
            MTUTransformMvpMNPD transform;
            transform.modelview_projection = modelview_projection;
            transform.model_matrix = modelMatrix;
            transform.normal_matrix = normal_matrix;
            transform.camera_position = cameraPosition;
            transform.camera_look_at = vector_normalize((vector_float3){cameraTarget.x - cameraPosition.x,
                                                                        cameraTarget.y - cameraPosition.y,
                                                                        cameraTarget.z - cameraPosition.z});
            memcpy(buffer.contents, &transform, sizeof(MTUTransformMvpMNPD));
            break;
        }
        default:
            break;
    }

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
    
    _commandBuffer = [_commandQueue commandBuffer];
    _commandBuffer.label = @"MTU CommandBuffer";
    
    _renderCommandEncoder = nil;
    MTLRenderPassDescriptor *renderPassDescriptor = _view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        _renderCommandEncoder = [_commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        _renderCommandEncoder.label = @"MTU RenderCommandEncoder";
        
        // view port
        CGSize viewSize = _view.drawableSize;
        [_renderCommandEncoder setViewport:(MTLViewport){0.0, 0.0, viewSize.width, viewSize.height, -1.0, 1.0}];
    }
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
    id <MTLBuffer> transformBuffer = material.transformBuffers[_inFlightBufferIndex];
    [_renderCommandEncoder setVertexBuffer:transformBuffer offset:0 atIndex:1];
    
    // Other buffers for vertex shader and fragment shader
    NSArray <id <MTLBuffer> > *buffers = material.buffers;
    NSArray <NSNumber *> *vsBufferIndices = material.bufferIndexOfVertexShader;
    if (buffers != nil && vsBufferIndices != nil) {
        for (NSUInteger i = 0; i < vsBufferIndices.count; ++i) {
            NSNumber *number = vsBufferIndices[i];
            id <MTLBuffer> buffer = buffers[number.unsignedIntegerValue];
            [_renderCommandEncoder setVertexBuffer:buffer offset:0 atIndex:i + 2];
        }
    }
    NSArray <NSNumber *> *fsBufferIndices = material.bufferIndexOfFragmentShader;
    if (buffers != nil && fsBufferIndices != nil) {
        for (NSUInteger i = 0; i < fsBufferIndices.count; ++i) {
            NSNumber *number = fsBufferIndices[i];
            id <MTLBuffer> buffer = buffers[number.unsignedIntegerValue];
            [_renderCommandEncoder setFragmentBuffer:buffer offset:0 atIndex:i + 2];
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
    
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [_commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer) {
        dispatch_semaphore_signal(block_sema);
    }];
    
    [_commandBuffer presentDrawable:_view.currentDrawable];
    [_commandBuffer commit];
}

@end
