//
//  ViewController.m
//  OpenGLES_Ch2_3
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//
/*
 *GLKit类封装并简化了Cocoa Touch应用和OpenGL ES之间的常见交互，就像推测已存的GLKit类可能是怎么实现的是一种指导一样，遵循苹果的用来构建GLKit的范例来创建新类也是可能的。
 本章的OpenGLES_Ch2_1例子使用了GLKit，并且为了实现两个目的添加了对于OpenGL ES函数的直接调用，这两个目的是：清除缓存，以及使用一个顶点数组缓存来绘图，就像GLKit的GLKView封装了帧缓存和层管理，例子OpenGLES_Ch2_3重构OpenGLES_Ch2_1的可重用OpenGL ES代码为两个新类：AGLKContext和AGLKVertexAttribArrayBuffer。本书使用AGLK作为类和函数前缀来代表是对于GLKit类的追加，GLKit将来的版本可能包含与AGLKit类相似的类，苹果通常不会预告对于其框架的增强，并且即使苹果最终实现了与本书中的AGLK类具有相似功能的类，也无法保证苹果会按相同的方式实现它。
 **/

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

@implementation ViewController
@synthesize baseEffect;
@synthesize vertexBuffer;

/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
    GLKVector3  positionCoords;
}
SceneVertex;

/////////////////////////////////////////////////////////////////
// Define vertex data for a triangle to use in example
static const SceneVertex vertices[] =
{
    {{-0.5f, -0.5f, 0.0}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0}}, // lower right corner
    {{-0.5f,  0.5f, 0.0}}  // upper left corner
};


/////////////////////////////////////////////////////////////////
// Called when the view controller's view is loaded
// Perform initialization before the view is asked to draw
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Verify the type of view created automatically by the
    // Interface Builder storyboard
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the
    // view
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    // shading language programs and set constants to be used for
    // all subsequent rendering
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    //仔细检查例子本例子中的类的实现，并把它与例子OpenGLES_Ch2_1中的类的实现做一下对比，在本例子中没有对于OpenGL ES函数的直接调用。另外，你可能会注意到一些小的代码风格的不一致。例如OpenGLES_Ch2_1使用一个GLKVector4结构体来设置恒定的颜色，但是用来设置清除颜色的对于OpenGL ES 函数的调用可以直接接收RGBA颜色元素值：
    //AGLKVertexAttribArrayBuffer和AGLKContext类扩展了GLKit引入的代码样式，因此OpenGLES_Ch2_3例子会使用一个一贯的样式：
    self.baseEffect.constantColor = GLKVector4Make(
                                                   1.0f, // Red
                                                   1.0f, // Green
                                                   1.0f, // Blue
                                                   1.0f);// Alpha
    
    // Set the background color stored in the current context
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    //细小的样式一致性上的改进会让应用代码更整洁，但是更重要的是，在objective-C类中封装OpenGL ES代码会让代码重用更容易，减少缓存被创建并使用时出现程序错误的机会，同时，可让用多个缓存的应用需要编写，测试的代码更少。
    // Create vertex buffer containing vertices to draw
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices
                         usage:GL_STATIC_DRAW];
}


/////////////////////////////////////////////////////////////////
// GLKView delegate method: Called by the view controller's view
// whenever Cocoa Touch asks the view controller's view to
// draw itself. (In this case, render into a frame buffer that
// shares memory with a Core Animation Layer)
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    
    // Clear back frame buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    
    // Draw triangles using the first three vertices in the
    // currently bound vertex buffer
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:3];
}


/////////////////////////////////////////////////////////////////
// Called when the view controller's view has been unloaded
// Perform clean-up that is possible when you know the view
// controller's view won't be asked to draw again soon.
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexBuffer = nil;
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

@end

