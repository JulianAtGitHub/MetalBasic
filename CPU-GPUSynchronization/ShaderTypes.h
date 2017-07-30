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

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs match
//   Metal API buffer set calls
typedef enum {
    VertexInputIndexVertices     = 0,
    VertexInputIndexViewportSize =  1,
} VertexInputIndex;


//  This structre devines the layout of each vertex in the array of vertices set as an input to our
//    Metal vertex shader.  Since this header is shared between our .metal shader and C code,
//    we can be sure that the layout of the vertex array in the Ccode matches the layour that
//    our vertex shader expects
typedef struct {
    //  Positions in pixel space (i.e. a value of 100 indicates 100 pixels from the origin/center)
    vector_float2 position;
    
    // Floating point RGBA colors
    vector_float4 color;
} Vertex;

#endif /* ShaderTypes_h */
