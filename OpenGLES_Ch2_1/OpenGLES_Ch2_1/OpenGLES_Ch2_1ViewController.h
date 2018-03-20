//
//  OpenGLES_Ch2_1ViewController.h
//  OpenGLES_Ch2_1
//
//  Created by frank.Zhang on 11/02/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface OpenGLES_Ch2_1ViewController : GLKViewController
{
    GLuint vertexBufferID;
}
@property(nonatomic,strong) GLKBaseEffect *baseEffect;

@end
