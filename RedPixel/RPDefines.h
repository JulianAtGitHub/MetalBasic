
#ifndef _RP_DEFINES_H_
#define _RP_DEFINES_H_

#include <cassert>
#include <iostream>
#include <string>

#ifdef __OBJC__
#define OBJC_CLASS(name) @class name
#else
typedef void *id;
#define OBJC_CLASS(name) typedef struct objc_object name
OBJC_CLASS(NSObject);
#endif

#ifdef NDEBUG
#define RP_ASSERT(b, err) ((void)0)
#else
#define RP_ASSERT(b, err) ((b)? : std::cout<<(err)<<std::endl, assert(0))
#endif


namespace RedPixel {

	std::string DefaultLabel("unknow");

	enum DataFormat {
		DataFormatInvalid	= 0,

		DataFormatFloat		= 1,
		DataFormatFloat2	= 2,
		DataFormatFloat3	= 3,
		DataFormatFloat4	= 4,

		DataFormatFloat2x2	= 51,
		DataFormatFloat3x3	= 52,
		DataFormatFloat4x4	= 53,
	};

	enum AttributeType {
		AttributeTypeInvalid	= 0,

		AttributeTypePosition	= 1,
		AttributeTypeNormal		= 2,
		AttributeTypeColor		= 3,
		AttributeTypeTexCoord	= 4,
	};

	enum StateType {
		StateTypeUnknow		= 0,
	};
}


#endif /* _RP_DEFINES_H_ */