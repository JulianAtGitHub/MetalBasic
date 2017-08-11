//
//  Phong.metal
//  MetalSample
//
//  Created by zhuwei on 7/30/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateTypes.h"
#include "../MTUShaderTypes.h"

vertex VertOutPTNTBH vertPhong(VertInPTNTB vertIn [[stage_in]],
                               constant MTUTransformMvpMN &transform [[buffer(1)]],
                               constant MTUCameraParams &camera [[buffer(2)]],
                               constant MTUDirectLight &light [[buffer(3)]]) {
    VertOutPTNTBH out;
    
    out.position = transform.modelview_projection * float4(vertIn.position, 1.0);
    out.texCoord = vertIn.texCoord;
    
    out.normal = normalize(transform.normal_matrix * vertIn.normal);
    out.tangent = normalize(transform.normal_matrix * vertIn.tangent);
    out.binormal = normalize(transform.normal_matrix * vertIn.binormal);
    
    float4 position = transform.model_matrix * float4(vertIn.position, 1.0);
    float3 direction = normalize(camera.position - position.xyz);
    out.halfVector = normalize(direction + light.inversed_direction);
    
    return out;
}

fragment float4 fragPhong(VertOutPTNTBH in [[stage_in]],
                          constant MTUDirectLight &light [[buffer(3)]],
                          constant MTUObjectParams &object [[buffer(4)]],
                          texture2d<float> diffuseTexture [[texture(0)]],
                          texture2d<float> normalTexture [[texture(1)]],
                          texture2d<float> specularTexture [[texture(2)]]) {
    in.halfVector = normalize(in.halfVector);
    in.normal = normalize(in.normal);
    in.tangent = normalize(in.tangent);
    in.binormal = normalize(in.binormal);
    float3x3 tangentMatrix = float3x3(in.tangent, in.binormal, in.normal);
    
    float3 normalRaw = normalTexture.sample(defaultSampler, in.texCoord).xyz;
    normalRaw.xy = normalRaw.xy * 2.0 - 1.0;
    normalRaw = normalize(normalRaw);
    float3 normal = tangentMatrix * normalRaw;
    
    // normal dot light
    float nDotL = saturate(dot(normal, light.inversed_direction));
    float3 baseColorIntensity = light.color * nDotL + light.ambient_color;
    float3 baseColorTerm = diffuseTexture.sample(defaultSampler, in.texCoord).xyz * baseColorIntensity;
    
    float reflectAmount = saturate(dot(normal, in.halfVector));
    float specularIntensity = pow(reflectAmount, object.shiness);
    float3 specularTerm = light.color * specularIntensity * specularTexture.sample(defaultSampler, in.texCoord).x;
    
    float3 color = baseColorTerm + specularTerm;
    return float4(color, 1.0);
}
