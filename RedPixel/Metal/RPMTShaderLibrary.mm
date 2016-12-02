#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include "Metal/RPMTDevice.h"
#include "Metal/RPMTShaderLibrary.h"

@interface MTShaderLibraryOC : NSObject

@property (nonatomic, readonly) id<MTLLibrary> mtlLibrary;

@end

@implementation MTShaderLibraryOC

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

MTShaderLibrary::MTShaderLibrary(void) {
	shaderLibraryOC_ = [[MTShaderLibraryOC alloc] init];
}

MTShaderLibrary::~MTShaderLibrary(void) {
	shaderLibraryOC_ = nil;
}

void MTShaderLibrary::GenerateDefaultShaders(void) {
	
}

}