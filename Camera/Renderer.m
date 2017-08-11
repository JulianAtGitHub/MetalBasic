//
//  Renderer.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <math.h>
#import "Utilities/MetalUtils.h"
#import "Renderer.h"

@interface Renderer () {
    MTUCamera *_camera;
    MTUNode *_scene;
    CGPoint _move;
    CGFloat _scroll;
}

@end

@implementation Renderer

- (void) loadMetal:(MTKView *)view {
    _camera = [[MTUCamera alloc] initWithPosition:(MTUPoint3){0.0f, 3.0f, 0.0f}
                                           target:(MTUPoint3){0.0f, 0.0f, 0.0f}
                                               up:(MTUPoint3){0.0f, 0.0f, 1.0f}];
    
    [MTUDevice sharedInstance].view = view;
    _scene = [[MTUFbxImporter shadedInstance] loadNodeFromFile:@"Models/sphere.obj" andConvertToFormat:MTUVertexFormatPT];
    MTUNode *sphere = [_scene findNodeWithName:@"default"];
    if (sphere) {
        MTUMaterialConfig *materialConfig = [[MTUMaterialConfig alloc] init];
        materialConfig.name = @"BasicColor";
        materialConfig.vertexShader = @"vertBasicColor";
        materialConfig.fragmentShader = @"fragBasicColor";
        materialConfig.vertexFormat = MTUVertexFormatPT;
        materialConfig.transformType = MTUTransformTypeMvp;
        materialConfig.cameraParamsUsage = MTUCameraParamsForVertexShader;
        materialConfig.textures = @[@"metal_image"];
        [sphere.meshes[0] resetMaterialFromConfig:materialConfig];
    }
}

- (float) calculateDistance {
    if (_scroll <= 0) {
        return 1.3 * (1 - powf(1.5, _scroll));
    } else {
        return -_scroll;
    }
}

- (void) onMouseDrag:(NSPoint)delta {
    _move.x += delta.x * 0.5;
    _move.y += delta.y * 0.5;
    MTUNode *sphere = [_scene findNodeWithName:@"default"];
    if (sphere) {
        [sphere rotateTo:(MTUPoint3){radians_from_degrees(_move.y), 0, radians_from_degrees(_move.x)}];
    }
}

- (void) onMouseScroll:(CGFloat)delta {
    _scroll += (delta * 0.01f);
    if (_scroll < -15.0) {
        _scroll = -15.0;
    }
    MTUNode *sphere = [_scene findNodeWithName:@"default"];
    if (sphere) {
        [sphere moveTo:(MTUPoint3){0, [self calculateDistance], 0}];
    }
}

#pragma mark - implementation of MKTViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    if (_scene == nil) {
        return;
    }
    
    MTUDevice *device = [MTUDevice sharedInstance];
    [device startDraw];
    [_camera update];
    [_scene updateWithCamera:_camera];
    [_scene draw];
    [device commit];
}

@end
