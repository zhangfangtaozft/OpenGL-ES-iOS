//
//  ViewController.h
//  OpenGLES_Ch5_5
//
//  Created by frank.zhang on 2019/1/28.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@class AGLKTextureTransformBaseEffect;
@interface ViewController : GLKViewController
@property (strong, nonatomic) AGLKTextureTransformBaseEffect
*baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*vertexBuffer;
@property (nonatomic) float
textureScaleFactor;
@property (nonatomic) float
textureAngle;
@property (nonatomic) GLKMatrixStackRef
textureMatrixStack;

@end

