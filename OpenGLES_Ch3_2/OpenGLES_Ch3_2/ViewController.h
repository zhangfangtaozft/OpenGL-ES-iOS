//
//  ViewController.h
//  OpenGLES_Ch3_2
//
//  Created by frank.Zhang on 23/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class  AGLKVertexAttribArrayBuffer;
@interface ViewController : GLKViewController
{
    
}
@property (nonatomic, strong) GLKBaseEffect*baseEffect;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@end

