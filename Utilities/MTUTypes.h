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
    float x, y;
} MTUPoint2;

typedef struct {
    float x, y, z;
} MTUPoint3;

// vertex types
typedef struct {
    MTUPoint3 position;
} MTUVertexP;

typedef struct {
    MTUPoint3 position;
    MTUPoint2 texCoord;
} MTUVertexPT;

typedef struct {
    MTUPoint3 position;
    MTUPoint2 texCoord;
    MTUPoint3 normal;
} MTUVertexPTN;

typedef struct {
    MTUPoint3 position;
    MTUPoint2 texCoord;
    MTUPoint3 normal;
    MTUPoint3 tangent;
    MTUPoint3 binormal;
} MTUVertexPTNTB;

typedef enum {
    MTUVertexFormatP = 0,
    MTUVertexFormatPT,
    MTUVertexFormatPTN,
    MTUVertexFormatPTNTB,
    MTUVertexFormatMax
} MTUVertexFormat;

typedef enum {
    MTUTransformTypeInvalid = 0,
    MTUTransformTypeMvp,
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
