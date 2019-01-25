//
//  ViewController.h
//  OpenGLES_Ch5_3
//
//  Created by frank.zhang on 2019/1/25.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "AGLKViewController.h"

@class AGLKVertexAttribArrayBuffer;
@interface ViewController : AGLKViewController
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexPositionBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexNormalBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexTextureCoordBuffer;

@end

