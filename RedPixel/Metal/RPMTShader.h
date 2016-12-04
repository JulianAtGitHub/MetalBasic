#ifndef _RP_MT_SHADER_H_
#define _RP_MT_SHADER_H_

#include "RPDefines.h"
#include "RPIShader.h"

namespace RedPixel {

class MTShader : public IShader {
public:
	MTShader(	std::string &vsName, 
				std::string &fsName, 
				std::string &label = DefaultLabel);
	virtual ~MTShader(void);

	inline id vertexFunction(void) const { return vertexFunction_; }
	inline id fragmentFunction(void) const { return fragmentFunction_; }

private:
	virtual void Generate(void);
	id vertexFunction_;
	id fragmentFunction_;
}

}

#endif /* _RP_MT_SHADER_H_ */