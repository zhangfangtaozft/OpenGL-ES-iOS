//
//  AGLKContext.h
//  OpenGLES_Ch2_3
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@interface AGLKContext : EAGLContext
//AGLKCntext类是一个在例子OpenGLES_Ch2_1中使用的內建EAGLContext类的简单子类，对于本例来说，AGLKContext仅仅添加了一个clearColor属性和一个用来告诉OpenGL ES去设置在上下文的帧缓存中的每一个像素颜色为clearColor的元素值的“-clear”方法。
{
    GLKVector4 clearColor;
}

@property (nonatomic, assign, readwrite)
GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;
- (void)enable:(GLenum)capability;
- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor
           destinationFunction:(GLenum)dfactor;

@end
