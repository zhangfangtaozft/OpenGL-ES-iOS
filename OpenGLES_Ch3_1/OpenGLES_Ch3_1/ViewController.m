//
//  ViewController.m
//  OpenGLES_Ch3_1
//
//  Created by frank.Zhang on 22/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import "ViewController.h"
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize  baseEffect;
@synthesize vertexBuffer;

typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5f,-0.5f,0.0f},{0.0f,0.0f}},
    {{0.5f,-0.5f,0.0f},{1.0f,0.0f}},
    {{-0.5f,0.5f,0.0f},{0.0f,1.0f}},
};
- (void)viewDidLoad {
    [super viewDidLoad];

    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.vertexBuffer =  [[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];
    //setup texture
    CGImageRef imageRef = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:3];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
