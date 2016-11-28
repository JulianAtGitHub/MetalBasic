
#ifndef _RP_MODEL_LOADER_H_
#define _RP_MODEL_LOADER_H_

#include <string>
#include "RPModel.h"

namespace RedPixel {

class ModelLoader {
public:
	static Model * LoadObjWithFile(const std::string &fileName);
};

}

#endif /* _RP_MODEL_LOADER_H_ */