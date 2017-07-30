//
//  Renderer.m
//  MetalSample
//
//  Created by zhuwei on 6/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#include <math.h>
#import "Utilities/FBX/MTUFbxImporter.h"
#import "Utilities/MTUTypes.h"
#import "Utilities/MTUShaderTypes.h"
#import "Utilities/MTUMath.h"
#import "Utilities/MTUDevice.h"
#import "Utilities/MTUNode.h"
#import "Utilities/MTUMesh.h"
#import "Utilities/MTUMaterial.h"
#import "Renderer.h"

@interface Renderer () {
    MTUCamera _camera;
    MTUNode *_scene;
    CGPoint _move;
    CGFloat _scroll;
}

@end

@implementation Renderer

- (instancetype) initWithMTKView:(MTKView *)view {
    self = [super init];
    if (self) {
        [self loadMetal:view];
    }
    return self;
}

- (void) loadMetal:(MTKView *)view {
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    
    _camera = (MTUCamera){
        {0.0f, 1000.0f, 200.0f},
        {0.0f, 0.0f, 200.0f},
        {0.0f, 0.0f, 1.0f},
        65.0f
    };
    
    [MTUDevice sharedInstance].view = view;
    MTUDirectLight light;
    light.inversed_direction = vector_normalize(vector3(-1.0f, 1.0f, 1.0f));
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
    structureConfig.isCullBackFace = YES;
    structureConfig.isClockWise = NO;
    structureConfig.transformType = MTUTransformTypeMvpMNP;
    structureConfig.buffers = @[lightData, objectData];
    structureConfig.bufferIndexOfVertexShader = @[@0];
    structureConfig.bufferIndexOfFragmentShader = @[@0, @1];
    structureConfig.textures = @[@"structure_baseColor", @"structure_normal", @"structure_specular"];
    MTUMaterial *structureMaterial = [[MTUMaterial alloc] initWithConfig:structureConfig];
    
    MTUMaterialConfig *foliageConfig = [[MTUMaterialConfig alloc] init];
    foliageConfig.name = @"foliage-phong";
    foliageConfig.vertexShader = @"vertPhong";
    foliageConfig.fragmentShader = @"fragPhong";
    foliageConfig.isCullBackFace = YES;
    foliageConfig.isClockWise = NO;
    foliageConfig.transformType = MTUTransformTypeMvpMNP;
    foliageConfig.buffers = @[lightData, objectData];
    foliageConfig.bufferIndexOfVertexShader = @[@0];
    foliageConfig.bufferIndexOfFragmentShader = @[@0, @1];
    foliageConfig.textures = @[@"foliage_baseColor", @"foliage_normal", @"foliage_specular"];
    MTUMaterial *foliageMaterial = [[MTUMaterial alloc] initWithConfig:foliageConfig];
    
    _scene = [[MTUFbxImporter shadedInstance] loadNodeFromFile:@"Models/Temple.dae" andConvertToFormat:MTUVertexFormatPTNTB];
    MTUNode *structure = [_scene findNodeWithName:@"cage_stairs_01_001_Material0"];
    if (structure) {
        structure.material = structureMaterial;
    }
    MTUNode *tree = [_scene findNodeWithName:@"cage_stairs_01_001_Material1"];
    if (tree) {
        tree.material = foliageMaterial;
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
    MTUNode *structure = [_scene findNodeWithName:@"cage_stairs_01_001_Material0"];
    if (structure) {
        [structure rotateTo:(MTUPoint3){radians_from_degrees(_move.y), 0, radians_from_degrees(_move.x)}];
    }
    MTUNode *tree = [_scene findNodeWithName:@"cage_stairs_01_001_Material1"];
    if (tree) {
        [tree rotateTo:(MTUPoint3){radians_from_degrees(_move.y), 0, radians_from_degrees(_move.x)}];
    }
}

- (void) onMouseScroll:(CGFloat)delta {
    _scroll += (delta * 0.01f);
    if (_scroll < -15.0) {
        _scroll = -15.0;
    }
    MTUNode *structure = [_scene findNodeWithName:@"cage_stairs_01_001_Material0"];
    if (structure) {
        [structure moveTo:(MTUPoint3){0, [self calculateDistance], 0}];
    }
    MTUNode *tree = [_scene findNodeWithName:@"cage_stairs_01_001_Material1"];
    if (tree) {
        [tree moveTo:(MTUPoint3){0, [self calculateDistance], 0}];
    }
}

#pragma mark - implementation of MKTViewDelegate

- (void)drawInMTKView:(nonnull MTKView *)view {
    if (_scene == nil) {
        return;
    }
    
    MTUDevice *device = [MTUDevice sharedInstance];
    [device startDraw];
    [_scene updateWithCamera:&_camera];
    [_scene draw];
    [device commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    
}

@end