
#ifndef _RP_MODEL_H_
#define _RP_MODEL_H_

#include <list>
#include "RPDefines.h"
#include "RPData.h"

namespace RedPixel {

class Model {
public:
	struct VertexElement {
		AttributeType type;
		DataFormat format;

		VertexElement(void)
		:attribute(VertexAttributeInvalid)
		,format(DataFormatInvalid)
		{}
	};

	struct VertexData {
		Data vertices;
		Data indices;
	};

	typedef std::list<VertexElement> VertexFormat;

	inline VertexData & vertexData(void) {return vertexData_;}
	inline VertexFormat & vertexFormat(void) {return vertexFormat_;}

private:
	VertexData vertexData_;
	VertexFormat vertexFormat_;
};

}

#endif /* _RP_MODEL_H_ */