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
@class MTUMaterialConfig;
@class MTUMaterial;
@class MTULayer;
@class MTUCamera;

@interface MTUDevice : NSObject

@property (nullable, nonatomic, readwrite) MTKView *view;

@property (nullable, nonatomic, readonly) id <MTLDevice> mtlDevice;

@property (nonnull, nonatomic, readonly) NSString *default3DLayerName;

+ (nonnull MTUDevice *) sharedInstance;

- (nullable id <MTLFunction>) shaderFunctionWithName:(nonnull NSString *)name;

- (nullable id <MTLBuffer>) newBufferWithRawData:(nonnull NSData *)data;

- (nullable NSArray <id <MTLBuffer> > *) newInFlightBuffersWithSize:(size_t)size;

- (nullable id <MTLBuffer>) currentInFlightBuffer:(nonnull NSArray <id <MTLBuffer> > *)buffers;

- (nullable id <MTLTexture>) newTextureWithFilename:(nonnull NSString *)filename;

- (nullable id <MTLTexture>) newTextureWithAssetset:(nonnull NSString *)assetset;

- (void) startDraw;

- (void) setTargetLayer:(nonnull MTULayer *)layer;

- (void) targetLayerEnded;

- (void) drawMesh:(nonnull MTUMesh *)mesh;

- (void) presentToView;

@end

#endif /* _MTU_DEVICE_H_ */
