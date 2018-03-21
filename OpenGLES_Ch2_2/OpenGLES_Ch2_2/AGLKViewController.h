//
//  AGLKViewController.h
//  OpenGLES_Ch2_2
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//这个类除了在显示GLKit类的运行机制时使用了AGLKView和AGLKViewController类而不是GLKit类之外，OpenGLES_Ch2_2和OpenGLES_Ch2_1是相同的。
//与GLKit的GLKViewController类相似，AGLKViewController使用一个Core Animation CADisplaylink对象调度和执行与控制器相关联的视图的周期性的重绘。CADisplayLink本质上是一个用于显示更新的同步计时器，它能够被设置用来在每个显示更新或者其他更新时发送一个消息。CADisplayLink计时器的周期是以显示更新来计量的。

#import <UIKit/UIKit.h>
#import "AGLKView.h"

@interface AGLKViewController : UIViewController
{
    CADisplayLink *displayLink;
    NSInteger preferredFramesPreSecond;
}
@property(nonatomic)NSInteger preferredFramesPerSecond;
@property(nonatomic,readonly) NSInteger framesPerSecond;
@property(nonatomic,getter= isPaused) BOOL paused;

@end
