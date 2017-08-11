//
//  MTUSkybox.m
//  MetalSample
//
//  Created by zhuwei on 8/1/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "MTUTypes.h"
#import "MTUDevice.h"
#import "MTUCamera.h"
#import "MTUMesh.h"
#import "MTUMaterial.h"
#import "MTUSkybox.h"

const static MTUVertexP SkyboxVertices[] = {
    // positions
    {-1.0f,  1.0f, -1.0f},
    {-1.0f, -1.0f, -1.0f},
    { 1.0f, -1.0f, -1.0f},
    { 1.0f, -1.0f, -1.0f},
    { 1.0f,  1.0f, -1.0f},
    {-1.0f,  1.0f, -1.0f},
    
    {-1.0f, -1.0f,  1.0f},
    {-1.0f, -1.0f, -1.0f},
    {-1.0f,  1.0f, -1.0f},
    {-1.0f,  1.0f, -1.0f},
    {-1.0f,  1.0f,  1.0f},
    {-1.0f, -1.0f,  1.0f},
    
    { 1.0f, -1.0f, -1.0f},
    { 1.0f, -1.0f,  1.0f},
    { 1.0f,  1.0f,  1.0f},
    { 1.0f,  1.0f,  1.0f},
    { 1.0f,  1.0f, -1.0f},
    { 1.0f, -1.0f, -1.0f},
    
    {-1.0f, -1.0f,  1.0f},
    {-1.0f,  1.0f,  1.0f},
    { 1.0f,  1.0f,  1.0f},
    { 1.0f,  1.0f,  1.0f},
    { 1.0f, -1.0f,  1.0f},
    {-1.0f, -1.0f,  1.0f},
    
    {-1.0f,  1.0f, -1.0f},
    { 1.0f,  1.0f, -1.0f},
    { 1.0f,  1.0f,  1.0f},
    { 1.0f,  1.0f,  1.0f},
    {-1.0f,  1.0f,  1.0f},
    {-1.0f,  1.0f, -1.0f},
    
    {-1.0f, -1.0f, -1.0f},
    {-1.0f, -1.0f,  1.0f},
    { 1.0f, -1.0f, -1.0f},
    { 1.0f, -1.0f, -1.0f},
    {-1.0f, -1.0f,  1.0f},
    { 1.0f, -1.0f,  1.0f}
};

@interface MTUSkybox ()

- (MTUMesh *) createMeshOfSkybox:(NSString *)textureAsset;

@end

@implementation MTUSkybox

- (instancetype) initWithTextureAsset:(NSString *)assetName {
    self = [super initWithParent:nil];
    if (self) {
        self.name = @"MTU-Skybox";
        [self addMesh:[self createMeshOfSkybox:assetName]];
    }
    return self;
}

- (MTUMesh *) createMeshOfSkybox:(NSString *)textureAsset {
    NSData *vertices = [NSData dataWithBytes:SkyboxVertices length:sizeof(SkyboxVertices)];
    MTUMesh *mesh = [[MTUMesh alloc] initWithVertexData:vertices andVertexFormat:MTUVertexFormatP];
    mesh.name = @"Skybox_mesh_0";
    
    MTUMaterialConfig *config = [[MTUMaterialConfig alloc] init];
    config.name = @"Skybox";
    config.vertexShader = @"vertSkybox";
    config.fragmentShader = @"fragSkybox";
    config.depthCompareFunction = MTLCompareFunctionLessEqual;
    config.depthWritable = NO;
    config.vertexFormat = MTUVertexFormatP;
    config.transformType = MTUTransformTypeMvp;
    config.textures = @[@"skybox_baseColor"];
    [mesh resetMaterialFromConfig:config];
    
    return mesh;
}

- (void) updateWithCamera:(MTUCamera *)camera {
    MTUCamera *skyboxCamera = [[MTUCamera alloc] init];
    skyboxCamera->target = vector3(camera->target.x - camera->position.x,
                                   camera->target.y - camera->position.y,
                                   camera->target.z - camera->position.z);
    skyboxCamera->up = camera->up;
    skyboxCamera.fovy = camera.fovy;
    
    [skyboxCamera update];
    [super updateWithCamera:skyboxCamera];
}

@end
