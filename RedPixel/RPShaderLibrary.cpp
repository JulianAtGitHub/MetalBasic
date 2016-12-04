#include <functional>
#include "RPDefines.h"
#include "RPShaderLibrary.h"

namespace RedPixel {

std::hash<std::string> ShaderLibrary::s_stringHash_;
ShaderLibrary * ShaderLibrary::s_shaderLibrary_ = nullptr;

ShaderLibrary * ShaderLibrary::SharedInstance(void) {
	if (s_shaderLibrary_ == nullptr) {
		s_shaderLibrary_ = new ShaderLibrary();
	}
	return s_shaderLibrary_;
}

ShaderLibrary::ShaderLibrary(void) {
	GenerateDefaultShaders();
}

ShaderLibrary::~ShaderLibrary(void) {

}

IShader & ShaderLibrary::GetShaderByLabel(const std::string &label) {
	size_t hash = s_stringHash_(label);
	auto it = Shaders_.find(hash);
	RP_ASSERT(it != Shaders_.end(), label + " shader not found!");
	return *(it->second);
}

}