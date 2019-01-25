//
//  ViewController.m
//  OpenGLES_Ch5_1
//
//  Created by frank.zhang on 2019/1/24.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
 三角形，线段，和点是按他们被GPU处理的顺序被渲染的。如果没有一个深度渲染缓存（或者直接简称为深度缓存），为最后一个对象的绘制而产生的片元总是会覆盖以前渲染的层叠的片元。至今为止本书中的例子一只小心地控制绘制的顺序，以确保在没有深度缓存的情况下仍然可以产生正确的最终图像。
 变换使从任意试点渲染场景成为可能。视点决定了场景中的哪一个对象会被渲染在其他对象的前面。例如，当一个看向面部的视点渲染一个人类头部的结合图形时，所有组成头部的三角形都不会出现在渲染的场景中。然而，当依赖于渲染的顺序时，如果GPU最后处理的是头后部的三角形，那么即使不应该可见，最终他们也将是可见的。
 在一些情况下，一个程序可以按照正确的渲染顺序从后向前排序对象。可以排序组成人类头部的三角形，以便组成面部的三角形是最后一个被GPU处理的并且覆盖组成头后部的三角形。不幸的是，排序三角形经常会导致重写顶点缓存的内容，并且会击溃缓存带来的内存访问优化。如果视点变成面向头的一侧，那么组成面部的部分三角形和组成头后部的部分三角形在渲染场景中将都是可见的，但这需要一个不同的排序顺序。一个变化的视点必然需要重新计算所绘制对象的正确顺序。此外，光排序可能还不够。在一些情况下，三角形贯穿彼此并且正确地渲染应该包含两个三角形的片元，但是排序会强制一个三角形的所有片元覆盖另一个的片元。
 深度渲染缓存是一个可选的输出缓存，并且与像素颜色缓存相似。第二章为了与像素颜色渲染缓存一起使用而介绍了”其他缓存“的概念。几乎所有的OpenGL ES应用都使用深度缓存，因为几乎所有的OpenGL ES应用都使用坐标系变换来渲染的视点。在大部分情况下，一个深度缓存会消除对于一个三角形，线段和点进行排序的需求。
 注意：深度缓存常常也叫做Z缓存，因为如果坐标系的X轴和Y轴应用于屏幕的宽和高，那么Z轴指示的就是屏幕的内外。一个片元和视点之间的距离大体相当于这个片元沿着Z轴深入屏幕的位置。
 每次渲染一个片元时，片元的深度（片元与视点之间的距离）被计算出来与在深度缓存中为那个片元位置保存的值进行对比。如果这个片元的深度值更小（更接近视点），那么就用这个片元来替换在像素颜色渲染缓存中的那个片元未知的任何颜色，并且刚刚渲染的片元的深度值来更新深度缓存。如果一个片元的深度值比在深度缓存中保存的值更大，这意味着某些已经渲染的片元更接近于视点。在这种情况下，新的片元在还没有更新像素颜色渲染缓存的情况下就会被丢弃。
 GPU把对于每个片元的深度的计算作为渲染的一个固有部分。深度缓存的使用为GPU提供了一个用来保存计算出的深度的地方，之后这个深度又被GPU利用来控制在像素颜色渲染缓存中的片元的位置。
 GLKView类让添加深度缓存变得很容易，只要设置视图的drawableDepthFormat属性为GLKViewDrawableDepthFormat16或者GLKViewDrawableDepthFormat24而不是默认值即可，具体执行代码为”GLKViewDrawableDepthFormatDepthFormatNone:view:drawableDepthFormat = GLKViewDrawableDepthFormat16;“。
 GLKit支持使用16位或者24位来保存深度值的深度渲染缓存。使用16位只可以表现65536个不同的深度。如果两个片元的深度非常接您，那么深度缓存可能就没有足够的精度来区分它们。像素颜色渲染中的最终片元颜色可能来自接近接近同一个深度的片元之一。事实上，这个结果有时也被称为深度冲突，因为最终的片元颜色常常会在可能性之间来回闪烁并在渲染场景中制造一个可见的干预。
 使用24位来保存深度值可以区分1700万个不同的深度值，同时这是以消耗更多的GPU稀缺内存为代价的。即使是使用24位，当共面三角形重叠的时候还可能会产生深度冲突，但这不是很常见。
 配置OpenGL ES状态的可选步骤允许改变GPU执行深度测试时所使用的哈数。例如，调用OpenGL ES glDepthFunc(GL_ALWAYS)函数实际上会禁止深度测试，因为所有渲染的片元会替换像素颜色缓存中这个片元的位置的先前的任何颜色。默认的深度测试函数是GL_LESS，它表示每个片元的位置的先前的任何颜色。默认的深度测试函数是GL_LESS，它表示每个片元的颜色只有在该片元的深度值小于深度缓存中该片元的位置所保存的值时才会替换像素颜色缓存的内容。更小的深度值意味着片元刚接近视点。glDepthFunc()指定的深度测试函数的完整集合是:GL_NEVER, GL_LESS ,GL_EQUAL,GL_LEQUAL,GL_GREATER,GL_NOTEQUAL ,GL_GEQUAL,GL_ALWAYS
 在前面的章节中，glClear()函数已经被用在例子中，它清除了缓存的内容。例如，调用glClear(GL_COLOR_BUFFER_BIT)会设置当前帧缓存的像素颜色缓存中的每个像素值为glClearColor()函数设定的颜色。调用glClear(GL_DEPTH_BUFFER_BIT)会设置当前缓存的深度缓存中的每个值为最大深度值。两个缓存通常勇一行代码来清楚，通过使用C语言的位OR操作符将参数结合到glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)。
 注意：几乎所有本书的例子所使用的AGLKContext中都包含”-setClearColor.“和”-clear:方法“，这两个方法封装了OpenGL ES的glClear()和glClear()函数。
 
 */

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize baseEffect;
@synthesize vertexNormalBuffer;
@synthesize vertexPositionBuffer;
@synthesize vertexTextureCoordBuffer;
/*
 如下方法添加了一个深度缓存和多个顶点缓存的代码。
 与之前把所有的顶点元素交错保存在一个缓存中的例子不同，在本例子中使用了多个顶点属性数组缓存。当所有的顶点属性靠在一起驻留在内存中时，大部分GPU可以最佳化执行。GPU可能会在一个内存操作中读取所需的所有值。然而，用来生成在sphere.h文件中声明的数据的脚本会保存定点位置，法向量和纹理坐标到不同的数组中，因此，如在前面的”-viewDidLoad“实现中以粗体标注的代码显示的一样，保存数据到不同缓存是最容易的，当一些顶点元素频繁变换而剩下的保存不变时，使用不同的缓存有时候有可能会产生一个性能优势。例如，如果纹理坐标从来不改变但是顶点位置频繁改变，那么把顶点位置保存到一个会用GL_DYNAMIC_DRAW提示的缓存中，把纹理坐标保存在另一个使用GL_STATIC_DRAW提示的缓存中，这样应该是最佳化的。
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, -0.8f, 0.0f);
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    /*
     使用多个顶点属性数组缓存提供的属性所做的绘制与以前的例子会有一点不同。为AGLKContext的"-clear:"方法指定GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT来自同一时间清除深度缓存和颜色渲染缓存。AGLKContext的”-clear：“方法会调用glClear()函数。在-viewDidLoad中创建每个AGLKVertexAttribArrayBuffer实例是为绘制准备的。准备好调用glBindBuffer(),glEnableVretexAttribArray()和glVetexAttribPointer()函数。最后，一个被添加到本例的AGLKVertexAttribArrayBuffer类的列方法+ (void)drawPreparedArraysWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count会调用glDrawArrays()函数，这个函数会绘制顶点，使用从每个开启属性的缓存指针搜集来的数据。
     */
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.vertexPositionBuffer= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    //如下代码开启了片元深度测试，如果好奇看看在不使用深度缓存的情况下在渲染过程中会发生什么，可以试着把如下的代码注释掉。
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
}
- (void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    self.vertexTextureCoordBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}
@end
