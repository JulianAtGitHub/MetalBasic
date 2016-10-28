//
//  RPView.h
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//


#import <AppKit/AppKit.h>

@protocol RPViewDelegate;

@interface RPView : NSView

@property (nonatomic, weak) id <RPViewDelegate> delegate;

@property (nonatomic, readwrite) BOOL updateLayerSizeFlag;

- (void)updateLayerSize;

@end

@protocol RPViewDelegate <NSObject>

@required
- (void)reshape:(CGSize)size;
- (void)draw;

@end
