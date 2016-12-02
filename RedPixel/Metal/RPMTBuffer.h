#ifndef _RP_MT_BUFFER_H_
#define _RP_MT_BUFFER_H_

#include "RPDefines.h"
#include "RPIBuffer.h"

namespace RedPixel {

class MTBuffer : public IBuffer {
public:
	virtual void * contents(void);

	MTBuffer(size_t size, void *bytes = nullptr);
	virtual ~MTBuffer(void);
	
private:
	id bufferOC_;
}

}

#endif /* _RP_MT_BUFFER_H_ */