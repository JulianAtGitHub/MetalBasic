//
//  MTUCamera.m
//  MetalSample
//
//  Created by zhuwei on 8/4/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "MTUMath.h"
#import "MTUCamera.h"

@implementation MTUCamera

- (void) reset {
    position = vector3(0.0f, 0.0f, 0.0f);
    target = vector3(0.0f, 0.0f, -1.0f);
    up = vector3(0.0f, 1.0f, 0.0f);
    viewMatrix = matrix_identity_float4x4;
    _fovy = 65.0f;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (instancetype) initWithPosition:(MTUPoint3)position_ target:(MTUPoint3)target_ up:(MTUPoint3)up_ {
    self = [super init];
    if (self) {
        [self reset];
        position = vector3(position_.x, position_.y, position_.z);
        target = vector3(target_.x, target_.y, target_.z);
        up = vector3(up_.x, up_.y, up_.z);
    }
    return self;
}

- (void) rotateXZOnTarget:(float) rotate {
    vector_float3 dir = position - target;
    matrix_float3x3 rotateMatrix = matrix3x3_rotation(rotate, 0, 1, 0);
    vector_float3 newDir = matrix_multiply(rotateMatrix, dir);
    position = target + newDir;
}

- (void) update {
    viewMatrix = matrix_look_at_right_hand(position, target, up);
}

@end
