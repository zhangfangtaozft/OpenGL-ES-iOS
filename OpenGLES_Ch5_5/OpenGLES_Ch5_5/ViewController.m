//
//  ViewController.m
//  OpenGLES_Ch5_5
//
//  Created by frank.zhang on 2019/1/28.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "AGLKTextureTransformBaseEffect.h"
@implementation ViewController
@synthesize baseEffect;
@synthesize vertexBuffer;
@synthesize textureScaleFactor;
@synthesize textureAngle;
@synthesize textureMatrixStack;
typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;

static const SceneVertex vertices[] =
{
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textureMatrixStack =
    GLKMatrixStackCreate(kCFAllocatorDefault);
    
    self.textureScaleFactor = 1.0; // Initial texture scale factor
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect =
    [[AGLKTextureTransformBaseEffect alloc] init];

    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(
                                                   1.0f, // Red
                                                   1.0f, // Green
                                                   1.0f, // Blue
                                                   1.0f);// Alpha
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red
                                                              0.0f, // Green
                                                              0.0f, // Blue
                                                              1.0f);// Alpha
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc]
                         initWithAttribStride:sizeof(SceneVertex)
                         numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)
                         bytes:vertices
                         usage:GL_STATIC_DRAW];
    
    // Setup texture0
    CGImageRef imageRef0 =
    [[UIImage imageNamed:@"leaves.png"] CGImage];
    GLKTextureInfo *textureInfo0 = [GLKTextureLoader
                                    textureWithCGImage:imageRef0
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES],
                                             GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    self.baseEffect.texture2d0.name = textureInfo0.name;
    self.baseEffect.texture2d0.target = textureInfo0.target;
    self.baseEffect.texture2d0.enabled = GL_TRUE;
    CGImageRef imageRef1 =
    [[UIImage imageNamed:@"beetle.png"] CGImage];
    
    GLKTextureInfo *textureInfo1 = [GLKTextureLoader
                                    textureWithCGImage:imageRef1
                                    options:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:YES],
                                             GLKTextureLoaderOriginBottomLeft, nil]
                                    error:NULL];
    self.baseEffect.texture2d1.name = textureInfo1.name;
    self.baseEffect.texture2d1.target = textureInfo1.target;
    self.baseEffect.texture2d1.enabled = GL_TRUE;
    self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    [self.baseEffect.texture2d1
     aglkSetParameter:GL_TEXTURE_WRAP_S
     value:GL_REPEAT];
    [self.baseEffect.texture2d1
     aglkSetParameter:GL_TEXTURE_WRAP_T
     value:GL_REPEAT];
    GLKMatrixStackLoadMatrix4(
                              self.textureMatrixStack,
                              self.baseEffect.textureMatrix2d1);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:offsetof(SceneVertex, positionCoords)
     shouldEnable:YES];
    
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:offsetof(SceneVertex, textureCoords)
     shouldEnable:YES];
    
    [self.vertexBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord1
     numberOfCoordinates:2
     attribOffset:offsetof(SceneVertex, textureCoords)
     shouldEnable:YES];
    GLKMatrixStackPush(self.textureMatrixStack);
    GLKMatrixStackTranslate(
                            self.textureMatrixStack,
                            0.5, 0.5, 0.0);
    GLKMatrixStackScale(
                        self.textureMatrixStack,
                        textureScaleFactor, textureScaleFactor, 1.0);
    GLKMatrixStackRotate(   // Rotate about Z axis
                         self.textureMatrixStack,
                         GLKMathDegreesToRadians(textureAngle),
                         0.0, 0.0, 1.0);
    GLKMatrixStackTranslate(
                            self.textureMatrixStack,
                            -0.5, -0.5, 0.0);
    self.baseEffect.textureMatrix2d1 =
    GLKMatrixStackGetMatrix4(self.textureMatrixStack);
    [self.baseEffect prepareToDrawMultitextures];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:sizeof(vertices) / sizeof(SceneVertex)];
    GLKMatrixStackPop(self.textureMatrixStack);
    self.baseEffect.textureMatrix2d1 =
    GLKMatrixStackGetMatrix4(self.textureMatrixStack);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    CFRelease(self.textureMatrixStack);
    self.textureMatrixStack = NULL;
}


- (IBAction)takeTextureScaleFactorFrom:(UISlider *)sender {
    self.textureScaleFactor = [sender value];
}

- (IBAction)takeTextureAngleFrom:(UISlider *)sender {
    self.textureAngle = [sender value];
}

@end
