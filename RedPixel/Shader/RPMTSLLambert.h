#ifndef _RP_MTSL_LAMBERT_H_
#define _RP_MTSL_LAMBERT_H_

namespace RedPixel {

struct LambertConstants {
	float4x4 mvpMatrix_;
	float4x4 normalMatrix_;
	float3 ambientColor_;
	float3 diffuseColor_;
	float3 lightDirection_;
};

}

#endif /* _RP_MTSL_LAMBERT_H_ */