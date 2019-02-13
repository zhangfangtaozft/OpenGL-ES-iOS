//
//  ViewController.m
//  OpenGLES_Ch6_2
//
//  Created by frank.zhang on 2019/2/13.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "SceneAnimatedMesh.h"

@interface ViewController ()
@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) SceneAnimatedMesh
*animatedMesh;
@end

@implementation ViewController
@synthesize baseEffect;
@synthesize animatedMesh;

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.6f, // Red
                                                         0.6f, // Green
                                                         0.6f, // Blue
                                                         1.0f);// Alpha
    
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
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
    animatedMesh = [[SceneAnimatedMesh alloc] init];
    self.baseEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         20, 25, 5,
                         20, 0, -15,
                         0, 1, 0);
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [((AGLKContext *)view.context)
     clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    const GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(60.0f),// Standard field of view
                              aspectRatio,
                              0.1f,   // Don't make near plane too close
                              255.0f);// Far is arbitrarily far enough to contain scene
    [self.animatedMesh
     updateMeshWithElapsedTime:self.timeSinceLastResume];
    [self.baseEffect prepareToDraw];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown &&
            interfaceOrientation !=
            UIInterfaceOrientationPortrait);
}
@end
