//
//  ViewController.m
//  OpenGLES_Ch4_2
//
//  Created by frank.zhang on 2019/1/22.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

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
