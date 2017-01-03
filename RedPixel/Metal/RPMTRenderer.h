#ifndef _RP_MT_RENDERER_H_
#define _RP_MT_RENDERER_H_

#include "RPDefines.h"
#include "RPIRenderer.h"

namespace RedPixel {

class MTRenderer : public IRenderer {
public:
	virtual void Draw(void);

	MTRenderer(void);
	virtual ~MTRenderer(void);
};

}

#endif /* _RP_MT_RENDERER_H_ */