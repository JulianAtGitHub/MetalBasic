#ifndef _RP_MT_PIPELINE_H_
#define _RP_MT_PIPELINE_H_

#include "RPDefines.h"
#include "RPIPipeline.h"

namespace RedPixel {

class MTShader;

class MTPipeline : public IPipeline {
public:
	virtual void ApplyState(void);
	
	inline id renderPipelineState(void) const {return renderPipelineState_;}
	inline id depthStencilState(void) const {return depthStencilState_;}

	MTPipeline(const MTShader *shader, std::string &label = DefaultLabel);
	virtual ~MTPipeline(void);

private:
	id renderPipelineState_;
	id depthStencilState_;
};

}

#endif /* _RP_MT_PIPELINE_H_ */