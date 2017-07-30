//
//  Shaders.metal
//  MetalSample
//
//  Created by zhuwei on 6/13/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

typedef struct {
    float4 clipSpacePosition [[position]];
    float4 color;
} RasterizerData;


vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
                                   constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
                                   constant vector_uint2 *viewportSizePointer [[buffer(VertexInputIndexViewportSize)]]) {
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    float2 viewportSize = float2(*viewportSizePointer);
    RasterizerData out;
    out.clipSpacePosition = float4((pixelSpacePosition / viewportSize * 2.0), 0.0, 1.0);
    out.color = vertices[vertexID].color;
    return out;
}

fragment float4 fragmentShader(RasterizerData data [[stage_in]]) {
    return data.color;
}

