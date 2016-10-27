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

- (RPSurface *) surface {
    return (RPSurface *)self.layer;
}

- (void)initCommon {
    _drawPause = NO;
    _updateLayerSizeFlag = NO;
}

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if(self = [super initWithCoder:coder]) {
        [self initCommon];
    }
    return self;
}

- (void)updateLayerSize {
    
}

- (void)display {
    if (_drawPause) {
        return;
    }
    
    if (_updateLayerSizeFlag) {
        [self updateLayerSize];
        _updateLayerSizeFlag = NO;
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
