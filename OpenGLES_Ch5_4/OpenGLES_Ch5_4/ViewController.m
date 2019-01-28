//
//  ViewController.m
//  OpenGLES_Ch5_4
//
//  Created by frank.zhang on 2019/1/28.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

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
