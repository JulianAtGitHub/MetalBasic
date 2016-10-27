//
//  RPSurface.h
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Metal/Metal.h>

@interface RPSurface : CAMetalLayer

// set these pixel formats to have the main drawable framebuffer get created with depth and/or stencil attachments
@property MTLPixelFormat depthPixelFormat;

@property MTLPixelFormat stencilPixelFormat;

@property NSUInteger multisampleCount;

+ (instancetype)surface;

- (void)reshape:(CGSize)size;

@end
