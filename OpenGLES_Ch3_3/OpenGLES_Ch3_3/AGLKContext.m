//
//  AGLKContext.m
//  OpenGLES_Ch3_3
//
//  Created by frank.zhang on 2019/1/16.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
 glEnable(GL_BLEND)函数来开启混合。然后通过调用glBlendFunc(sourceFactor,destinationFactor)来设置混合函数。sourceFactor参数用于指定每个片元的最终颜色元素是怎么样影响混合的。destinationFactor参数用于指定子目标帧缓存中已经存在的最终颜色元素会怎么影响混合。最常用的混合函数配置是设置sourceFactor为GL_SRC_ALPHA，设置destinationFactor为GL_ONE_MINUS_SRC_ALPHA。如下代码所示：
 glEnable(GL_BLEND)
 glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 gl_src_alpha用于让源片的透明度元素挨个与其他的片颜色元素相乘。GL_ONE_MINUS_SRC_ALPHA用于让源片的透明度元素（1.0）与在缓存内的正在被更新的像素的颜色元素相乘。结果是，如果片元的透明度值为0，那么没有片元的颜色会出现在镇缓存中。如果片元的透明度值为1.那么片元的透明度值为0.
 GL_SRC_ALPHA用于让源片元的透明度元素挨个与其他的片元颜色元素相乘。GL_ONE_MINUS_SRC_ALPHA用于让源片元的透明度元素（1.0）与在缓存帧内的正被更新的像素的颜色元素相乘。结果是，如果片元的透明度是0，那么没有偏远的元素会出现在帧缓存中。如果片元的透明度是1，那么片元的颜色会完全替代在帧缓存中的对应的像素颜色。结余0.0到1.0之间的透明度意味着片元颜色的一部分会被添加到h帧缓存内对应的像素颜色的一部分来产生一个混合的结果。
 */

#import "AGLKContext.h"

@implementation AGLKContext
- (void)setClearColor:(GLKVector4)clearColorRGBA
{
    clearColor = clearColorRGBA;
    
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    glClearColor(
                 clearColorRGBA.r,
                 clearColorRGBA.g,
                 clearColorRGBA.b,
                 clearColorRGBA.a);
}

- (GLKVector4)clearColor
{
    return clearColor;
}

- (void)clear:(GLbitfield)mask
{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    glClear(mask);
}

- (void)enable:(GLenum)capability;
{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    glEnable(capability);
}

- (void)disable:(GLenum)capability;
{
    NSAssert(self == [[self class] currentContext],
             @"Receiving context required to be current context");
    
    glDisable(capability);
}

- (void)setBlendSourceFunction:(GLenum)sfactor
           destinationFunction:(GLenum)dfactor;
{
    glBlendFunc(sfactor, dfactor);
}

@end
