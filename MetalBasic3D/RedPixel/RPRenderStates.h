
#ifndef _RP_RENDER_STATES_H_
#define _RP_RENDER_STATES_H_

#include <string>
#include <vector>

#include "RPRenderConstants.h"
#include "RPMathTypes.h"

namespace RedPixel {

struct ScissorRect {
	uint x, y, width, height;
}

struct Viewport {
	float x, y, width, height, near, far;
}

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
	std::string name_;

	VertexAttribute(void)
	:format_(VertexFormatInvalid)
	,offset_(0)
	{ }

	~VertexAttribute(void) { }
};

class VertexAttributes {
public:
	std::vector<VertexAttribute> attributes_;
	uint stride_;

	VertexAttributes(void)
	:stride_(0)
	{ }

	~VertexAttributes(void) { }
};

class RenderPipelineColorAttachment {
public:
	// Specifying Render Pipeline State
	PixelFormat pixelFormat_;
	ColorWriteMask writeMask_;

	// Controlling the Blend Operation
	bool blendingEnabled_;
	BlendOperation alphaBlendOperation_;
	BlendOperation rgbBlendOperation_;

	// Specifying Blend Factors
	BlendFactor destinationAlphaBlendFactor_;
	BlendFactor destinationRGBBlendFactor_;
	BlendFactor sourceAlphaBlendFactor_;
	BlendFactor sourceRGBBlendFactor_;

	RenderPipelineColorAttachment(void)
	:pixelFormat_(PixelFormatInvalid)
	,writeMask_(ColorWriteMaskAll)
	,blendingEnabled_(false)
	,alphaBlendOperation_(BlendOperationAdd)
	,rgbBlendOperation_(BlendOperationAdd)
	,destinationAlphaBlendFactor_(BlendFactorZero)
	,destinationRGBBlendFactor_(BlendFactorZero)
	,sourceAlphaBlendFactor_(BlendFactorOne)
	,sourceRGBBlendFactor_(BlendFactorOne)
	{ }

	~RenderPipelineColorAttachment(void) { }
};

class RenderPipelineState {
public:
	// Specifying Shader Functions and Associated Data
	std::string fragmentModuleName_;
	std::string vertexModuleName_;
	VertexAttributes vertexDescriptor_;

	// Specifying Rendering Pipeline State
	RenderPipelineColorAttachment colorAttachment_;
	PixelFormat depthAttachmentPixelFormat_;
	PixelFormat stencilAttachmentPixelFormat_;

	// Specifying Rasterization and Visibility State
	uint sampleCount_;
	bool alphaToCoverageEnabled_;
	bool alphaToOneEnabled_;
	bool rasterizationEnabled_;
	PrimitiveTopologyClass inputPrimitiveTopology_;

	// label
	std::string label_;

	RenderPipelineState(void)
	:depthAttachmentPixelFormat_(PixelFormatInvalid)
	,stencilAttachmentPixelFormat_(PixelFormatInvalid)
	,sampleCount_(1)
	,alphaToCoverageEnabled_(false)
	,alphaToOneEnabled_(false)
	,rasterizationEnabled_(true)
	,inputPrimitiveTopology_(MTLPrimitiveTopologyClassUnspecified)
	{ }

	~RenderPipelineState(void) { }
};

class RenderBuffer {
public:
	const void *contents_;
	uint length_;

	RenderBuffer(void)
	:contents_(nullptr)
	,length_(0)
	{ }

	~RenderBuffer(void) { }
};

class RenderTexture {
public:
	// Specifying Texture Attributes
	TextureType textureType_;
	PixelFormat pixelFormat_;
	uint width_;
	uint height_;
	uint depth_;
	uint mipmapLevelCount_;
	uint sampleCount_;
	uint arrayLength_;
	ResourceOptions resourceOptions_;
	CPUCacheMode cpuCacheMode_;
	StorageMode storageMode_;
	TextureUsage usage_;
	RenderBuffer rawData_;

	RenderTexture(void)
	:textureType_(TextureType2D)
	,pixelFormat_(PixelFormatRGBA8Unorm)
	,width_(1)
	,height_(1)
	,depth_(1)
	,mipmapLevelCount_(1)
	,sampleCount_(1)
	,arrayLength_(1)
	,resourceOptions_(ResourceCPUCacheModeDefaultCache)
	,cpuCacheMode_(CPUCacheModeDefaultCache)
#ifdef TARGET_PLATFORM_IOS
	,storageMode_(StorageModeShared)
#else
	,storageMode_(StorageModeManaged)
#endif
	,usage_(TextureUsageShaderRead)
	{ }

	~RenderTexture(void) { }
};

class RenderPassAttachment {
public:
	// Specifying the Texture for the Attachment
	RenderTexture *texture_;
	uint level_;
	uint slice_;
	uint depthPlane_;

	// Specifying Rendering Pass Actions
	LoadAction loadAction_;
	StoreAction storeAction_;

	// Specifying the Texture to Resolve Multisample Data
	RenderTexture *resolveTexture_;
	uint resolveLevel_;
	uint resolveSlice_;
	uint resolveDepthPlane_;

	RenderPassAttachment(void)
	:texture_(nullptr)
	,level_(0)
	,slice_(0)
	,depthPlane_(0)
	,loadAction_(LoadActionDontCare)
	,storeAction_(StoreActionDontCare)
	,resolveTexture_(nullptr)
	,resolveLevel_(0)
	,resolveSlice_(0)
	,resolveDepthPlane_(0)
	{ }

	~RenderPassAttachment(void) { }
	
};

class RenderPassColorAttachment : public RenderPassAttachment {
public:
	float4 clearColor_;

	RenderPassColorAttachment(void) {
		clearColor_ = struct{0.0f, 0.0f, 0.0f, 1.0f};
	}

	~RenderPassColorAttachment(void) { }
};

class RenderPassDepthAttachment : public RenderPassAttachment {
public:
	float clearDepth_;
	MultisampleDepthResolveFilter depthResolveFilter_;

	RenderPassDepthAttachment(void)
	:clearDepth_(1.0f)
	,depthResolveFilter_(MultisampleDepthResolveFilterSample0)
	{}

	~RenderPassDepthAttachment(void) { }
};

class RenderPassStencilAttachment : public RenderPassAttachment {
public:
	uint clearStencil_;

	RenderPassStencilAttachment(void)
	:clearStencil_(0.0f)
	{}

	~RenderPassStencilAttachment(void) { }
};

class RenderPassState
{
public:
	// Specifying the Attachments for a Rendering Pass
	RenderPassColorAttachment *colorAttachment_;
	RenderPassDepthAttachment *depthAttachment_;
	RenderPassStencilAttachment *stencilAttachment_;

	// Specifying the Visibility Result Buffer
	RenderBuffer visibilityResultBuffer_;

	// Specifying the Visibility Result Buffer
	uint renderTargetArrayLength_;

	RenderPassState(void)
	:colorAttachment_(nullptr)
	,depthAttachment_(nullptr)
	,stencilAttachment_(nullptr)
	,renderTargetArrayLength_(0)
	{ }

	~RenderPassState(void) { }
	
};

}

#endif /* _RP_RENDER_STATES_H_ */