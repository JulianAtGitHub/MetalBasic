//
//  NoLight-Diffuse.metal
//  MetalSample
//
//  Created by zhuwei on 7/17/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateShaderTypes.h"
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
                               texture2d<half> colorTexture [[texture(0)]]) {
    const half4 color = colorTexture.sample(defaultSampler, in.texCoord);
    return float4(color);
}
