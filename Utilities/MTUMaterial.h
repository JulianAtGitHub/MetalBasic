//
//  MTUMaterial.h
//  MetalSample
//
//  Created by zhuwei on 7/16/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_MATERIAL_H_
#define _MTU_MATERIAL_H_

#import <Metal/Metal.h>
#import "MTUTypes.h"

@interface MTUMaterialConfig : NSObject

@property (nonnull, nonatomic) NSString *name;

@property (nullable, nonatomic) NSString *vertexShader;

@property (nullable, nonatomic) NSString *fragmentShader;

@property (nonatomic) MTLPixelFormat colorFormat;

@property (nonatomic) MTLPixelFormat depthFormat;

@property (nonatomic) MTLPixelFormat stencilFormat;

@property (nonatomic) MTLCompareFunction depthCompareFunction;

@property (nonatomic) BOOL depthWritable;

@property (nonatomic) BOOL isCullBackFace;

@property (nonatomic) BOOL isClockWise;

@property (nonatomic) MTUTransformType transformType;

@property (nonatomic) MTUCameraParamsUsage cameraParamsUsage;

@property (nonnull, nonatomic) NSArray <NSData *> *buffers;

@property (nonnull, nonatomic) NSArray <NSNumber *> *bufferIndexOfVertexShader;

@property (nonnull, nonatomic) NSArray <NSNumber *> *bufferIndexOfFragmentShader;

@property (nonnull, nonatomic) NSArray <NSString *> *textures;

@end

@interface MTUMaterial : NSObject

- (nonnull instancetype) initWithConfig:(nonnull MTUMaterialConfig *)config;

@property (nonnull, readonly) NSString *name;

@property (nonnull, readonly) id <MTLRenderPipelineState> renderPipelineState;

@property (nullable, readonly) id <MTLDepthStencilState> depthStencilState;

@property (readonly) MTLCullMode cullMode;

@property (readonly) MTLWinding winding;

@property (nonatomic, readonly) MTUTransformType transformType;

@property (nonatomic, readonly) MTUCameraParamsUsage cameraParamsUsage;

@property (nonnull, readonly) NSArray <id <MTLBuffer> > *transformBuffers;

@property (nonnull, readwrite) NSArray <id <MTLBuffer> > *cameraBuffers;

@property (nonnull, readonly) NSArray <id <MTLBuffer> > *buffers;

@property (nonnull, readonly) NSArray <NSNumber *> *bufferIndexOfVertexShader;

@property (nonnull, readonly) NSArray <NSNumber *> *bufferIndexOfFragmentShader;

@property (nonnull, readonly) NSArray <id <MTLTexture> > *textures;

@end

#endif /* _MTU_MATERIAL_H_ */
