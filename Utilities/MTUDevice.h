//
//  MTUDevice.h
//  MetalSample
//
//  Created by zhuwei on 7/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_DEVICE_H_
#define _MTU_DEVICE_H_

#import <MetalKit/MetalKit.h>
#import "MTUTypes.h"

@class MTUNode;

@class MTUMesh;

@class MTUMaterial;

@class MTUMaterialConfig;

@interface MTUDevice : NSObject

@property (nullable) MTKView *view;

+ (nonnull MTUDevice *) sharedInstance;

- (nullable id <MTLRenderPipelineState>) renderPipelineStateWithConfig:(nonnull MTUMaterialConfig *)config;

- (nullable id <MTLDepthStencilState>) depthStencilStateWithConfig:(nonnull MTUMaterialConfig *)config;

- (nullable id <MTLBuffer>) newBufferWithRawData:(nonnull NSData *)data;

- (nullable NSArray <id <MTLBuffer> > *) newInFlightBuffersWithTransformType:(MTUTransformType)type;

- (void) updateInFlightBuffersWithNode:(nonnull MTUNode *)node andCamera:(nonnull MTUCamera *)camera;

- (nullable id <MTLTexture>) newTextureWithFilename:(nonnull NSString *)filename;

- (nullable id <MTLTexture>) newTextureWithAssetset:(nonnull NSString *)assetset;

- (void) startDraw;

- (void) drawMesh:(nonnull MTUMesh *)mesh withMaterial:(nonnull MTUMaterial *)material;

- (void) commit;

@end

#endif /* _MTU_DEVICE_H_ */
