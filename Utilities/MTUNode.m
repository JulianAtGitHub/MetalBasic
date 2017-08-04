//
//  MTUNode.m
//  MetalSample
//
//  Created by zhuwei on 7/15/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "FBX/MTUFbxImporter.h"
#import "MTUMath.h"
#import "MTUMesh.h"
#import "MTUMaterial.h"
#import "MTUDevice.h"
#import "MTUCamera.h"
#import "MTUNode.h"

@interface MTUNode () {
    NSMutableArray <MTUMesh *> *_meshes;
    NSMutableArray <MTUNode *> *_children;
}

@end

@implementation MTUNode

- (NSArray <MTUMesh *> *) meshes {
    return _meshes;
}

- (NSArray <MTUNode *> *) children {
    return _children;
}

- (instancetype) initWithParent:(MTUNode *)parent {
    self = [super init];
    if (self) {
        _meshes = [NSMutableArray array];
        _children = [NSMutableArray array];
        _parent = parent;
        scale = vector3(1.0f, 1.0f, 1.0f);
        modelMatrix = matrix_identity_float4x4;
    }
    return self;
}

- (void) setName:(NSString *)name {
    if (name == nil || name.length == 0) {
        _name = @"noname";
    }
    _name = name;
}

- (void) addMesh:(nonnull MTUMesh *)mesh {
    if (mesh != nil && [_meshes containsObject:mesh] == NO) {
        [_meshes addObject:mesh];
    }
}

- (void) addChild:(nonnull MTUNode *)child {
    if (child != nil && [_children containsObject:child] == NO) {
        [_children addObject:child];
    }
}

- (MTUNode *) findNodeWithName:(NSString *)name {
    if (name == nil || name.length == 0) {
        return nil;
    }
    
    if (_name != nil && [_name isEqualToString:name]) {
        return self;
    }
    
    MTUNode *node = nil;
    for (MTUNode *child in _children) {
        node = [child findNodeWithName:name];
        if (node != nil) {
            break;
        }
    }
    
    return node;
}

- (nullable MTUNode *) findNodeWithNames:(nonnull NSArray <NSString *> *)names {
    if (names == nil) {
        return nil;
    }
    
    MTUNode *target = nil;
    MTUNode *node = self;
    for (NSString *name in names) {
        target = [node findNodeWithName:name];
        if (target == nil) {
            return nil;
        }
        node = target;
    }
    
    return target;
}

- (void) moveTo:(MTUPoint3)position_ {
    position = vector3(position_.x, position_.y, position_.z);
}

- (void) rotateTo:(MTUPoint3)rotation_ {
    rotation = vector3(rotation_.x, rotation_.y, rotation_.z);
}

- (void) updateWithCamera:(MTUCamera *)camera {
    if (_meshes.count > 0) {
        matrix_float4x4 translateMatrix = matrix4x4_translation(position);
        matrix_float4x4 scaleMatrix = matrix4x4_scale(scale);
        quaternion_float rotate = quaternion_multiply(quaternion_normalize(quaternion_multiply(
                                  quaternion_normalize(quaternion(rotation.x, vector3(1.0f, 0.0f, 0.0f))),
                                  quaternion_normalize(quaternion(rotation.y, vector3(0.0f, 1.0f, 0.0f))))),
                                  quaternion_normalize(quaternion(rotation.z, vector3(0.0f, 0.0f, 1.0f))));
        matrix_float4x4 rotateMatrix = matrix4x4_from_quaternion(rotate);
        modelMatrix = matrix_multiply(translateMatrix, matrix_multiply(rotateMatrix, scaleMatrix));
        
        MTUDevice *device = [MTUDevice sharedInstance];
        [device updateInFlightBuffersWithNode:self andCamera:camera];
    }
    
    for (MTUNode *child in _children) {
        [child updateWithCamera:camera];
    }
}

- (void) draw {
    if (_meshes.count > 0) {
        MTUDevice *device = [MTUDevice sharedInstance];
        for (MTUMesh *mesh in _meshes) {
            if (mesh.material == nil) {
                continue;
            }
            [device drawMesh:mesh withMaterial:mesh.material];
        }
    }
    
    for (MTUNode *child in _children) {
        [child draw];
    }
}

@end
