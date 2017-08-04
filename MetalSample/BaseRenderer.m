//
//  BaseRender.m
//  MetalSample
//
//  Created by zhuwei on 8/2/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "BaseRenderer.h"

@implementation BaseRenderer

- (instancetype) initWithMTKView:(MTKView *)view {
    self = [super init];
    if (self) {
        [self loadMetal:view];
    }
    return self;
}

- (void) loadMetal:(MTKView *)view {
    
}

- (void) onMouseDrag:(NSPoint)delta {
    
}

- (void) onRightMouseDrag:(NSPoint)delta {
    
}

- (void) onMouseScroll:(CGFloat)delta {
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

- (void)drawInMTKView:(MTKView *)view {
    
}


@end
