//
//  AGLKTextureLoader.h
//  OpenGLES_Ch3_2
//
//  Created by frank.Zhang on 23/03/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>
#pragma mark -AGLKTextureInfo
@interface AGLKTextureInfo: NSObject
{
@private
    GLuint name;
    GLenum target;
    GLuint width;
    GLuint height;
}

@property (nonatomic, readwrite) GLuint name;
@property (nonatomic, readwrite) GLenum target;
@property (nonatomic, readwrite) GLuint width;
@property (nonatomic, readwrite) GLuint height;
@end

#pragma mark -AGLKTextureLoader
@interface AGLKTextureLoader : NSObject
+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError **)outError;
@end
