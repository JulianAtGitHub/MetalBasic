//
//  MTULayer.m
//  MetalSample
//
//  Created by zhuwei on 8/12/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "MTUDevice.h"
#import "MTULayer.h"

@implementation MTULayerConfig

- (instancetype) init {
    self = [super init];
    if (self) {
        _name = @"MTU Layer Config";
        _depthFormat = MTLPixelFormatInvalid;
        _stencilFormat = MTLPixelFormatInvalid;
        _hasClearAction = YES;
        _clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
        _clearDepth = 1.0;
        _clearStencil = 0;
    }
    return self;
}

@end

@interface MTULayer ()

- (void) createColorAttachmentsWithConfig:(MTULayerConfig *)config andDevice:(id <MTLDevice>)device;
- (void) createDepthAttachmentWithConfig:(MTULayerConfig *)config andDevice:(id <MTLDevice>)device;
- (void) createStencilAttachmentWithConfig:(MTULayerConfig *)config andDevice:(id <MTLDevice>)device;
- (void) createRenderPassWithConfig:(MTULayerConfig *)config;

@end

@implementation MTULayer

static NSMutableDictionary <NSString *, MTULayer *> *_LayerCache = nil;

+ (BOOL) createLayerToCache:(MTULayerConfig *)config {
    if (config == nil) {
        return NO;
    }
    
    if (config.name == nil || config.name.length == 0) {
        config.name = @"Unknow layer";
    }
    MTULayer *layer = [[MTULayer alloc] initWithConfig:config];
    if (layer == nil) {
        return NO;
    }
    
    if (_LayerCache == nil) {
        _LayerCache = [NSMutableDictionary dictionary];
    }
    
    if ([_LayerCache objectForKey:config.name] != nil) {
        NSLog(@"Layer %@ is exist in cache, will replaced with new instance!", config.name);
    }
    
    [_LayerCache setObject:layer forKey:config.name];
    return YES;
}

+ (MTULayer *) layerFromCache:(NSString *)name {
    return (_LayerCache != nil && name != nil) ? [_LayerCache objectForKey:name] : nil;
}

- (instancetype) initWithConfig:(MTULayerConfig *)config {
    self = [super init];
    if (self) {
        _name = config.name;
        if (config.size.width > 0 && config.size.height > 0) {
            id <MTLDevice> device = [MTUDevice sharedInstance].mtlDevice;
            [self createColorAttachmentsWithConfig:config andDevice:device];
            [self createDepthAttachmentWithConfig:config andDevice:device];
            [self createStencilAttachmentWithConfig:config andDevice:device];
            [self createRenderPassWithConfig:config];
        }
    }
    return self;
}

- (void) createColorAttachmentsWithConfig:(MTULayerConfig *)config andDevice:(id <MTLDevice>)device {
    if (config.colorFormats == nil || config.colorFormats.count == 0) {
        return;
    }
    
    NSUInteger count = config.colorFormats.count;
    id <MTLTexture> colorAttachments[count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger pixelFormat = config.colorFormats[i].unsignedIntegerValue;
        MTLTextureDescriptor *descriptor =
        [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:pixelFormat
                                                           width:config.size.width
                                                          height:config.size.height
                                                       mipmapped:NO];
        descriptor.storageMode = MTLStorageModePrivate;
        descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
        colorAttachments[i] = [device newTextureWithDescriptor:descriptor];
    }
    _colorAttachments = [NSArray arrayWithObjects:colorAttachments count:count];
}

- (void) createDepthAttachmentWithConfig:(MTULayerConfig *)config andDevice:(id <MTLDevice>)device {
    if (config.depthFormat == MTLPixelFormatInvalid) {
        return;
    }
    
    MTLTextureDescriptor *descriptor =
    [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:config.depthFormat
                                                       width:config.size.width
                                                      height:config.size.height
                                                   mipmapped:NO];
    descriptor.storageMode = MTLStorageModePrivate;
    descriptor.usage = MTLTextureUsageRenderTarget;
    _depthAttachment = [device newTextureWithDescriptor:descriptor];
}

- (void) createStencilAttachmentWithConfig:(MTULayerConfig *)config andDevice:(id <MTLDevice>)device {
    if (config.stencilFormat == MTLPixelFormatInvalid) {
        return;
    }
    
    MTLTextureDescriptor *descriptor =
    [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:config.stencilFormat
                                                       width:config.size.width
                                                      height:config.size.height
                                                   mipmapped:NO];
    descriptor.storageMode = MTLStorageModePrivate;
    descriptor.usage = MTLTextureUsageRenderTarget;
    _stencilAttachment = [device newTextureWithDescriptor:descriptor];
}

- (void) createRenderPassWithConfig:(MTULayerConfig *)config {
    _renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
    for (NSUInteger i = 0; i < _colorAttachments.count; ++i) {
        _renderPass.colorAttachments[i].texture = _colorAttachments[i];
        if (config.hasClearAction == YES) {
            _renderPass.colorAttachments[i].loadAction = MTLLoadActionClear;
            _renderPass.colorAttachments[i].clearColor = config.clearColor;
        }
    }
    if (_depthAttachment != nil) {
        _renderPass.depthAttachment.texture = _depthAttachment;
        if (config.hasClearAction == YES) {
            _renderPass.depthAttachment.loadAction = MTLLoadActionClear;
            _renderPass.depthAttachment.clearDepth = config.clearDepth;
        }
    }
    if (_stencilAttachment != nil) {
        _renderPass.stencilAttachment.texture = _stencilAttachment;
        if (config.hasClearAction == YES) {
            _renderPass.stencilAttachment.loadAction = MTLLoadActionClear;
            _renderPass.stencilAttachment.clearStencil = config.clearStencil;
        }
    }
}

@end
