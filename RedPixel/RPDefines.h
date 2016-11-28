
#ifndef _RP_DEFINES_H_
#define _RP_DEFINES_H_

#include <cassert>
#include <iostream>

#ifdef __OBJC__
#define OBJC_CLASS(name) @class name
#else
typedef struct objc_object id;
#define OBJC_CLASS(name) typedef struct objc_object name
#endif

#ifdef NDEBUG
#define RP_ASSERT(condition, log) ((void)0)
#else
#define RP_ASSERT(condition, log) ((condition)? : std::cout<<(log)<<std::endl)
#endif


namespace RedPixel {

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