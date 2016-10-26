
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstring>

#include "RPObjModel.h"

const std::string RPObjModel::position_key_ = "v";
const std::string RPObjModel::texcoord_key_ = "vt";
const std::string RPObjModel::normal_key_ = "vn";
const std::string RPObjModel::primitive_key_ = "f";

RPObjModel::RPObjModel(const std::string &filePath) 
:types_(0) {
	if (!ParseModel(filePath)) {
		std::cout << "Parse Model File:" << filePath << " Failed" << std::endl;
	}
}

RPObjModel::~RPObjModel(void) {

}

bool RPObjModel::ParseModel(const std::string &filePath) {
	std::ifstream objFile(filePath);
	if (!objFile.is_open()) {
		return false;
	}

	vertexDatas_.clear();
	indexDatas_.clear();

	std::vector< std::array<float, 3> > positions;
	std::vector< std::array<float, 2> > texcoords;
	std::vector< std::array<float, 3> > normals;
	std::vector< std::string > primitives;

	std::string strWord;
	auto parse_float_n = [&objFile, &strWord] (auto &attributes, int n) {
		std::array<float, n> attribute;
		for (int i = 0; i < n; ++i) {
			objFile >> strWord;
			float f = std::stof(strWord);
			attribute[i] = f;
		}
		attributes.push_back(attribute);
	}

	while (objFile >> strWord) {
		if (strWord == position_key_) {
			parse_float_n(positions, 3);

		} else if (strWord == texcoord_key_) {
			parse_float_n(texcoords, 2);

		} else if (strWord == normal_key_) {
			parse_float_n(normals, 3);

		} else if (strWord == primitive_key_) {
			for (int i = 0; i < 3; ++i) {
				objFile >> strWord;
				int index = primitives.size();
				for (int i = 0; i < index; ++i) {
					if (strWord == primitives[i]) {
						index = i;
						break;
					}
				}
				primitives[index] = strWord;
				indexDatas_.push_back(index);
			}
			

		} else {
			// TODO:
		}
	}

	std::array<char, 8> arr;
	auto parse_primitive_data = [this, &arr] (auto &iss, auto &attrs) {
		iss.getline(&arr[0], 8, '/');
		if (std::strlen(&arr[0]) > 0){
			int index = std::atoi(&arr[0]);
			for (float f : attrs[index]) {
				vertexDatas_.push_back(f);
			}
		}
	}

	for ( auto const & strPrimitive : primitives) {
		
		std::istringstream iss(strPrimitive);
		parse_primitive_data(iss, positions);
		parse_primitive_data(iss, texcoords);
		parse_primitive_data(iss, normals)
	}

	objFile.close()
	return true;
}
