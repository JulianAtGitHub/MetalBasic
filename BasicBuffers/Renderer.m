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
    // Pixel Positions, RGBA colors
    { { -20,   20 },   { 1, 0, 0, 1 } },
    { {  20,   20 },   { 0, 0, 1, 1 } },
    { { -20,  -20 },   { 0, 1, 0, 1 } },
    
    { {  20,  -20 },   { 1, 0, 0, 1 } },
    { { -20,  -20 },   { 0, 1, 0, 1 } },
    { {  20,   20 },   { 0, 0, 1, 1 } },
};
const NSUInteger NUM_COLUMNS = 30;
const NSUInteger NUM_ROWS = 20;
const NSUInteger NUM_VERTICES_PER_QUAD = sizeof(quadVertices) / sizeof(Vertex);
const float QUAD_SPACING = 50.0;

@implementation Renderer {
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLBuffer> _vertexBuffer;
    id <MTLBuffer> _viewportSizeBuffer;
    
    vector_uint2 _viewportSize;
    NSUInteger _vertexCount;
}

- (NSData *) generateVertexData {
    NSUInteger dataSize = sizeof(quadVertices) * NUM_COLUMNS * NUM_ROWS;
    NSMutableData *vertexData = [[NSMutableData alloc] initWithLength:dataSize];
    
    Vertex *currentQuad = vertexData.mutableBytes;
    for(NSUInteger row = 0; row < NUM_ROWS; ++row) {
        for(NSUInteger column = 0; column < NUM_COLUMNS; ++column) {
            vector_float2 upperLeftPosition;
            upperLeftPosition.x = ((-((float)NUM_COLUMNS) / 2.0) + column) * QUAD_SPACING + QUAD_SPACING/2.0;
            upperLeftPosition.y = ((-((float)NUM_ROWS) / 2.0) + row) * QUAD_SPACING + QUAD_SPACING/2.0;
            
            memcpy(currentQuad, &quadVertices, sizeof(quadVertices));
            
            for (NSUInteger vertexInQuad = 0; vertexInQuad < NUM_VERTICES_PER_QUAD; ++vertexInQuad) {
                currentQuad[vertexInQuad].position += upperLeftPosition;
            }
            
            currentQuad += NUM_VERTICES_PER_QUAD;
        }
    }
    return vertexData;
}

- (void) loadMetal:(MTKView *)view {
    _device = view.device;
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
    
    NSData *vertexData = [self generateVertexData];
    _vertexBuffer = [_device newBufferWithLength:vertexData.length options:MTLResourceStorageModeShared];
    memcpy(_vertexBuffer.contents, vertexData.bytes, vertexData.length);
    _vertexCount = vertexData.length / sizeof(Vertex);
    
    _viewportSizeBuffer = [_device newBufferWithLength:sizeof(_viewportSize) options:MTLResourceStorageModeShared];
    
    _commandQueue = [_device newCommandQueue];
}

#pragma mark - implementation of MKTViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        id <MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderCommandEncoder.label = @"MyRenderCommandEncoder";
        
        [renderCommandEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
        [renderCommandEncoder setRenderPipelineState:_pipelineState];
        
        [renderCommandEncoder setVertexBuffer:_vertexBuffer offset:0 atIndex:VertexInputIndexVertices];
        [renderCommandEncoder setVertexBuffer:_viewportSizeBuffer offset:0 atIndex:VertexInputIndexViewportSize];
        
        [renderCommandEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_vertexCount];
        
        [renderCommandEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
    memcpy(_viewportSizeBuffer.contents, &_viewportSize, sizeof(_viewportSize));
}

@end
