
#ifndef _RP_DATA_H_
#define _RP_DATA_H_

#include <vector>

namespace RedPixel {

class Data : public std::vector<char> {
public:
	void update(const void *source, uint size);
};

}

#endif /* _RP_DATA_H_ */