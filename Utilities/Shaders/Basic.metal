//
//  NoLight-Diffuse.metal
//  MetalSample
//
//  Created by zhuwei on 7/17/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateTypes.h"
#include "../MTUShaderTypes.h"

vertex VertOutPT vertBasicColor(uint vertexID [[vertex_id]],
                                constant MTUVertexPT *verties [[buffer(0)]],
                                constant MTUTransformMvp &transform [[buffer(1)]]) {
    VertOutPT vertOut;
    constant MTUVertexPT &vertIn = verties[vertexID];
    vertOut.position = transform.modelview_projection * float4(vertIn.position, 1.0);
    vertOut.texCoord = vertIn.texCoord;
    return vertOut;
}

fragment float4 fragBasicColor(VertOutPT in [[stage_in]],
                               texture2d<float> colorTexture [[texture(0)]]) {
    return colorTexture.sample(defaultSampler, in.texCoord);
}

vertex VertOutPT3 vertSkybox(uint vertexID [[vertex_id]],
                             constant MTUVertexP *verties [[buffer(0)]],
                             constant MTUTransformMvp &transform [[buffer(1)]]) {
    VertOutPT3 vertOut;
    constant MTUVertexP &vertIn = verties[vertexID];
    float4 position = transform.modelview_projection * float4(vertIn.position, 1.0);
    vertOut.position = position.xyww;
    vertOut.texCoord = vertIn.position;
    return vertOut;
}

fragment float4 fragSkybox(VertOutPT3 in [[stage_in]],
                           texturecube<float> colorTexture [[texture(0)]]) {
    return colorTexture.sample(cubemapSampler, in.texCoord);
}
