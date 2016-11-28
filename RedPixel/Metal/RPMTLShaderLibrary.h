#ifndef _RP_MTL_SHADER_LIBRARY_H_
#define _RP_MTL_SHADER_LIBRARY_H_

#include "RPDefines.h"
#include "RPIShaderLibrary.h"

namespace RedPixel {

class MTLShaderLibrary : public IShaderLibrary {
public:
	virtual IShader & GetShaderByLabel(const std::string &label);

	void MTLShaderLibrary(void);
	virtual ~MTLShaderLibrary(void);

protected:
	virtual void GenerateDefaultShaders(void);

private:
	id shaderLibraryOC_;
};

}

#endif /* _RP_MTL_SHADER_LIBRARY_H_ */