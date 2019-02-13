//
//  SceneAnimatedMesh.h
//  OpenGLES_Ch6_2
//
//  Created by frank.zhang on 2019/2/13.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "SceneMesh.h"


@interface SceneAnimatedMesh : SceneMesh
- (void)drawEntireMesh;
- (void)updateMeshWithDefaultPositions;
- (void)updateMeshWithElapsedTime:(NSTimeInterval)anInterval;
@end

