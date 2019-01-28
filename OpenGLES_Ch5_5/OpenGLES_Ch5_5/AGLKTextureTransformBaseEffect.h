//
//  AGLKTextureTransformBaseEffect.h
//  OpenGLES_Ch5_5
//
//  Created by frank.zhang on 2019/1/28.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKTextureTransformBaseEffect : GLKBaseEffect
@property (assign) GLKVector4 light0Position;
@property (assign) GLKVector3 light0SpotDirection;
@property (assign) GLKVector4 light1Position;
@property (assign) GLKVector3 light1SpotDirection;
@property (assign) GLKVector4 light2Position;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d0;
@property (nonatomic, assign) GLKMatrix4 textureMatrix2d1;
- (void)prepareToDrawMultitextures;
@end

@interface GLKEffectPropertyTexture (AGLKAdditions)
- (void)aglkSetParameter:(GLenum)parameterID
                   value:(GLint)value;
@end
