//
//  AGLKView.h
//  OpenGLES_Ch5_3
//
//  Created by frank.zhang on 2019/1/25.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@class EAGLContext;
@protocol AGLKViewDelegate;
typedef enum
{
    AGLKViewDrawableDepthFormatNone = 0,
    AGLKViewDrawableDepthFormat16,
} AGLKViewDrawableDepthFormat;

@interface AGLKView : UIView
{
    EAGLContext   *context;
    GLuint        defaultFrameBuffer;
    GLuint        colorRenderBuffer;
    GLuint        depthRenderBuffer;
    GLint         drawableWidth;
    GLint         drawableHeight;
}

@property (nonatomic, weak) IBOutlet id
<AGLKViewDelegate> delegate;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, readonly) NSInteger drawableWidth;
@property (nonatomic, readonly) NSInteger drawableHeight;
@property (nonatomic) AGLKViewDrawableDepthFormat
drawableDepthFormat;

- (void)display;

@end


#pragma mark - AGLKViewDelegate

@protocol AGLKViewDelegate <NSObject>

@required
- (void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end
