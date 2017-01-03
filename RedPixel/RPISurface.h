#ifndef _RP_I_SURFACE_H_
#define _RP_I_SURFACE_H_

#include "RPMath.h"

namespace RedPixel {

class ISurface {
public:
	struct Descriptor {
		float4 clearColor_;
		double clearDepth_;
		uint clearStencil_;
		uint sampleCount_;
		uint colorPixelFormat_;
		uint depthStencilPixelFormat_;
	};

	ISurface(const Descriptor &descriptor) {descriptor_ = descriptor;}
	virtual ~ISurface(void) { }

	inline const Descriptor & Descriptor(void) const {return descriptor_;}

protected:
	virtual void Generate(void) = 0;

	Descriptor descriptor_;
};

}

#endif /* _RP_I_SURFACE_H_ */