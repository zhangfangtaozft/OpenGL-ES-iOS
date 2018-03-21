//
//  AGLKView.h
//  OpenGLES_Ch2_2
//
//  Created by frank.Zhang on 20/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;
@protocol AGLKViewDelegate;

typedef enum {
    AGLKViewDrawableDepthFormatNone = 0,
    AGLKViewDrawableDepthFormat16,
}AGLKViewDrawableDepthFormat;

@interface AGLKView : UIView
{
    EAGLContext *context;
    GLuint defaultFrameBuffer;
    GLuint colorRenderbuffer;
    GLuint depthRenderBuffer;
    GLint drawableWidth;
    GLint drawableheight;
}

@property (nonatomic, weak) IBOutlet id <AGLKViewDelegate> delegate;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, readonly) NSInteger drawableWidth;
@property (nonatomic, readonly) NSInteger drawableHeight;
@property (nonatomic) AGLKViewDrawableDepthFormat drawableDepthFormat;

-(void)display;

@end
#pragma mark - AGLKViewDelegate
/*
 *AGLKViewDelegate协议指定了一个任何AGLKView的委托都必须实现的方法。如果AGLKView实例的委托属性不等于nil，每个AGLKView实例都会向它的委托发送“-glkView:drawInRect:”消息。
 AGLKView的实现比较简单，但重写了来自View的多个方法并添加了一些用于支持OpenGL ES绘图的方法。
 **/
@protocol AGLKViewDelegate<NSObject>
@required
-(void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end
