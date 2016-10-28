//
//  RPView.m
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "RPView.h"

@implementation RPView {

@private
    BOOL _drawPause;
}

- (void)updateLayerSize {
    CGSize newSize = self.bounds.size;
    NSScreen* screen = self.window.screen ?: [NSScreen mainScreen];
    newSize.width *= screen.backingScaleFactor;
    newSize.height *= screen.backingScaleFactor;
    if (self.delegate) {
        [self.delegate reshape:newSize];
    }
}

- (void)display {
    if (_drawPause) {
        return;
    }
    
    if (_updateLayerSizeFlag) {
        [self updateLayerSize];
        _updateLayerSizeFlag = NO;
    }

    if (self.delegate) {
        [self.delegate draw];
    }
}

- (void)viewWillStartLiveResize {
    _drawPause = YES;
}

- (void)viewDidEndLiveResize {
    _drawPause = NO;
    _updateLayerSizeFlag = YES;
}

@end
