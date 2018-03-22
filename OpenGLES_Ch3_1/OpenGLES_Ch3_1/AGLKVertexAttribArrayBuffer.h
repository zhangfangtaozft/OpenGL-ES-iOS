//
//  AGLKVertexAttribArrayBuffer.h
//  OpenGLES_Ch3_1
//
//  Created by frank.Zhang on 22/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
@class  AGLKElementIndexArrayBuffer;
typedef enum{
    AGLKVertexAttribPosition = GLKVertexAttribPosition,
    AGLKVertexAttribNormal = GLKVertexAttribNormal,
    AGLKVertexAttribColor  = GLKVertexAttribColor,
    AGLKVertexAttribTexCoord0 = GLKVertexAttribTexCoord0,
    AGLKVertexAttribTexCoord1 = GLKVertexAttribTexCoord1,
} AGLKVertexAttrib;

@interface AGLKVertexAttribArrayBuffer : NSObject
{
    GLsizeiptr stride;
    GLsizeiptr bufferSizeBytes;
    GLuint name;
}
@property (nonatomic, readonly) GLuint name;
@property (nonatomic, readonly) GLsizeiptr bufferSizeBytes;
@property (nonatomic, readonly) GLsizeiptr stride;

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
