//
//  BaseRender.h
//  MetalSample
//
//  Created by zhuwei on 8/2/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MetalKit/MetalKit.h>

@interface BaseRenderer : NSObject <MTKViewDelegate>

- (_Nonnull instancetype) initWithMTKView:(nonnull MTKView *)view;

- (void) loadMetal:(nonnull MTKView *)view;

- (void) onMouseDrag:(NSPoint)delta;

- (void) onRightMouseDrag:(NSPoint)delta;

- (void) onMouseScroll:(CGFloat)delta;

- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size;

- (void)drawInMTKView:(nonnull MTKView *)view;

@end
