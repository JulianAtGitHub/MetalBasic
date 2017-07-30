//
//  ViewController.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import <MetalKit/MetalKit.h>
#import "ViewController.h"
#import "Renderer.h"

@implementation ViewController {
    MTKView *_mtkView;
    Renderer *_renderer;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    _mtkView = (MTKView *)self.view;
    _mtkView.device = MTLCreateSystemDefaultDevice();
    
    if (!_mtkView.device) {
        NSLog(@"Metal is not support on this device!");
        self.view = [[NSView alloc] initWithFrame:self.view.frame];
        return;
    }
    
    _renderer = [[Renderer alloc] initWithMTKView:_mtkView];
    if(!_renderer) {
        NSLog(@"Renderer failed initialization");
        return;
    }
    [_renderer mtkView:_mtkView drawableSizeWillChange:_mtkView.drawableSize];
    
    _mtkView.delegate = _renderer;
    _mtkView.preferredFramesPerSecond = 60;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)mouseDown:(NSEvent *)theEvent {
    BOOL keepOn = YES;
    NSPoint delta;
    NSPoint mouseLoc;
    NSPoint lastMouseLoc = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
    NSWindow *window = [[NSApplication sharedApplication] mainWindow];
    
    while (keepOn) {
        theEvent = [window nextEventMatchingMask: NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
        mouseLoc = [self.view convertPoint:[theEvent locationInWindow] fromView:nil];
        
        switch ([theEvent type]) {
            case NSEventTypeLeftMouseDragged:
                delta = CGPointMake(mouseLoc.x - lastMouseLoc.x, mouseLoc.y - lastMouseLoc.y);
                [_renderer onMouseDrag:delta];
                lastMouseLoc = mouseLoc;
                break;
            case NSEventTypeLeftMouseUp:
                keepOn = NO;
                break;
            default:
                /* Ignore any other kind of event. */
                break;
        }
        
    };
    
    return;
}

- (void)scrollWheel:(NSEvent *)event {
    CGFloat scroll = [event scrollingDeltaY];
    [_renderer onMouseScroll:scroll];
}

@end
