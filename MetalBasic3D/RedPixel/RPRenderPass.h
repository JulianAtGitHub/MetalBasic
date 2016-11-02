
#ifndef _RP_RENDER_PASS_H_
#define _RP_RENDER_PASS_H_

#include <string>
#include "RPMathType.h"

namespace RedPixel {

enum CullMode {
	CullModeNone,
	CullModeFront,
	CullModeBack
};

enum DepthClipMode {
	DepthClipModeClip,
	DepthClipModeClamp
};

enum CompareFunction {
	CompareFunctionNever,
	CompareFunctionLess,
	CompareFunctionEqual,
	CompareFunctionLessEqual,
	CompareFunctionGreater,
	CompareFunctionNotEqual,
	CompareFunctionGreaterEqual,
	CompareFunctionAlways,
};

class DepthStencilState
{
public:
	CompareFunction depthCompareFunction_;
	bool depthWriteEnabled_;

	DepthStencilState();
	~DepthStencilState();
};

class RenderPass
{
public:
	float4 blendColor_;
	CullMode cullMode_;
	float depthBias_;
	float slopeScale_;
	float depthClamp_;
	DepthClipMode depthClipMode_


	RenderPass();
	~RenderPass();
};

}

#endif /* _RP_RENDER_PASS_H_ */