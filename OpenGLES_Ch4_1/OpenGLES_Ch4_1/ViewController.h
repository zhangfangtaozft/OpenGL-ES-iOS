//
//  ViewController.h
//  OpenGLES_Ch4_1
//
//  Created by frank.zhang on 2019/1/21.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@interface ViewController : GLKViewController
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKBaseEffect *extraEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *extraBuffer;
@property (nonatomic, assign) GLfloat centerVertexHeight;
@property (nonatomic, assign) BOOL shouldUseFaceNormals;
@property (nonatomic, assign) BOOL shouldDrawNormals;


@end

