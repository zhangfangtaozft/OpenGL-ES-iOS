//
//  SceneMesh.m
//  OpenGLES_Ch6_1
//
//  Created by frank.zhang on 2019/2/12.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "SceneMesh.h"
#import "AGLKVertexAttribArrayBuffer.h"

@interface SceneMesh()
@property (nonatomic, strong, readwrite) AGLKVertexAttribArrayBuffer *vertexAttributeBuffer;
@property (assign, nonatomic, readwrite) GLuint indexBufferID;
@property (strong, nonatomic, readwrite) NSData *vertexData;
@property (strong, nonatomic, readwrite) NSData *indexData;
@end

@implementation SceneMesh
@synthesize vertexAttributeBuffer;
@synthesize indexBufferID;
@synthesize vertexData;
@synthesize indexData;

- (id)initWithVertexAttributeData:(NSData *)vertexAttributes indexData:(NSData *)indices{
    if (nil != (self = [super init])) {
        self.vertexData = vertexAttributes;
        self.indexData = indices;
    }
    return self;
}

- (id)initWithPositionCoords:(const GLfloat *)somePositions normalCoords:(const GLfloat *)someNormals texCoords0:(const GLfloat *)someTexCoords0 numberOfPositions:(size_t)countPositions indices:(const GLushort *)someIndices numberOfIndices:(size_t)countIndices{
    NSParameterAssert(NULL != somePositions);
    NSParameterAssert(NULL != someNormals);
    NSParameterAssert(0 < countPositions);
    NSMutableData *vertexAttributesData = [[NSMutableData alloc] init];
    NSMutableData *indicesData = [[NSMutableData alloc] init];
    [indicesData appendBytes:someIndices length:countIndices * sizeof(GLushort)];
    for(size_t i = 0; i < countPositions; i++)
    {
        SceneMeshVertex currentVertex;
        currentVertex.position.x = somePositions[i * 3 + 0];
        currentVertex.position.y = somePositions[i * 3 + 1];
        currentVertex.position.z = somePositions[i * 3 + 2];
        
        currentVertex.normal.x = someNormals[i * 3 + 0];
        currentVertex.normal.y = someNormals[i * 3 + 1];
        currentVertex.normal.z = someNormals[i * 3 + 2];
        
        if(NULL != someTexCoords0)
        {
            currentVertex.texCoords0.s = someTexCoords0[i * 2 + 0];
            currentVertex.texCoords0.t = someTexCoords0[i * 2 + 1];
        }
        else
        {
            currentVertex.texCoords0.s = 0.0f;
            currentVertex.texCoords0.t = 0.0f;
        }
        
        [vertexAttributesData appendBytes:&currentVertex
                                   length:sizeof(currentVertex)];
    }
    
    return [self initWithVertexAttributeData:vertexAttributesData
                                   indexData:indicesData];
}

- (void)dealloc
{
    if(0 != indexBufferID)
    {
        glDeleteBuffers(1, &indexBufferID);
        indexBufferID = 0;
    }
}

- (void)prepareToDraw{
    if(nil == self.vertexAttributeBuffer &&
       0 < [self.vertexData length])
    {
        self.vertexAttributeBuffer =
        [[AGLKVertexAttribArrayBuffer alloc]
         initWithAttribStride:sizeof(SceneMeshVertex)
         numberOfVertices:[self.vertexData length] /
         sizeof(SceneMeshVertex)
         bytes:[self.vertexData bytes]
         usage:GL_STATIC_DRAW];
        self.vertexData = nil;
    }
    
    if(0 == indexBufferID && 0 < [self.indexData length])
    {
        glGenBuffers(1, &indexBufferID);
        NSAssert(0 != self.indexBufferID,
                 @"Failed to generate element array buffer");
        
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBufferID);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,
                     [self.indexData length],
                     [self.indexData bytes],
                     GL_STATIC_DRAW);
        
        self.indexData = nil;
    }
    
    [self.vertexAttributeBuffer
     prepareToDrawWithAttrib:GLKVertexAttribPosition
     numberOfCoordinates:3
     attribOffset:offsetof(SceneMeshVertex, position)
     shouldEnable:YES];
    
    [self.vertexAttributeBuffer
     prepareToDrawWithAttrib:GLKVertexAttribNormal
     numberOfCoordinates:3
     attribOffset:offsetof(SceneMeshVertex, normal)
     shouldEnable:YES];
    
    [self.vertexAttributeBuffer
     prepareToDrawWithAttrib:GLKVertexAttribTexCoord0
     numberOfCoordinates:2
     attribOffset:offsetof(SceneMeshVertex, texCoords0)
     shouldEnable:YES];
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBufferID);
}

- (void)drawUnidexedWithMode:(GLenum)mode startVertexIndex:(GLint)first numberOfVertices:(GLsizei)count{
    [self.vertexAttributeBuffer drawArrayWithMode:mode startVertexIndex:first numberOfVertices:count];
}

- (void)makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)someVerts numberOfVertices:(size_t)count{
    NSParameterAssert(NULL != someVerts);
    NSParameterAssert(0 < count);
    if (nil == self.vertexAttributeBuffer) {
        self.vertexAttributeBuffer =
        [[AGLKVertexAttribArrayBuffer alloc]
         initWithAttribStride:sizeof(SceneMeshVertex)
         numberOfVertices:count
         bytes:someVerts
         usage:GL_DYNAMIC_DRAW];
    }else{
        [self.vertexAttributeBuffer
         reinitWithAttribStride:sizeof(SceneMeshVertex)
         numberOfVertices:count
         bytes:someVerts];
    }
}
@end
