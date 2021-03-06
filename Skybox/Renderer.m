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
    [MTUDevice sharedInstance].view = view;
    
    _camera = [[MTUCamera alloc] initWithPosition:(MTUPoint3){0.0f, 2.5f, 5.0f}
                                           target:(MTUPoint3){0.0f, 2.5f, 0.0f}
                                               up:(MTUPoint3){0.0f, 1.0f, 0.0f}];
    
    MTUDirectLight light;
    light.inversed_direction = vector_normalize(vector3(1.0f, 1.0f, 1.0f));
    light.ambient_color = vector3(0.25f, 0.25f, 0.25f);
    light.color = vector3(0.75f, 0.75f, 0.75f);
    NSData *lightData = [NSData dataWithBytes:&light length:sizeof(MTUDirectLight)];
    
    MTUObjectParams object;
    object.shiness = 16.0f;
    NSData *objectData = [NSData dataWithBytes:&object length:sizeof(MTUObjectParams)];
    
    MTUMaterialConfig *cyborgConfig = [[MTUMaterialConfig alloc] init];
    cyborgConfig.name = @"cyborg-phong";
    cyborgConfig.vertexShader = @"vertPhong";
    cyborgConfig.fragmentShader = @"fragPhong";
    cyborgConfig.vertexFormat = MTUVertexFormatPTNTB;
    cyborgConfig.transformType = MTUTransformTypeMvpMN;
    cyborgConfig.cameraParamsUsage = MTUCameraParamsForVertexShader;
    cyborgConfig.buffers = @[lightData, objectData];
    cyborgConfig.bufferIndexOfVertexShader = @[@0];
    cyborgConfig.bufferIndexOfFragmentShader = @[@0, @1];
    cyborgConfig.textures = @[@"cyborg_diffuse", @"cyborg_normal", @"cyborg_specular"];
    
    _scene = [[MTUFbxImporter shadedInstance] loadNodeFromFile:@"Models/Cyborg.obj" andConvertToFormat:MTUVertexFormatPTNTB];
    MTUNode *cyborg = [_scene findNodeWithName:@"default"];
    NSArray <MTUMesh *> *meshes = cyborg.meshes;
    [meshes[0] resetMaterialFromConfig:cyborgConfig];
    
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
    
    [device setTargetLayer:[MTULayer layerFromCache:device.default3DLayerName]];
    
    [_scene draw];
    [_skybox draw];
    
    [device targetLayerEnded];
    
    [device presentToView];
}

@end
