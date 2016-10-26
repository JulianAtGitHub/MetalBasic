
#ifndef _RP_OBJ_MODEL_H_
#define _RP_OBJ_MODEL_H_

#include <string>
#include <vector>

class RPObjModel {

	enum VertexDataType {
		Position 	= 0x01,
		TexCoord 	= 0x10,
		Normal 		= 0x100
	};

	const static std::string position_key_;
	const static std::string texcoord_key_;
	const static std::string normal_key_;
	const static std::string primitive_key_;

public:
	RPObjModel(const std::string &filePath);
	~RPObjModel(void);

protected:
	bool ParseModel(const std::string &filePath);
	inline const std::vertor<float>& GetVertexData(void) {return vertexDatas_;}
	inline const std::vertor<int>& GetIndexData(void) {return indexDatas_;}

private:
	unsigned int types_;
	std::vertor<float> vertexDatas_;
	std::vector<int> indexDatas_;
};

#endif /* _RP_OBJ_MODEL_H_ */