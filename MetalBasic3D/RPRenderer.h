//
//  RPRenderer.h
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>

#import "RPView.h"
#import "RPViewController.h"

@interface RPRenderer : NSObject <RPViewDelegate, RPViewControllerDelegate>

@property (readonly) CALayer *layer;

@property (readonly) MTLPixelFormat colorPixelFormat;

@property (readonly) MTLPixelFormat depthPixelFormat;

@property (readonly) MTLPixelFormat stencilPixelFormat;

@property (readonly) NSUInteger multisampleCount;

- (void)draw;

@end
