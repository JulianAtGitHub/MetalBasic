//
//  Refraction.metal
//  MetalSample
//
//  Created by zhuwei on 8/7/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateTypes.h"
#include "../MTUShaderTypes.h"

vertex VertOutPPTN vertBasicRefraction(VertInPTN vertIn [[stage_in]],
                                       constant MTUTransformMvpMN &transform [[buffer(1)]]) {
    VertOutPPTN out;
    
    out.position = transform.modelview_projection * float4(vertIn.position, 1.0);
    out.wp_position = (transform.model_matrix * float4(vertIn.position, 1.0)).xyz;
    out.texCoord = vertIn.texCoord;
    out.normal = normalize(transform.normal_matrix * vertIn.normal);
    
    return out;
}

fragment float4 fragBasicRefraction(VertOutPPTN in [[stage_in]],
                                    constant MTUCameraParams &camera [[buffer(2)]],
                                    constant MTUObjectParams &object [[buffer(3)]],
                                    texturecube<float> envTexture [[texture(0)]]) {
    float3 N = normalize(in.normal);
    float3 I = normalize(in.wp_position - camera.position);
    float3 R = normalize(refract(I, N, object.refractRatio));
    
    return envTexture.sample(defaultSampler, R);
}

vertex VertOutPPTNTB vertRefraction(VertInPTNTB vertIn [[stage_in]],
                                    constant MTUTransformMvpMN &transform [[buffer(1)]]) {
    VertOutPPTNTB out;
    
    out.position = transform.modelview_projection * float4(vertIn.position, 1.0);
    out.wp_position = (transform.model_matrix * float4(vertIn.position, 1.0)).xyz;
    out.texCoord = vertIn.texCoord;
    
    out.normal = normalize(transform.normal_matrix * vertIn.normal);
    out.tangent = normalize(transform.normal_matrix * vertIn.tangent);
    out.binormal = normalize(transform.normal_matrix * vertIn.binormal);
    
    return out;
}

fragment float4 fragRefraction(VertOutPPTNTB in [[stage_in]],
                               constant MTUCameraParams &camera [[buffer(2)]],
                               constant MTUObjectParams &object [[buffer(3)]],
                               texture2d<float> normalTexture [[texture(0)]],
                               texturecube<float> envTexture [[texture(1)]]) {
    in.normal = normalize(in.normal);
    in.tangent = normalize(in.tangent);
    in.binormal = normalize(in.binormal);
    float3x3 tangentMatrix = float3x3(in.tangent, in.binormal, in.normal);
    
    float3 normalRaw = normalTexture.sample(defaultSampler, in.texCoord).xyz;
    normalRaw.xy = normalRaw.xy * 2.0 - 1.0;
    normalRaw = normalize(normalRaw);
    
    float3 N = tangentMatrix * normalRaw;
    float3 I = normalize(in.wp_position - camera.position);
    float3 R = normalize(refract(I, N, object.refractRatio));
    
    return envTexture.sample(defaultSampler, R);
}
