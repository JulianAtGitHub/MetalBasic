#import <Metal/Metal.h>
#import "Metal/RPMTDefault.h"
#include "RPDefine.h"

static __strong id<MTLDevice> defaultDevice = nil;

id<MTLDevice> DefaultMTLDevice(void) {
	if (defaultDevice == nil) {
		defaultDevice = MTLCreateSystemDefaultDevice();
		RP_ASSERT(defaultDevice, "ERROR: Failed create default metal device");
	}
	return defaultDevice;
}

static __strong id<MTLLibrary> defaultLibrary = nil;

id<MTLLibrary> DefaultMTLLibrary(void) {
	if (defaultLibrary == nil) {
		defaultLibrary = [DefaultMTLDevice() newDefaultLibrary];
		RP_ASSERT(defaultLibrary, "ERROR: Failed load default shader library");
	}
	return defaultLibrary;
}