//
//  ViewController.h
//  OpenGLES_Ch2_2
//
//  Created by frank.Zhang on 20/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGLKViewController.h"
#import <GLKit/GLKit.h>
@interface ViewController : AGLKViewController
{
    GLuint vertexBufferID;
}

@property(nonatomic,strong) GLKBaseEffect *baseEffect;
@end
