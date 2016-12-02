
#include <metal_stdlib>
#include "RPMTSLLambert.h"

using namespace metal;
using namespace RedPixel;

struct VertexInput {
	packed_float3 position;
	packed_float3 normal;
};

struct VertexOutput {
	float4 position [[position]];
	half4 color;
}

vertex VertexOutput LambertVertex ( const device VertexInput *vertices [[buffer(0)]],
									constant LambertConstants &constants [[buffer(1)]],
									unsigned int vid [[vertex_id]] ) {
	VertexOutput out;
	out.position = constants.mvpMatrix_ * float4(vertices[vid].position, 1.0);
	float4 eye_normal = normalize(constants.normalMatrix_ * float4(vertices[vid].normal, 0.0));
	float n_dot_l = fmax(0.0, dot(eye_normal.xyz, normalize(constants.lightDirection_)));
	half3 color = half3(constants.ambientColor_ + constants.diffuseColor_ * n_dot_l);
	out.color = half4(color, 1.0);
	return out;
}

fragment half4 LambertFragment ( VertexOutput in [[stage_in]]) {
	return in.color;
}