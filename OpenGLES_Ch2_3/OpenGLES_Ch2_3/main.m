//
//  main.m
//  OpenGLES_Ch2_3
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
//总结
/*
 *所有的图形iOS应用都包含Core Animation层。所有的绘图都发生在层之上。Core Aniamtion合成器会混合当前应用与操作系统的层，从而在OpenGL ES 后帧缓存中产生最终的像素颜色，之后Core Animation合成器切换前后缓存以便把合成的内容显示到屏幕上。
 原生iOS应用程序使用的是苹果的Cocoa Touch框架，并且Xcode IDE组建而成，由Xcode生成的main.m文件包含Cocoa Touch应用结构和从storyboard文件中加载的用户界面代码。一个标准的Cocoa Touch对象集合会提供iOS应用的所有功能，特定于某一个应用的功能是通过修改在标准应用结构中的应用委托或者根视图控制器对象来实现的，复杂的应用会向Xcode工程添加很多额外文件。
 使用OpenGL ES 的Cocoa Touch应用要么使用Core Animation层配置一个与一个OpenGL ES 的帧缓存分享内容的自定义UIView以处理细节，因此开发者很少会从新创建UIView的子类，一个OpenGL ES 上下文会存储当前OpenGL ES 的状态，并控制GPU硬件，每个GLKView实例都需要一个上下文。
 本章中的OpenGLES_Ch2_1例子为接下来的例子奠定了基础，所有本例专有的代码都是在OpenGLES_Ch2_1ViewController类中实现的。应用的storyboard文件指定了GLKView实例，这个实例使用根视图控制器作为委托。委托会接受来自其他对象的消息。并在响应中执行特定应用的操作或者控制其他对象。
 例子中OpenGLES_Ch2_1ViewControlle类的实现包含3个方法：一个会在视图从storyboard文件中加载时被自动调用，一个会在每次视图需要被重绘时被自动调用，还有一个会在视图卸载时被自动调用，这三个方法分别通过创建必要的上下文和顶点缓存来初始化OpenGL ES,使用上下而未能和顶点缓存在GLKView的与Core Animation层分享内存的帧缓存中绘图，并删除上下文和顶点缓存。
 GLKBaseEffect类隐藏了iOS所支持的OpenGL ES 版本之间的很多不同，当使用OpenGL ES 2.0的时候，GLKBaseEffect会生成直接在GPU上运行的Shanding Language程序GLKBaseEffect使程序员专注于应用的功能和图形概念，而无需学习Shanding Language。
 本例子把OpenGL_Ch2_1例子中的OpenGL ES 函数调用重构AGLKVertexAttribArrayBuffer类和AGLKContext类。
 **/
