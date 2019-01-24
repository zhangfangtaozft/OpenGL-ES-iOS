//
//  ViewController.h
//  OpenGLES_Ch5_1
//
//  Created by frank.zhang on 2019/1/24.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;

@interface ViewController : GLKViewController
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;


@end

