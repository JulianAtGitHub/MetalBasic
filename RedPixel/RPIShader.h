
#ifndef _RP_I_SHADER_H_
#define _RP_I_SHADER_H_

#include <string>
#include <list>

#include "RPDefines.h"
#include "RPData.h"

namespace RedPixel {

class IShader {
public:
	struct PipelineState {
		StateType state;
		union {
			bool b;
			int n;
		} value;
	};
	
	virtual void Use(void) = 0;

	IShader(std::string vsName, std::string fsName, std::string label = "");
	virtual ~IShader(void);

	inline const std::string & Lable(void) const {return label_;}
	inline const std::string & VSName(void) const {return vertexShaderName_;}
	inline const std::string & FSName(void) const {return fragmentShaderName_;}

protected:
	std::string label_;
	std::string vertexShaderName_;
	std::string fragmentShaderName_;
	std::list<PipelineState> pipelineStates_;
};

}

#endif /* _RP_I_SHADER_H_ */