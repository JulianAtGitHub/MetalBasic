//
//  PostProcess.metal
//  MetalSample
//
//  Created by zhuwei on 8/9/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "PrivateTypes.h"
#include "../MTUShaderTypes.h"

vertex VertOutPT vertPostProcess(uint vertexID [[vertex_id]],
                                 constant MTUVertexPT *vertices [[buffer(0)]]) {
    
    VertOutPT out;
    constant MTUVertexPT &vertIn = vertices[vertexID];
    
    out.position = float4(vertIn.position, 1.0);
    out.texCoord = vertIn.texCoord;

    return out;
}

fragment float4 fragPostProcess(VertOutPT in [[stage_in]],
                                texture2d<float> colorTexture [[texture(0)]]) {
//    float3 color = colorTexture.sample(defaultSampler, in.texCoord).rgb;
//    // Gamma correction
//    float gamma = 2.2;
//    color = pow(color, 1.0/gamma);
//    return float4(color, 1.0);
    return colorTexture.sample(defaultSampler, in.texCoord);
}
