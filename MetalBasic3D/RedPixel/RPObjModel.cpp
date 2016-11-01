
#include <iostream>
#include <fstream>
#include <sstream>
#include <array>
#include <cstdlib>
#include <cstring>

#include "RPMathType.h"
#include "RPObjModel.h"

namespace RedPixel {

const std::string ObjModel::position_key_ = "v";
const std::string ObjModel::texcoord_key_ = "vt";
const std::string ObjModel::normal_key_ = "vn";
const std::string ObjModel::primitive_key_ = "f";

ObjModel::ObjModel(const std::string &filePath) 
:dataType_(0) {
	if (!ParseModel(filePath)) {
		std::cout << "Parse Model File:" << filePath << " Failed" << std::endl;
	}
}

ObjModel::~ObjModel(void) {

}

bool ObjModel::ParseModel(const std::string &filePath) {
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

		iss.getline(&arr[0], 8, '/');
		if (std::strlen(&arr[0]) > 0){
			int index = std::atoi(&arr[0]) - 1;
			float3 &position = positions[index];
			for (int i = 0; i < 3; ++i) {vertexDatas_.push_back(position.v[i]);}
		}

		iss.getline(&arr[0], 8, '/');
		if (std::strlen(&arr[0]) > 0){
			int index = std::atoi(&arr[0]) - 1;
			float2 &texcoord = texcoords[index];
			for (int i = 0; i < 2; ++i) {vertexDatas_.push_back(texcoord.v[i]);}
		}

		iss.getline(&arr[0], 8, '/');
		if (std::strlen(&arr[0]) > 0){
			int index = std::atoi(&arr[0]) - 1;
			float3 &normal = normals[index];
			for (int i = 0; i < 3; ++i) {vertexDatas_.push_back(normal.v[i]);}
		}
	}

	if (positions.size() > 0) {dataType_ |= VDT_Position;}
	if (texcoords.size() > 0) {dataType_ |= VDT_TexCoord;}
	if (normals.size() > 0) {dataType_ |= VDT_Normal;}

	objFile.close();

	return true;
}

const void * ObjModel::GetVertexData(uint &length) {
	length = vertexDatas_.size() << 2;
	return &(vertexDatas_[0]);
}

const void * ObjModel::GetIndexData(uint &length) {
	length = indexDatas_.size() << 2;
	return &(indexDatas_[0]);
}

}
