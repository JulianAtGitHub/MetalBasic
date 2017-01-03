#import <Metal/Metal.h>
#import "Metal/RPMTDefault.h"
#include "RPMTPipeline.h"

namespace RedPixel {

MTPipeline::MTPipeline(const MTShader *shader, std::string &label) 
:IShader(shader, label) {
	renderPipelineState_ = nil;
	depthStencilState_ = nil;
}

MTPipeline::~MTPipeline(void) {
	renderPipelineState_ = nil;
	depthStencilState_ = nil;
}

void MTPipeline::ApplyState(void) {
	MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];

	const MTShader *shader = (const MTShader *)shader_;
}

}