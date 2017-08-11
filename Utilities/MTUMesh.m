//
//  MTUMesh.m
//  MetalSample
//
//  Created by zhuwei on 7/5/17.
//  Copyright © 2017 julian. All rights reserved.
//

#import "MTUShaderTypes.h"
#import "MTUDevice.h"
#import "MTUMaterial.h"
#import "MTUMesh.h"

@implementation MTUMesh

- (instancetype) initWithVertexData:(NSData *)data andVertexFormat:(MTUVertexFormat) format {
    self = [super init];
    if (self) {
        MTUDevice *device = [MTUDevice sharedInstance];
        _vertexBuffer = [device newBufferWithRawData:data];
        _vertexFormat = format;
        size_t vertexSize = 0;
        switch (format) {
            case MTUVertexFormatP: vertexSize = sizeof(MTUVertexP); break;
            case MTUVertexFormatPT: vertexSize = sizeof(MTUVertexPT); break;
            case MTUVertexFormatPTN: vertexSize = sizeof(MTUVertexPTN); break;
            case MTUVertexFormatPTNTB: vertexSize = sizeof(MTUVertexPTNTB); break;
            default: break;
        }
        if (vertexSize > 0) {
            _vertexCount = data.length / vertexSize;
        }
    }
    return self;
}

- (void) resetMaterialFromConfig:(MTUMaterialConfig *)config {
    if (config == nil) {
        return;
    }
    
    _material = nil;
    _material = [[MTUMaterial alloc] initWithConfig:config andVertexFormat:_vertexFormat];
}

@end

