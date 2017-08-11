//
//  MTSMesh.h
//  MetalSample
//
//  Created by zhuwei on 7/5/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_MESH_H_
#define _MTU_MESH_H_

#import <Metal/Metal.h>
#import "MTUTypes.h"

@class MTUMaterial;
@class MTUMaterialConfig;

@interface MTUMesh : NSObject

@property (nullable, readwrite) NSString *name;

@property (nonatomic, readonly) NSUInteger vertexCount;

@property (nonatomic, readonly) MTUVertexFormat vertexFormat;

@property (nullable, readonly) id <MTLBuffer> vertexBuffer;

@property (nullable, readonly) MTUMaterial *material;

- (nonnull instancetype) initWithVertexData:(nonnull NSData *)data andVertexFormat:(MTUVertexFormat) format;

- (void) resetMaterialFromConfig:(nonnull MTUMaterialConfig *)config;

@end

#endif /* _MTU_MESH_H_ */
