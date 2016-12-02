#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include "Metal/RPMTShader.h"
#include "Metal/RPMTShaderLibrary.h"

@interface MTShaderOC : NSObject

@property (nonatomic) id<MTLFunction> vertexFunction;
@property (nonatomic) id<MTLFunction> fragmentFunction;

- (id) initWithVSName:(NSString *)vsName andFSName:(NSString *)fsName;

@end

@implementation MTShaderOC

- (id) initWithVSName:(NSString *)vsName andFSName:(NSString *)fsName {
	if (self = [super init]) {
		MTShaderLibrary *shaderLibrary = dynamic_cast<MTShaderLibrary *>(IShaderLibrary::DefaultShaderLibrary());
		RP_ASSERT(shaderLibrary, "ERROR: default shader library is nil!");
		id<MTLLibrary> library = [shaderLibrary->ShaderLibraryOC() mtlLibrary];
		vertexFunction_ = [library newFunctionWithName:vsName];
		fragmentFunction_ = [library newFunctionWithName:fsName];
		RP_ASSERT(vertexFunction_, "ERROR: create vertex shader function");
		RP_ASSERT(fragmentFunction_, "ERROR: create fragment shader function");
	}
	return self;
}

@end

namespace RedPixel {

MTShader::MTShader(std::string vsName, std::string fsName, std::string label)
:IShader(vsName, fsName, label) {
	shaderOC_ = [[MTShaderOC alloc] initWithVSName:[NSString stringWithUTF8String:vertexShaderName_.c_str()]
									andFSName:[NSString stringWithUTF8String:fragmentShaderName_.c_str()]];
	
}

MTShader::~MTShader(void) {
	shaderOC_ = nil;
}

void MTShader::Use(void) {
	
}

}
