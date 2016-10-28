//
//  RPRenderer.m
//  MetalBasic3D
//
//  Created by Julian on 27/10/2016.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

#import "RPRenderer.h"

@implementation RPRenderer {

@private
	__weak CAMetalLayer *_metalLayer;
	id<MTLDevice> _device;
	MTLRenderPassDescriptor *_renderPassDescriptor;
}

- (id)init {
    if(self = [super init]) {
        _colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    	_depthPixelFormat = MTLPixelFormatDepth32Float;
    	_stencilPixelFormat = MTLPixelFormatInvalid;
    	_multisampleCount = 1;

    	_device = MTLCreateSystemDefaultDevice();
    	_renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];

    	_layer = _metalLayer = [CAMetalLayer layer];
    	_metalLayer.device = _device;
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        _metalLayer.framebufferOnly = YES;
    }
    return self;
}

- (void)reshape:(CGSize)size {
	_metalLayer.drawableSize = size;
    NSUInteger width = size.width;
    NSUInteger height = size.height;
    id <MTLTexture> colorTexture = _metalLayer.nextDrawable.texture;
    
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
        
        id <MTLTexture> msaaTexture = [_device newTextureWithDescriptor: desc];
        
        // When multisampling, perform rendering to _msaaTex, then resolve
        // to 'texture' at the end of the scene
        colorAttachment.texture = msaaTexture;
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
        
        id <MTLTexture> depthTexture = [_device newTextureWithDescriptor: desc];
        
        MTLRenderPassDepthAttachmentDescriptor *depthAttachment = _renderPassDescriptor.depthAttachment;
        depthAttachment.texture = depthTexture;
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
        
        id <MTLTexture> stencilTexture = [_device newTextureWithDescriptor: desc];
        
        MTLRenderPassStencilAttachmentDescriptor* stencilAttachment = _renderPassDescriptor.stencilAttachment;
        stencilAttachment.texture = stencilTexture;
        stencilAttachment.loadAction = MTLLoadActionClear;
        stencilAttachment.storeAction = MTLStoreActionDontCare;
        stencilAttachment.clearStencil = 0;
    } else {
        MTLRenderPassStencilAttachmentDescriptor* stencilAttachment = _renderPassDescriptor.stencilAttachment;
        stencilAttachment.texture = nil;
    } //stencil
}

- (void)draw {

}

- (void)update:(NSTimeInterval)deltaTime {
    
}

- (void)viewController:(RPViewController *)controller willPause:(BOOL)pause {
    
}

@end
