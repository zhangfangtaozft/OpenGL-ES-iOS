//
//  AGLKTextureLoader.m
//  OpenGLES_Ch3_2
//
//  Created by frank.Zhang on 23/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//
/*
 AGLKTextureLoader是苹果的GLKit的GLKTextureLoader类的部分实现。AGLKTextureLoader不会出现在产品代码中，它仅仅是为了消除关于GLKTextureLoader、Core Graphics 和 OpenGL ES 之间交互的神秘感。
 GLKit的GLKTextureLoader类支持异步纹理加载，MIP贴图生成，以及比简单的2D平面更加吸引人的纹理缓存类型。AGLKTextureLoader只复制了在例子3_1中用到的GLKTextureLoader的功能。
 */
#import "AGLKTextureLoader.h"
typedef enum{
    AGLK1 = 1,
    AGLK2= 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}AGLKPowerof2;

static AGLKPowerof2 AGLKCalculatePowerOf2ForDimension(GLuint dimension);
static NSData *AGLKDataWithResizedCGImageBytes(CGImageRef CGImage,size_t *widthPtr,size_t *heightPtr);
/*
 在cgImage被拖入imageData提供的字节之后，函数会返回imageData()和数据对应的高度和宽度。AGLKTextureLoader文件内剩下的diamante是不言自明的。只有一个小细节的实现有点生疏，就是为了用于初始化AGLKTextureinfo类的一个方法的实现和声明所使用的一个一个Objective-C类别（category）。
 */
@interface AGLKTextureInfo(AGLKTextLoader)
- (id)initWithName:(GLuint)aName
            target:(GLenum)aTarget
             width:(size_t)aWidth
            height:(size_t)aHeight;
@end

@implementation AGLKTextureInfo(AGLKTextLoader)
-(id)initWithName:(GLuint)aName target:(GLenum)aTarget width:(size_t)aWidth height:(size_t)aHeight{
    if (nil != (self = [super init])) {
        name = aName;
        target = aTarget;
        width = aWidth;
        height = aHeight;
    }
    return self;
}
@end

@implementation AGLKTextureInfo
@synthesize name;
@synthesize target;
@synthesize width;
@synthesize height;
@end
/*
 AGLKTextureLoader的实现展现了Core Graphics和OpenGL ES的整合，提供了与GLKit的GLKTextureLoader相似的功能，在“+textureWithCGImge:operation:error:”方法中对于OpenGL ES函数的调用完成了标准的缓存管理步骤，包括生成，绑定和初始化一个新的纹理缓存。
 */
@implementation AGLKTextureLoader
/*
 下面这个方法使用AGLKDataWithResizedCGImageBytes()函数来获取用于初始化纹理缓存的内容字节。
 */
+(AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError{
    size_t width;
    size_t height;
    NSData *imageData = AGLKDataWithResizedCGImageBytes(cgImage, &width, &height);
    GLuint textureBufferID;
    /*
     glGenTextures()和glBindTexture()函数与用于顶点缓存的命名方式相似的函数的工作方式相同。
     */
    glGenTextures(1, &textureBufferID);
    glBindTexture(GL_TEXTURE_2D, textureBufferID);
    /*
     glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels)函数是OpenGL ES标准中最复杂的函数之一。它复制图片像素的颜色数据到绑定的纹理缓存中。glTexImage2D每一个参数的介绍如下：
     第一个参数：用于2D纹理的GL_TEXTURE_2D
     第二个参数：必须是0.如果开启了MIP贴图，使用第二个参数来明确地初始化每个细节级别，但是要小心，因为从分辨率到只有一条纹理的每一个级别都必须被指定，否则GPU将不会接受这个纹理缓存。
     第三个参数：internalformat，用于指定在纹理缓存内每一个纹素需要保存的信息的数量，对于iOS设备来说，皖苏信息要么是GL_RGB,要么是GL_RGBA。GL_RGB为每一个纹素保存红，绿，蓝三种颜色元素。GL_RGBA保存一个额外的用于指定每个纹素透明度的透明度元素。
     第四个元素和第五个元素用于指定图像的宽度和高度，高度和宽度需要是2的幂，border参数一直是用来确定围绕纹理的纹素的一个边界的大小，但是在OpenGL ES中它总是被设置为0.
     第七个元素：format用于指定初始化缓存所使用的图像的数据中的每个像素索要保存的信息。这个参数总是与internalformat参数相同。其他的openGL ES版本可能在format和internalformat参数不一致时自动执行图像数据格式的转换。
     倒数第二个参数：用于指定缓存中的纹素数据所使用的位编码类型，可以是下面的符号之一：
         #define GL_UNSIGNED_BYTE                                 0x1401
         #define GL_UNSIGNED_SHORT_4_4_4_4                        0x8033
         #define GL_UNSIGNED_SHORT_5_5_5_1                        0x8034
         #define GL_UNSIGNED_SHORT_5_6_5                          0x8363
         使用GL_UNSIGNED_BYTE 会提供最佳色彩质量，但是它每个纹素中每个颜色元素需要保存一字节的存储空间。结果是每次取样一个RGB类型的元素，GPU都必须最少读取三个字节（24位），每一个RGBA类型的纹素的所有的颜色元素需要读取4字节（32位）。其他的纹素的所有元素的信息保存在2字节（16位）中。GL_UNSIGNED_SHORT_5_6_5 格式把5位用于红色，6位用于绿色，5位用于蓝色，但是没有透明度部分。GL_UNSIGNED_SHORT_4_4_4_4格式平均每个纹素的颜色元素使用4位。GL_UNSIGNED_SHORT_5_5_5_1 格式为红，绿，蓝各使用5位，但是透明度只使用1位。使用GL_UNSIGNED_SHORT_5_5_5_1 格式会让每个纹素要么完全透明，要么完全不透明。
         不管为每个颜色元素保存的位数量是多少，颜色元素的强度最终都会被GPU缩放到0.0到1.0的范围内。一个强度为满值的颜色元素（所有那个颜色元素的位都是1）对应于一个1.0的强度，透明度颜色元素强度为1.0表示完全不投民，透明度强度为0.5表示50%透明度。透明度强度为0.0表示为完全透明。
     最后一个参数：是一个要被复制到绑定的纹理缓存中的图片的像素颜色数据的指针。
     
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [imageData bytes]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    AGLKTextureInfo *result = [[AGLKTextureInfo alloc]initWithName:textureBufferID target:GL_TEXTURE_2D width:width height:height];
    return result;
}
@end
/*
 AGLKDataWithResizedCGImageBytes()是在AGLKTextureLoader中实现的，并且包含转换一个Core Graphics图像为OpenGL ES可用的合适字节的代码。
 */
static NSData *AGLKDataWithResizedCGImageBytes(CGImageRef cgImage,size_t *widthPtr, size_t *heightPtr){
    NSCParameterAssert(NULL != cgImage);
    NSCParameterAssert(NULL != widthPtr);
    NSCParameterAssert(NULL != heightPtr);
    
    size_t originalWidth = CGImageGetWidth(cgImage);
    size_t originalHeight = CGImageGetWidth(cgImage);
    
    NSCAssert(0 < originalWidth, @"Invalid image width");
    NSCAssert(0 < originalHeight, @"Invalid image width");
    
    size_t width = AGLKCalculatePowerOf2ForDimension(originalWidth);
    size_t height = AGLKCalculatePowerOf2ForDimension(originalHeight);
    NSMutableData *imageData = [NSMutableData dataWithLength:height *width *4];
    NSCAssert(nil != imageData,
              @"Unable to allocate image storage");
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext = CGBitmapContextCreate([imageData mutableBytes], width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(cgContext, 0, height);
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cgImage);
    CGContextRelease(cgContext);
    *widthPtr = width;
    *heightPtr = height;
    return imageData;
}

static AGLKPowerof2 AGLKCalculatePowerOf2ForDimension(GLuint dimension){
    AGLKPowerof2 result= AGLK1;
    
    if (dimension > (GLuint)AGLK512) {
        result = AGLK1024;
    }
    else if (dimension > (GLuint)AGLK256){
        result = AGLK512;
    }
    else if (dimension > (GLuint)AGLK128){
        result = AGLK256;
    }
    else if (dimension >(GLuint)AGLK64){
        result = AGLK128;
    }
    else if (dimension > (GLuint)AGLK32){
        result = AGLK64;
    }
    else if (dimension > (GLuint)AGLK16){
        result = AGLK32;
    }
    else if (dimension > (GLuint)AGLK8){
        result = AGLK16;
    }
    else if (dimension > (GLuint)AGLK4){
        result = AGLK8;
    }
    else if (dimension > (GLuint)AGLK2){
        result = AGLK4;
    }
    else if (dimension > (GLuint)AGLK1){
        result = AGLK2;
    }
    return result;
}

