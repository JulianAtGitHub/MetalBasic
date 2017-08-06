//
//  PrivateShaderTypes.h
//  MetalSample
//
//  Created by zhuwei on 7/17/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _PRIVATE_SHADER_TYPES_H_
#define _PRIVATE_SHADER_TYPES_H_

typedef struct {
    float4 position [[position]];
    float2 texCoord;
} VertOutPT;

typedef struct {
    float4 position [[position]];
    float3 texCoord;
} VertOutPT3;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
    float3 normal;
} VertOutPTN;

typedef struct {
    float4 position [[position]];
    float3 wp_position; // world space position
    float2 texCoord;
    float3 normal;
} VertOutPPTN;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
    float3 normal;
    float3 halfVector;
} VertOutPTNH;

typedef struct {
    float4 position [[position]];
    float3 wp_position; // world space position
    float2 texCoord;
    float3 normal;
    float3 tangent;
    float3 binormal;
} VertOutPPTNTB;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
    float3 normal;
    float3 tangent;
    float3 binormal;
    float3 halfVector;
} VertOutPTNTBH;

constexpr sampler defaultSampler(filter::linear, address::repeat);
constexpr sampler cubemapSampler(filter::linear, address::clamp_to_edge);

#endif /* _PRIVATE_SHADER_TYPES_H_ */
