
#ifndef _RP_MATH_TYPES_H
#define _RP_MATH_TYPES_H

namespace RedPixel {

union _float2 {
    struct { float x, y; };
    float v[2];
};
typedef union _float2 float2;

union _float3 {
    struct { float x, y, z; };
    struct { float r, g, b; };
    float v[3];
};
typedef union _float3 float3;

union _float4 {
    struct { float x, y, z, w; };
    struct { float r, g, b, a; };
    float v[4];
};
typedef union _float4 float4;

}

#endif /* _RP_MATH_TYPES_H */