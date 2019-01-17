//
//  AGLKVertexAttribArrayBuffer.m
//  OpenGLES_Ch2_3
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//
/*
 *下面的实现在三个方法中封装了7个缓存管理步骤，AGLKVertexAttribArrayBuffer类包含一些错误检查代码，但除此之外还包含一个对于例子OpenGLES_Ch2_1中的缓存管理代码的简单重用和重构。除了在类接口中声明的3个方法之外，还实现了一个“-dealloc”方法来删除一个相关联的OpenGL ES缓存标识符。
 **/
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


/////////////////////////////////////////////////////////////////
//此方法在中创建顶点属性数组缓冲区,这个线程的当前OpenGL ES上下文方法被调用。
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


/////////////////////////////////////////////////////////////////
// 此方法加载接收器存储的数据。
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


/////////////////////////////////////////////////////////////////
//当你的时候必须准备一个顶点属性数组缓冲区，应用程序想要使用缓冲区来渲染任何几何体。当应用程序准备缓冲区时，某些OpenGL ES状态被更改为允许绑定缓冲区并配置指针。
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


/////////////////////////////////////////////////////////////////
//提交由mode标识的绘图命令并指示
//  OpenGL ES从缓冲区开始使用计数顶点
//  首先是索引处的顶点。 顶点索引从0开始。
- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >=
             ((first + count) * self.stride),
             @"Attempt to draw more vertex data than available.");
    
    glDrawArrays(mode, first, count); // Step 6
}


/////////////////////////////////////////////////////////////////
//提交由mode标识的绘图命令并指示
//  OpenGL ES使用之前准备的计数顶点
//  缓冲区首先从索引处的顶点开始
//  准备缓冲区
+ (void)drawPreparedArraysWithMode:(GLenum)mode
                  startVertexIndex:(GLint)first
                  numberOfVertices:(GLsizei)count;
{
    glDrawArrays(mode, first, count); // Step 6
}


/////////////////////////////////////////////////////////////////
// This method deletes the receiver's buffer from the current
// Context when the receiver is deallocated.
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

