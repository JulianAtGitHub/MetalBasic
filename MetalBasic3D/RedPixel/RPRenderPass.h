
#ifndef _RP_RENDER_PASS_H_
#define _RP_RENDER_PASS_H_

#include "RPMathType.h"

namespace RedPixel {

class RenderPass
{
public:
	float4 blendColor_;

	RenderPass();
	~RenderPass();
};

}

#endif /* _RP_RENDER_PASS_H_ */