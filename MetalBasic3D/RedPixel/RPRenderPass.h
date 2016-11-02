
#ifndef _RP_RENDER_PASS_H_
#define _RP_RENDER_PASS_H_

#include <string>
#include <vector>

#include "RPRenderConstants.h"
#include "RPMathTypes.h"

namespace RedPixel {

class StencilState {
public:
	// Specifying Stencil Functions and Operations
	StencilOperation stencilFailureOperation_;
	StencilOperation depthFailureOperation_;
	StencilOperation depthStencilPassOperation_;
	CompareFunction stencilCompareFunction_;

	// Specifying Stencil Bit Mask Properties
	uint readMask_;
	uint writeMask_;

	// label
	std::string label_;

	StencilState(void)
	:stencilFailureOperation_(StencilOperationKeep)
	,depthFailureOperation_(StencilOperationKeep)
	,depthStencilPassOperation_(StencilOperationKeep)
	,stencilCompareFunction_(CompareFunctionAlways)
	,readMask_(0xffffffff)
	,writeMask_(0xffffffff) 
	{ }

	~StencilState(void) { }
};

class DepthStencilState {
public:
	// Specifying Depth Operations
	CompareFunction depthCompareFunction_;
	bool depthWriteEnabled_;

	// Specifying Stencil States for Primitives
	StencilState *backFaceStencil_;
	StencilState *frontFaceStencil_;

	// label
	std::string label_;

	DepthStencilState(void)
	:depthCompareFunction_(CompareFunctionAlways)
	,depthWriteEnabled_(false)
	,backFaceStencil_(nullptr)
	,frontFaceStencil_(nullptr)
	{ }

	~DepthStencilState(void) { }
};

class VertexAttribute {
public:
	VertexFormat format_;
	uint offset_;
	std::string label_;

	VertexAttribute(void)
	:format_(VertexFormatInvalid)
	,offset_(0)
	{ }

	~VertexAttribute(void) { }
};

class VertexDescriptor {
public:
	std::vector<VertexAttribute> attributes_;
	uint stride_;

	VertexDescriptor(void)
	:stride_(0)
	{ }

	~VertexDescriptor(void) { }
};

class RenderPipelineState {
public:
	// Specifying Shader Functions and Associated Data
	std::string fragmentModuleName_;
	std::string vertexModuleName_;
	VertexDescriptor vertexDescriptor_;

	RenderPipelineState(void)
	{ }

	~RenderPipelineState(void) { }
};

class RenderPass {
public:
	// Setting Graphics Rendering State
	float4 blendColor_;
	CullMode cullMode_;
	float depthBias_;
	float slopeScale_;
	float depthClamp_;
	DepthClipMode depthClipMode_
	DepthStencilState *depthStencilState_;
	WindingMode frontFacingWinding_;

	RenderPass();
	~RenderPass();
};

}

#endif /* _RP_RENDER_PASS_H_ */