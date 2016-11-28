
#ifndef _RP_I_RENDERER_H_
#define _RP_I_RENDERER_H_

namespace RedPixel {

class IRenderer {
public
	virtual void Draw(void) = 0;
	virtual ~IRenderer(void) { }
};

}

#endif /* _RP_I_RENDERER_H_ */