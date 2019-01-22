//
//  ViewController.m
//  OpenGLES_Ch4_1
//
//  Created by frank.zhang on 2019/1/21.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
}
SceneVertex;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
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
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB)
{
    return GLKVector3Normalize(
                               GLKVector3CrossProduct(vectorA, vectorB));
}

