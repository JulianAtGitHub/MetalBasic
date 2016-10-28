//
//  RPViewController.h
//  MetalBasic3D
//
//  Created by Zhu, Wei on 28/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#ifdef TARGET_IOS
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

@protocol RPViewControllerDelegate;

#ifdef TARGET_IOS
@interface RPViewController : UIViewController
#else
@interface RPViewController : NSViewController
#endif

@property (nonatomic, weak) id <RPViewControllerDelegate> delegate;

// the time interval from the last draw
@property (nonatomic, readonly) NSTimeInterval timeSinceLastDraw;

// What vsync refresh interval to fire at. (Sets CADisplayLink frameinterval property)
// set to 1 by default, which is the CADisplayLink default setting (60 FPS).
// Setting to 2, will cause gameloop to trigger every other vsync (throttling to 30 FPS)
@property (nonatomic) NSUInteger interval;

// Used to pause and resume the controller.
@property (nonatomic, getter=isPaused) BOOL paused;

// use invalidates the main game loop. when the app is set to terminate
- (void)stopGameLoop;

@end

// required view controller delegate functions.
@protocol RPViewControllerDelegate <NSObject>
@required

// Note this method is called from the thread the main game loop is run
- (void)update:(NSTimeInterval)deltaTime;

// called whenever the main game loop is paused, such as when the app is backgrounded
- (void)viewController:(RPViewController *)controller willPause:(BOOL)pause;
@end
