
#include "RPDefines.h"
#include "RPIShader.h"

namespace RedPixel {

IShader::IShader(std::string vsName, std::string fsName, std::string label) 
:label_(label)
,vertexShaderName_(vsName)
,fragmentShaderName_(fsName) {

}

IShader::~IShader(void) {

}

}