#ifndef _RP_MT_SHADER_LIBRARY_H_
#define _RP_MT_SHADER_LIBRARY_H_

#include "RPDefines.h"
#include "RPIShaderLibrary.h"

namespace RedPixel {

class MTShaderLibrary : public IShaderLibrary {
public:
	virtual IShader & GetShaderByLabel(const std::string &label);
	inline id ShaderLibraryOC(void) {return shaderLibraryOC_;}

	void MTShaderLibrary(void);
	virtual ~MTShaderLibrary(void);

protected:
	virtual void GenerateDefaultShaders(void);

private:
	id shaderLibraryOC_;
};

}

#endif /* _RP_MT_SHADER_LIBRARY_H_ */