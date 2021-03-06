//
//  MTUShaderTypes.h
//  MetalSample
//
//  Created by zhuwei on 7/21/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_SHADER_TYPES_H_
#define _MTU_SHADER_TYPES_H_

#include <simd/simd.h>

#ifdef __cplusplus
extern "C" {
#endif

// transform types

typedef struct {
    matrix_float4x4 modelview_projection;
} MTUTransformMvp;

typedef struct {
    matrix_float4x4 modelview_projection;
    matrix_float4x4 model_matrix;
    matrix_float3x3 normal_matrix;
} MTUTransformMvpMN;

typedef struct {
    vector_float3 position;
    vector_float3 direction;
} MTUCameraParams;

// Material types

typedef struct {
    vector_float3 direction;
    vector_float3 intensity;
} MTUGlobalLight;

typedef struct {
    vector_float3 inversed_direction;
    vector_float3 ambient_color;
    vector_float3 color;
} MTUDirectLight;

typedef struct {
    float shiness;
/*
     Material    Refractive index
     Air         1.00
     Water       1.33
     Ice         1.309
     Glass       1.52
     Diamond     2.42
*/
    float refractRatio;
} MTUObjectParams;
    
#ifdef __cplusplus
}
#endif


#endif /* _MTU_SHADER_TYPES_H_ */
