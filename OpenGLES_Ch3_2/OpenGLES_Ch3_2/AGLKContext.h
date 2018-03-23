//
//  AGLKContext.h
//  OpenGLES_Ch3_2
//
//  Created by frank.Zhang on 23/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
@interface AGLKContext : EAGLContext
{
    GLKVector4 clearColor;
}
@property(nonatomic,assign,readwrite) GLKVector4 clearColor;
-(void)clear:(GLbitfield)mask;
-(void)enable:(GLenum)captibility;
-(void)disable:(GLenum)captibility;
- (void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor;
@end
