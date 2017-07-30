//
//  Phong-Diffuse.metal
//  MetalSample
//
//  Created by zhuwei on 7/17/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateShaderTypes.h"
#include "../MTUShaderTypes.h"

vertex VertOutPTNH vertPhongDiffuse(uint vertexID [[vertex_id]],
                                constant MTUVertexPTN *vertices [[buffer(0)]],
                                constant MTUTransformMvpMNP &transform [[buffer(1)]],
                                constant MTUGlobalLight &light [[buffer(2)]]) {
    VertOutPTNH vertOut;
    constant MTUVertexPTN &vertIn = vertices[vertexID];
    vertOut.position = transform.modelview_projection * float4(vertIn.position, 1.0);
    vertOut.texCoord = vertIn.texCoord;
    vertOut.normal = normalize(transform.normal_matrix * vertIn.normal);
    float4 position = transform.model_matrix * float4(vertIn.position, 1.0);
    float3 eye_direction = normalize(transform.camera_position - position.xyz);
    vertOut.halfVector = normalize(eye_direction + light.direction);
    return vertOut;
}

fragment float4 fragPhongDiffuse(VertOutPTNH in [[stage_in]],
                                 constant MTUGlobalLight &light [[buffer(2)]],
                                 constant MTUObjectParams &object [[buffer(3)]],
                                 texture2d<float> colorTexture [[texture(0)]]) {
    float3 normal = normalize(in.normal);
    float3 halfVector = normalize(in.halfVector);
    const float3 intensity = light.intensity;
    
    float diffuse_fraction = max(dot(light.direction, normal), 0.0);
    float specular_fraction = pow(max(dot(halfVector, normal), 0.0), object.shiness);
    const float4 base_color = colorTexture.sample(defaultSampler, in.texCoord);
    float3 final_color = base_color.rgb * (intensity.x + intensity.y * diffuse_fraction + intensity.z * specular_fraction);
    return float4(final_color, 1.0);
}
