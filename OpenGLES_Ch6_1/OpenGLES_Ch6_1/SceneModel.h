//
//  SceneModel.h
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;
@class SceneMesh;
typedef struct {
    GLKVector3 min;
    GLKVector3 max;
}SceneAxisAllignedBoundingBox;
@interface SceneModel : NSObject
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) SceneAxisAllignedBoundingBox axisAlignedBoundingBox;
- (id)initWithName:(NSString *)aName mesh:(SceneMesh *)aMesh numberOfVertices:(GLsizei)aCount;
- (void)draw;
- (void)updateAlignedBoundingBoxForVertices:(float *)verts count:(unsigned int)aCount;
@end
