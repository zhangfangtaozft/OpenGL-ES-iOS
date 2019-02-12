//
//  ViewController.m
//  OpenGLES_Ch5_4
//
//  Created by frank.zhang on 2019/1/28.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

/*
 变换：
 从数学上说，变换就是在两个坐标之间转换顶点坐标。每一个坐标系都是相对于其他的参照坐标系定义的对于OpenGL ES来说，最终的参照坐标西是在一个像素颜色渲染缓存中的像素位置的2D数组。默认3D坐标系是相对于最终参考坐标系定义的。能够用来将-1.0~1.0范围内的X坐标值转换为像素颜色渲染缓存对应宽度处的像素位置，将-1.0~1.0到范围内的Y坐标值转换为像素颜色渲染缓存对应高度处的像素位置。除了Z坐标值在-1.0到1.0范围外的顶点不会绘制以外，Z坐标值不会影响默认3D坐标系跟像素坐标之间的转换。
 注意：
 在渲染过程中，GPU会转换点，线和三角形的顶点数据为着色的片元。当前（实际上是在GPU处理顶点数据时）坐标系决定了片元在像素颜色渲染缓存和深度缓存中的位置。当前坐标系因此决定了每个片元会显示在屏幕的哪里，并使从任意视点渲染场景成为可能。
 程序能够相对于默认3D坐标系（作为一个参考）定义一个新的坐标系。可以相对于其他坐标系定义任意数量的坐标系。因此，可以转换在任意坐标中的任意顶点位置为像素颜色渲染缓存中的一个位置。
 变换看起来需要大量的数学计算才能在坐标系之间进行转换。但是线性代数再次提供了解决方案。任意数量任意顺序的基本变换都能够被捕获并且保存在一个简单的4*4的浮点值矩阵中，一个矩阵定义一个坐标系。
 矩阵计算几乎完全使用加法和乘法，并且在现代GPU上执行得非常快。每次场景被渲染的时候，GPU都会变换所有的顶点，并且在一个场景中常常含有几十万个顶点。
 基本变换
 只存在四个基本变换：平移，旋转，缩放，和透视。基本变换决定了在一个新的坐标系中的每一个顶点位置是怎么转换为参考系中的一个位置的。四个基本变换足以产生变化无穷的坐标系。
 每个基本变换对应于矩阵的简单变化。定义一个与参考坐标系相同的坐标系的矩阵叫做单位矩阵。任意两个矩阵可以在一个级联操作中结合起来以产生一个新的矩阵，然后把这个简单的矩阵与当前变换矩阵连接起来已产生一个新的当期矩阵。
 注意：“矩阵级联”有时候被称为“矩阵乘法”。术语“矩阵乘法”还适用于使用一个矩阵把一个矢量或者一个顶点从一个坐标系变换到另一个的操作。“级联”是一个更精确的术语，它描绘了两个矩阵的结合，这个结合产生了饱含着两个源矩阵的所有信息的第三个矩阵。
 平移：通过相对于参考坐标系的原点移动新坐标系的原点，平移定义了一个新的坐标系。平移不会影响坐标轴的单位长度，平移不会改变坐标轴相对于参考坐标系的方向。
 GLKit提供了GLKMatrix4makeTranslation(float x, float y, float z)函数，这个函数通过平移一个单位矩阵来返回一个定义了坐标系的新矩阵。x,y,z参数指定了新坐标系的原点沿着当前参考坐标系的每个轴移动的单位数。函数GLKMatrix4translate(GLKMatrix4matrix, float x, float y, float z)通过平移作为参数传入的矩阵来返回定义了一个坐标系的新矩阵。从概念上看看，GLKMatrix4Translate()会返回参数矩阵与GLKMatrix4MakeTranslation()产生的新矩阵的级联。
 旋转：旋转是通过相对于参考坐标系坐标轴的方向旋转新坐标系的坐标轴来定义一个新坐标系。旋转的坐标系会与参考坐标系使用同一个原点。旋转不会影响坐标轴的单位长度，只有坐标轴的方向会发生变化。
 GLKit提供了GLKMatrix4makeRotation(float angleRadians, float x, float y, float z)函数，这个函数通过旋转一个单位矩阵来返回定义了一个坐标系的新矩阵。angleRadians参数指定了要旋转的弧度数。使用GLKMathDegreesToRadians()函数可以把角度转换成弧度。,y,z参数用于当前坐标系的哪一个轴可以作为当前旋转的轮毂。例如：代码GLKMatrix4MakeRotation(GLKMathDegreesToRadians(30.0),1.0,1.0,1.0);会沿着一个特定的坐标系的X轴旋转30度来产生一个新的坐标系。GLKMatrix4Rotate(GLKMatrix4 matrix,float angleRadians, float x, float y, float z)函数会通过旋转一个作为参数传入的矩阵来返回定义了一个坐标系的新矩阵。从概念上看，GLKMatrix4Rotate()会返回参数矩阵与GLKMatrix4makeRotation()产生的新矩阵的级联。
 缩放：缩放是通过相对于参考坐标系的坐标轴的单位长度改变新坐标系的坐标轴的单位长度来定义一个新坐标系。缩放的坐标系与参考坐标系使用同一个原点坐标轴的方向通常不会改变。不过，通过一个负值所做的缩放会翻转坐标系的方向。例如，如果增加一个坐标轴的值通常代表方向向上，那么使用一个负值缩放那个坐标轴后再增加这个坐标轴的值就代表方向向下。
 GLKit提供了GLKMatrix4makeScale(float x, float y, float, z)函数，这个函数会通过扩大或者缩小一个单位矩阵的任意坐标轴的单位长度来返回一个定义了坐标系的矩阵。x,y,z参数指定了用来扩大或者缩小的每个轴的单位长度的因数。GLKMatrix4Scale(GLKMatrix4 matrix, float x, float y, float z)函数通过指定的因数缩放作为参数传入的矩阵来返回一个定义了坐标系的新矩阵。从概念上看，GLKMatrix4Scale()会返回参数矩阵与GLKMatrix4MakeScale()产生的新矩阵的级联。例如：函数GLKMatrix4Scale(matrix, 2.0,2.0, 2.0)会返回一个新矩阵，这个矩阵拉伸了由参数矩阵定义的坐标系的X和Z轴的单位长度。
 透视：透视是通过相对参考坐标系的坐标轴的单位长度多样化新坐标系的坐标轴的单位长度来定义一个新的坐标系。透视坐标轴的方向或者原点，但是坐标轴的每个单位距离原点越远长度越短。这个效果会让子远处的物体比离原点近的物体显得更小。
 GLKit提供了GLKMatrix4MakeFrustum(float left, float right, float bottom, float top, float nearVal, float farVal)函数，这个函数会透视一个单位矩阵来返回一个定义了坐标系的新矩阵。透视坐标系的形状是一个类似于角锥体的平截头体。平截头体会在后面有介绍。
 */

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "lowPolyAxesAndModels2.h"

static GLKMatrix4 SceneMatrixForTransform(
                                          SceneTransformationSelector type,
                                          SceneTransformationAxisSelector axis,
                                          float value);

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISlider *transform1ValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *transform2ValueSlider;
@property (weak, nonatomic) IBOutlet UISlider *transform3ValueSlider;

@end

@implementation ViewController
@synthesize baseEffect;
@synthesize vertexPositionBuffer;
@synthesize vertexNormalBuffer;
@synthesize transform1ValueSlider;
@synthesize transform2ValueSlider;
@synthesize transform3ValueSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.4f, // Red
                                                         0.4f, // Green
                                                         0.4f, // Blue
                                                         1.0f);// Alpha
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);
    
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    self.vertexPositionBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                                 initWithAttribStride:(3 * sizeof(GLfloat))
                                 numberOfVertices:sizeof(lowPolyAxesAndModels2Verts) /
                                 (3 * sizeof(GLfloat))
                                 bytes:lowPolyAxesAndModels2Verts
                                 usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                               initWithAttribStride:(3 * sizeof(GLfloat))
                               numberOfVertices:sizeof(lowPolyAxesAndModels2Normals) /
                               (3 * sizeof(GLfloat))
                               bytes:lowPolyAxesAndModels2Normals
                               usage:GL_STATIC_DRAW];
    
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    
    GLKMatrix4 modelviewMatrix = GLKMatrix4MakeRotation(
                                                        GLKMathDegreesToRadians(30.0f),
                                                        1.0,  // Rotate about X axis
                                                        0.0,
                                                        0.0);
    modelviewMatrix = GLKMatrix4Rotate(
                                       modelviewMatrix,
                                       GLKMathDegreesToRadians(-30.0f),
                                       0.0,
                                       1.0,  // Rotate about Y axis
                                       0.0);
    modelviewMatrix = GLKMatrix4Translate(
                                          modelviewMatrix,
                                          -0.25,
                                          0.0,
                                          -0.20);
    self.baseEffect.transform.modelviewMatrix = modelviewMatrix;
    [((AGLKContext *)view.context) enable:GL_BLEND];
    [((AGLKContext *)view.context)
     setBlendSourceFunction:GL_SRC_ALPHA
     destinationFunction:GL_ONE_MINUS_SRC_ALPHA];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    const GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakeOrtho(
                        -0.5 * aspectRatio,
                        0.5 * aspectRatio,
                        -0.5,
                        0.5,
                        -5.0,
                        5.0);
    [((AGLKContext *)view.context)
     clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [self.vertexPositionBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    [self.vertexNormalBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:0
     shouldEnable:YES];
    GLKMatrix4 savedModelviewMatrix =
    self.baseEffect.transform.modelviewMatrix;
    GLKMatrix4 newModelviewMatrix =
    GLKMatrix4Multiply(savedModelviewMatrix,
                       SceneMatrixForTransform(
                                               transform1Type,
                                               transform1Axis,
                                               transform1Value));
    newModelviewMatrix =
    GLKMatrix4Multiply(newModelviewMatrix,
                       SceneMatrixForTransform(
                                               transform2Type,
                                               transform2Axis,
                                               transform2Value));
    newModelviewMatrix =
    GLKMatrix4Multiply(newModelviewMatrix,
                       SceneMatrixForTransform(
                                               transform3Type,
                                               transform3Axis,
                                               transform3Value));
    
    // Set the Modelview matrix for drawing
    self.baseEffect.transform.modelviewMatrix = newModelviewMatrix;
    
    // Make the light white
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:lowPolyAxesAndModels2NumVerts];
    self.baseEffect.transform.modelviewMatrix =
    savedModelviewMatrix;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         0.0f, // Blue
                                                         0.3f);// Alpha
    
    [self.baseEffect prepareToDraw];
    [AGLKVertexAttribArrayBuffer
     drawPreparedArraysWithMode:GL_TRIANGLES
     startVertexIndex:0
     numberOfVertices:lowPolyAxesAndModels2NumVerts];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

static GLKMatrix4 SceneMatrixForTransform(
                                          SceneTransformationSelector type,
                                          SceneTransformationAxisSelector axis,
                                          float value)
{
    GLKMatrix4 result = GLKMatrix4Identity;
    switch (type) {
        case SceneRotate:
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeRotation(
                                                    GLKMathDegreesToRadians(180.0 * value),
                                                    1.0,
                                                    0.0,
                                                    0.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeRotation(
                                                    GLKMathDegreesToRadians(180.0 * value),
                                                    0.0,
                                                    1.0,
                                                    0.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeRotation(
                                                    GLKMathDegreesToRadians(180.0 * value),
                                                    0.0,
                                                    0.0,
                                                    1.0);
                    break;
            }
            break;
        case SceneScale:
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeScale(
                                                 1.0 + value,
                                                 1.0,
                                                 1.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeScale(
                                                 1.0,
                                                 1.0 + value,
                                                 1.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeScale(
                                                 1.0,
                                                 1.0,
                                                 1.0 + value);
                    break;
            }
            break;
        default:
            switch (axis) {
                case SceneXAxis:
                    result = GLKMatrix4MakeTranslation(
                                                       0.3 * value,
                                                       0.0,
                                                       0.0);
                    break;
                case SceneYAxis:
                    result = GLKMatrix4MakeTranslation(
                                                       0.0,
                                                       0.3 * value,
                                                       0.0);
                    break;
                case SceneZAxis:
                default:
                    result = GLKMatrix4MakeTranslation(
                                                       0.0,
                                                       0.0,
                                                       0.3 * value);
                    break;
            }
            break;
    }
    return result;
}


- (IBAction)resetIdentity:(id)sender {
    [transform1ValueSlider setValue:0.0];
    [transform2ValueSlider setValue:0.0];
    [transform3ValueSlider setValue:0.0];
    transform1Value = 0.0;
    transform2Value = 0.0;
    transform3Value = 0.0;
}

- (IBAction)takeTransform1TypeFrom:(id)sender {
    transform1Type = [sender selectedSegmentIndex];
}

- (IBAction)takeTransform2TypeFrom:(id)sender {
    transform2Type = [sender selectedSegmentIndex];
}
- (IBAction)takeTransform3TypeFrom:(id)sender {
    transform3Type = [sender selectedSegmentIndex];
}

- (IBAction)takeTransform1AxisFrom:(id)sender {
    transform1Axis = [sender selectedSegmentIndex];
}
- (IBAction)takeTransform2AxisFrom:(id)sender {
    transform2Axis = [sender selectedSegmentIndex];
}
- (IBAction)takeTransform3AxisFrom:(id)sender {
    transform3Axis = [sender selectedSegmentIndex];
}

- (IBAction)takeTransform1ValueFrom:(UISlider *)sender {
    transform1Value = [sender value];
}

- (IBAction)takeTransform2ValueFrom:(UISlider *)sender {
    transform2Value = [sender value];
}
- (IBAction)takeTransform3ValueFrom:(UISlider *)sender {
    transform3Value = [sender value];
}

@end
