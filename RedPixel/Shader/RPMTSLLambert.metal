
#include <metal_stdlib>
#include "RPMTSLLambert.h"

using namespace metal;
using namespace RedPixel;

struct VertexInput {
	float3 position;
	float3 normal;
};

struct VertexOutput {
	float4 position [[position]];
	half4 color;
}

vertex VertexOutput LambertVertex ( device VertexInput *vertices [[buffer(0)]],
									constant LambertConstants &constants [[buffer(1)]],
									unsigned int vid [[vertex_id]] ) {
	VertexOutput out;
	out.position = constants.mvpMatrix_ * float4(vertices[vid].position, 1.0);
	float3 eye_normal = normalize(constants.normalMatrix_ * vertices[vid].normal);
	float n_dot_l = fmax(0.0, dot(eye_normal, normalize(constants.lightDirection_)));
	half3 color = half3(constants.ambientColor_ + constants.diffuseColor_ * n_dot_l);
	out.color = half4(color, 1.0);
	return out;
}

fragment half4 LambertFragment ( VertexOutput in [[stage_in]]) {
	return in.color;
}