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
    [MTUDevice sharedInstance].view = view;
    
    _camera = [[MTUCamera alloc] initWithPosition:(MTUPoint3){0.0f, 300.0f, 800.0f}
                                           target:(MTUPoint3){0.0f, 300.0f, 0.0f}
                                               up:(MTUPoint3){0.0f, 1.0f, 0.0f}];
    
    MTUDirectLight light;
    light.inversed_direction = vector_normalize(vector3(1.0f, 1.0f, 1.0f));
    light.ambient_color = vector3(0.2f, 0.2f, 0.2f);
    light.color = vector3(0.75f, 0.75f, 0.75f);
    NSData *lightData = [NSData dataWithBytes:&light length:sizeof(MTUDirectLight)];
    
    MTUObjectParams object;
    object.shiness = 4.0f;
    NSData *objectData = [NSData dataWithBytes:&object length:sizeof(MTUObjectParams)];
    
    MTUMaterialConfig *structureConfig = [[MTUMaterialConfig alloc] init];
    structureConfig.name = @"structure-phong";
    structureConfig.vertexShader = @"vertPhong";
    structureConfig.fragmentShader = @"fragPhong";
    structureConfig.cullMode = MTLCullModeBack;
    structureConfig.winding = MTLWindingCounterClockwise;
    structureConfig.vertexFormat = MTUVertexFormatPTNTB;
    structureConfig.transformType = MTUTransformTypeMvpMN;
    structureConfig.cameraParamsUsage = MTUCameraParamsForVertexShader;
    structureConfig.buffers = @[lightData, objectData];
    structureConfig.bufferIndexOfVertexShader = @[@0];
    structureConfig.bufferIndexOfFragmentShader = @[@0, @1];
    structureConfig.textures = @[@"structure_baseColor", @"structure_normal", @"structure_specular"];
    
    MTUMaterialConfig *foliageConfig = [[MTUMaterialConfig alloc] init];
    foliageConfig.name = @"foliage-phong";
    foliageConfig.vertexShader = @"vertPhong";
    foliageConfig.fragmentShader = @"fragPhong";
    foliageConfig.cullMode = MTLCullModeBack;
    foliageConfig.winding = MTLWindingCounterClockwise;
    foliageConfig.vertexFormat = MTUVertexFormatPTNTB;
    foliageConfig.transformType = MTUTransformTypeMvpMN;
    foliageConfig.cameraParamsUsage = MTUCameraParamsForVertexShader;
    foliageConfig.buffers = @[lightData, objectData];
    foliageConfig.bufferIndexOfVertexShader = @[@0];
    foliageConfig.bufferIndexOfFragmentShader = @[@0, @1];
    foliageConfig.textures = @[@"foliage_baseColor", @"foliage_normal", @"foliage_specular"];
    
    _scene = [[MTUFbxImporter shadedInstance] loadNodeFromFile:@"Models/Temple.dae" andConvertToFormat:MTUVertexFormatPTNTB];
    MTUNode *cageStairs = [_scene findNodeWithName:@"cage_stairs_01_001"];
    NSArray <MTUMesh *> *meshes = cageStairs.meshes;
    [meshes[0] resetMaterialFromConfig:structureConfig];
    [meshes[1] resetMaterialFromConfig:foliageConfig];
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
    MTUNode *cageStairs = [_scene findNodeWithName:@"cage_stairs_01_001"];
    if (cageStairs) {
        [cageStairs rotateTo:(MTUPoint3){radians_from_degrees(-_move.y), radians_from_degrees(_move.x), 0}];
    }
}

- (void) onMouseScroll:(CGFloat)delta {
    _scroll += (delta * 0.01f);
    if (_scroll < -15.0) {
        _scroll = -15.0;
    }
    MTUNode *cageStairs = [_scene findNodeWithName:@"cage_stairs_01_001"];
    if (cageStairs) {
        [cageStairs moveTo:(MTUPoint3){0, 0, [self calculateDistance]}];
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
