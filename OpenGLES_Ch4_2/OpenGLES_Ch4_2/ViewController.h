//
//  ViewController.h
//  OpenGLES_Ch4_2
//
//  Created by frank.zhang on 2019/1/22.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;

@interface ViewController : GLKViewController
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) GLKTextureInfo *blandTextureInfo;
@property (strong, nonatomic) GLKTextureInfo *interestingTextureInfo;
@property (nonatomic) BOOL shouldUseDetailLighting;
@end

