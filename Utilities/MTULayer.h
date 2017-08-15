//
//  MTULayer.h
//  MetalSample
//
//  Created by zhuwei on 8/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import <Metal/Metal.h>

@interface MTULayerConfig : NSObject

@property (nonnull, nonatomic, copy) NSString *name;

@property (nonatomic) CGSize size;

@property (nullable, nonatomic) NSArray <NSNumber *> *colorFormats;

@property (nonatomic) MTLPixelFormat depthFormat;

@property (nonatomic) MTLPixelFormat stencilFormat;

@property (nonatomic) BOOL hasClearAction;

@property (nonatomic) MTLClearColor clearColor;

@property (nonatomic) double clearDepth;

@property (nonatomic) uint32_t clearStencil;

@end

@interface MTULayer : NSObject

@property (nonnull, readonly) NSString *name;

@property (nullable, readonly) NSArray <id <MTLTexture> > *colorAttachments;

@property (nullable, readonly) id <MTLTexture> depthAttachment;

@property (nullable, readonly) id <MTLTexture> stencilAttachment;

@property (nullable, readonly) MTLRenderPassDescriptor *renderPass;

+ (BOOL) createLayerToCache:(nonnull MTULayerConfig *)config;

+ (nullable MTULayer *) layerFromCache:(nonnull NSString *)name;

- (nonnull instancetype) initWithConfig:(nonnull MTULayerConfig *)config;

@end
