//
//  ViewController.h
//  OpenGLES_Ch2_3
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@interface ViewController : GLKViewController
{
    AGLKVertexAttribArrayBuffer *vertexBuffer;
}

@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*vertexBuffer;

@end
