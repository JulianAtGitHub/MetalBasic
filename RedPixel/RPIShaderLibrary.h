
#ifndef _RP_I_SHADER_LIBRARY_H_
#define _RP_I_SHADER_LIBRARY_H_

#include <map>
#include "RPIShader.h"

namespace RedPixel {

class IShaderLibrary
{
public:
	virtual IShader & GetShaderByLabel(const std::string &label) = 0;
	virtual ~IShaderLibrary(void) { }

protected:
	virtual void GenerateDefaultShaders(void) = 0;
	std::map<std::string, Ishader*> Shaders_;
};

}

#endif /* _RP_I_SHADER_LIBRARY_H_ */