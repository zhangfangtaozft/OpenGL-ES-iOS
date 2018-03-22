//
//  AGLKVertexAttribArrayBuffer.h
//  OpenGLES_Ch2_3
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//
/*
 *AGLKVertexAttribArrayBuffer类封装了使用OpenGL ES 2.0的顶点属性数组缓存（或者简称“顶点缓存”）的所有7个步骤。这个函数减少了应用需要调用的OpenGL ES 函数的数量，在后续章节的例子中重用AGLKVertexAttribArrayBuffer会在尽可能被减少与7个缓存管理步骤相关的错误的同时减少编写的代码量。
 **/

#import <GLKit/GLKit.h>

@class AGLKElementIndexArrayBuffer;

/////////////////////////////////////////////////////////////////
//
typedef enum {
    AGLKVertexAttribPosition = GLKVertexAttribPosition,
    AGLKVertexAttribNormal = GLKVertexAttribNormal,
    AGLKVertexAttribColor = GLKVertexAttribColor,
    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
} AGLKVertexAttrib;


@interface AGLKVertexAttribArrayBuffer : NSObject
{
    GLsizeiptr   stride;
    GLsizeiptr   bufferSizeBytes;
    GLuint       name;
}

@property (nonatomic, readonly) GLuint
name;
@property (nonatomic, readonly) GLsizeiptr
bufferSizeBytes;
@property (nonatomic, readonly) GLsizeiptr
stride;

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;

- (id)initWithAttribStride:(GLsizeiptr)stride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

- (void)reinitWithAttribStride:(GLsizeiptr)stride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;

@end

