//
//  ViewController.m
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

/*
 动画通常包括两种情况，对象对于用户的视点移动或者用户的视点相对于对象的位置变化。与很多3D图像概念相似，视点存在于一个抽象的数学领域中。实际上，当前的OpenGL ES视点永远不会改变。矩阵定义了几何对象（如三角形）是怎么映射到像素颜色渲染缓存中的片元位置的。改变矩阵进而改变映射，最终创造了试点改变的错觉。其实，观察者并没有移动，只是来计算胡来的每个可视对象的位置相对于观察者发生了变化。
 */
/*
 这个例子里面天啊及了五个类SceneMesh,SceneModel,SceneCar,SceneCarModel和SceneRinkModel。SceneMesh类的存在是为了管理大量的顶点数据以及GPU控制的内存数据的坐标转换。网格（mesh）就是共享顶点或者边，同时用于定义3D图形的三角形的一个集合。SceneModel类会绘制全部或者部分的网格。一个单独的模型可能由多个网格组成m，多个模型可能共用相同的网格。模型代表了汽车，山脉或者人物等3D对象，这些3D对象的形状是由网格定义的。模型聚合了绘制3D对象所需的所有网格。SceneCar类封装了每个碰碰车的当前位置，速度，颜色，偏航角和模型。偏航（yaw）是来自轮船和航空的一个术语，代表了围绕垂直轴的旋转度，在这里是围绕Y轴。偏航定义了碰碰车的方向并且会随着时间变化而让碰碰车面向它移动的方向。SceneModel的子类SceneCarModel封装了一个碰碰车的方向会随着时间变化而让碰碰车面向它移动的方向。SceneModel的子类SceneCarModel封装了一个碰碰车形状的网格。每个SceneCar实例都使用一个SceneCarModel实例。如果想要碰碰车拥有不同的外形，比如有的看起来x像卡车，有的看起来像飞机，那么就需要每个SceneCar实例使用一个不同的模型。最后SceneModel的子类SceneRinkModel封装了代表溜冰场的面壁和地面的网格。
 */
#import "ViewController.h"
#import "SceneCarModel.h"
#import "SceneRinkModel.h"
#import "AGLKContext.h"

@interface ViewController ()
{
    NSMutableArray *cars;
}
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) SceneModel *carModel;
@property (strong, nonatomic) SceneModel *rinkModel;
@property (nonatomic, assign) BOOL shouldUseFirstPersonPOV;
@property (nonatomic, assign) GLfloat
pointOfViewAnimationCountdown;
@property (nonatomic, assign) GLKVector3 eyePosition;
@property (nonatomic, assign) GLKVector3 lookAtPosition;
@property (nonatomic, assign) GLKVector3 targetEyePosition;
@property (nonatomic, assign) GLKVector3 targetLookAtPosition;
@property (nonatomic, assign, readwrite)
SceneAxisAllignedBoundingBox rinkBoundingBox;
@end

@implementation ViewController
@synthesize baseEffect;
@synthesize carModel;
@synthesize rinkModel;
@synthesize pointOfViewAnimationCountdown;
@synthesize shouldUseFirstPersonPOV;
@synthesize eyePosition;
@synthesize lookAtPosition;
@synthesize targetEyePosition;
@synthesize targetLookAtPosition;
@synthesize rinkBoundingBox;
static const int SceneNumberOfPOVAnimationSeconds = 2.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    cars = [[NSMutableArray alloc] init];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.6f, // Red
                                                         0.6f, // Green
                                                         0.6f, // Blue
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
    
    [((AGLKContext *)view.context) enable:GL_DEPTH_TEST];
    [((AGLKContext *)view.context) enable:GL_BLEND];
    
    self.carModel = [[SceneCarModel alloc] init];
    self.rinkModel = [[SceneRinkModel alloc] init];

    self.rinkBoundingBox = self.rinkModel.axisAlignedBoundingBox;
    NSAssert(0 < (self.rinkBoundingBox.max.x -
                  self.rinkBoundingBox.min.x) &&
             0 < (self.rinkBoundingBox.max.z -
                  self.rinkBoundingBox.min.z),
             @"Rink has no area");

    SceneCar   *newCar = [[SceneCar alloc]
                          initWithModel:self.carModel
                          position:GLKVector3Make(1.0, 0.0, 1.0)
                          velocity:GLKVector3Make(1.5, 0.0, 1.5)
                          color:GLKVector4Make(0.0, 0.5, 0.0, 1.0)];
    [cars addObject:newCar];
    
    newCar = [[SceneCar alloc]
              initWithModel:self.carModel
              position:GLKVector3Make(-1.0, 0.0, 1.0)
              velocity:GLKVector3Make(-1.5, 0.0, 1.5)
              color:GLKVector4Make(0.5, 0.5, 0.0, 1.0)];
    [cars addObject:newCar];
    
    newCar = [[SceneCar alloc]
              initWithModel:self.carModel
              position:GLKVector3Make(1.0, 0.0, -1.0)
              velocity:GLKVector3Make(-1.5, 0.0, -1.5)
              color:GLKVector4Make(0.5, 0.0, 0.0, 1.0)];
    [cars addObject:newCar];
    
    newCar = [[SceneCar alloc]
              initWithModel:self.carModel
              position:GLKVector3Make(2.0, 0.0, -2.0)
              velocity:GLKVector3Make(-1.5, 0.0, -0.5)
              color:GLKVector4Make(0.3, 0.0, 0.3, 1.0)];
    [cars addObject:newCar];
    
    self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
    self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
}
/*
 在3D应用中，活动中的视点叫做“第一人称”视点，因为它呈现了一个观察者站在应用环境内部时的场景。另一种视点称为“第三人称”，它模拟了从一个活动之外的有利位置从上往下看的视图添加一个新的方法“-updatePointOfView”来设置“目标”眼睛位置和看相的位置，如下所示：
 */
/*
 第三人称视点会把观察者的眼睛置于溜冰场的侧上方不并且看向溜冰场中央稍微向上的位置。第三人称眼睛和看相的位置是任意角度的并且不会发生变化。相比之下，第一人称视点会随着观察者所乘坐的碰碰车而移动和转向。眼睛位置被设置为碰碰车当前位置的正上方，看向位置是在碰碰车前面的碰碰车行驶方向的一个点。在前面的代码中，viewerCar.velocity与eyePosition相加会计算出碰碰车前方的一个位置。
 */
- (void)updatePointOfView{
    if(!self.shouldUseFirstPersonPOV)
    {
        self.eyePosition = GLKVector3Make(10.5, 5.0, 0.0);
        self.lookAtPosition = GLKVector3Make(0.0, 0.5, 0.0);
    }
    else
    {
        SceneCar *viewerCar = [cars lastObject];
        self.targetEyePosition = GLKVector3Make(
                                                viewerCar.position.x,
                                                viewerCar.position.y + 0.45f,
                                                viewerCar.position.z);
        self.targetLookAtPosition = GLKVector3Add(
                                                  eyePosition,
                                                  viewerCar.velocity);
    }
}
/*
类似从第三人称视点瞬间转向第一人称十点的不和谐视觉变化会让用户失去方向感。update方法为用户变化渲染视点提供了一个平滑的过渡动画。这个动画是使用一个低通滤波器来逐渐减少当前视点与用户选择的视点之间的差异产生的。低通滤波器会反复逐渐地改变计算出来的值，并且必须调用很多次才能产生一个明显的效果。之所以叫做“低通”是因为对于正在被过滤的值来说，低频的，长期的变化会有一个明显的影响，而高频变化的影响甚微。下面的代码实现了低通滤波器：
 */
/*
 与低通滤波器类似的函数会让动画更加流畅。碰碰车改变方向时使用过滤器，当碰碰车从墙壁弹回并且转向时，碰碰车并不会瞬间转向新的方向，而是先让目标方向变为新的方向，然后碰碰车的f当前方向逐步更新直接到与目标方向一致。几乎所有的3D模拟都受益于这样的或者那样的过滤器。
 */
-(void)update{
    if(0 < self.pointOfViewAnimationCountdown)
    {
        self.pointOfViewAnimationCountdown -=
        self.timeSinceLastUpdate;
        self.eyePosition = SceneVector3SlowLowPassFilter(
                                                         self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3SlowLowPassFilter(
                                                            self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }
    else
    {
        self.eyePosition = SceneVector3FastLowPassFilter(
                                                         self.timeSinceLastUpdate,
                                                         self.targetEyePosition,
                                                         self.eyePosition);
        self.lookAtPosition = SceneVector3FastLowPassFilter(
                                                            self.timeSinceLastUpdate,
                                                            self.targetLookAtPosition,
                                                            self.lookAtPosition);
    }

    [cars makeObjectsPerformSelector:
     @selector(updateWithController:) withObject:self];

    [self updatePointOfView];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    [((AGLKContext *)view.context)
     clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    const GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(35.0f),// Standard field of view
                              aspectRatio,
                              0.1f,   // Don't make near plane too close
                              25.0f); // Far is aritrarily far enough to contain scene
    /*
     GLKMatrix4MakeLookAt有6个参数。前三个参数指定观察着眼睛的{x,y,z}位置，接下来的三个参数指定观察者正在看向的{x,y,z}位置。GLKMatrix4MakeLookAt()函数会计算并且返回一个model-view矩阵，这个矩阵会对齐从眼睛的位置到看向的位置之间的矢量与当前视域的中心线。如果眼睛的位置与看向的位置相同，函数GLKMatrix4MakeLookAt()就不会产生有效的效果。
     GLKMatrix4MakeLookAt()函数的最后三个参数指定了“上”方向矢量的{x,y,z}元素。改变“上”方向与倾斜观察者头部的效果相同。
     注意：“上”方向可以是任意矢量，但是GLKMatrix4MakeLookAt()的实现所使用的数学计算不能产生一个有效的直接顺着“上”矢量看的视点。这个限制的存在是因为当直接向“上”或者向“下”看时。GLKMatrix4MakeLookAt()函数使用的数学计算会试图计算90度角的正切，而这在数学上是未定义的。这个“未定义”的现象还发生在现实世界中。例如，当机械陀螺仪碰到“万象街锁定”并且产生摇摆不可靠的数据时。但是存在一个巧妙的数学解决方案---四元法。
     */
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         self.eyePosition.x,
                         self.eyePosition.y,
                         self.eyePosition.z,
                         self.lookAtPosition.x,
                         self.lookAtPosition.y,
                         self.lookAtPosition.z,
                         0, 1, 0);
    [self.baseEffect prepareToDraw];
    [self.rinkModel draw];
    [cars makeObjectsPerformSelector:@selector(drawWithBaseEffect:)
                          withObject:self.baseEffect];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    baseEffect = nil;
    cars = nil;
    carModel = nil;
    rinkModel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown &&
            toInterfaceOrientation !=
            UIInterfaceOrientationPortrait);
}

- (NSArray *)cars{
    return cars;
}

- (IBAction)stateChange:(id)sender {
    self.shouldUseFirstPersonPOV = [sender isOn];
    pointOfViewAnimationCountdown =
    SceneNumberOfPOVAnimationSeconds;
}


@end
