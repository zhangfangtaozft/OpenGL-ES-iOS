//
//  AGLKView.m
//  OpenGLES_Ch5_3
//
//  Created by frank.zhang on 2019/1/25.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>


@implementation AGLKView

@synthesize delegate;
@synthesize context;
@synthesize drawableDepthFormat;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext;
{
    if ((self = [super initWithFrame:frame]))
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,
         kEAGLColorFormatRGBA8,
         kEAGLDrawablePropertyColorFormat,
         nil];
        
        self.context = aContext;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:NO],
         kEAGLDrawablePropertyRetainedBacking,
         kEAGLColorFormatRGBA8,
         kEAGLDrawablePropertyColorFormat,
         nil];
    }
    
    return self;
}

- (void)setContext:(EAGLContext *)aContext
{
    if(context != aContext)
    {  // Delete any buffers previously created in old Context
        [EAGLContext setCurrentContext:context];
        
        if (0 != defaultFrameBuffer)
        {
            glDeleteFramebuffers(1, &defaultFrameBuffer); // Step 7
            defaultFrameBuffer = 0;
        }
        
        if (0 != colorRenderBuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderBuffer); // Step 7
            colorRenderBuffer = 0;
        }
        
        if (0 != depthRenderBuffer)
        {
            glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
            depthRenderBuffer = 0;
        }
        
        context = aContext;
        
        if(nil != context)
        {  // Configure the new Context with required buffers
            context = aContext;
            [EAGLContext setCurrentContext:context];
            
            glGenFramebuffers(1, &defaultFrameBuffer);    // Step 1
            glBindFramebuffer(                            // Step 2
                              GL_FRAMEBUFFER,
                              defaultFrameBuffer);
            
            glGenRenderbuffers(1, &colorRenderBuffer);    // Step 1
            glBindRenderbuffer(                           // Step 2
                               GL_RENDERBUFFER,
                               colorRenderBuffer);
            
            // Attach color render buffer to bound Frame Buffer
            glFramebufferRenderbuffer(
                                      GL_FRAMEBUFFER,
                                      GL_COLOR_ATTACHMENT0,
                                      GL_RENDERBUFFER,
                                      colorRenderBuffer);
            [self layoutSubviews];
        }
    }
}

- (EAGLContext *)context
{
    return context;
}

- (void)display;
{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    [self drawRect:[self bounds]];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)drawRect:(CGRect)rect
{
    if(delegate)
    {
        [self.delegate glkView:self drawInRect:[self bounds]];
    }
}

- (void)layoutSubviews
{
    CAEAGLLayer     *eaglLayer = (CAEAGLLayer *)self.layer;
    
    // Make sure our context is current
    [EAGLContext setCurrentContext:self.context];
    [self.context renderbufferStorage:GL_RENDERBUFFER
                         fromDrawable:eaglLayer];
    
 /*
  下面使用了一个扩展自例子2_2的AGLKView版本，而不是GLKit的GLKView。drawableDepthFormat属性被添加到AGLKView，同时还有一个用来存储OpenGL ES 深度环迅表示服的实例变量。下面添加到GLKView的"-layoutSubviews"方法的代码按照需求创建并且配置了一个深度缓存来匹配视图的像素颜色渲染缓存的尺寸。
  */
    if (0 != depthRenderBuffer)
    {
        glDeleteRenderbuffers(1, &depthRenderBuffer); // Step 7
        depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth = self.drawableWidth;
    GLint currentDrawableHeight = self.drawableHeight;
    
    if(self.drawableDepthFormat !=
       AGLKViewDrawableDepthFormatNone &&
       0 < currentDrawableWidth &&
       0 < currentDrawableHeight)
    {
        glGenRenderbuffers(1, &depthRenderBuffer); // Step 1
        glBindRenderbuffer(GL_RENDERBUFFER,        // Step 2
                           depthRenderBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER,     // Step 3
                              GL_DEPTH_COMPONENT16,
                              currentDrawableWidth,
                              currentDrawableHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER,  // Step 4
                                  GL_DEPTH_ATTACHMENT,
                                  GL_RENDERBUFFER,
                                  depthRenderBuffer);
    }
    GLenum status = glCheckFramebufferStatus(
                                             GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete frame buffer object %x", status);
    }
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
}

- (NSInteger)drawableWidth;
{
    GLint          backingWidth;
    
    glGetRenderbufferParameteriv(
                                 GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_WIDTH,
                                 &backingWidth);
    
    return (NSInteger)backingWidth;
}

- (NSInteger)drawableHeight;
{
    GLint          backingHeight;
    
    glGetRenderbufferParameteriv(
                                 GL_RENDERBUFFER,
                                 GL_RENDERBUFFER_HEIGHT,
                                 &backingHeight);
    
    return (NSInteger)backingHeight;
}

- (void)dealloc
{
    // Make sure the receiver's OpenGL ES Context is not current
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    // Deletes the receiver's OpenGL ES Context
    context = nil;
}

@end
