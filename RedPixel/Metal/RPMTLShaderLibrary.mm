#import <Metal/Metal.h>
#include "RPMTLDevice.h"
#include "RPMTLShaderLibrary.h"

@interface MTLShaderLibraryOC : NSObject

@property (nonatomic, readonly) id<MTLLibrary> mtlLibrary;

@end

@implementation MTLShaderLibraryOC

- (id<MTLLibrary>) mtlLibrary {
	if (mtlLibrary_ == nil) {
		id<MTLDevice> device = DefaultMTLDevice();
		mtlLibrary_ = [device newDefaultLibrary];
		RP_ASSERT(mtlLibrary_, "ERROR: Can not create default shader library");
	}
	return mtlLibrary_;
}

@end

namespace RedPixel {

MTLShaderLibrary::MTLShaderLibrary(void) {
	shaderLibraryOC_ = [[MTLShaderLibraryOC alloc] init];
}

MTLShaderLibrary::~MTLShaderLibrary(void) {
	shaderLibraryOC_ = nil;
}

void MTLShaderLibrary::GenerateDefaultShaders(void) {
	
}

}