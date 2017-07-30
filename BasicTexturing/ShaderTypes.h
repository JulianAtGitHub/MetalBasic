//
//  ShaderTypes.h
//  MetalSample
//
//  Created by zhuwei on 6/13/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

typedef enum {
    VertexInputIndexVertices        = 0,
    VertexInputIndexViewportSize    = 1
} VertexInputIndex;

typedef enum {
    TextureIndexBaseColor = 0
} TextureIndex;

typedef struct {
    vector_float2 position;
    vector_float2 textureCoordinate;
} Vertex;


#endif /* ShaderTypes_h */
