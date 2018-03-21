//
//  ViewController.m
//  OpenGLES_Ch2_2
//
//  Created by frank.Zhang on 20/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize baseEffect;

typedef struct{
    GLKVector3 positionCoords;
}

SceneVertex;

static const SceneVertex vertices[] = {
    {{-0.5f,-0.5f,0.0}},
    {{0.5f,-0.5f,0.0}},
    {{-0.5f,0.5f,0.0}}
};

- (void)viewDidLoad {
    [super viewDidLoad];
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]],
             @"View controller's view is not a AGLKView");
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    glClearColor(1.0f, 0.5f, 0.0f, 1.0f);
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

-(void)glkView:(AGLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);//Step4
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

-(void)viewDidUnload{
    [super viewDidUnload];
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    ((AGLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
