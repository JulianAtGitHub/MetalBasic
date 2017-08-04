//
//  Renderer.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import <Metal/Metal.h>
#import "Renderer.h"

@implementation Renderer {
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;
}

- (void) loadMetal:(MTKView *)view {
    _device = view.device;
    _commandQueue = [_device newCommandQueue];
}

//    Gradually cycles through different colors on each invocation.  Generally you would just pick
//    a single clear color color, set it once and forget, but since that would make this sample
//    very boring we'll just return a different clear color each frame :)
- (MTLClearColor)makeFancyColor
{
    static BOOL       growing = YES;
    static NSUInteger primaryChannel = 0;
    static float      colorChannels[] = {1.0, 0.0, 0.0, 1.0};
    
    const float DynamicColorRate = 0.01;
    
    if(growing) {
        NSUInteger dynamicChannelIndex = (primaryChannel+1)%3;
        colorChannels[dynamicChannelIndex] += DynamicColorRate;
        if(colorChannels[dynamicChannelIndex] >= 1.0) {
            growing = NO;
            primaryChannel = dynamicChannelIndex;
        }
    } else {
        NSUInteger dynamicChannelIndex = (primaryChannel+2)%3;
        colorChannels[dynamicChannelIndex] -= DynamicColorRate;
        if(colorChannels[dynamicChannelIndex] <= 0.0) {
            growing = YES;
        }
    }
    
    return MTLClearColorMake(colorChannels[0], colorChannels[1], colorChannels[2], colorChannels[3]);
}

#pragma mark - implementation of MKTViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    view.clearColor = [self makeFancyColor];
    
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommandBuffer";
    
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor) {
        id <MTLRenderCommandEncoder> renderCommandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderCommandEncoder.label = @"MyRenderCommandEncoder";
        [renderCommandEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    [commandBuffer commit];
}

@end
