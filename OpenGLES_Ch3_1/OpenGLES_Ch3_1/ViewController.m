//
//  ViewController.m
//  OpenGLES_Ch3_1
//
//  Created by frank.Zhang on 22/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//
/*
 深入探讨GLKTextureLoader是怎么工作的：
 OpenGL ES 的纹理缓存与第一章讨论过的其他的缓存具有相同的步骤，首先使用glGenTextures()函数生成一个纹理缓存标识符；然后使用glBindTexture()函数将其绑定到当前上下文；接下来，通过使用glTextImage2D函数复制图像数据来初始化纹理缓存的内容
 */
#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize  baseEffect;
@synthesize vertexBuffer;
//纹理坐标
typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;
/*
 初始化纹理坐标和位置坐标。
 */
static const SceneVertex vertices[] = {
    {{-0.5f,-0.5f,0.0f},{0.0f,0.0f}},
    {{0.5f,-0.5f,0.0f},{1.0f,0.0f}},
    {{-0.5f,0.5f,0.0f},{0.0f,1.0f}},
};

- (void)viewDidLoad {
    [super viewDidLoad];

    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.vertexBuffer =  [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    //setup texture
    /*
     CGImageRef 是一个在苹果的Core Graphics框架中定义的C数据类型。Core Graphics包含很多强大的2D图像处理和绘制函数。UIImage的"+imgeNamed:"方法会返回一个初始化自图形文件的UIImage实例，很多不同的图像文件格式都支持，命名的图像必须包含一个为应用的一部分，以便"+imageNamed:"可以找到它。
     */
    CGImageRef imageRef = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    /*
     GLKTextureLoader的“-textureWithCGImage:”方法会接受一个CGImageRef并创建一个新的包含CGImageRef使得图像数据源的源可以是任何Core Graphics支持的形式，从一个电影的单个帧到由一个应用绘制的自定义2D图像，再到一个文件的内容。“options:”参数接受一个存储了用于指定GLKTextureLoader怎么解析加载的图像数据的键值对的NSDictinary。可用选项之一是指示GLKTextureLoader为加载的图像生成MIP贴图。
     GLKTextureLoader会自动调用glTextParameteri()方法来为创建的纹理缓存设置OpenGL ES取样和循环模式，如果使用了MIP贴图，并且GL_TEXTURE_MIN_FILTE被设置成GL_LINEAR_MIPMAP_LINEAR，这会告诉OpenGL ES 使用与被取样的S，T坐标最近的纹素的线性插值取样两个最合适的MIP贴图图像尺寸(细节级别)。然后，来自MIP贴图的两个样本被线性插值来产生最终的片颜色。GL_LINEAR_MIPMAP_LINEAR过滤器通常会产生高质量的渲染输出，但是会比其他模式需要更多的GPU计算。如果没有使用MIP贴图，GLKTextureLoader会自动设置GL_TEXTURE_MIN_FILTER为GL_LINEAR。GL_TEXTURE_WRAP_S和GL_TEXTURE_WRAP_T都会被设置为GL_CLLAMP_TO_EDGE。
     */
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}
/*
 GLKTextureInfo类封装了与刚创建的纹理缓存相关的信息，包括它的尺寸以及它是否包含MIP贴图，但是这个例子只需要缓存的OpenGL ES标识符，名字和用于纹理的OpenGL ES目标。OpenGL ES上下文会为各种缓存分别保存配置信息。镇缓存会被单独从顶点属性数组缓存或者纹理缓存配置。事实上，OpenGL ES的上下文支持多种纹理缓存，例如：一种纹理缓存会包含普通的2D图像数据，然后另一种会保存一个用于特殊效果的特别形状的图像。GLKTextureInfo的target属性指定被配置的纹理缓存的类型，一些OpenGL ES实现还会为1D 和3D纹理保持独立的纹理缓存目标。
 */
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    //告诉vertexBuffer让OpenGL ES为每个顶点的两个纹理坐标的渲染做好准备。编译器会用纹理坐标开始的每个SceneVertex结构体内的内存偏移来代替ANSI C的offsetof()宏。
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    //指示OpenGL ES 去渲染有纹理的三角形。
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
