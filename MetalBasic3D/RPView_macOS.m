//
//  RPView_macOS.m
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "RPView_macOS.h"

@implementation RPView_macOS

- (void)initCommon {
    [super initCommon];
    self.wantsLayer = YES;
    self.layer = [RPSurface surface];
}

- (void)updateLayerSize {
    CGSize newSize = self.bounds.size;
    NSScreen* screen = self.window.screen ?: [NSScreen mainScreen];
    newSize.width *= screen.backingScaleFactor;
    newSize.height *= screen.backingScaleFactor;
    [self.surface reshape:newSize];
}

@end
