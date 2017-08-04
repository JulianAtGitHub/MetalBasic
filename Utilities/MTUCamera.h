//
//  MTUCamera.h
//  MetalSample
//
//  Created by zhuwei on 8/4/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_CAMERA_H_
#define _MTU_CAMERA_H_

#include <simd/simd.h>
#import <Foundation/Foundation.h>
#import "MTUTypes.h"

@interface MTUCamera : NSObject {
    @public
    vector_float3 position;
    vector_float3 target;
    vector_float3 up;
    matrix_float4x4 viewMatrix;
}

@property (nonatomic, readwrite) float fovy;

- (nonnull instancetype) initWithPosition:(MTUPoint3)position target:(MTUPoint3)target up:(MTUPoint3)up;

- (void) rotateXZOnTarget:(float) rotate;

- (void) update;

@end

#endif /* _MTU_CAMERA_H_ */
