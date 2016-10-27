//
//  RPSurface.m
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "RPSurface.h"

@implementation RPSurface {
    
@private
    id <MTLTexture>  _depthTexture;
    id <MTLTexture>  _stencilTexture;
    id <MTLTexture>  _msaaTexture;
    
    MTLRenderPassDescriptor *_renderPassDescriptor;
}

+ (instancetype)surface {
    return [RPSurface layer];
}

- (void) initCommon {
    self.device = MTLCreateSystemDefaultDevice();
    
    self.pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.depthPixelFormat = MTLPixelFormatDepth32Float;
    self.stencilPixelFormat = MTLPixelFormatInvalid;
    self.multisampleCount = 1;
    
    // this is the default but if we wanted to perform compute on the final rendering layer we could set this to no
    self.framebufferOnly = YES;
    
    _renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
}

- (id)init {
    if(self = [super init]) {
        [self initCommon];
    }
    return self;
}

- (id)initWithLayer:(id)layer {
    if(self = [super initWithLayer:layer]) {
        [self initCommon];
    }
    return self;
}

- (void)reshape:(CGSize)size {
    self.drawableSize = size;
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    id <MTLTexture> colorTexture = self.nextDrawable.texture;
    
    MTLRenderPassColorAttachmentDescriptor *colorAttachment = _renderPassDescriptor.colorAttachments[0];
    colorAttachment.texture = colorTexture;
    colorAttachment.loadAction = MTLLoadActionClear;
    colorAttachment.clearColor = MTLClearColorMake(0.65f, 0.65f, 0.65f, 1.0f);
    
    // if multisample count is greater than 1, render into using MSAA, then resolve into our color texture
    if(_multisampleCount > 1) {
        MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: MTLPixelFormatBGRA8Unorm
                                                                                        width: width
                                                                                       height: height
                                                                                    mipmapped: NO];
        desc.textureType = MTLTextureType2DMultisample;
        
        // sample count was specified to the view by the renderer.
        // this must match the sample count given to any pipeline state using this render pass descriptor
        desc.sampleCount = _multisampleCount;
        
        _msaaTexture = [self.device newTextureWithDescriptor: desc];
        
        // When multisampling, perform rendering to _msaaTex, then resolve
        // to 'texture' at the end of the scene
        colorAttachment.texture = _msaaTexture;
        colorAttachment.resolveTexture = colorTexture;
        
        // set store action to resolve in this case
        colorAttachment.storeAction = MTLStoreActionMultisampleResolve;
    } else {
        // store only attachments that will be presented to the screen, as in this case
        colorAttachment.storeAction = MTLStoreActionStore;
    } // color0
    
    // Now create the depth and stencil attachments
    
    if(_depthPixelFormat != MTLPixelFormatInvalid) {
        //  If we need a depth texture and don't have one, or if the depth texture we have is the wrong size
        //  Then allocate one of the proper size
        MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: _depthPixelFormat
                                                                                        width: width
                                                                                       height: height
                                                                                    mipmapped: NO];
        
        desc.textureType = (_multisampleCount > 1) ? MTLTextureType2DMultisample : MTLTextureType2D;
        desc.sampleCount = _multisampleCount;
        desc.usage = MTLTextureUsageUnknown;
        desc.storageMode = MTLStorageModePrivate;
        
        _depthTexture = [self.device newTextureWithDescriptor: desc];
        
        MTLRenderPassDepthAttachmentDescriptor *depthAttachment = _renderPassDescriptor.depthAttachment;
        depthAttachment.texture = _depthTexture;
        depthAttachment.loadAction = MTLLoadActionClear;
        depthAttachment.storeAction = MTLStoreActionDontCare;
        depthAttachment.clearDepth = 1.0;

    } else {
        MTLRenderPassDepthAttachmentDescriptor *depthAttachment = _renderPassDescriptor.depthAttachment;
        depthAttachment.texture = nil;
    } // depth
    
    if(_stencilPixelFormat != MTLPixelFormatInvalid) {
        //  If we need a stencil texture and don't have one, or if the depth texture we have is the wrong size
        //  Then allocate one of the proper size
        MTLTextureDescriptor* desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat: _stencilPixelFormat
                                                                                        width: width
                                                                                       height: height
                                                                                    mipmapped: NO];
        
        desc.textureType = (_multisampleCount > 1) ? MTLTextureType2DMultisample : MTLTextureType2D;
        desc.sampleCount = _multisampleCount;
        
        _stencilTexture = [self.device newTextureWithDescriptor: desc];
        
        MTLRenderPassStencilAttachmentDescriptor* stencilAttachment = _renderPassDescriptor.stencilAttachment;
        stencilAttachment.texture = _stencilTexture;
        stencilAttachment.loadAction = MTLLoadActionClear;
        stencilAttachment.storeAction = MTLStoreActionDontCare;
        stencilAttachment.clearStencil = 0;
    } else {
        MTLRenderPassStencilAttachmentDescriptor* stencilAttachment = _renderPassDescriptor.stencilAttachment;
        stencilAttachment.texture = nil;
    } //stencil
}

@end
