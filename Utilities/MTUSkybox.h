//
//  MTUSkybox.h
//  MetalSample
//
//  Created by zhuwei on 8/1/17.
//  Copyright © 2017 julian. All rights reserved.
//

#ifndef _MTU_SKYBOX_H_
#define _MTU_SKYBOX_H_

#import "MTUNode.h"

@interface MTUSkybox : MTUNode

- (nonnull instancetype) initWithTextureAsset:(nonnull NSString *)assetName;

@end

#endif /* _MTU_SKYBOX_H_ */
