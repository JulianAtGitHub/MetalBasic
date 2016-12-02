
#include <iostream>
#include <fstream>
#include <sstream>
#include <array>
#include <cstdlib>
#include <cstring>

#include "RPMathTypes.h"
#include "RPObjLoader.h"

namespace RedPixel {

const std::string ObjLoader::position_key_ = "v";
const std::string ObjLoader::texcoord_key_ = "vt";
const std::string ObjLoader::normal_key_ = "vn";
const std::string ObjLoader::primitive_key_ = "f";

ObjLoader::ObjLoader(const std::string &filePath) 
:dataType_(0) {
	if (!ParseModel(filePath)) {
		std::cout << "Parse Model File:" << filePath << " Failed" << std::endl;
	}
}

ObjLoader::~ObjLoader(void) {

}

bool ObjLoader::ParseModel(const std::string &filePath) {
	std::ifstream objFile(filePath);
	if (!objFile.is_open()) {
		return false;
	}

	vertexDatas_.clear();
	indexDatas_.clear();

	std::vector<float3> positions;
	std::vector<float2> texcoords;
	std::vector<float3> normals;
	std::vector<std::string> primitives;

	std::string strWord;
	float2 attrfloat2;
	float3 attrfloat3;

	while (objFile >> strWord) {
		if (strWord == position_key_) {
			for (int i = 0; i < 3; ++i) {
				objFile >> strWord;
				attrfloat3.v[i] = std::stof(strWord);
			}
			positions.push_back(attrfloat3);

		} else if (strWord == texcoord_key_) {
			for (int i = 0; i < 2; ++i) {
				objFile >> strWord;
				attrfloat2.v[i] = std::stof(strWord);
			}
			texcoords.push_back(attrfloat2);

		} else if (strWord == normal_key_) {
			for (int i = 0; i < 3; ++i) {
				objFile >> strWord;
				attrfloat3.v[i] = std::stof(strWord);
			}
			normals.push_back(attrfloat3);

		} else if (strWord == primitive_key_) {
			for (int i = 0; i < 3; ++i) {
				objFile >> strWord;
				uint index = (uint)primitives.size();
				for (int i = 0; i < index; ++i) {
					if (strWord == primitives[i]) {
						index = i;
						break;
					}
				}
				if (index == primitives.size()) {
					primitives.push_back(strWord);
				}
				indexDatas_.push_back(index);
			}

		} else {
			// TODO:
		}
	}

	std::array<char, 8> arr;
	for ( auto const & strPrimitive : primitives) {
		std::istringstream iss(strPrimitive);
		
		int positionIndex = -1;
		int normalIndex = -1;
		int texcoordIndex = -1;

		iss.getline(arr.data(), 8, '/');
		if (std::strlen(arr.data()) > 0){
			positionIndex = std::atoi(arr.data()) - 1;
		}

		iss.getline(arr.data(), 8, '/');
		if (std::strlen(arr.data()) > 0){
			texcoordIndex = std::atoi(arr.data()) - 1;
		}

		iss.getline(arr.data(), 8, '/');
		if (std::strlen(arr.data()) > 0){
			normalIndex = std::atoi(arr.data()) - 1;
		}
		
		if (positionIndex >= 0) {
			float3 &position = positions[positionIndex];
			for (int i = 0; i < 3; ++i) {vertexDatas_.push_back(position.v[i]);}
		}

		if (normalIndex >= 0) {
			float3 &normal = normals[normalIndex];
			for (int i = 0; i < 3; ++i) {vertexDatas_.push_back(normal.v[i]);}
		}

		if (texcoordIndex >= 0) {
			float2 &texcoord = texcoords[texcoordIndex];
			for (int i = 0; i < 2; ++i) {vertexDatas_.push_back(texcoord.v[i]);}
		}
	}

	if (positions.size() > 0) {dataType_ |= OVDTPosition;}
	if (normals.size() > 0) {dataType_ |= OVDTNormal;}
	if (texcoords.size() > 0) {dataType_ |= OVDTTexCoord;}


	objFile.close();

	return true;
}

void ObjLoader::GetVertexData(Data &data) {
	length = vertexDatas_.size() << 2;
	data.resize(length)
	data.update(vertexDatas_.data(), length)
}

void ObjLoader::GetIndexData(Data &data) {
	length = indexDatas_.size() << 2;
	data.resize(length)
	data.update(indexDatas_.data(), length)
}

}
