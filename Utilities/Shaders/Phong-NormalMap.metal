//
//  Phong-NormalMap.metal
//  MetalSample
//
//  Created by zhuwei on 7/27/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateShaderTypes.h"
#include "../MTUShaderTypes.h"

vertex VertOutPTNTBH vertPhongNormalMap(uint vertexID [[vertex_id]],
                                        constant MTUVertexPTNTB *vertices [[buffer(0)]],
                                        constant MTUTransformMvpMNP &transform [[buffer(1)]],
                                        constant MTUGlobalLight &light [[buffer(2)]]) {
    VertOutPTNTBH out;
    constant MTUVertexPTNTB &vertIn = vertices[vertexID];
    
    out.position = transform.modelview_projection * float4(vertIn.position, 1.0);
    out.texCoord = vertIn.texCoord;
    
    out.normal = normalize(transform.normal_matrix * vertIn.normal);
    out.tangent = normalize(transform.normal_matrix * vertIn.tangent);
    out.binormal = normalize(transform.normal_matrix * vertIn.binormal);
    
    float4 position = transform.model_matrix * float4(vertIn.position, 1.0);
    float3 eye_direction = normalize(transform.camera_position - position.xyz);
    out.halfVector = normalize(eye_direction + light.direction);
    
    return out;
}

fragment float4 fragPhongNormalMap(VertOutPTNTBH in [[stage_in]],
                                   constant MTUGlobalLight &light [[buffer(2)]],
                                   constant MTUObjectParams &object [[buffer(3)]],
                                   texture2d<float> colorTexture [[texture(0)]],
                                   texture2d<float> normalTexture [[texture(1)]]) {
    in.normal = normalize(in.normal);
    in.tangent = normalize(in.tangent);
    in.binormal = normalize(in.binormal);
    float3x3 tangentMatrix = float3x3(in.tangent, in.binormal, in.normal);
    
    float3 normalRaw = normalTexture.sample(defaultSampler, in.texCoord).xyz;
    normalRaw.xy = normalRaw.xy * 2.0 - 1.0;
    normalRaw = normalize(normalRaw);
    float3 normal = tangentMatrix * normalRaw;
    
    float3 halfVector = normalize(in.halfVector);
    const float3 intensity = light.intensity;
    
    float diffuse_fraction = max(dot(light.direction, normal), 0.0);
    float specular_fraction = pow(max(dot(halfVector, normal), 0.0), object.shiness);
    const float4 color = colorTexture.sample(defaultSampler, in.texCoord);
    float3 final_color = color.rgb * (intensity.x + intensity.y * diffuse_fraction + intensity.z * specular_fraction);
    return float4(final_color, 1.0);
}


