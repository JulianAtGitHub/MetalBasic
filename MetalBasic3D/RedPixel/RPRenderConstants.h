
#ifndef _RP_RENDER_CONSTANTS_H_
#define _RP_RENDER_CONSTANTS_H_

namespace RedPixel {

enum VertexFormat {
	VertexFormatInvalid,

	VertexFormatUChar2,
	VertexFormatUChar3,
	VertexFormatUChar4,

	VertexFormatChar2,
	VertexFormatChar3,
	VertexFormatChar4,

	VertexFormatUChar2Normalized,
	VertexFormatUChar3Normalized,
	VertexFormatUChar4Normalized,

	VertexFormatChar2Normalized,
	VertexFormatChar3Normalized,
	VertexFormatChar4Normalized,

	VertexFormatUShort2,
	VertexFormatUShort3,
	VertexFormatUShort4,

	VertexFormatShort2,
	VertexFormatShort3,
	VertexFormatShort4,

	VertexFormatUShort2Normalized,
	VertexFormatUShort3Normalized,
	VertexFormatUShort4Normalized,

	VertexFormatShort2Normalized,
	VertexFormatShort3Normalized,
	VertexFormatShort4Normalized,

	VertexFormatHalf2,
	VertexFormatHalf3,
	VertexFormatHalf4,

	VertexFormatFloat,
	VertexFormatFloat2,
	VertexFormatFloat3,
	VertexFormatFloat4,

	VertexFormatInt,
	VertexFormatInt2,
	VertexFormatInt3,
	VertexFormatInt4,

	VertexFormatUInt,
	VertexFormatUInt2,
	VertexFormatUInt3,
	VertexFormatUInt4,

	VertexFormatInt1010102Normalized,
	VertexFormatUInt1010102Normalized,
};

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

enum StencilOperation {
	StencilOperationKeep,
	StencilOperationZero,
	StencilOperationReplace,
	StencilOperationIncrementClamp,
	StencilOperationDecrementClamp,
	StencilOperationInvert,
	StencilOperationIncrementWrap,
	StencilOperationDecrementWrap
};

enum WindingMode {
	WindingClockwise,
	MTLWindingCounterClockwise
};

}

#endif /* _RP_RENDER_CONSTANTS_H_ */