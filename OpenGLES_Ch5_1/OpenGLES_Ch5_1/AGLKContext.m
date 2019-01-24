//
//  AGLKContext.m
//  OpenGLES_Ch5_1
//
//  Created by frank.zhang on 2019/1/24.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext
- (void)setClearColor:(GLKVector4)clearColorRGBA{
    clearColor = clearColorRGBA;
    NSAssert([[self class] currentContext], @"Receiving context required to be current context");
    glClearColor(clearColorRGBA.r, clearColorRGBA.g, clearColorRGBA.b, clearColorRGBA.a);
}

- (GLKVector4)clearColor{
    return clearColor;
}

- (void)clear:(GLbitfield)mask{
    NSAssert([[self class] currentContext], @"Receiving context required to be current context");
    glClear(mask);
}

- (void)enable:(GLenum)capability{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
    glEnable(capability);
}

- (void)disable:(GLenum)capability{
    NSAssert(self == [[self class] currentContext], @"Receiving context required to be current context");
}

- (void)setBlendSourceFunction:(GLenum)sfactor destinationFunction:(GLenum)dfactor{
    glBlendFunc(sfactor, dfactor);
}
@end
