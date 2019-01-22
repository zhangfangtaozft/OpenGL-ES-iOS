//
//  Shader.vsh
//  OpenGLES_Ch3_6
//
//  Created by frank.zhang on 2019/1/21.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
 多重纹理的强大和灵活性在使用自定义的利用OpenGL ES Shading Language的OpenGL ES 2.0片元程序时会变得更加明显。一个额外的例子，在OpenGLES_Ch3_6中，首先使用一个由GLKit的GLKBaseEffect在后台自动生成的Shading Language程序绘制一个立方体，然后使用下面的自定义定点和片元的Shading Language程序绘制第二个立方体，现在不用担心没有学过Shading Language（截止到目前为止，我对于Shading Language也是不熟悉）。
 */

// VERTEX ATTRIBUTES
attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTextureCoord0;
attribute vec2 aTextureCoord1;

// Varyings
varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

// UNIFORMS
uniform mat4 uModelViewProjectionMatrix;
uniform mat3 uNormalMatrix;

void main()
{
    vec3 eyeNormal = normalize(uNormalMatrix * aNormal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.7, 0.7, 0.7, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, lightPosition));
    vColor = vec4((diffuseColor * nDotVP).xyz, diffuseColor.a);

    vTextureCoord0 = aTextureCoord0.st;
    vTextureCoord1 = aTextureCoord1.st;

    gl_Position = uModelViewProjectionMatrix * aPosition;
}
