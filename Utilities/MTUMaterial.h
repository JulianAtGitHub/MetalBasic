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

@class MTULayer;

@interface MTUMaterialConfig : NSObject

@property (nonnull, nonatomic, copy) NSString *name;

@property (nullable, nonatomic) NSString *vertexShader;

@property (nullable, nonatomic) NSString *fragmentShader;

@property (nonatomic) MTLCompareFunction depthCompareFunction;

@property (nonatomic) BOOL depthWritable;

@property (nonatomic) MTLCullMode cullMode;

@property (nonatomic) MTLWinding winding;

@property (nonatomic) MTUVertexFormat vertexFormat;

@property (nonatomic) MTUTransformType transformType;

@property (nonatomic) MTUCameraParamsUsage cameraParamsUsage;

@property (nonnull, nonatomic) NSArray <NSData *> *buffers;

@property (nonnull, nonatomic) NSArray <NSNumber *> *bufferIndexOfVertexShader;

@property (nonnull, nonatomic) NSArray <NSNumber *> *bufferIndexOfFragmentShader;

@property (nonnull, nonatomic) NSArray <NSString *> *textures;

@end

@interface MTUMaterial : NSObject

@property (nonnull, readonly) NSString *name;

@property (nonnull, readonly) MTUMaterialConfig *config;

@property (nonnull, readonly) id <MTLRenderPipelineState> renderPipelineState;

@property (nullable, readonly) id <MTLDepthStencilState> depthStencilState;

@property (nonnull, readonly) NSArray <id <MTLBuffer> > *transformBuffers;

@property (nonnull, readwrite) NSArray <id <MTLBuffer> > *cameraBuffers;

@property (nonnull, readonly) NSArray <id <MTLBuffer> > *buffers;

@property (nonnull, readonly) NSArray <NSNumber *> *bufferIndexOfVertexShader;

@property (nonnull, readonly) NSArray <NSNumber *> *bufferIndexOfFragmentShader;

@property (nonnull, readonly) NSArray <id <MTLTexture> > *textures;

- (nonnull instancetype) initWithConfig:(nonnull MTUMaterialConfig *)config;

- (void) setRenderLayer:(nonnull MTULayer *)layer andMeshVertexFormat:(MTUVertexFormat)format;

@end

#endif /* _MTU_MATERIAL_H_ */
