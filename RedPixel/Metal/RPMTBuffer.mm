#import <Metal/Metal.h>
#import "Metal/RPMTDefault.h"
#include "Metal/RPMTBuffer.h"

namespace RedPixel {

MTBuffer(size_t size, void *bytes) 
:IBuffer(size) {
	if (bytes == nullptr) {
		bufferOC_ = [DefaultMTLDevice() newBufferWithLength:size options:0];
	} else {
		bufferOC_ = [DefaultMTLDevice() newBufferWithBytes:bytes length:size options:0];
	}
}

MTBuffer::~MTBuffer(void) {
	bufferOC_ = nil;
}

void * MTBuffer::contents(void) {
	return [bufferOC_ contents];
}

}