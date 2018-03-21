//
//  AGLKViewController.m
//  OpenGLES_Ch2_2
//
//  Created by frank.Zhang on 21/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import "AGLKViewController.h"

@interface AGLKViewController ()

@end

@implementation AGLKViewController

static const NSInteger kAGLKDefaultFramesPerSecond = 30;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (nil != (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        
        self.preferredFramesPerSecond = kAGLKDefaultFramesPerSecond;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.paused = NO;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder{
    if (nil != (self = [super initWithCoder:coder])) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        self.preferredFramesPerSecond = kAGLKDefaultFramesPerSecond;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.paused = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AGLKView *view = (AGLKView *)self.view;
    NSAssert([view isKindOfClass:[AGLKView class]],
             @"View controller's view is not a AGLKView");
    view.opaque = YES;
    view.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.paused = NO;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.paused = YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }else{
        return YES;
    }
}

-(void)drawView:(id)sender{
    [(AGLKView *)self.view display];
}

-(NSInteger)framesPerSecond{
    return 60 / displayLink.preferredFramesPerSecond;
}

-(NSInteger)preferredFramesPerSecond{
    return preferredFramesPreSecond;
}

-(void)setPreferredFramesPerSecond:(NSInteger)avalue{
    preferredFramesPreSecond = avalue;
    displayLink.frameInterval = MAX(1, (60 / avalue));
}

-(BOOL)isPaused{
    return  displayLink.paused;
}

-(void)setPaused:(BOOL)avalue{
    displayLink.paused = avalue;
}

-(void)glkView:(AGLKView *)view drawInRect:(CGRect)rect{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
