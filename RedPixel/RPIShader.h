
#ifndef _RP_I_SHADER_H_
#define _RP_I_SHADER_H_

#include <string>
#include <list>

#include "RPDefines.h"
#include "RPData.h"

namespace RedPixel {

class IShader {
public:
	IShader(std::string &vsName, 
			std::string &fsName, 
			std::string &label = DefaultLabel)
	:label_(label)
	,vertexShaderName_(vsName)
	,fragmentShaderName_(fsName) { }
	virtual ~IShader(void) { }

	inline const std::string & Lable(void) const {return label_;}
	inline const std::string & VSName(void) const {return vertexShaderName_;}
	inline const std::string & FSName(void) const {return fragmentShaderName_;}

protected:
	// use to compile and link shader or load from binary
	virtual void Generate(void) = 0;

	std::string label_;
	std::string vertexShaderName_;
	std::string fragmentShaderName_;
};

}

#endif /* _RP_I_SHADER_H_ */