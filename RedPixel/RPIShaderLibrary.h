
#ifndef _RP_I_SHADER_LIBRARY_H_
#define _RP_I_SHADER_LIBRARY_H_

#include <map>
#include "RPIShader.h"

namespace RedPixel {

class IShaderLibrary
{
	static IShaderLibrary * s_shaderLibrary_;
public:
	static IShaderLibrary * DefaultShaderLibrary(void);
	static void SetDefaultShaderLibrary(IShaderLibrary *library);

	virtual IShader & GetShaderByLabel(const std::string &label) = 0;
	virtual ~IShaderLibrary(void);

protected:
	virtual void GenerateDefaultShaders(void) = 0;
	std::map<std::string, Ishader*> Shaders_;
};

}

#endif /* _RP_I_SHADER_LIBRARY_H_ */