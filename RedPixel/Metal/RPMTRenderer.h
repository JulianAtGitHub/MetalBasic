#ifndef _RP_MT_RENDERER_H_
#define _RP_MT_RENDERER_H_

#include "RPDefines.h"
#include "RPIRenderer.h"

namespace RedPixel {

class RPMTRenderer {
public:
	virtual void Draw(void);
	virtual ~RPMTRenderer(void);
};

}

#endif /* _RP_MT_RENDERER_H_ */