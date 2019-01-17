//
//  ViewController.h
//  OpenGLES_Ch3_3
//
//  Created by frank.zhang on 2019/1/16.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@interface ViewController : GLKViewController

{
}

@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*vertexBuffer;
@property (nonatomic) BOOL
shouldUseLinearFilter;
@property (nonatomic) BOOL
shouldAnimate;
@property (nonatomic) BOOL
shouldRepeatTexture;
@property (nonatomic) GLfloat
sCoordinateOffset;
@end

