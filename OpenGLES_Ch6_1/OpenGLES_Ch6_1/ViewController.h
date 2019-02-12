//
//  ViewController.h
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "SceneCar.h"
@interface ViewController : GLKViewController<SceneCarControllerProtocol>
@property (nonatomic, strong, readonly) NSArray *cars;
@property (nonatomic, assign, readonly) SceneAxisAllignedBoundingBox rinkBoundingBox;

@end

