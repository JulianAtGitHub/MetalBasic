
#ifndef _RP_OBJ_MODEL_H_
#define _RP_OBJ_MODEL_H_

#include <string>
#include <vector>

#include "RPIModel.h"

namespace RedPixel {

class ObjModel : public IModel {

	enum VertexDataType {
		VDT_Position 	= 0x01,
		VDT_TexCoord 	= 0x10,
		VDT_Normal 		= 0x100
	};

	const static std::string position_key_;
	const static std::string texcoord_key_;
	const static std::string normal_key_;
	const static std::string primitive_key_;

public:
	ObjModel(const std::string &filePath);
	~ObjModel(void);

	inline uint GetDataType(void) {return dataType_;}
	virtual const void * GetVertexData(uint &length);
	virtual const void * GetIndexData(uint &length);

protected:
	bool ParseModel(const std::string &filePath);

private:
	uint dataType_;
	std::vector<float> vertexDatas_;
	std::vector<uint> indexDatas_;
};

}

#endif /* _RP_OBJ_MODEL_H_ */
