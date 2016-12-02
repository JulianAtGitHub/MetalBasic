#ifndef _RP_I_BUFFER_H_
#define _RP_I_BUFFER_H_

namespace RedPixel {

class IBuffer {
public:
	virtual void * contents(void) = 0;

	IBuffer(size_t size, void *bytes = nullptr) :size_(size) { }
	virtual ~IBuffer(void) { }

protected:
	size_t size_;
}

}

#endif /* _RP_I_BUFFER_H_ */