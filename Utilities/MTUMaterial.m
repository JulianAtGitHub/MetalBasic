//
//  MTUMaterial.m
//  MetalSample
//
//  Created by zhuwei on 7/16/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "MTUMaterial.h"
#import "MTUShaderTypes.h"
#import "MTUDevice.h"

@implementation MTUMaterialConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"MTUMaterial";
        // default value
        _colorFormat = MTLPixelFormatBGRA8Unorm;
        _depthFormat = MTLPixelFormatDepth32Float;
        _stencilFormat = MTLPixelFormatStencil8;
        _depthCompareFunction = MTLCompareFunctionLess;
        _depthWritable = YES;
        _isCullBackFace = NO;
        _isClockWise = YES;
        _vertexFormat = MTUVertexFormatP;
        _transformType = MTUTransformTypeInvalid;
        _cameraParamsUsage = MTUCameraParamsNotUse;
    }
    return self;
}

@end

@implementation MTUMaterial

- (instancetype) initWithConfig:(MTUMaterialConfig *)config andVertexFormat:(MTUVertexFormat)vertexFormat {
    self = [super init];
    if (self) {
        _name = config.name;
        
        MTUDevice *device = [MTUDevice sharedInstance];
        
        _renderPipelineState = [device renderPipelineStateWithConfig:config andMeshVertexFormat:vertexFormat];
        _depthStencilState = [device depthStencilStateWithConfig:config];
        
        _cullMode = config.isCullBackFace == YES ? MTLCullModeBack : MTLCullModeNone;
        _winding = config.isClockWise == YES ? MTLWindingClockwise : MTLWindingCounterClockwise;
        
        _vertexFormat = config.vertexFormat;
        
        _transformType = config.transformType;
        size_t transformBufferLenght = 0;
        switch (_transformType) {
            case MTUTransformTypeMvp: transformBufferLenght = sizeof(MTUTransformMvp); break;
            case MTUTransformTypeMvpMN: transformBufferLenght = sizeof(MTUTransformMvpMN); break;
            default: break;
        }
        if (transformBufferLenght > 0) {
            _transformBuffers = [device newInFlightBuffersWithSize:transformBufferLenght];
        }
        
        _cameraParamsUsage = config.cameraParamsUsage;
        
        if (config.buffers != nil && config.buffers.count > 0) {
            NSUInteger bufferCount = config.buffers.count;
            id <MTLBuffer> buffers[bufferCount];
            for (NSUInteger i = 0; i < bufferCount; ++i) {
                buffers[i] = [device newBufferWithRawData:config.buffers[i]];
            }
            _buffers = [NSArray arrayWithObjects:buffers count:bufferCount];
        }
        
        _bufferIndexOfVertexShader = config.bufferIndexOfVertexShader;
        _bufferIndexOfFragmentShader = config.bufferIndexOfFragmentShader;
        
        if (config.textures != nil && config.textures.count > 0) {
            NSUInteger textureCount = config.textures.count;
            id <MTLTexture> textures[textureCount];
            for (NSUInteger i = 0; i < textureCount; ++i) {
                textures[i] = [device newTextureWithAssetset:config.textures[i]];
            }
            _textures = [NSArray arrayWithObjects:textures count:textureCount];
        }
    }
    return self;
}

@end


