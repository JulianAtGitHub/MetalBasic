#ifndef _RP_MTSL_LAMBERT_H_
#define _RP_MTSL_LAMBERT_H_

#include <simd/simd.h>

namespace RedPixel {

struct LambertConstants {
	simd::float4x4 mvpMatrix_;
	simd::float3x3 normalMatrix_;
	simd::float3 ambientColor_;
	simd::float3 diffuseColor_;
	simd::float3 lightDirection_;
};

}

#endif /* _RP_MTSL_LAMBERT_H_ */