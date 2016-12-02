#include "RPIShaderLibrary.h"

namespace RedPixel {

IShaderLibrary * IShaderLibrary::s_shaderLibrary_ = nullptr;

IShaderLibrary * IShaderLibrary::DefaultShaderLibrary(void) {
	return s_shaderLibrary_;
}

void IShaderLibrary::SetDefaultShaderLibrary(IShaderLibrary *library) {
	s_shaderLibrary_ = library;
}

IShaderLibrary::~IShaderLibrary(void) {

}

}