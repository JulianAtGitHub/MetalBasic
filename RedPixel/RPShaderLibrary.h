
#ifndef _RP_SHADER_LIBRARY_H_
#define _RP_SHADER_LIBRARY_H_

#include <map>
#include <string>
#include "RPIShader.h"

namespace RedPixel {

class ShaderLibrary {
public:
	static ShaderLibrary * SharedInstance(void);

	virtual IShader & GetShaderByLabel(const std::string &label);
	virtual ~ShaderLibrary(void);

protected:
	ShaderLibrary(void);
	virtual void GenerateDefaultShaders(void);

	static std::hash<std::string> s_stringHash_;
	static ShaderLibrary * s_shaderLibrary_;
	std::map<size_t, IShader*> Shaders_;
};

}

#endif /* _RP_SHADER_LIBRARY_H_ */