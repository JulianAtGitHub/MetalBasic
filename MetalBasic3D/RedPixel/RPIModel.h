
#ifndef _RP_IMODEL_H_
#define _RP_IMODEL_H_

namespace RedPixel {

class IModel {
public:
	virtual const void * GetVertexData(uint &length) = 0;
	virtual const void * GetIndexData(uint &length) = 0;
};

}

#endif /* _RP_IMODEL_H_ */