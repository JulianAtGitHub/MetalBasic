
#ifndef _RP_MODEL_H_
#define _RP_MODEL_H_

class RPModel {
public:
	virtual const void * GetVertexData(uint &length) = 0;
	virtual const void * GetIndexData(uint &length) = 0;
};

#endif /* _RP_MODEL_H_ */