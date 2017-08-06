//
//  MTUNode.h
//  MetalSample
//
//  Created by zhuwei on 7/15/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_NODE_H_
#define _MTU_NODE_H_

#import <Foundation/Foundation.h>
#import "MTUTypes.h"

@class MTUMesh;
@class MTUMaterial;
@class MTUCamera;

@interface MTUNode : NSObject

@property (nullable, nonatomic) NSString *name;

@property (nullable, readonly) NSArray <MTUMesh *> *meshes;

@property (nullable, readonly) NSArray <MTUNode *> *children;

@property (nullable, readonly) MTUNode *parent;

- (nonnull instancetype) initWithParent:(nullable MTUNode *)parent;

- (void) addMesh:(nonnull MTUMesh *)mesh;

- (void) addChild:(nonnull MTUNode *)child;

- (nullable MTUNode *) findNodeWithName:(nonnull NSString *)name;

- (nullable MTUNode *) findNodeWithNames:(nonnull NSArray <NSString *> *)names;

- (void) moveTo:(MTUPoint3)position;

- (void) rotateTo:(MTUPoint3)rotation;

- (void) updateWithCamera:(nonnull MTUCamera *)camera;

- (void) draw;

@end


#endif /* _MTU_NODE_H_ */
