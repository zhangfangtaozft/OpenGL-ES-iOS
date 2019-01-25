//
//  AGLKVertexAttribArrayBuffer.m
//  OpenGLES_Ch5_3
//
//  Created by frank.zhang on 2019/1/25.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@interface AGLKVertexAttribArrayBuffer ()

@property (nonatomic, assign) GLsizeiptr
bufferSizeBytes;

@property (nonatomic, assign) GLsizeiptr
stride;

@end


@implementation AGLKVertexAttribArrayBuffer

@synthesize name;
@synthesize bufferSizeBytes;
@synthesize stride;

- (id)initWithAttribStride:(GLsizeiptr)aStride
          numberOfVertices:(GLsizei)count
                     bytes:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;
{
    NSParameterAssert(0 < aStride);
    NSAssert((0 < count && NULL != dataPtr) ||
             (0 == count && NULL == dataPtr),
             @"data must not be NULL or count > 0");
    
    if(nil != (self = [super init]))
    {
        stride = aStride;
        bufferSizeBytes = stride * count;
        
        glGenBuffers(1,                // STEP 1
                     &name);
        glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                     self.name);
        glBufferData(                  // STEP 3
                     GL_ARRAY_BUFFER,  // Initialize buffer contents
                     bufferSizeBytes,  // Number of bytes to copy
                     dataPtr,          // Address of bytes to copy
                     usage);           // Hint: cache in GPU memory
        
        NSAssert(0 != name, @"Failed to generate name");
    }
    
    return self;
}

- (void)reinitWithAttribStride:(GLsizeiptr)aStride
              numberOfVertices:(GLsizei)count
                         bytes:(const GLvoid *)dataPtr;
{
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    NSAssert(0 != name, @"Invalid name");
    
    self.stride = aStride;
    self.bufferSizeBytes = aStride * count;
    
    glBindBuffer(GL_ARRAY_BUFFER,  // STEP 2
                 self.name);
    glBufferData(                  // STEP 3
                 GL_ARRAY_BUFFER,  // Initialize buffer contents
                 bufferSizeBytes,  // Number of bytes to copy
                 dataPtr,          // Address of bytes to copy
                 GL_DYNAMIC_DRAW);
}

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0 < count) && (count < 4));
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != name, @"Invalid name");
    
    glBindBuffer(GL_ARRAY_BUFFER,     // STEP 2
                 self.name);
    
    if(shouldEnable)
    {
        glEnableVertexAttribArray(     // Step 4
                                  index);
    }
    
    glVertexAttribPointer(            // Step 5
                          index,               // Identifies the attribute to use
                          count,               // number of coordinates for attribute
                          GL_FLOAT,            // data is floating point
                          GL_FALSE,            // no fixed point scaling
                          self.stride,         // total num bytes stored per vertex
                          NULL + offset);      // offset from start of each vertex to
    // first coord for attribute
#ifdef DEBUG
    {  // Report any errors
        GLenum error = glGetError();
        if(GL_NO_ERROR != error)
        {
            NSLog(@"GL Error: 0x%x", error);
        }
    }
#endif
}

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >=
             ((first + count) * self.stride),
             @"Attempt to draw more vertex data than available.");
    
    glDrawArrays(mode, first, count); // Step 6
}

+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;
{
    glDrawArrays(mode, first, count); // Step 6
}

- (void)dealloc
{
    // Delete buffer from current context
    if (0 != name)
    {
        glDeleteBuffers (1, &name); // Step 7
        name = 0;
    }
}

@end
