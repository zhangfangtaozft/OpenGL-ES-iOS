//
//  SceneMesh.h
//  OpenGLES_Ch6_2
//
//  Created by frank.zhang on 2019/2/13.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 position;
    GLKVector3 normal;
    GLKVector2 texCoords0;
}SceneMeshVertex;

@interface SceneMesh : NSObject
- (id)initWithVertexAttributeData:(NSData *)vertexAttributes
                        indexData:(NSData *)indices;

- (id)initWithPositionCoords:(const GLfloat *)somePositions
                normalCoords:(const GLfloat *)someNormals
                  texCoords0:(const GLfloat *)someTexCoords0
           numberOfPositions:(size_t)countPositions
                     indices:(const GLushort *)someIndices
             numberOfIndices:(size_t)countIndices;

- (void)prepareToDraw;

- (void)drawUnidexedWithMode:(GLenum)mode
            startVertexIndex:(GLint)first
            numberOfVertices:(GLsizei)count;

- (void)makeDynamicAndUpdateWithVertices:
(const SceneMeshVertex *)someVerts
                        numberOfVertices:(size_t)count;
@end

