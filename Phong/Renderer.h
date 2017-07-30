//
//  Renderer.h
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface Renderer : NSObject <MTKViewDelegate>

- (_Nonnull instancetype) initWithMTKView:(nonnull MTKView *)view;

- (void) onMouseDrag:(NSPoint)delta;

- (void) onMouseScroll:(CGFloat)delta;

@end
