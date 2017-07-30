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
    float2 textureCoordinate;
} RasterizerData;


vertex RasterizerData vertexShader(uint vertexID [[vertex_id]],
                                   constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
                                   constant vector_uint2 *viewportSizePointer [[buffer(VertexInputIndexViewportSize)]]) {
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    float2 viewportSize = float2(*viewportSizePointer);
    RasterizerData out;
    out.clipSpacePosition = float4((pixelSpacePosition / viewportSize * 2.0), 0.0, 1.0);
    out.textureCoordinate = vertices[vertexID].textureCoordinate;
    return out;
}

fragment float4 fragmentShader(RasterizerData data [[stage_in]],
                               texture2d<half> colorTexture [[texture(TextureIndexBaseColor)]]) {
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    const half4 colorSample = colorTexture.sample(textureSampler, data.textureCoordinate);
    return float4(colorSample);
}

constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

kernel void grayScaleKernel(texture2d<half, access::read> inTexture [[texture(TextureIndexInput)]],
                            texture2d<half, access::write> outTexture [[texture(TextureIndexOutput)]],
                            uint2 gid [[thread_position_in_grid]]) {
    half4 inColor = inTexture.read(gid);
    half gray = dot(inColor.rgb, kRec709Luma);
    outTexture.write(half4(gray, gray, gray, 1.0), gid);
}
