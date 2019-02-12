//
//  ViewController.m
//  OpenGLES_Ch5_5
//
//  Created by frank.zhang on 2019/1/28.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
上一个例子通过复制矩阵到一个临时的变量来保存并恢复modelviewMatrix。GLKit提供了一个方便的数据类型GLKMatrixStack,还提供了一个用来向栈数据结构保存矩阵的函数集合。堆栈是一个先进后出的数据结构，它可以方便地存储某个程序可能需要恢复的矩阵。GLKMatrixStack会实现一个4X4矩阵的堆栈。GLKMatrixStackPush()函数会复制最顶部的矩阵到堆栈的顶部。GLKit为修改矩阵堆栈顶部的矩阵提供了一个综合的函数集合。包括GLKMatrixStackMultiplymatrix4()函数，则个函数是其他函数的基础，GLKMatrixStackGetMatrix4()函数会返回最顶部的矩阵。GLKMatrixStackPop()函数会移除堆栈最顶部的项，并且把前面一个顶部矩阵恢复到最顶部位置。
 应用会堆入一个新矩阵到栈顶部，操作并使用它在OpenGL ES中渲染几何图形，然后把它弹出堆栈并把上一个矩阵恢复到对战的顶部。
 */

/*
 复合变换手册
 下面会讲解一些常见的复合变换手册：
 1：倾斜：
 倾斜是一个复合变换，这个变换产生了不再相互垂直的坐标轴。立方体会变成带有梯形面的盒子。
 1）围着一个轴旋转。
 2）施加不均匀的缩放，比如缩放X轴但不缩放Y轴或者Z轴。
 3）沿着在第一步中使用的轴做反向旋转。
 想要在上一个例子中看到的倾斜效果，首先围着Y轴旋转45度，然后沿着X轴尽量放大，最后我这Y轴回转。测试并且试着对其白色变换轴和半透明的参考轴。
 2：围着一个点旋转
 旋转和缩放常常围着当前坐标系的原点发生。想想一下，太阳就是我们太阳系的假象坐标系的原点。地球围绕着太阳旋转，但是也沿着一条自己的轴旋转。围着一个第纳尔不是一个原点旋转的解决方案也很简单。
 1）平移到所需的旋转中心。
 2）施加所需的旋转。
 3）使用与第一步相反的平移值平移回来。
3：围着一个点缩放
 围绕着任意一个点缩放与围绕一个点旋转相似。
 1）平移到所需的缩放中心。
 2）施加想要的缩放。
 3）使用与第一步相反的平移值平移回来。
 */

/*
 透视和平截头体
 OpenGL ES使用一个叫做视域的几何图形来决定一个场景生成的哪些片元将会显示在最终的渲染结果中。处于视域范围之外的几何图形会被剔除，这个意味着它会被丢弃。视域有时也被称为投影。在本章之前，在例子中使用的视域一直是一个立方体，这个立方体包括了在X轴上从-1.0到1.0，Y轴上从-1.0到1.0，Z轴上-1.0到1.0范文内的所有顶点、这就是当projectionmatrix是一个单位矩阵时的默认投影结果。
 一个立方体或者矩形视域叫做一个正射投影。利用一个正射投影m，视点与每个位置之间的距离对于投影毫无影响。GLKit的GLKMatrix4Makeortho(GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far)函数会返回一个矩阵，这个矩阵定义了一个由left和right，bottom,top，near和far所界定的矩形视域。
 当使用透视投影时，视域不再是矩形，它变成了角锥体被切去顶端之后的形状---成为“平截头体”。当投影到2D像素颜色渲染缓存中后，离视点越远的对象越小，但是接近视点的对象仍然很大。GLKit的GLKMatrix4MakeFrustum()函数与GLKMatrix4MakeOrtho()函数的参数形同，并且会创建一个包含透视的新变换矩阵。这个矩阵通常会与当前projectionmatrix级联来定义视域。
 注意：对GLKMatrix4MakeFrustum()函数的限制产生了一个小问题：OpenGL ES默认为一个指入屏幕的负的Z坐标轴，但是GLKMatrix4MakeFrustum()总会产生一个指入屏幕的带有正的Z坐标轴的视域。GLKMatrix4MakeFrustum()函数翻转了Z坐标轴的符号。
 使用视域的另一个关键是要认识到，正射和透视投影都是由站在位置{0,0,0}并向下俯视Z轴的观察者的视点产生的。
 */
#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "AGLKTextureTransformBaseEffect.h"
@implementation ViewController
@synthesize baseEffect;
@synthesize vertexBuffer;
@synthesize textureScaleFactor;
@synthesize textureAngle;
@synthesize textureMatrixStack;
typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;

static const SceneVertex vertices[] =
{
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textureMatrixStack =
    GLKMatrixStackCreate(kCFAllocatorDefault);
    
    self.textureScaleFactor = 1.0; // Initial texture scale factor
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect =
    [[AGLKTextureTransformBaseEffect alloc] init];

    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(
                                                   1.0f, // Red
                                                   1.0f, // Green
                                                   1.0f, // Blue
                                                   1.0f);// Alpha
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices
                         usage:GL_STATIC_DRAW];
    
    // Setup texture0
    CGImageRef imageRef0 =
    [[UIImage imageNamed:@"leaves.png"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader
                                    textureWithCGImage:imageRef0
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES],
                                             GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    CGImageRef imageRef1 =
    [[UIImage imageNamed:@"beetle.png"] CGImage];
    
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader
                                    textureWithCGImage:imageRef1
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES],
                                             GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.enabled = GL_TRUE;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [self.baseEffect.texture2d1
     aglkSetParameter:GL_TEXTURE_WRAP_S
     value:GL_REPEAT];
    [self.baseEffect.texture2d1
     aglkSetParameter:GL_TEXTURE_WRAP_T
     value:GL_REPEAT];
    GLKMatrixStackLoadMatrix4(
                              self.textureMatrixStack,
                              self.baseEffect.textureMatrix2d1);
}
/*
 桌面OpenGL ES和OpenGL ES 1.x包含三个内建的矩阵堆栈。前两个保存投影矩阵和model-view矩阵。第三个是纹理矩阵，S和T坐标系的纹理与顶点的U和V坐标之间有一个映射，纹理矩阵会想这个映射施加变换。纹理映射是在3章中讲解的。在写作本书是，GLKBaseEffect的transform属性还没有使用或者提供一个textureMatrix。因此，本例子使用一个新的AGLKTextureTransformBaseEffect类扩展了GLKit的GLKBaseEffect类，用来显示使用纹理矩阵可能会产生的一些效果。正如b本书中的其他AGLK类，如果某天GLKit添加了一个textureMatrix属性，那么应该优先使用苹果的实现。
 注意：
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:offsetof(SceneVertex, positionCoords)
     shouldEnable:YES];
    
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:offsetof(SceneVertex, textureCoords)
     shouldEnable:YES];
    
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
     numberOfCoordinates:2
     attribOffset:offsetof(SceneVertex, textureCoords)
     shouldEnable:YES];
    /*
     当使用多重纹理时，textureMatrix2d1属性会保存用来变换第二个纹理的纹理坐标的矩阵。多重纹理效果是在3.5节介绍的。AGLKTexture TransformBaseEffect还提供了一个textureMatrix2d0属性，用于使用多重纹理时第一个纹理的纹理坐标的变换。
     */
    GLKMatrixStackPush(self.textureMatrixStack);
    GLKMatrixStackTranslate(
                            self.textureMatrixStack,
                            0.5, 0.5, 0.0);
    GLKMatrixStackScale(
                        self.textureMatrixStack,
                        textureScaleFactor, textureScaleFactor, 1.0);
    GLKMatrixStackRotate(   // Rotate about Z axis
                         self.textureMatrixStack,
                         GLKMathDegreesToRadians(textureAngle),
                         0.0, 0.0, 1.0);
    GLKMatrixStackTranslate(
                            self.textureMatrixStack,
                            -0.5, -0.5, 0.0);
    self.baseEffect.textureMatrix2d1 =
    GLKMatrixStackGetMatrix4(self.textureMatrixStack);
    [self.baseEffect prepareToDrawMultitextures];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    GLKMatrixStackPop(self.textureMatrixStack);
    self.baseEffect.textureMatrix2d1 =
    GLKMatrixStackGetMatrix4(self.textureMatrixStack);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    CFRelease(self.textureMatrixStack);
    self.textureMatrixStack = NULL;
}


- (IBAction)takeTextureScaleFactorFrom:(UISlider *)sender {
    self.textureScaleFactor = [sender value];
}

- (IBAction)takeTextureAngleFrom:(UISlider *)sender {
    self.textureAngle = [sender value];
}

@end
