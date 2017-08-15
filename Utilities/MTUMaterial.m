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
#import "MTULayer.h"

@implementation MTUMaterialConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"MTUMaterial";
        _depthCompareFunction = MTLCompareFunctionLess;
        _depthWritable = YES;
        _cullMode = MTLCullModeNone;
        _winding = MTLWindingClockwise;
        _vertexFormat = MTUVertexFormatP;
        _transformType = MTUTransformTypeInvalid;
        _cameraParamsUsage = MTUCameraParamsNotUse;
    }
    return self;
}

@end

@interface MTUMaterial () {
    BOOL _isRenderPipelineDirty;
    BOOL _isDepthStencilDirty;
    void *_layerPointer;
    MTUVertexFormat _meshVertexFormat;
    id <MTLRenderPipelineState> _renderPipelineState;
    id <MTLDepthStencilState> _depthStencilState;
}

- (NSString *) renderPipelineStateIdentity;
- (NSString *) depthStencilStateIdentity;

@end

@implementation MTUMaterial

static NSMutableDictionary <NSString *, id <MTLRenderPipelineState> > *_RenderPipelineStateCache = nil;
static NSMutableDictionary <NSString *, id <MTLDepthStencilState> > *_DepthStencilStateCache = nil;

- (instancetype) initWithConfig:(MTUMaterialConfig *)config {
    self = [super init];
    if (self) {
        _name = config.name;
        _config = config;
        
        MTUDevice *device = [MTUDevice sharedInstance];
        
//        _renderPipelineState = [device renderPipelineStateWithConfig:config andMeshVertexFormat:vertexFormat];
//        _depthStencilState = [device depthStencilStateWithConfig:config];
        
        size_t transformBufferLenght = 0;
        switch (config.transformType) {
            case MTUTransformTypeMvp: transformBufferLenght = sizeof(MTUTransformMvp); break;
            case MTUTransformTypeMvpMN: transformBufferLenght = sizeof(MTUTransformMvpMN); break;
            default: break;
        }
        if (transformBufferLenght > 0) {
            _transformBuffers = [device newInFlightBuffersWithSize:transformBufferLenght];
        }
        
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
        
        _isRenderPipelineDirty = YES;
        _isDepthStencilDirty = YES;
        _meshVertexFormat = MTUVertexFormatInvalid;
    }
    return self;
}

- (void) setRenderLayer:(MTULayer *)layer andMeshVertexFormat:(MTUVertexFormat)format {
    if (layer == nil) {
        return;
    }
    
    void *layerPointer = (__bridge void *)layer;
    if (layerPointer != _layerPointer || format != _meshVertexFormat) {
        _isRenderPipelineDirty = YES;
        _isDepthStencilDirty = YES;
        _layerPointer = layerPointer;
        _meshVertexFormat = format;
        
        _renderPipelineState = nil;
        _depthStencilState = nil;
    }
}

- (NSString *) renderPipelineStateIdentity {
    return [NSString stringWithFormat:@"RenderPipelineState#%@#%@#%u#%u#%lu",
                _config.vertexShader,
                _config.fragmentShader,
                _config.vertexFormat,
                _meshVertexFormat,
                (NSUInteger)_layerPointer];
}

- (NSString *) depthStencilStateIdentity {
    return [NSString stringWithFormat:@"DepthStencilState#%lu#%hhd",
                _config.depthCompareFunction,
                _config.depthWritable];
}

- (id <MTLRenderPipelineState>) renderPipelineState {
    if (_isRenderPipelineDirty == YES) {
        do {
            if (!_layerPointer || _meshVertexFormat == MTUVertexFormatInvalid) {
                break;
            }
            
            MTULayer *layer = (__bridge MTULayer *)_layerPointer;
            if (layer.colorAttachments == nil || layer.colorAttachments.count == 0) {
                break;
            }
            
            if (_RenderPipelineStateCache == nil) {
                _RenderPipelineStateCache = [NSMutableDictionary dictionary];
            }
            
            NSString *renderPipelineStateId = [self renderPipelineStateIdentity];
            _renderPipelineState = [_RenderPipelineStateCache objectForKey:renderPipelineStateId];
            if (_renderPipelineState != nil) {
                break;
            }
            
            MTUDevice *device = [MTUDevice sharedInstance];
            id <MTLFunction> vertexFunction = [device shaderFunctionWithName:_config.vertexShader];
            id <MTLFunction> fragmentFunction = [device shaderFunctionWithName:_config.fragmentShader];
            if (vertexFunction == nil || fragmentFunction == nil) {
                break;
            }
            
            MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
            renderPipelineDescriptor.label = [NSString stringWithFormat:@"%@ Render Pipeline", _config.name];
            renderPipelineDescriptor.vertexFunction = vertexFunction;
            renderPipelineDescriptor.fragmentFunction = fragmentFunction;
            NSArray <id <MTLTexture> > *colorAttachments = layer.colorAttachments;
            for (NSUInteger i = 0; i < colorAttachments.count; ++i) {
                renderPipelineDescriptor.colorAttachments[i].pixelFormat = colorAttachments[i].pixelFormat;
            }
            renderPipelineDescriptor.depthAttachmentPixelFormat =
                layer.depthAttachment != nil ? layer.depthAttachment.pixelFormat : MTLPixelFormatInvalid;
            renderPipelineDescriptor.stencilAttachmentPixelFormat =
                layer.stencilAttachment != nil ? layer.stencilAttachment.pixelFormat : MTLPixelFormatInvalid;
            renderPipelineDescriptor.inputPrimitiveTopology = MTLPrimitiveTopologyClassTriangle;
            
            MTLVertexDescriptor *vertexDescriptor = [[MTLVertexDescriptor alloc] init];
            // position
            vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
            vertexDescriptor.attributes[0].offset = 0;
            vertexDescriptor.attributes[0].bufferIndex = 0;
            switch (_config.vertexFormat) {
                case MTUVertexFormatPT:
                    // texture coord
                    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
                    vertexDescriptor.attributes[1].offset = 12;
                    vertexDescriptor.attributes[1].bufferIndex = 0;
                    break;
                case MTUVertexFormatPTN:
                    // texture coord
                    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
                    vertexDescriptor.attributes[1].offset = 12;
                    vertexDescriptor.attributes[1].bufferIndex = 0;
                    // normal
                    vertexDescriptor.attributes[2].format = MTLVertexFormatFloat3;
                    vertexDescriptor.attributes[2].offset = 20;
                    vertexDescriptor.attributes[2].bufferIndex = 0;
                    break;
                case MTUVertexFormatPTNTB:
                    // texture coord
                    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
                    vertexDescriptor.attributes[1].offset = 12;
                    vertexDescriptor.attributes[1].bufferIndex = 0;
                    // normal
                    vertexDescriptor.attributes[2].format = MTLVertexFormatFloat3;
                    vertexDescriptor.attributes[2].offset = 20;
                    vertexDescriptor.attributes[2].bufferIndex = 0;
                    // tangent
                    vertexDescriptor.attributes[3].format = MTLVertexFormatFloat3;
                    vertexDescriptor.attributes[3].offset = 32;
                    vertexDescriptor.attributes[3].bufferIndex = 0;
                    // binormal
                    vertexDescriptor.attributes[4].format = MTLVertexFormatFloat3;
                    vertexDescriptor.attributes[4].offset = 44;
                    vertexDescriptor.attributes[4].bufferIndex = 0;
                    break;
                default:
                    break;
            }
            switch (_meshVertexFormat) {
                case MTUVertexFormatP:
                    vertexDescriptor.layouts[0].stride = 12;
                    break;
                case MTUVertexFormatPT:
                    vertexDescriptor.layouts[0].stride = 20;
                    break;
                case MTUVertexFormatPTN:
                    vertexDescriptor.layouts[0].stride = 32;
                    break;
                case MTUVertexFormatPTNTB:
                    vertexDescriptor.layouts[0].stride = 56;
                    break;
                default:
                    break;
            }
            vertexDescriptor.layouts[0].stepFunction = MTLStepFunctionPerVertex;
            vertexDescriptor.layouts[0].stepRate = 1;
            
            renderPipelineDescriptor.vertexDescriptor = vertexDescriptor;
            
            NSError *error = nil;
            _renderPipelineState = [device.mtlDevice newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:&error];
            if (_renderPipelineState != nil) {
                [_RenderPipelineStateCache setObject:_renderPipelineState forKey:renderPipelineStateId];
            } else {
                NSLog(@"Failed to created render pipeline state, error %@", error);
            }
        } while (0);
        _isRenderPipelineDirty = NO;
    }
    
    return _renderPipelineState;
}

- (id <MTLDepthStencilState>) depthStencilState {
    if (_isDepthStencilDirty == YES) {
        do {
            if (!_layerPointer || _meshVertexFormat == MTUVertexFormatInvalid) {
                break;
            }
            
            MTULayer *layer = (__bridge MTULayer *)_layerPointer;
            if (layer.depthAttachment == nil) {
                break;
            }
            
            if (_DepthStencilStateCache == nil) {
                _DepthStencilStateCache = [NSMutableDictionary dictionary];
            }
            
            NSString *depthStencilStateId = [self depthStencilStateIdentity];
            _depthStencilState = [_DepthStencilStateCache objectForKey:depthStencilStateId];
            if (_depthStencilState != nil) {
                break;
            }
            
            MTLDepthStencilDescriptor *depthStencilDescriptor = [[MTLDepthStencilDescriptor alloc] init];
            depthStencilDescriptor.label = [NSString stringWithFormat:@"%@ Depth Stencil", _config.name];
            depthStencilDescriptor.depthCompareFunction = _config.depthCompareFunction;
            depthStencilDescriptor.depthWriteEnabled = _config.depthWritable;
            
            id <MTLDevice> device = [MTUDevice sharedInstance].mtlDevice;
            _depthStencilState = [device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
            if (_depthStencilState != nil) {
                [_DepthStencilStateCache setObject:_depthStencilState forKey:depthStencilStateId];
            } else {
                NSLog(@"Failed to created depth stencil state!");
            }
        } while (0);
        _isDepthStencilDirty = NO;
    }
    
    return _depthStencilState;
}

@end


