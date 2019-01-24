//
//  ViewController.m
//  OpenGLES_Ch4_1
//
//  Created by frank.zhang on 2019/1/21.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
 3D计算机图形技术会把物体的数学描述转换成逼真的幻象。人类大脑可以解释在平面屏幕上现实的图片，还可以部分基于几个图形的暗示感知不存在的深度。例如感觉小的物体要比大的物体更远一些。如果一个物体盖住另一个物体的一部分，人脑就可以感觉到前后。但是，要呈现现有深度的错觉就要有模拟的灯光效果。
 本章会介绍用于模拟3D物体与光线之间的相互作用的多个技术，OpenGL ES使用GPU来计算每一个场景中的几何图形投射和散发出的模拟光线的数量。通常，GPU首先为每个三角形的每个定点执行光线计算，然后把计算的结果插补在定点之间来修改每个渲染片元的最终颜色。因此模拟灯光的质量和光滑程度要取决于组成每个3D物体的顶点的数量。模拟灯光的另一种方法会增强或替代传统的模拟方法。在许多情况下，灯光效果可以被预算并被“烘焙”进纹理中，以便可以在完全不需要GPU光线计算的情况下产生逼真的场景。然而另一中方法会利用GPU的能力为渲染场景中的每个单独的片元分别计算和应用灯光效果。
 本章会介绍灯光模拟背后的概念，利用GLKit并使用相对简单的应用代码演示灯光效果。GLKit复制了OpenGL ES 1.x的传统灯光能力，同时为大部分应用提供了适当的内建灯模拟方式。
 */

/*
OpenGL ES灯光模拟由每个光源的三个截然不同的部分组成：环境光，漫反射光，镜面反射。程序会分别配置每个部分的颜色。环境光来自各个方向，因此会同等地增强所有几何图形的亮度。程序通过设置模拟环境光的颜色和亮度来设置场景中的背景灯光的基础水平。环境光的颜色会着色所有的几何图形，因此一个红色的环境光会让一个场景中的所有几何图形对象显现红色或者粉红色。每个光源的漫反射部分是定向的，会基于三角形相对于光线的方向来照亮场景中的每一个三角形。如果一个三角形的平面垂直于光线的方向，那么漫反射会直接投射到三角形上，并被剧烈地散射开来，这样会让三角形显得灯光通明。如果三角形的平面是平行于光线的方向或者背离光线的方向，那么几乎没有任何光线会照射到三角形上，因此漫反射很少或者几乎不会对三角形的亮度产生影响。漫反射的颜色只会着色被定向的光线照射到三角形。最后从几何图形对象反射出来的光线叫做镜面反射光。镜面物体会反射大量的光线，但是钝面的物体不会。因此镜面反射光的感知亮度是由照射到每个三角形上的光线的量和三角形的反光度决定的。镜面反射部分的颜色决定了闪光点的颜色。
 */

/*
 环境光：光源的光线从所有方向照向平面。
 漫反射光：定向光线会照向跟定向光线接近垂直平面，忽略跟定向光线平行的面。
 镜面反射光：定向光线会从一个跟定向光线接近垂直的面反向回来，忽略跟定向光线平行的面。
 */
/*
 iOS5的GLKit使用与下面摘录的用于漫反射的代码相似的Shading Language代码为每一个光线实现了标准的灯光模拟方程式：
 vec3 eyeNormal = normalize(uNormalMatrix * Normal);
 float nDotVP = max(0.0,dot(eyeNormal, ulightDirection));
 vColor = vec4((uDiffuseColor * nDotVP).xyz, uDiffuseColor.a);
 现在不用担心不理解Shading Language摘录。这里提供它只是为了显示出GPU实现灯光模拟的方式的特点。这个代码会改变每个顶点的法向量来匹配正在被渲染的场景的方向，计算光线方向与心得法向量之间的标量积，然后使用这个标量积来按比例决定光的漫反射颜色的影响力。GLKit会自动地自动生成与摘录相似的Shading language代码，以便同时混入每个光线的镜面发射光和环境光颜色。
 GLKit的GLKBaseEffect类最多支持三个命名为light0,light1, light2的模拟灯光。每个灯光都有一个相同名字的GLKBaseEffect属性所代表。这些属性是GLKEffectPropertyLight类的实例，这些属性反过来又包含用于设置每个灯光的属性。每一个灯光都由一个相同名字的GLKBaseEffect属性所代表。这些属性是GLKEffectPropertyLight类的实例，这些属性反过来又包含用于设置每个灯光的属性。每个灯光至少有一个位置，一个环境颜色，一个漫反射颜色和一个静默安反射颜色。每个灯光都可以被单独地开启和关闭。
 */

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
}
SceneVertex;
//SceneTriangle声明了一个用于用于保存定义一个三角形的三个顶点的结构体。
typedef struct {
    SceneVertex vertices[3];
}
SceneTriangle;

static const SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE = {{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

#define NUM_FACES (8)
#define NUM_NORMAL_LINE_VERTS (48)
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)
static SceneTriangle SceneTriangleMake(const SceneVertex vertexA, const SceneVertex vertexB, const SceneVertex vertexC);
static GLKVector3 SceneTriangleFaceNormal( const SceneTriangle triangle);
static void SceneTrianglesUpdateFaceNormals(SceneTriangle someTriangles[NUM_FACES]);
static void SceneTrianglesUpdateVertexNormals( SceneTriangle someTriangles[NUM_FACES]);
static  void SceneTrianglesNormalLinesUpdate( const SceneTriangle someTriangles[NUM_FACES], GLKVector3 lightPosition, GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]);

static  GLKVector3 SceneVector3UnitNormal( const GLKVector3 vectorA, const GLKVector3 vectorB);

@interface ViewController ()
{
    SceneTriangle triangles[NUM_FACES];
}
@end

@implementation ViewController
@synthesize baseEffect;
@synthesize extraEffect;
@synthesize vertexBuffer;
@synthesize extraBuffer;
@synthesize centerVertexHeight;
@synthesize shouldUseFaceNormals;
@synthesize shouldDrawNormals;
/*
 灯光的漫反射颜色被设置为不透明中等灰色。灯光的镜面反射和环境颜色保持为GLKit的默认值，分别为不透明白色和不透明黑色。这意味着灯光的漫反射部分不会影响场景并且高反光的物体会显得非常有光泽。
 这段代码使用一个带有四个元素的GLKVector4来设置光源的位置。前三个光源的位置。前三个元素要么是光源的X,Y和Z位置，要么是指向一个无线远的光源的方向。第四个元素指定了前三个元素是一个位置还是一个方向。如果是第四个元素是零，前三个元素就是一个方向；如果第四个元素非零，光源会从它的位置向各个方向投射光线。因此每个顶点的光线方向是多种多样的，并且必须要由GPU使用从每个方向发散光线的聚光灯。
 
 */
/*
 在一个或多个GLKBaseEffect的灯光被开启后，灯光决定了渲染的物体的颜色；GLKBaseEffect的常量的颜色和所有的顶点的颜色被忽略了。本例子使用了一个开启了灯光绘制的场景，然后使用GLKBaseEffect的constantColor属性(而不是使用一个灯光)绘制了线段。需要两个独立的GLKBaseEffect实例，因为在iOS5中，在一个GLKBaseEffect的灯光被创建以后，constantColor属性就被忽略了，即使GLKBaseEffect的灯光被关闭了。例如“BaseEffect.light0.enabled = GL_FALSE;”
 注意作为最后的手段，GLKBaseEffect的constantColor属性会告诉GLKBaseEffect为生成的片元是用什么颜色。大部分OpenGl ES 应用使用某种灯光和纹理的结合来决定片元的颜色。constantColor属性仅适用于渲染单调不发光的物体。
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
   //下面的代码显示了怎么使用GLKit灯光
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         0.7f, // Red
                                                         0.7f, // Green
                                                         0.7f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     1.0f,
                                                     0.5f,
                                                     0.0f);
    
    extraEffect = [[GLKBaseEffect alloc] init];
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor = GLKVector4Make(
                                                    0.0f, // Red
                                                    1.0f, // Green
                                                    0.0f, // Blue
                                                    1.0f);// Alpha
    
    /*
     注释下面这个括号里面的代码，就是用一个俯视图对的视角来显示整个图形
     */
    {
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeRotation(
                                                            GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        modelViewMatrix = GLKMatrix4Rotate(
                                           modelViewMatrix,
                                           GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        modelViewMatrix = GLKMatrix4Translate(
                                              modelViewMatrix,
                                              0.0f, 0.0f, 0.25f);
        
        self.baseEffect.transform.modelviewMatrix = modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix = modelViewMatrix;
    }
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    //从0到7的8个三角形被使用如下的vertexA到vertexI的定点初始化，然后三角形被存储在一个定点属性数组缓存中以提供GPU使用。
    triangles[0] = SceneTriangleMake(vertexA, vertexB, vertexD);
    triangles[1] = SceneTriangleMake(vertexB, vertexC, vertexF);
    triangles[2] = SceneTriangleMake(vertexD, vertexB, vertexE);
    triangles[3] = SceneTriangleMake(vertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, vertexE, vertexH);
    triangles[5] = SceneTriangleMake(vertexE, vertexF, vertexH);
    triangles[6] = SceneTriangleMake(vertexG, vertexD, vertexH);
    triangles[7] = SceneTriangleMake(vertexH, vertexF, vertexI);
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
                         bytes:triangles
                         usage:GL_DYNAMIC_DRAW];
    self.extraBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                        initWithAttribStride:sizeof(SceneVertex)
                        numberOfVertices:0
                        bytes:NULL
                        usage:GL_DYNAMIC_DRAW];
    self.centerVertexHeight = 0.0f;
    self.shouldUseFaceNormals = YES;
}

-(void)drawNormals{
    GLKVector3  normalLineVertices[NUM_LINE_VERTS];
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.baseEffect.light0.position.v),
                                    normalLineVertices);
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3)
                            numberOfVertices:NUM_LINE_VERTS
                                       bytes:normalLineVertices];
    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                          numberOfCoordinates:3
                                 attribOffset:0
                                 shouldEnable:YES];
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor =
    GLKVector4Make(0.0, 1.0, 0.0, 1.0); // Green
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:0
                       numberOfVertices:NUM_NORMAL_LINE_VERTS];
    self.extraEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0); // Yellow
    [self.extraEffect prepareToDraw];
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:NUM_NORMAL_LINE_VERTS
                       numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
}
/*
 每次“-setCenterVertexHeight:“方法被调用来改变centerVertexHeight属性的值时，vertexE的高度（Z分量）也改变了，并且包含vertexE的四个三角形也被重新创建。下面的”updateNormals“方法被调用来重新计算受影响后的法向量。
 */
/*
 包含法向量的三角形的顶点值被更新在顶点属性数组缓存中，以便在下一次场景被渲染时，他们可以被GPU使用。如果你对于法向量重新计算的数学计算过程比较好奇，SceneTrianglesUpdateFaceNormals函数，它使用了SceneVector3UnitNormal()函数。
 */
- (void)updateNormals
{
    if(self.shouldUseFaceNormals)
    {
        SceneTrianglesUpdateFaceNormals(triangles);
    }else{
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    [self.vertexBuffer
     reinitWithAttribStride:sizeof(SceneVertex)
     numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)
     bytes:triangles];
}
/*
使用baseEffect渲染的三角形包含由GLKit在后台自动生成的Shanding Language程序提供的模拟灯光。最后，如果shouldDrawNormals属性值是YES，那么属性值是YES，那么-drawNormals方法会被调用。
 */
/*
 使用本例子做测试来影响渲染结果。试着改变灯光的位置。这个例子会为光源保持默认颜色值，试着为环境和镜面反射部分指定颜色。试着添加第二个光源。
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, position)
                                  shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, normal)
                                  shouldEnable:YES];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
   /*
    shouldDrawNormal属性同centerVertexHeight和ShouldUseFaceNormals属性一起在ViewController中声明。更新属性值的代码在当前的类的实现中。每当一个如滑块或者切换器的用户界面对象改变时，viewcontroller会使用Cocoa Touch Target-Action设计模式。本质上接收一个单独的对象参数的方法会被用户界面对象调用来更新应用的状态。改变状态的特定对象是用户界面对象的目标（target）。这个方法叫做动作（action）。按照惯例，动作方法的参数是调用这个动作的用户界面对象。
    */
    if(self.shouldDrawNormals)
    {
        [self drawNormals];
    }
}

- (void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


- (IBAction)leftSwitchAction:(UISwitch *)sender {
    self.shouldUseFaceNormals = sender.isOn; 
}

- (IBAction)rightSwitchAction:(UISwitch *)sender {
    self.shouldDrawNormals = sender.isOn;
}
- (IBAction)sliderAction:(UISlider *)sender {
    self.centerVertexHeight = sender.value;
}

#pragma mark - Accessors with side effects
- (GLfloat)centerVertexHeight
{
    return centerVertexHeight;
}
/*
 ViewController通过实现属性的自定义访问器方法来拦截睡醒的改变。访问器是在第二章中介绍的，他们是被特别命名的方法，可以被调用来修改属性值。当编译类似“self.centerVertexHeight = sender.value”的点标记语法时，Objective-C编译器会自动生成对于访问器方法的调用。用来设置centerVertexHeight属性的值得方法被命名为“-setCenterVertexHeight:”
 */
- (void)setCenterVertexHeight:(GLfloat)aValue
{
    centerVertexHeight = aValue;
    SceneVertex newVertexE = vertexE;
    newVertexE.position.z = self.centerVertexHeight;
    triangles[2] = SceneTriangleMake(vertexD, vertexB, newVertexE);
    triangles[3] = SceneTriangleMake(newVertexE, vertexB, vertexF);
    triangles[4] = SceneTriangleMake(vertexD, newVertexE, vertexH);
    triangles[5] = SceneTriangleMake(newVertexE, vertexF, vertexH);
    [self updateNormals];
}

- (BOOL)shouldUseFaceNormals
{
    return shouldUseFaceNormals;
}

- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != shouldUseFaceNormals)
    {
        shouldUseFaceNormals = aValue;
        [self updateNormals];
    }
}
@end

#pragma mark - Triangle manipulation
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex vertexA,
                                       const SceneVertex vertexB,
                                       const SceneVertex vertexC)
{
    SceneTriangle   result;
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    return result;
}

static GLKVector3 SceneTriangleFaceNormal(const SceneTriangle triangle)
{
    GLKVector3 vectorA = GLKVector3Subtract(
                                            triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(
                                            triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(
                                  vectorA,
                                  vectorB);
}

/*
 
 */
static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES])
{
    int i;
    for (i=0; i<NUM_FACES; i++)
    {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(
                                                        someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}

static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES])
{
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    GLKVector3 faceNormals[NUM_FACES];
    
    // Calculate the face normal of each triangle
    for (int i=0; i<NUM_FACES; i++)
    {
        faceNormals[i] = SceneTriangleFaceNormal(
                                                 someTriangles[i]);
    }
    
    // Average each of the vertex normals with the face normals of
    // the 4 adjacent vertices
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[1]),
                                                                             faceNormals[2]),
                                                               faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[1],
                                                                                           faceNormals[3]),
                                                                             faceNormals[5]),
                                                               faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[4],
                                                                                           faceNormals[5]),
                                                                             faceNormals[6]),
                                                               faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    someTriangles[0] = SceneTriangleMake(
                                         newVertexA,
                                         newVertexB,
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(
                                         newVertexB,
                                         newVertexC,
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexB,
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexB,
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexE,
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(
                                         newVertexE,
                                         newVertexF,
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(
                                         newVertexG,
                                         newVertexD,
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(
                                         newVertexH,
                                         newVertexF,
                                         newVertexI);
}

static  void SceneTrianglesNormalLinesUpdate(
                                             const SceneTriangle someTriangles[NUM_FACES],
                                             GLKVector3 lightPosition,
                                             GLKVector3 someNormalLineVertices[NUM_LINE_VERTS])
{
    int                       trianglesIndex;
    int                       lineVetexIndex = 0;
    
    // Define lines that indicate direction of each normal vector
    for (trianglesIndex = 0; trianglesIndex < NUM_FACES;
         trianglesIndex++)
    {
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[0].position;
        
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[0].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[0].normal,
                                               0.5));
        
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[1].position;
        
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[1].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[1].normal,
                                               0.5));
        
        someNormalLineVertices[lineVetexIndex++] =
        someTriangles[trianglesIndex].vertices[2].position;
        
        someNormalLineVertices[lineVetexIndex++] =
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[2].position,
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[2].normal,
                                               0.5));
        
    }
    someNormalLineVertices[lineVetexIndex++] =
    lightPosition;
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(
                                                            0.0,
                                                            0.0,
                                                            -0.5);
}

#pragma mark - Utility GLKVector3 functions
/*
 光线计算依赖于表面法向量，或者简称法向量。可以为任何一个三角形计算出一个法向量，法向量的方向垂直于一个三角形的平面并且法向量可以使用定义三角形的任意两个矢量的矢量积计算出来。法向量也是单位向量，这意味着一个法向量的大小（也成为长度）总是1.0。
 任何矢量都可以转换成一个单位向量，通过这个矢量的长度除以这个矢量的每一个分量。结果是一个与原先的矢量的方向相同的并且长度等于1.0的新矢量。因此，为了计算一个法向量，首先需要计算矢量积向量，然后用这个矢量积向量的的长度除以矢量积的每个分量，这个操作是如此的常见以至于转换矢量为单位矢量通常称为“标准化”操作。
 */
//下面的代码来计算法向量：
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB)
{
    return GLKVector3Normalize(
                               GLKVector3CrossProduct(vectorA, vectorB));
}

//矢量积是用GLKit的GLKVector3.h头文件内的一个内流连函数来计算的，下面的实现匹配实际的GLKitb实现并且已经为显示做了合法化：
/*
 GLK_INLINE GLKVector3 GLKVector3CrossProduct(GLKVector3 vectorLeft, GLKVector3 vectorRight)
 {
 GLKVector3 v = { vectorLeft.v[1] * vectorRight.v[2] - vectorLeft.v[2] * vectorRight.v[1],
 vectorLeft.v[2] * vectorRight.v[0] - vectorLeft.v[0] * vectorRight.v[2],
 vectorLeft.v[0] * vectorRight.v[1] - vectorLeft.v[1] * vectorRight.v[0] };
 return v;
 }
 */

