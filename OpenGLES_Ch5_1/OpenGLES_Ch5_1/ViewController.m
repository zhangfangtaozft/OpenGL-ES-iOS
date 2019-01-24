//
//  ViewController.m
//  OpenGLES_Ch5_1
//
//  Created by frank.zhang on 2019/1/24.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"
#import "sphere.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize baseEffect;
@synthesize vertexNormalBuffer;
@synthesize vertexPositionBuffer;
@synthesize vertexTextureCoordBuffer;

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    self.baseEffect.light0.ambientColor = GLKVector4Make(0.2f, 0.2f, 0.2f, 1.0f);
    self.baseEffect.light0.position = GLKVector4Make(1.0f, 0.0f, -0.8f, 0.0f);
    CGImageRef imageRef = [[UIImage imageNamed:@"Earth512x256.jpg"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.vertexPositionBuffer= [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereVerts) / (3 * sizeof(GLfloat)) bytes:sphereVerts usage:GL_STATIC_DRAW];
    self.vertexNormalBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(3 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereNormals) / (3 * sizeof(GLfloat)) bytes:sphereNormals usage:GL_STATIC_DRAW];
    self.vertexTextureCoordBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:(2 * sizeof(GLfloat)) numberOfVertices:sizeof(sphereTexCoords) / (2 * sizeof(GLfloat)) bytes:sphereTexCoords usage:GL_STATIC_DRAW];
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    [self.vertexPositionBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexNormalBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:0 shouldEnable:YES];
    [self.vertexTextureCoordBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:0 shouldEnable:YES];
    [AGLKVertexAttribArrayBuffer drawPreparedArraysWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sphereNumVerts];
}
- (void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexPositionBuffer = nil;
    self.vertexNormalBuffer = nil;
    self.vertexTextureCoordBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}
@end
