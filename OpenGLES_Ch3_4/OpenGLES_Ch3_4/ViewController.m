//
//  ViewController.m
//  OpenGLES_Ch3_4
//
//  Created by frank.zhang on 2019/1/17.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-1.0f, -0.67f, 0.0f},{0.0f, 0.0f}},
    {{ 1.0f, -0.67f, 0.0f},{1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f},{0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f},{1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f},{0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f},{1.0f, 1.0f}},
};

@interface ViewController ()
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (nonatomic, strong) GLKTextureInfo *textureInfo0;
@property (nonatomic, strong) GLKTextureInfo *textureInfo1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    view.context = [[AGLKContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices) / sizeof(SceneVertex) bytes:vertices usage:GL_STATIC_DRAW];

    CGImageRef imageRef0 = [[UIImage imageNamed:@"leaves.png"] CGImage];
    /*
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil]这里面，GLKTextureLoaderOriginBottomLeft键与布尔YES搭配只为了i命令GLKit的GLKTextureLeader类垂直翻转图像数据。这个翻转可以抵消图像的原点与OpenGL ES标准原点之间的差异。
    */
    self.textureInfo0 = [GLKTextureLoader textureWithCGImage:imageRef0 options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    CGImageRef imageRef1 = [UIImage imageNamed:@"beetle.png"].CGImage;
    
    /*
     * 下面的方法会加载第二个纹理并且开启与像素颜色渲染缓存的混合。
     **/
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    // Clear back frame buffer (erase previous drawing)
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                           numberOfCoordinates:3
                                  attribOffset:offsetof(SceneVertex, positionCoords)
                                  shouldEnable:YES];
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
                           numberOfCoordinates:2
                                  attribOffset:offsetof(SceneVertex, textureCoords)
                                  shouldEnable:YES];
    /*
     GLKit的baseEffect是由第一个纹理设定的，同时，vertexBuffer被绘制。然后，baseEffect由第二个纹理设定，同时vertextBuffer被再次绘制。z和两个过程也伴随着与像素颜色渲染缓存的混合。绘制的顺序决定了哪一个纹理会出现在另一个之上，在当前情况下是虫子在树叶的上面。纹理绘制的顺序倒过来的话会把树叶置于虫子之上。
     */
    self.baseEffect.texture2d0.name = self.textureInfo0.name;
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    [self.baseEffect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:6];
    self.baseEffect.texture2d0.name = self.textureInfo1.name;
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
    [self.baseEffect prepareToDraw];
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES
                        startVertexIndex:0
                        numberOfVertices:6];
}

-(void)viewDidUnload{
    [super viewDidUnload];
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    self.vertexBuffer = nil;
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}
@end
