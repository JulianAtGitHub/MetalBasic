
#ifndef _RP_OBJ_LOADER_H_
#define _RP_OBJ_LOADER_H_

#include <string>
#include <vector>

#include "RPData.h"

namespace RedPixel {

class ObjLoader {

	enum ObjVertexDataType {
		OVDTPosition 	= 0x1 << 0,
		OVDTTexCoord 	= 0x1 << 1,
		OVDTNormal 		= 0x1 << 2
	};

	const static std::string position_key_;
	const static std::string texcoord_key_;
	const static std::string normal_key_;
	const static std::string primitive_key_;

public:
	ObjLoader(const std::string &filePath);
	virtual ~ObjLoader(void);

	void GetVertexData(Data &data);
	void GetIndexData(Data &data);

	inline bool hasPositionData(void) {return (dataType_ & OVDTPosition);}
	inline bool hasTexcoordData(void) {return (dataType_ & OVDTTexCoord);}
	inline bool hasNormalData(void) {return (dataType_ & OVDTNormal);}

protected:
	bool ParseModel(const std::string &filePath);

private:
	uint dataType_;
	std::vector<float> vertexDatas_;
	std::vector<uint> indexDatas_;
};

}

#endif /* _RP_OBJ_LOADER_H_ */
