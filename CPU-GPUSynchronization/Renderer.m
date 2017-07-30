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

// The max number of command buffers in flight
static const NSUInteger MaxBuffersInFlight = 3;


// A simple class represing our sprite object, which is represented by a colored quad on screen
@interface Sprite : NSObject

@property (nonatomic) vector_float2 position;

@property (nonatomic) vector_float4 color;

+(const Vertex*)vertices;

+(NSUInteger)vertexCount;

@end

@implementation Sprite

// Return the vertices of one quad posistion at the origin.  After updating the sprites postion
//   each frame we displace the positon with the sprite's postion and copy it to our vertex buffer
+(const Vertex *)vertices {
    const float SpriteSize = 5;
    static const Vertex spriteVertices[] = {
        //Pixel Positions,                 RGBA colors
        { { -SpriteSize,   SpriteSize },   { 0, 0, 0, 1 } },
        { {  SpriteSize,   SpriteSize },   { 0, 0, 0, 1 } },
        { { -SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        
        { {  SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        { { -SpriteSize,  -SpriteSize },   { 0, 0, 0, 1 } },
        { {  SpriteSize,   SpriteSize },   { 0, 0, 1, 1 } },
    };
    
    return spriteVertices;
}

// The number of vertices for each sprite
+(NSUInteger) vertexCount {
    return 6;
}

@end

// Main class performing the rendering
@implementation Renderer {
    dispatch_semaphore_t _inFlightSemaphore;
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
    
    id <MTLRenderPipelineState> _pipelineState;
    id <MTLBuffer>              _vertexBuffers[MaxBuffersInFlight];
    
    
    // The current size of our view so we can use this in our render pipeline
    vector_uint2 _viewportSize;
    
    NSUInteger _currentBuffer;
    
    NSArray<Sprite*> *_sprites;
    
    NSUInteger _spritesPerRow;
    NSUInteger _rowsOfSprites;
    NSUInteger _totalSpriteVertexCount;
    
}

/// Initialize with the MetalKit view from which we'll obtain our Metal device.  We'll also use this
/// mtkView object to set the pixelformat and other properties of our drawable
/// Initialize with the MetalKit view from which we'll obtain our metal device
- (instancetype) initWithMTKView:(nonnull MTKView *)mtkView {
    self = [super init];
    if(self) {
        _device = mtkView.device;
        
        _inFlightSemaphore = dispatch_semaphore_create(MaxBuffersInFlight);
        // Create and load our basic Metal state objects
        
        // Load all the shader files with a metal file extension in the project
        id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        
        // Load the vertex function into the library
        id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        
        // Load the fragment function into the library
        id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        // Create a reusable pipeline state
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"MyPipeline";
        pipelineStateDescriptor.sampleCount = mtkView.sampleCount;
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        pipelineStateDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat;
        pipelineStateDescriptor.stencilAttachmentPixelFormat = mtkView.depthStencilPixelFormat;
        
        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        if (!_pipelineState) {
            NSLog(@"Failed to created pipeline state, error %@", error);
        }
        // Create the command queue
        _commandQueue = [_device newCommandQueue];
        
        [self generateSprites];
        
        _totalSpriteVertexCount = Sprite.vertexCount * _sprites.count;
        
        NSUInteger spriteVertexBufferSize = _totalSpriteVertexCount * sizeof(Vertex);
        
        
        for(NSUInteger bufferIndex = 0; bufferIndex < MaxBuffersInFlight; bufferIndex++) {
            _vertexBuffers[bufferIndex] = [_device newBufferWithLength:spriteVertexBufferSize
                                                               options:MTLResourceStorageModeShared];
        }
        
    }
    
    return self;
}

/// Generate a list of sprites, initializing each and inserting it into `_sprites`.
- (void) generateSprites {
    const float XSpacing = 12;
    const float YSpacing = 16;
    
    const NSUInteger SpritesPerRow = 110;
    const NSUInteger RowsOfSprites = 50;
    const float WaveMagnitude = 30.0;
    
    const vector_float4 Colors[] = {
        { 1.0, 0.0, 0.0, 1.0 },  // Red
        { 0.0, 1.0, 1.0, 1.0 },  // Cyan
        { 0.0, 1.0, 0.0, 1.0 },  // Green
        { 1.0, 0.5, 0.0, 1.0 },  // Orange
        { 1.0, 0.0, 1.0, 1.0 },  // Magenta
        { 0.0, 0.0, 1.0, 1.0 },  // Blue
        { 1.0, 1.0, 0.0, 1.0 },  // Yellow
        { .75, 0.5, .25, 1.0 },  // Brown
        { 1.0, 1.0, 1.0, 1.0 },  // White
        
    };
    
    const NSUInteger NumColors = sizeof(Colors) / sizeof(vector_float4);
    
    _spritesPerRow = SpritesPerRow;
    _rowsOfSprites = RowsOfSprites;
    
    NSMutableArray *sprites = [[NSMutableArray alloc] initWithCapacity:_rowsOfSprites * _spritesPerRow];
    
    // Create a grid of 'sprite' objects
    for(NSUInteger row = 0; row < _rowsOfSprites; row++) {
        for(NSUInteger column = 0; column < _spritesPerRow; column++) {
            vector_float2 spritePosition;
            
            // Determine the positon of our sprite in the grid
            spritePosition.x = ((-((float)_spritesPerRow) / 2.0) + column) * XSpacing;
            spritePosition.y = ((-((float)_rowsOfSprites) / 2.0) + row) * YSpacing + WaveMagnitude;
            
            // Displace the height of this sprite using a sin wave
            spritePosition.y += (sin(spritePosition.x/WaveMagnitude) * WaveMagnitude);
            
            // Create our sprite, set its properties and add it to our list
            Sprite * sprite = [[Sprite alloc] init];
            
            sprite.position = spritePosition;
            sprite.color = Colors[row%NumColors];
            
            [sprites addObject:sprite];
        }
    }
    _sprites = sprites;
}

- (void) onMouseDrag:(NSPoint)delta {
    
}

- (void) onMouseScroll:(CGFloat)delta {
    
}

/// Called whenever view changes orientation or is resized
- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    // Save the size of the drawable as we'll pass these
    //   values to our vertex shader when we draw
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

/// Update the position of each sprite and also update vertices for each sprite in our buffer
- (void)updateState {
    
    // Change the position of the sprites by getting taking on the height of the sprite
    //  immediately to the right of the current sprite.
    
    Vertex *currentSpriteVertices = _vertexBuffers[_currentBuffer].contents;
    NSUInteger  currentVertex = _totalSpriteVertexCount-1;
    NSUInteger  spriteIdx = (_rowsOfSprites * _spritesPerRow)-1;
    
    for(NSInteger row = _rowsOfSprites - 1; row >= 0; row--) {
        float startY = _sprites[spriteIdx].position.y;
        for(NSInteger spriteInRow = _spritesPerRow-1; spriteInRow >= 0; spriteInRow--) {
            // Update the position of our sprite
            vector_float2 updatedPosition = _sprites[spriteIdx].position;
            
            if(spriteInRow == 0) {
                updatedPosition.y = startY;
            } else {
                updatedPosition.y = _sprites[spriteIdx-1].position.y;
            }
            
            _sprites[spriteIdx].position = updatedPosition;
            
            // Update vertices of the current vertex buffer with the sprites new position
            
            for(NSInteger vertexOfSprite = Sprite.vertexCount-1; vertexOfSprite >= 0 ; vertexOfSprite--) {
                currentSpriteVertices[currentVertex].position = Sprite.vertices[vertexOfSprite].position + _sprites[spriteIdx].position;
                currentSpriteVertices[currentVertex].color = _sprites[spriteIdx].color;
                currentVertex--;
            }
            spriteIdx--;
        }
    }
}

// Called whenever the view needs to render
- (void)drawInMTKView:(nonnull MTKView *)view {
    // Wait to ensure only kMaxBuffersInFlight are getting proccessed by any stage in the Metal
    //   pipeline (App, Metal, Drivers, GPU, etc)
    dispatch_semaphore_wait(_inFlightSemaphore, DISPATCH_TIME_FOREVER);
    
    // Iterate through our metal buffers, and cycle back to the first when we've written to MaxBuffersInFlight
    _currentBuffer = (_currentBuffer + 1) % MaxBuffersInFlight;
    
    // Update data in our buffers
    [self updateState];
    
    // Create a new command buffer for each renderpass to the current drawable
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // Add completion hander which signals _inFlightSemaphore when Metal and the GPU has fully
    //   finished proccssing the commands we're encoding this frame.  This indicates when the
    //   dynamic buffers filled with our vertices, that we're writing to this frame, will no longer
    //   be needed by Metal and the GPU, meaning we can overwrite the buffer contents without
    //   corrupting the rendering.
    __block dispatch_semaphore_t block_sema = _inFlightSemaphore;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer) {
         dispatch_semaphore_signal(block_sema);
     }];
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if(renderPassDescriptor != nil) {
        // Create a render command encoder so we can render into something
        id <MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        // Set render command encoder state
        [renderEncoder setCullMode:MTLCullModeBack];
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        [renderEncoder setVertexBuffer:_vertexBuffers[_currentBuffer]
                                offset:0
                               atIndex:VertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportSize
                               length:sizeof(_viewportSize)
                              atIndex:VertexInputIndexViewportSize];
        
        // Draw the vertices of our quads
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:_totalSpriteVertexCount];
        
        // We're done encoding commands
        [renderEncoder endEncoding];
        
        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    // Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
}

@end

