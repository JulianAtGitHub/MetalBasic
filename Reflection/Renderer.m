//
//  Renderer.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <math.h>
#import "MetalUtils.h"
#import "Renderer.h"

@interface Renderer () {
    MTUCamera *_camera;
    MTUNode *_scene;
    MTUSkybox *_skybox;
    CGPoint _move;
    CGFloat _scroll;
}

@end

@implementation Renderer

- (void) loadMetal:(MTKView *)view {
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    
    _camera = [[MTUCamera alloc] initWithPosition:(MTUPoint3){0.0f, 2.5f, 5.0f}
                                           target:(MTUPoint3){0.0f, 2.5f, 0.0f}
                                               up:(MTUPoint3){0.0f, 1.0f, 0.0f}];
    
    [MTUDevice sharedInstance].view = view;
  
    MTUMaterialConfig *cyborgConfig = [[MTUMaterialConfig alloc] init];
    cyborgConfig.name = @"cyborg-reflect";
    cyborgConfig.vertexShader = @"vertBasicReflection";
    cyborgConfig.fragmentShader = @"fragBasicReflection";
    cyborgConfig.transformType = MTUTransformTypeMvpMN;
    cyborgConfig.cameraParamsUsage = MTUCameraParamsForFragmentShader;
    cyborgConfig.textures = @[@"skybox_baseColor"];
    MTUMaterial *cyborgMaterial = [[MTUMaterial alloc] initWithConfig:cyborgConfig];
    
    _scene = [[MTUFbxImporter shadedInstance] loadNodeFromFile:@"Models/Cyborg.obj" andConvertToFormat:MTUVertexFormatPTN];
    MTUNode *cyborg = [_scene findNodeWithName:@"default"];
    NSArray <MTUMesh *> *meshes = cyborg.meshes;
    meshes[0].material = cyborgMaterial;
    
    _skybox = [[MTUSkybox alloc] initWithTextureAsset:@"skybox_baseColor"];
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
        [sphere rotateTo:(MTUPoint3){0, radians_from_degrees(_move.x), 0}];
    }
}

- (void) onRightMouseDrag:(NSPoint)delta {
    [_camera rotateXZOnTarget:radians_from_degrees(delta.x * 0.5)];
}

- (void) onMouseScroll:(CGFloat)delta {
    _scroll += (delta * 0.01f);
    if (_scroll < -15.0) {
        _scroll = -15.0;
    }
    MTUNode *sphere = [_scene findNodeWithName:@"default"];
    if (sphere) {
        [sphere moveTo:(MTUPoint3){0, 0, [self calculateDistance]}];
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
    [_skybox updateWithCamera:_camera];
    
    [_scene draw];
    [_skybox draw];
    
    [device commit];
}

@end
