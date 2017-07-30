//
//  MTUFbxImporter.h
//  MetalSample
//
//  Created by zhuwei on 7/5/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_FBX_IMPORTER_H_
#define _MTU_FBX_IMPORTER_H_

#import <Foundation/Foundation.h>
#import "../MTUTypes.h"

@class MTUNode;

@interface MTUFbxImporter : NSObject

+ (nonnull MTUFbxImporter *) shadedInstance;

- (nullable MTUNode *)loadNodeFromFile:(nonnull NSString *)filename andConvertToFormat:(MTUVertexFormat)format;

@end

#endif /* _MTU_FBX_IMPORTER_H_ */
