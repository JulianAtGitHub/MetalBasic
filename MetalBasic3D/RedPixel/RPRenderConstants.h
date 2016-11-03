
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

enum PixelFormat {
	PixelFormatInvalid,

	/* Normal 8 bit formats */
	
	PixelFormatA8Unorm,
	
	PixelFormatR8Unorm,
	PixelFormatR8Unorm_sRGB,	// Only Available On iOS(8_0)

	PixelFormatR8Snorm,
	PixelFormatR8Uint,
	PixelFormatR8Sint,
	
	/* Normal 16 bit formats */

	PixelFormatR16Unorm,
	PixelFormatR16Snorm,
	PixelFormatR16Uint,
	PixelFormatR16Sint,
	PixelFormatR16Float,

	PixelFormatRG8Unorm,
	PixelFormatRG8Unorm_sRGB,	// Only Available On iOS(8_0)
	PixelFormatRG8Snorm,
	PixelFormatRG8Uint,
	PixelFormatRG8Sint,

	/* Packed 16 bit formats */
	
	PixelFormatB5G6R5Unorm,		// Only Available On iOS(8_0)
	PixelFormatA1BGR5Unorm,		// Only Available On iOS(8_0)
	PixelFormatABGR4Unorm,		// Only Available On iOS(8_0)
	PixelFormatBGR5A1Unorm,		// Only Available On iOS(8_0)

	/* Normal 32 bit formats */

	PixelFormatR32Uint,
	PixelFormatR32Sint,
	PixelFormatR32Float,

	PixelFormatRG16Unorm,
	PixelFormatRG16Snorm,
	PixelFormatRG16Uint,
	PixelFormatRG16Sint,
	PixelFormatRG16Float,

	PixelFormatRGBA8Unorm,
	PixelFormatRGBA8Unorm_sRGB,
	PixelFormatRGBA8Snorm,
	PixelFormatRGBA8Uint,
	PixelFormatRGBA8Sint,

	PixelFormatBGRA8Unorm,
	PixelFormatBGRA8Unorm_sRGB,

	/* Packed 32 bit formats */

	PixelFormatRGB10A2Unorm,
	PixelFormatRGB10A2Uint,

	PixelFormatRG11B10Float,
	PixelFormatRGB9E5Float,

	PixelFormatBGR10_XR,		// Only Available On iOS(10_0)
	PixelFormatBGR10_XR_sRGB,	// Only Available On iOS(10_0)

	/* Normal 64 bit formats */

	PixelFormatRG32Uint,
	PixelFormatRG32Sint,
	PixelFormatRG32Float,

	PixelFormatRGBA16Unorm,
	PixelFormatRGBA16Snorm,
	PixelFormatRGBA16Uint,
	PixelFormatRGBA16Sint,
	PixelFormatRGBA16Float,

	PixelFormatBGRA10_XR,		// Only Available On iOS(10_0)
	PixelFormatBGRA10_XR_sRGB,	// Only Available On iOS(10_0)

	/* Normal 128 bit formats */

	PixelFormatRGBA32Uint,
	PixelFormatRGBA32Sint,
	PixelFormatRGBA32Float,

	/* Compressed formats. */

	/* S3TC/DXT */
	PixelFormatBC1_RGBA,			// Only Available On macOS(10_11)
	PixelFormatBC1_RGBA_sRGB,		// Only Available On macOS(10_11)
	PixelFormatBC2_RGBA,			// Only Available On macOS(10_11)
	PixelFormatBC2_RGBA_sRGB,		// Only Available On macOS(10_11)
	PixelFormatBC3_RGBA,			// Only Available On macOS(10_11)
	PixelFormatBC3_RGBA_sRGB,		// Only Available On macOS(10_11)

	/* RGTC */
	PixelFormatBC4_RUnorm,			// Only Available On macOS(10_11)
	PixelFormatBC4_RSnorm,			// Only Available On macOS(10_11)
	PixelFormatBC5_RGUnorm,			// Only Available On macOS(10_11)
	PixelFormatBC5_RGSnorm,			// Only Available On macOS(10_11)

	/* BPTC */
	PixelFormatBC6H_RGBFloat,		// Only Available On macOS(10_11)
	PixelFormatBC6H_RGBUfloat,		// Only Available On macOS(10_11)
	PixelFormatBC7_RGBAUnorm,		// Only Available On macOS(10_11)
	PixelFormatBC7_RGBAUnorm_sRGB,	// Only Available On macOS(10_11)

	/* PVRTC */
	PixelFormatPVRTC_RGB_2BPP,		// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGB_2BPP_sRGB,	// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGB_4BPP,		// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGB_4BPP_sRGB,	// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGBA_2BPP,		// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGBA_2BPP_sRGB,// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGBA_4BPP,		// Only Available On iOS(8_0)
	PixelFormatPVRTC_RGBA_4BPP_sRGB,// Only Available On iOS(8_0)

	/* ETC2 */
	PixelFormatEAC_R11Unorm,		// Only Available On iOS(8_0)
	PixelFormatEAC_R11Snorm,		// Only Available On iOS(8_0)
	PixelFormatEAC_RG11Unorm,		// Only Available On iOS(8_0)
	PixelFormatEAC_RG11Snorm,		// Only Available On iOS(8_0)
	PixelFormatEAC_RGBA8,			// Only Available On iOS(8_0)
	PixelFormatEAC_RGBA8_sRGB,		// Only Available On iOS(8_0)

	PixelFormatETC2_RGB8,			// Only Available On iOS(8_0)
	PixelFormatETC2_RGB8_sRGB,		// Only Available On iOS(8_0)
	PixelFormatETC2_RGB8A1,			// Only Available On iOS(8_0)
	PixelFormatETC2_RGB8A1_sRGB,	// Only Available On iOS(8_0)

	/* ASTC */
	PixelFormatASTC_4x4_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_5x4_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_5x5_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_6x5_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_6x6_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_8x5_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_8x6_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_8x8_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x5_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x6_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x8_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x10_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_12x10_sRGB,		// Only Available On iOS(8_0)
	PixelFormatASTC_12x12_sRGB,		// Only Available On iOS(8_0)

	PixelFormatASTC_4x4_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_5x4_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_5x5_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_6x5_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_6x6_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_8x5_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_8x6_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_8x8_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x5_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x6_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x8_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_10x10_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_12x10_LDR,		// Only Available On iOS(8_0)
	PixelFormatASTC_12x12_LDR,		// Only Available On iOS(8_0)

	/*!
	 @constant MTLPixelFormatGBGR422
	 @abstract A pixel format where the red and green channels are subsampled horizontally.  Two pixels are stored in 32 bits, with shared red and blue values, and unique green values.
	 @discussion This format is equivelent to YUY2, YUYV, yuvs, or GL_RGB_422_APPLE/GL_UNSIGNED_SHORT_8_8_REV_APPLE.   The component order, from lowest addressed byte to highest, is Y0, Cb, Y1, Cr.  There is no implicit colorspace conversion from YUV to RGB, the shader will receive (Cr, Y, Cb, 1).  422 textures must have a width that is a multiple of 2, and can only be used for 2D non-mipmap textures.  When sampling, ClampToEdge is the only usable wrap mode.
	 */
	PixelFormatGBGR422,

	/*!
	 @constant MTLPixelFormatBGRG422
	 @abstract A pixel format where the red and green channels are subsampled horizontally.  Two pixels are stored in 32 bits, with shared red and blue values, and unique green values.
	 @discussion This format is equivelent to UYVY, 2vuy, or GL_RGB_422_APPLE/GL_UNSIGNED_SHORT_8_8_APPLE. The component order, from lowest addressed byte to highest, is Cb, Y0, Cr, Y1.  There is no implicit colorspace conversion from YUV to RGB, the shader will receive (Cr, Y, Cb, 1).  422 textures must have a width that is a multiple of 2, and can only be used for 2D non-mipmap textures.  When sampling, ClampToEdge is the only usable wrap mode.
	 */
	PixelFormatBGRG422,

	/* Depth */

	PixelFormatDepth32Float,

	/* Stencil */

	PixelFormatStencil8,

	/* Depth Stencil */
	
	PixelFormatDepth24Unorm_Stencil8,	// Only Available On macOS(10_11)
	PixelFormatDepth32Float_Stencil8,	// Only Available On macOS(10_11) iOS(9_0)

	PixelFormatX32_Stencil8,	// Only Available On macOS(10_12) iOS(10_0)
	PixelFormatX24_Stencil8,	// Only Available On macOS(10_12)
};

enum TextureType {
	TextureType1D,
	TextureType1DArray,
	TextureType2D,
	TextureType2DArray,
	TextureType2DMultisample,
	TextureTypeCube,
	TextureTypeCubeArray,	// Only Available On macOS(10_11),
	TextureType3D
};

enum TextureUsage {
	TextureUsageUnknown			= 0x0,
	TextureUsageShaderRead		= 0x1 << 0,
	TextureUsageShaderWrite		= 0x1 << 1,
	TextureUsageRenderTarget	= 0x1 << 2,
};

enum CPUCacheMode {
	CPUCacheModeDefaultCache,
	CPUCacheModeWriteCombined
};

enum StorageMode {
	StorageModeShared,
	StorageModeManaged,		// Only Available On macOS(10_11)
	StorageModePrivate,
	StorageModeMemoryless	// Only Available On iOS(10_0)
};

enum ResourceOptions {
	ResourceCPUCacheModeDefaultCache,
	ResourceCPUCacheModeWriteCombined,

	ResourceStorageModeShared,		// Only Available On macOS(10_11) iOS(9_0)  
	ResourceStorageModeManaged,		// Only Available On macOS(10_11)
	ResourceStorageModePrivate,		// Only Available On macOS(10_11) iOS(9_0) 
	ResourceStorageModeMemoryless,	// Only Available On iOS(10_0)

	ResourceHazardTrackingModeUntracked,	// Only Available On iOS(10_0)
};

enum LoadAction {
	LoadActionDontCare,
	LoadActionLoad,
	LoadActionClear,
};

enum StoreAction {
	StoreActionDontCare,
	StoreActionStore,
	StoreActionMultisampleResolve,
	StoreActionStoreAndMultisampleResolve, // Only Available On macOS(10_12) iOS(10_0)
	StoreActionUnknown // Only Available On macOS(10_12) iOS(10_0)
};

enum MultisampleDepthResolveFilter {
	MultisampleDepthResolveFilterSample0,
	MultisampleDepthResolveFilterMin,
	MultisampleDepthResolveFilterMax,
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

enum ColorWriteMask {
	ColorWriteMaskNone	= 0x0,
	ColorWriteMaskRed	= 0x1 << 3,
	ColorWriteMaskGreen	= 0x1 << 2,
	ColorWriteMaskBlue	= 0x1 << 1,
	ColorWriteMaskAlpha	= 0x1 << 0,
	ColorWriteMaskAll	= 0xf
};

enum BlendOperation {
	BlendOperationAdd,
	BlendOperationSubtract,
	BlendOperationReverseSubtract,
	BlendOperationMin,
	BlendOperationMax
};

enum BlendFactor {
	BlendFactorZero,
	BlendFactorOne,
	BlendFactorSourceColor,
	BlendFactorOneMinusSourceColor,
	BlendFactorSourceAlpha,
	BlendFactorOneMinusSourceAlpha,
	BlendFactorDestinationColor,
	BlendFactorOneMinusDestinationColor,
	BlendFactorDestinationAlpha,
	BlendFactorOneMinusDestinationAlpha,
	BlendFactorSourceAlphaSaturated,
	BlendFactorBlendColor,
	BlendFactorOneMinusBlendColor,
	BlendFactorBlendAlpha,
	BlendFactorOneMinusBlendAlpha
};

enum PrimitiveTopologyClass {
    MTLPrimitiveTopologyClassUnspecified,
    MTLPrimitiveTopologyClassPoint,
    MTLPrimitiveTopologyClassLine,
    MTLPrimitiveTopologyClassTriangle
};

enum TriangleFillMode {
	TriangleFillModeFill,
	TriangleFillModeLines
};

enum VisibilityResultMode {
	VisibilityResultModeDisabled,
	VisibilityResultModeBoolean,
	VisibilityResultModeCounting
};

#endif /* _RP_RENDER_CONSTANTS_H_ */