//
//  MTUNode.m
//  MetalSample
//
//  Created by zhuwei on 7/15/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <simd/simd.h>
#import "FBX/MTUFbxImporter.h"
#import "MTUMath.h"
#import "MTUShaderTypes.h"
#import "MTUMesh.h"
#import "MTUMaterial.h"
#import "MTUDevice.h"
#import "MTUCamera.h"
#import "MTUNode.h"

@interface MTUNode () {
    vector_float3 position;
    vector_float3 rotation;
    vector_float3 scale;
    matrix_float4x4 modelMatrix;
    
    NSMutableArray <MTUMesh *> *_meshes;
    NSMutableArray <MTUNode *> *_children;
}

- (void) updateBuffersWithCamera:(MTUCamera *)camera;

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

- (void) updateBuffersWithCamera:(MTUCamera *)camera {
    matrix_float4x4 translateMatrix = matrix4x4_translation(position);
    matrix_float4x4 scaleMatrix = matrix4x4_scale(scale);
    quaternion_float rotate = quaternion_multiply(quaternion_normalize(quaternion_multiply(
                                                  quaternion_normalize(quaternion(rotation.x, vector3(1.0f, 0.0f, 0.0f))),
                                                  quaternion_normalize(quaternion(rotation.y, vector3(0.0f, 1.0f, 0.0f))))),
                                                  quaternion_normalize(quaternion(rotation.z, vector3(0.0f, 0.0f, 1.0f))));
    matrix_float4x4 rotateMatrix = matrix4x4_from_quaternion(rotate);
    modelMatrix = matrix_multiply(translateMatrix, matrix_multiply(rotateMatrix, scaleMatrix));
    matrix_float4x4 modelview_projection = matrix_multiply(camera->projectionMatrix, matrix_multiply(camera->viewMatrix, modelMatrix));
    matrix_float3x3 normal_matrix = matrix3x3_upper_left(modelMatrix);
    
    MTUDevice *device = [MTUDevice sharedInstance];
    for (MTUMesh *mesh in _meshes) {
        if (mesh.material == nil) {
            continue;
        }
        
        if (mesh.material.config.cameraParamsUsage != MTUCameraParamsNotUse) {
            mesh.material.cameraBuffers = camera.buffers;
        }
        
        id <MTLBuffer> buffer = [device currentInFlightBuffer:mesh.material.transformBuffers];
        switch (mesh.material.config.transformType) {
            case MTUTransformTypeMvp: {
                MTUTransformMvp transform;
                transform.modelview_projection = modelview_projection;
                memcpy(buffer.contents, &transform, sizeof(MTUTransformMvp));
                break;
            }
            case MTUTransformTypeMvpMN: {
                MTUTransformMvpMN transform;
                transform.modelview_projection = modelview_projection;
                transform.model_matrix = modelMatrix;
                transform.normal_matrix = normal_matrix;
                memcpy(buffer.contents, &transform, sizeof(MTUTransformMvpMN));
                break;
            }
            default:
                break;
        }
    }
}

- (void) updateWithCamera:(MTUCamera *)camera {
    if (_meshes.count > 0) {
        // transform buffer and camera params buffer
        [self updateBuffersWithCamera: camera];
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
            [device drawMesh:mesh];
        }
    }
    
    for (MTUNode *child in _children) {
        [child draw];
    }
}

@end
