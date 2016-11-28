
#include <cstring>
#include "RPDefines.h"
#include "RPData.h"

namespace RedPixel {

void Data::update(const void *source, uint size) {
	RP_ASSERT((source && size() >= size), "Update Data With Invalid Source!");
	char *dest = data();
	std::memcpy(dest, source, size);
}

}