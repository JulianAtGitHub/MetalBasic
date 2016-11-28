
#include "RPObjLoader.h"
#include "RPModelLoader.h"

namespace RedPixel {

Model * ModelLoader::LoadObjWithFile(const std::string &fileName) {
	if (fileName.empty()) {
		return nullptr;
	}

	ObjLoader obj(fileName);
	Model *model = new Model();

	obj.GetVertexData(model->vertexData().vertices);
	obj.GetIndexData(model->vertexData().indices);
	
	Model::VertexElement element;
	Model::VertexFormat &format = model->vertexFormat();
	if (obj.hasPositionData()) {
		element.type = AttributeTypePosition;
		element.format = DataFormatFloat3;
		format.push_back(element);
	}
	if (obj.hasTexcoordData()) {
		element.type = AttributeTypeTexCoord;
		element.format = DataFormatFloat2;
		format.push_back(element);
	}
	if (obj.hasNormalData()) {
		element.type = AttributeTypeNormal;
		element.format = DataFormatFloat3;
		format.push_back(element);
	}

	return model;
}

}