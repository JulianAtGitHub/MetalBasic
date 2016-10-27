//
//  RPView.h
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RPSurface.h"

@interface RPView : NSView

@property (nonatomic, readonly) RPSurface *surface;

@property (nonatomic, readwrite) BOOL updateLayerSizeFlag;

- (void)initCommon;

- (void)updateLayerSize;

@end
