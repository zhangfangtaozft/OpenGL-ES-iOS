//
//  ViewController.m
//  OpenGLES_Ch4_2
//
//  Created by frank.zhang on 2019/1/22.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
前面每个照射到的顶点，除了位置坐标，法向量的使用还需要三个浮点值（12字节）的存储空间。当定义一个场景中的集合图形的顶点有几十万或上百万个时，每个顶点的额外的12个字节会加速增加。额外的12个字节不仅会消耗稀缺的GPU所控制的内存，而且每次几何图形被渲染时，它还必须被GPU读取。
 如果纹理可以以任何方式来使用，那么OpenGL ES灯光模拟的一个替代方法就是把灯光烘焙进一个现存的纹理中。换句话说，就是使用已经包含了本来是由灯光模拟生成的明亮和黑暗区域的纹理。本例子就会使用一个包含阴影灯光效果的纹理。
 把灯光烘焙进纹理中仅仅适用于几何图形和灯光都不是动态的情况下。如果灯光来回移动或者改变颜色，烘焙金的灯光看起来就不合适了。如果集合图形发生了比较大的变化，以至于原先的黑色区域暴露在了光线之下，此时的五年里看起来就是错误的。
 如之前提到的，OpenGL ES 1.x灯光模拟是GKit通过计算光线方向矢量和每个顶点的顶点法向量之间的标量积来测定的。标量积决定了有多少光线会照向顶点。之后，计算出来的光线效果被插补在顶点之间使用光线看起来平滑。
 在决定片元颜色的时候，GPU已经执行了复杂的运算。是否可以使用GPU为每个单独的片元而不仅仅是为订单重新计算灯光效果？其实是可以的GPU是通过编程来做到这一点的。
 用于顶点的相同的方程式可以用在每一个片元上。片元方程式需要每个片元的法向量。解决办法是编码一个纹理的每个RGB纹素内的法向量的X,Y,Z分量。这样的纹理称为法线贴图（normal map）。用于每个片元灯光的技术通常叫做法线贴图，凹凸贴图，或者DOT3灯光，因为这三个术语本质上都是描述的效果。
 一个纹理单元决定了哪一个法线贴图纹素会影响片元。一个Shading Language程序会计算由选中的纹素和光线的方向所代表的矢量的标量积。然后使用这个标量积啦按比例确定最终的片元的颜色的效果。
 每个片元光线计算即使是在动态的灯光和几何图形的情况下，仍然可以工作良好。但是，每个片元光线计算既需要嵌入式GPU做高耗费计算，有需要使用会耗尽GPU控制内存的法线贴图。生成法线贴图时也可能会出现问题。在一些情况下，iPhone SDK附带的PVRTectureTool能够帮助生成法线贴图，但要让一切看起来刚好也是复杂的。由于早期工具支持，计算耗费和纹理的内存限制等原因，可用设备对于每个片元光线计算的支持并不好。随着嵌入式GPU和工具支持的必然改进。高级每片元光线计算效果会变得更实际。
 */
#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
typedef struct {
    GLKVector3 position;
    GLKVector3 textureCoords;
}
SceneVertex;

typedef struct {
    SceneVertex vertices[3];
}
SceneTriangle;

static SceneVertex vertexA = {{-0.5,  0.5, -0.5}, {0.0, 1.0}};
static SceneVertex vertexB = {{-0.5,  0.0, -0.5}, {0.0, 0.5}};
static SceneVertex vertexC = {{-0.5, -0.5, -0.5}, {0.0, 0.0}};
static SceneVertex vertexD = {{ 0.0,  0.5, -0.5}, {0.5, 1.0}};
static SceneVertex vertexE = {{ 0.0,  0.0,  0.0}, {0.5, 0.5}};
static SceneVertex vertexF = {{ 0.0, -0.5, -0.5}, {0.5, 0.0}};
static SceneVertex vertexG = {{ 0.5,  0.5, -0.5}, {1.0, 1.0}};
static SceneVertex vertexH = {{ 0.5,  0.0, -0.5}, {1.0, 0.5}};
static SceneVertex vertexI = {{ 0.5, -0.5, -0.5}, {1.0, 0.0}};

static SceneTriangle SceneTriangleMake(
                                       const SceneVertex vertexA,
                                       const SceneVertex vertexB,
                                       const SceneVertex vertexC);
@interface ViewController ()
{
    SceneTriangle triangles[8];
}
@end

@implementation ViewController
@synthesize baseEffect;
@synthesize vertexBuffer;
@synthesize blandTextureInfo;
@synthesize interestingTextureInfo;
@synthesize shouldUseDetailLighting;

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 1.0, 1.0); // White
    
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
    }
    CGImageRef blandSimulatedLightingImageRef =
    [[UIImage imageNamed:@"Lighting256x256.png"] CGImage];
    blandTextureInfo = [GLKTextureLoader
                        textureWithCGImage:blandSimulatedLightingImageRef
                        options:[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],
                                 GLKTextureLoaderOriginBottomLeft, nil]
                        error:NULL];
    
    CGImageRef interestingSimulatedLightingImageRef =
    [[UIImage imageNamed:@"LightingDetail256x256.png"] CGImage];
    interestingTextureInfo = [GLKTextureLoader
                              textureWithCGImage:interestingSimulatedLightingImageRef
                              options:[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:YES],
                                       GLKTextureLoaderOriginBottomLeft, nil]
                              error:NULL];
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
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
    self.shouldUseDetailLighting = YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    if (self.shouldUseDetailLighting) {
        self.baseEffect.texture2d0.name = interestingTextureInfo.name;
        self.baseEffect.texture2d0.target = interestingTextureInfo.target;
    }else{
        self.baseEffect.texture2d0.name = blandTextureInfo.name;
        self.baseEffect.texture2d0.target = blandTextureInfo.target;
    }
    [self.baseEffect prepareToDraw];
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles) / sizeof(SceneVertex)];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (IBAction)switchAction:(UISwitch *)sender {
    self.shouldUseDetailLighting = sender.isOn;
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
