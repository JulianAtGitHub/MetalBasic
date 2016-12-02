#ifndef _RP_MT_SHADER_H_
#define _RP_MT_SHADER_H_

#include "RPDefines.h"
#include "RPIShader.h"

namespace RedPixel {

class MTShader : public IShader {
public:
	virtual void Use(void);

	MTShader(std::string vsName, std::string fsName, std::string label = "");
	virtual ~MTShader(void);

private:
	id shaderOC_;
}

}

#endif /* _RP_MT_SHADER_H_ */