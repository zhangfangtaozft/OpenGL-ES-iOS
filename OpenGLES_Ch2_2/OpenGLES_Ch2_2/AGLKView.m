//
//  AGLKView.m
//  OpenGLES_Ch2_2
//
//  Created by frank.Zhang on 20/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import "AGLKView.h"
#import <QuartzCore/QuartzCore.h>
@implementation AGLKView

@synthesize delegate;
@synthesize context;
@synthesize drawableDepthFormat;
/*
 *每一个UIView实例都有一个相关联的被Cocoa Touch按需自动创建的Core Animation层。Cocoa Touch会调用“+layerLcass”方法来确定要创建什么类型的层。在这个例子中，AGLKView类重写了继承自UIView的实现。当CocoaTouch调用AGLKView实现的“+layerClass”方法时，它被告知要使用一个CAEAGLLayer类的实例，而不是原先的CALyer。CAEAGLLayer是Core Animation提供的标准层类之一。CAEAGLLayer会与一个OpenGL ES 的帧缓存共享它的像素颜色仓库。
 **/
+(Class) layerClass{
    return [CAEAGLLayer class];
}
/*
 *接下来的代码快实现了“-(id)initWithFrame:(CGRect) frame context:(EAGLContext *)aContext”方法并重写了继承来的“-(id)initWithCoder:(NSCoder*)coder”方法，下面两种方法只有一种会被调用。下面这两个方法都会个超类UIView和OpenGL ES 上下文的一次性初始化。第一步是初始化视图的Core Animation层的本地指针，具体代码如下
 **/
//如下方法初始化了通过代码手动分配的实例。
-(id)initWithFrame:(CGRect) frame context:(EAGLContext *)aContext{
    if (self = [super initWithFrame:frame]) {
        // 第一步:初始化视图的Core Animation层的本地指针。需要C语言的类型转换(CAEAGLLayer *)。这是因为UIView的-CALayer实例的指针，在AGLKView类的实现中，真正使用的是CAEAGLLayer类型，因此强制编译器接受CAEAGLLayer类型的这个转换是安全的。
        CAEAGLLayer *eagLayer = (CAEAGLLayer *)self.layer;
         //每个AGLKView的初始化方法会用一个临时的NSDictionary实例来设置eagLayer的drawableProperties属性。Dictionary是一个Cocoa Touch 类，在这里被CAEAGLLayer类实例使用是为了保存层中用到的OpenGL ES 的帧缓存类型的信息。
        eagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
        self.context = aContext;
    }
    return self;
}
//如下代码这是反归档先前归档入一个文件的对象的过程的一部分，归档和反归档在他的流行的面向对象的框架中（比如Java和微软的。Net）叫做串行化和反串行化。当本应用程序启动时，在这个例子中使用的AGLKView实例会自动地从应用的storyboard文件中加载（又叫做反归档）。

-(id)initWithCoder:(NSCoder*)coder{
    // 第一步:初始化视图的Core Animation层的本地指针。需要C语言的类型转换(CAEAGLLayer *)。这是因为UIView的-CALayer实例的指针，在AGLKView类的实现中，真正使用的是CAEAGLLayer类型，因此强制编译器接受CAEAGLLayer类型的这个转换是安全的。
    CAEAGLLayer *eagLayer = (CAEAGLLayer *)self.layer;
    if (self = [super initWithCoder:coder]) {
    //每个AGLKView的初始化方法会用一个临时的NSDictionary实例来设置eagLayer的drawableProperties属性。Dictionary是一个Cocoa Touch 类，在这里被CAEAGLLayer类实例使用是为了保存层中用到的OpenGL ES 的帧缓存类型的信息。
        eagLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                       //这个示例设置kEAGLDrawablePropertyRetainedBacking键的值为NO并设置kEAGLDrawablePropertyColorFormat键的值为 kEAGLColorFormatRGBA8。不适用保护背景色的意思是告诉Core Animation在层的任何部分需要在屏幕上显示的时候都要绘制整个层的内容。换句话说，这段代码是告诉Core Animation不要试图保留任何以前绘制的图像留作以后重用。RGBA8颜色格式是告诉Core Animation用8位来保存层内的每个像素的每个颜色元素的值。
                                       [NSNumber numberWithBool:NO],
                                       kEAGLDrawablePropertyRetainedBacking,
                                       kEAGLColorFormatRGBA8,
                                       kEAGLDrawablePropertyColorFormat, nil];
    }
    return self;
}

/*
 *两个手动实现的访问器方法用于设置和返回视图的特定于平台的OpenGL ES上下文。因为AGLKView实例需要创建和配置一个帧缓存和一个像素颜色渲染缓存来与视图的Core Animation层一起使用，所以设置上下文会引起一些副作用。由于上下文保存缓存，因此修改视图的上下文会导致先前创建的所有缓存全部失效，并需要创建和配置新的缓存。
 **/

/*
 *会受缓存操作影响的上下文是在调用OpenGL ES函数之前设定为当前上下文的。请注意在下面的代码中，创建帧缓存和渲染缓存会遵循一些适用于其他类型的缓存的相同的步骤，包括在OpenGLES_Ch2_1例子中的顶点数组缓存。一个新的步骤会调用glFramebufferRenderbuffer()函数来配置当前绑定的帧缓存以便于在colorRenderBuffer中保存渲染的像素颜色。
 **/
-(void)setContext:(EAGLContext *)aContext{
    if (context != aContext) {
        [EAGLContext setCurrentContext:context];
        if (0 != defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer = 0;
        }
        
        if (0 != colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        if (0 != depthRenderBuffer) {
            glDeleteRenderbuffers(1, &depthRenderBuffer);
            depthRenderBuffer = 0;
        }
        context = aContext;
        if (nil != context) {
            context = aContext;
            [EAGLContext setCurrentContext:context];
           
            glGenBuffers(1, &defaultFrameBuffer);//step1
            glBindFramebuffer(GL_FRAMEBUFFER,defaultFrameBuffer);//Step2
          
            glGenRenderbuffers(1, &colorRenderbuffer);//step1
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);//Step2
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
//            [self layoutSubviews];
        }
    }
}

-(EAGLContext *)context{
    return context;
}

//下面的-display方法设置视图的上下文为当前上下文，告诉OpenGL ES让渲染填满整个帧缓存，调用视图的“-drawRect：”方法来实现调用OpenGL ES函数进行真正的绘图，然后让上下文调整外观并使用Core Animation合成器把帧缓存的像素颜色渲染缓存与其他相关层混合起来。
-(void)display{
    [EAGLContext setCurrentContext:self.context];
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    [self drawRect:[self bounds]];
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

/*
 *glViewport()函数可以用来控制渲染至帧缓存的子集，但是在这个例子中使用的是整个帧缓存。
 *如果视图的委托属性不是nil，-drawRect：方法会调用委托的-glkView：drawInRect：方法。没有委托，AGLKView什么都不会绘制。AGLKView的子类可以通过重写继承的“-drawRect：”实现来绘图，即使是没有指定委托。“-glkView：drawInRecr：”的参数是一个要被绘制的视图和一个覆盖整个视图范围的矩形。
 **/
-(void)drawRect:(CGRect)rect{
    if (delegate) {
        [self.delegate glkView:self drawInRect:[self bounds]];
    }
}
/*
 *任何在接收到视图重新调整大小的消息时，Cocoa Touch都会调用下面的-layout-SubViews方法。视图附属的帧缓存和像素颜色渲染缓存取决于视图的尺寸。视图会自动地调整相关层的尺寸。与上下文的renderbufferStorage：fromDrawable:方法会调整视图的缓存的尺寸以匹配层的新尺寸。
 ***/
-(void)layoutSubviews{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    [EAGLContext setCurrentContext:self.context];
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    if (0 != depthRenderBuffer) {
        glDeleteRenderbuffers(1, &depthRenderBuffer);//Step7
        depthRenderBuffer = 0;
    }
    
    GLint currentDrawableWidth = self.drawableWidth;
    GLint currentDrawableHeight = self.drawableHeight;
    if (self.drawableDepthFormat != AGLKViewDrawableDepthFormatNone && 0 < currentDrawableWidth && 0 < currentDrawableHeight) {
        glGenRenderbuffers(1, &depthRenderBuffer);//Step1
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);//Step2
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, currentDrawableWidth, currentDrawableHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
    }
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
         NSLog(@"failed to make complete frame buffer object %x", status);
    }
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
}
/*
 *-drawableWidth和drawableHeight方法是他们各自的属性访问器。它们被实现用来通过OpenGL ES的glGetRenderbufferParameteriv()方法获取和返回当前上下文的帧缓存的像素颜色渲染缓存的尺寸。
 **/
-(NSInteger)drawableWidth{
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    return (NSInteger)backingWidth;
}
-(NSInteger)drawableHeight{
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    return (NSInteger)backingHeight;
}
//最后，在一个对象可以被回收时Cocoa Touch会自动地调用-dealloc方法。然后它的资源就会返回给操作系统。AGLKView实现dealloc方法是为了确保视图的上下文不再是当前的上下文，其次是为了设置上下文属性为nil。如果在属性变成nil之后，视图的上下文不再被使用了，那个上下文也会被自动回收。
-(void)dealloc{
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    context = nil;
}

@end
