//
//  main.m
//  OpenGLES_Ch2_1
//
//  Created by frank.Zhang on 11/02/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLES_Ch2_1AppDelegate.h"
/*
*main()函数使用Objective-C的@autoreleacepool关键字来开启自动引用计数，main()还会调用UIApplicationMain()函数，这个函数创建了包含UIApplication实例在内的应用的关键对象，同时开始处理用户事件。NSSTringFromClass([OpenGLES_Ch2_AppDelegate class])表达式指定了与新创建的UIApplication实例一起使用的应用委托类的名字。UIApplication创建了一个充满整个显示屏的UIWindow，同时加载了一个或者多个storyboard文件来构建应用的用户界面。UIApplicationMain()函数不会干涉IUApplication的执行,直到用户退出才会返回。
**/
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([OpenGLES_Ch2_1AppDelegate class]));
    }
}
