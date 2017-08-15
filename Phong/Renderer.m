//
//  Renderer.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

//static const vector_float3 light_direction = {1.0, -0.15, -0.176};
//static const vector_float3 light_intensity = {0.05, 0.6, 0.35};
//static const float object_shiness = 32;

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
    [MTUDevice sharedInstance].view = view;
    
    _camera = [[MTUCamera alloc] initWithPosition:(MTUPoint3){0.0f, 3.0f, 0.0f}
                                           target:(MTUPoint3){0.0f, 0.0f, 0.0f}
                                               up:(MTUPoint3){0.0f, 0.0f, 1.0f}];
    
    _scene = [[MTUFbxImporter shadedInstance] loadNodeFromFile:@"Models/sphere.obj" andConvertToFormat:MTUVertexFormatPTN];
    MTUNode *sphere = [_scene findNodeWithName:@"default"];
    if (sphere) {
        MTUGlobalLight light;
        light.direction = vector_normalize(vector3(-1.0f, -0.1f, -0.176f));
        light.intensity = vector3(0.05f, 0.6f, 0.35f);
        NSData *lightData = [NSData dataWithBytes:&light length:sizeof(MTUGlobalLight)];
        
        MTUObjectParams object;
        object.shiness = 32.0f;
        NSData *objectData = [NSData dataWithBytes:&object length:sizeof(MTUObjectParams)];
        
        MTUMaterialConfig *materialConfig = [[MTUMaterialConfig alloc] init];
        materialConfig.name = @"Phong-Diffuse";
        materialConfig.vertexShader = @"vertPhongDiffuse";
        materialConfig.fragmentShader = @"fragPhongDiffuse";
        materialConfig.vertexFormat = MTUVertexFormatPTN;
        materialConfig.transformType = MTUTransformTypeMvpMN;
        materialConfig.cameraParamsUsage = MTUCameraParamsForVertexShader;
        materialConfig.buffers = @[lightData, objectData];
        materialConfig.bufferIndexOfVertexShader = @[@0];
        materialConfig.bufferIndexOfFragmentShader = @[@0, @1];
        materialConfig.textures = @[@"earth_day"];
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
    [device setTargetLayer:[MTULayer layerFromCache:device.default3DLayerName]];
    [_scene draw];
    [device targetLayerEnded];
    [device presentToView];
}

@end
