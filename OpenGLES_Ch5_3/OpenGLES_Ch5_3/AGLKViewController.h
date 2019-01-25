//
//  AGLKViewController.h
//  OpenGLES_Ch5_3
//
//  Created by frank.zhang on 2019/1/25.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AGLKView.h"

@class CADisplayLink;


@interface AGLKViewController : UIViewController
<AGLKViewDelegate>
{
    CADisplayLink     *displayLink;
    NSInteger         preferredFramesPerSecond;
}

@property (nonatomic) NSInteger preferredFramesPerSecond;
@property (nonatomic, readonly) NSInteger framesPerSecond;
@property (nonatomic, getter=isPaused) BOOL paused;

@end
