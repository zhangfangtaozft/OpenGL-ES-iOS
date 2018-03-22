//
//  ViewController.h
//  OpenGLES_Ch3_1
//
//  Created by frank.Zhang on 22/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@interface ViewController : GLKViewController
{
    
}

@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*vertexBuffer;
@end

