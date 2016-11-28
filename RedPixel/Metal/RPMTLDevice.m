#import <Metal/Metal.h>
#import "RPMTLDevice.h"

static __strong id<MTLDevice> defaultDevice = nil;

id<MTLDevice> DefaultMTLDevice(void) {
	if (defaultDevice == nil) {
		defaultDevice = MTLCreateSystemDefaultDevice();
	}
	return defaultDevice;
}