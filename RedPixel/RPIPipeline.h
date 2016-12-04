#ifndef _RP_I_PIPELINE_H_
#define _RP_I_PIPELINE_H_

#include <list>
#include <string>
#include "RPDefines.h"

namespace RedPixel {

class IShader;

class IPipeline {
public:
	struct PipelineState {
		StateType state;
		union {
			bool b;
			uint u;
		} value;
	};

	inline const std::string & Lable(void) const {return label_;}
	inline void AddState(PipelineState &s) {pipelineStates_.push_back(s);}
	
	virtual void ApplyState(void) = 0;

	IPipeline(const IShader *shader, std::string &label = DefaultLabel) 
	:shader_(shader) { }
	virtual ~IPipeline(void) { }

protected:
	std::string label_;
	std::list<PipelineState> pipelineStates_;
	const IShader * shader_;
};

}

#endif /* _RP_I_PIPELINE_H_ */