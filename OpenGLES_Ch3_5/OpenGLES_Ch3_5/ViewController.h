//
//  ViewController.h
//  OpenGLES_Ch3_5
//
//  Created by frank.zhang on 2019/1/18.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@interface ViewController : GLKViewController
{
    
}
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

