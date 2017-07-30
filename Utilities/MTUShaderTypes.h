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

// vertex types

typedef struct {
    vector_float3 position;
    vector_float2 texCoord;
} MTUVertexPT;

typedef struct {
    vector_float3 position;
    vector_float3 normal;
} MTUVertexPN;

typedef struct {
    vector_float3 position;
    vector_float2 texCoord;
    vector_float3 normal;
} MTUVertexPTN;

typedef struct {
    vector_float3 position;
    vector_float2 texCoord;
    vector_float3 normal;
    vector_float3 tangent;
    vector_float3 binormal;
} MTUVertexPTNTB;

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
    matrix_float4x4 modelview_projection;
    matrix_float4x4 model_matrix;
    matrix_float3x3 normal_matrix;
    vector_float3 camera_position;
} MTUTransformMvpMNP;

typedef struct {
    matrix_float4x4 modelview_projection;
    matrix_float4x4 model_matrix;
    matrix_float3x3 normal_matrix;
    vector_float3 camera_position;
    vector_float3 camera_look_at;
} MTUTransformMvpMNPD;

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
} MTUObjectParams;
    
#ifdef __cplusplus
}
#endif


#endif /* _MTU_SHADER_TYPES_H_ */
