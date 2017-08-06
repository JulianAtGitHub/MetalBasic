//
//  MTUTypes.h
//  MetalSample
//
//  Created by zhuwei on 7/15/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_TYPES_H_
#define _MTU_TYPES_H_

#include <stdbool.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    float x, y, z;
} MTUPoint3;

typedef enum {
    MTUVertexFormatP = 0,
    MTUVertexFormatPT,
    MTUVertexFormatPN,
    MTUVertexFormatPTN,
    MTUVertexFormatPTNTB,
    MTUVertexFormatMax
} MTUVertexFormat;

typedef enum {
    MTUTransformTypeMvp = 0,
    MTUTransformTypeMvpMN,
    MTUTransformTypeMax
} MTUTransformType;

typedef enum {
    MTUCameraParamsNotUse = 0,
    MTUCameraParamsForVertexShader,
    MTUCameraParamsForFragmentShader,
    MTUCameraParamsForBothShaders
} MTUCameraParamsUsage;
    
#ifdef __cplusplus
}
#endif
    
#endif /* _MTU_TYPES_H_ */
