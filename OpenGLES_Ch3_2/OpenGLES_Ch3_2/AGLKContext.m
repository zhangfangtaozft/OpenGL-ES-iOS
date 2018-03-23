//
//  AGLKContext.m
//  OpenGLES_Ch3_2
//
//  Created by frank.Zhang on 23/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext
-(void)setClearColor:(GLKVector4)clearColorRGBA{
    clearColor = clearColorRGBA;
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);
}

-(GLKVector4)clearColor{
    return  clearColor;
}

-(void)clear:(GLbitfield)mask{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    glClear(mask);
}

-(void)enable:(GLenum)captibility{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    glEnable(captibility);
}

-(void)disable:(GLenum)captibility{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    glDisable(captibility);
}

-(void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor{
    glBlendFunc(sfactor, dfactor);
}

@end
