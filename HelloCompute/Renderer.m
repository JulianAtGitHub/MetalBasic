//
//  Renderer.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import <Metal/Metal.h>
#import "ShaderTypes.h"
#import "Renderer.h"

static const Vertex quadVertices[] = {
    // Pixel Positions, Texture Coordinates
    { {  250,  -250 }, { 1.f, 0.f } },
    { { -250,  -250 }, { 0.f, 0.f } },
    { { -250,   250 }, { 0.f, 1.f } },
    
    { {  250,  -250 }, { 1.f, 0.f } },
    { { -250,   250 }, { 0.f, 1.f } },
    { {  250,   250 }, { 1.f, 1.f } },
};

@implementation Renderer {
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    
    id <MTLComputePipelineState> _computePipelineState;
    id <MTLRenderPipelineState> _renderPipelineState;
    id <MTLBuffer> _vertices;
    id <MTLBuffer> _viewportSize;
    id <MTLTexture> _inTexture;
    id <MTLTexture> _outTexture;
    
    vector_uint2 _viewSize;
    NSUInteger _vertexCount;
    MTLSize _threadgroupSize;
    MTLSize _threadgroupCount;
}

- (instancetype) initWithMTKView:(MTKView *)view {
    self = [super init];
    if (self) {
        _device = view.device;
        [self loadMetal:view];
    }
    return self;
}

- (void) loadMetal:(MTKView *)view {
    NSError *err = nil;
    id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    
    id <MTLFunction> computeFunction = [defaultLibrary newFunctionWithName:@"grayScaleKernel"];
    _computePipelineState = [_device newComputePipelineStateWithFunction:computeFunction error:&err];
    if (!_computePipelineState) {
        NSLog(@"Failed to created compute pipeline state, error %@", err);
        return;
    }
    
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
    _inTexture = [textureLoader newTextureWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Image" withExtension:@"png"]
                                                  options:@{ MTKTextureLoaderOptionSRGB: @NO,
                                                             MTKTextureLoaderOptionOrigin: MTKTextureLoaderOriginBottomLeft,
                                                             MTKTextureLoaderOptionTextureUsage: @(MTLTextureUsageShaderRead)}
                                                    error:&err];
    if (!_inTexture) {
        NSLog(@"Failed to load text Image.png, error %@", err);
        return;
    }
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    textureDescriptor.textureType = MTLTextureType2D;
    textureDescriptor.pixelFormat = _inTexture.pixelFormat;
    textureDescriptor.width = _inTexture.width;
    textureDescriptor.height = _inTexture.height;
    textureDescriptor.usage = MTLTextureUsageShaderRead | MTLTextureUsageShaderWrite;
    _outTexture = [_device newTextureWithDescriptor:textureDescriptor];
    
    _threadgroupSize = MTLSizeMake(16, 16, 1);
    _threadgroupCount.width = (_inTexture.width  + _threadgroupSize.width -  1) / _threadgroupSize.width;
    _threadgroupCount.height = (_inTexture.height  + _threadgroupSize.height -  1) / _threadgroupSize.height;
    _threadgroupCount.depth = 1;
    
    id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    
    _renderPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&err];
    if (!_renderPipelineState) {
        NSLog(@"Failed to created render pipeline state, error %@", err);
        return;
    }
    
    _vertices = [_device newBufferWithLength:sizeof(quadVertices) options:MTLResourceStorageModeShared];
    memcpy(_vertices.contents, quadVertices, sizeof(quadVertices));
    _vertexCount = sizeof(quadVertices) / sizeof(Vertex);
    
    _viewportSize = [_device newBufferWithLength:sizeof(_viewSize) options:MTLResourceStorageModeShared];
    
    _commandQueue = [_device newCommandQueue];
}

- (void) onMouseDrag:(NSPoint)delta {
    
}

- (void) onMouseScroll:(CGFloat)delta {
    
}

#pragma mark - implementation of MKTViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    
    id <MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    computeEncoder.label = @"MyComputeCommandEncoder";
    
    [computeEncoder setComputePipelineState:_computePipelineState];
    [computeEncoder setTexture:_inTexture atIndex:TextureIndexInput];
    [computeEncoder setTexture:_outTexture atIndex:TextureIndexOutput];
    
    [computeEncoder dispatchThreadgroups:_threadgroupCount threadsPerThreadgroup:_threadgroupSize];
    [computeEncoder endEncoding];
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderCommandEncoder";
        
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewSize.x, _viewSize.y, -1.0, 1.0}];
        [renderEncoder setRenderPipelineState:_renderPipelineState];
        
        [renderEncoder setVertexBuffer:_vertices offset:0 atIndex:VertexInputIndexVertices];
        [renderEncoder setVertexBuffer:_viewportSize offset:0 atIndex:VertexInputIndexViewportSize];
        [renderEncoder setFragmentTexture:_outTexture atIndex:TextureIndexBaseColor];
        
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexCount];
        
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewSize.x = size.width;
    _viewSize.y = size.height;
    memcpy(_viewportSize.contents, &_viewSize, sizeof(_viewSize));
}

@end
