//
//  ViewController.m
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

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
