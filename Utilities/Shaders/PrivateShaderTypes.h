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
    float2 texCoord;
    float3 normal;
    float3 halfVector;
} VertOutPTNH;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
    float3 normal;
    float3 tangent;
    float3 binormal;
    float3 halfVector;
} VertOutPTNTBH;

constexpr sampler defaultSampler(filter::linear, address::repeat);

#endif /* _PRIVATE_SHADER_TYPES_H_ */
