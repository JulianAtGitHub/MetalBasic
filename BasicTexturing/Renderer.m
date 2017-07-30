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
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLBuffer> _vertices;
    id <MTLBuffer> _viewportSize;
    id <MTLTexture> _texture;
    
    vector_uint2 _viewSize;
    NSUInteger _vertexCount;
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
    id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    
    NSError *err = nil;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&err];
    if (!_pipelineState) {
        NSLog(@"Failed to created pipeline state, error %@", err);
        return;
    }
    
    MTKTextureLoader *textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
    _texture = [textureLoader newTextureWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Image" withExtension:@"png"]
                                                  options:@{MTKTextureLoaderOptionSRGB: @NO, MTKTextureLoaderOptionOrigin: MTKTextureLoaderOriginBottomLeft}
                                                  error:&err];
    if (!_texture) {
        NSLog(@"Failed to load text Image.png, error %@", err);
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
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        id <MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderCommandEncoder.label = @"MyRenderCommandEncoder";
        
        [renderCommandEncoder setViewport:(MTLViewport){0.0, 0.0, _viewSize.x, _viewSize.y, -1.0, 1.0}];
        [renderCommandEncoder setRenderPipelineState:_pipelineState];
        
        [renderCommandEncoder setVertexBuffer:_vertices offset:0 atIndex:VertexInputIndexVertices];
        [renderCommandEncoder setVertexBuffer:_viewportSize offset:0 atIndex:VertexInputIndexViewportSize];
        [renderCommandEncoder setFragmentTexture:_texture atIndex:TextureIndexBaseColor];
        
        [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexCount];
        
        [renderCommandEncoder endEncoding];
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
