
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

void IShader::UpdateConstant(std::string &name, void *data, uint size) {
	for (auto &v : constants_) {
		if(v.name == constant.name) {
			v.data.update(data, size);
			break;
		}
	}
}

void IShader::AddVertexAttribute(VertexAttribute &attribute) {
	for (auto &v : vertexAttributes_) {
		RP_ASSERT(v.name != attribute.name, 
			label + ": add duplicate attribute " + attribute.name);
	}

	vertexAttributes_.push_back(attribute);
}

void IShader::AddConstant(Constant &constant) {
	for (auto &v : constants_) {
		RP_ASSERT(v.name != constant.name, 
			label + ": add duplicate constant " + constant.name);
	}
	
	constants_.push_back(constant);
}

}