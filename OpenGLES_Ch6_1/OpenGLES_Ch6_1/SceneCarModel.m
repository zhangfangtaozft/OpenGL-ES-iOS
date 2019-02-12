//
//  SceneCarModel.m
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "SceneCarModel.h"
#import "SceneMesh.h"
#import "bumperCar.h"
#import "AGLKVertexAttribArrayBuffer.h"
@implementation SceneCarModel
- (id)init
{
    SceneMesh *carMesh = [[SceneMesh alloc]
                          initWithPositionCoords:bumperCarVerts
                          normalCoords:bumperCarNormals
                          texCoords0:NULL
                          numberOfPositions:bumperCarNumVerts
                          indices:NULL
                          numberOfIndices:0];
    if(nil != (self = [super initWithName:@"bumberCar"
                                     mesh:carMesh
                         numberOfVertices:bumperCarNumVerts]))
    {
        [self updateAlignedBoundingBoxForVertices:bumperCarVerts
                                            count:bumperCarNumVerts];
    }
    
    return self;
}
@end
