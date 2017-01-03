#import <Metal/Metal.h>
#import "Metal/RPMTDefault.h"
#include "Metal/RPMTShader.h"

namespace RedPixel {

MTShader::MTShader(	std::string &vsName, 
					std::string &fsName, 
					std::string &label)
:IShader(vsName, fsName, label) {
	Generate();
}

MTShader::~MTShader(void) {
	vertexFunction_ = nil;
	fragmentFunction_ = nil;
}

void MTShader::Generate(void) {
	id<MTLLibrary> library = DefaultMTLLibrary()
	vertexFunction_ = [library newFunctionWithName:vertexShaderName_];
	fragmentFunction_ = [library newFunctionWithName:fragmentShaderName_];
	RP_ASSERT(vertexFunction_, "ERROR: create vertex function failed!");
	RP_ASSERT(fragmentFunction_, "ERROR: create fragment function failed!");
}

}
