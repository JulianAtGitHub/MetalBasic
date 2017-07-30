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

@interface MTUNode : NSObject

@property (nullable, nonatomic) NSString *name;

@property (nonatomic) MTUPoint3 position;

@property (nonatomic) MTUPoint3 rotation;

@property (nonatomic) MTUPoint3 scale;

@property (nullable, readwrite) MTUMesh *mesh;

@property (nullable, readwrite) MTUMaterial *material;

@property (nullable, readonly) NSArray <MTUNode *> *children;

@property (nullable, readonly) MTUNode *parent;

- (nonnull instancetype) initWithParent:(nullable MTUNode *)parent;

- (void) addChild:(nonnull MTUNode *)child;

- (nullable MTUNode *) findNodeWithName:(nonnull NSString *)name;

- (nullable MTUNode *) findNodeWithNames:(nonnull NSArray <NSString *> *)names;

- (void) moveTo:(MTUPoint3)position;

- (void) rotateTo:(MTUPoint3)roatation;

- (void) updateWithCamera:(nonnull MTUCamera *)camera;

- (void) draw;

@end


#endif /* _MTU_NODE_H_ */
