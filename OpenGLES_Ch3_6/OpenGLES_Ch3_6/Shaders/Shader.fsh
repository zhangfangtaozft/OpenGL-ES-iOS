//
//  Shader.fsh
//  OpenGLES_Ch3_6
//
//  Created by frank.zhang on 2019/1/21.
//  Copyright © 2019 Frank.zhang. All rights reserved.
//
/*
 一个片元着色器是一个由GPU执行的，用来完成计算当前渲染缓存中的每个片元的最终红颜色所需要的运算的间断程序。包含偏远着色器程序的文件通常使用".fsh"文件扩展名。
 相比其他的文离婚和配置方法，GL Shading Language程序往往是既剪短又更加自文档化的。但是，OpenGL ES Shading Language是一个复杂到值得用整本书来论述的主题。
 */
// UNIFORMS
uniform sampler2D uSampler0;
uniform sampler2D uSampler1;

// Varyings
varying lowp vec4 vColor;
varying lowp vec2 vTextureCoord0;
varying lowp vec2 vTextureCoord1;

void main()
{
    lowp vec4 color0 = texture2D(uSampler0, vTextureCoord0);
    lowp vec4 color1 = texture2D(uSampler1, vTextureCoord1);
    
    gl_FragColor = mix(color0, color1, color1.a) * vColor;
}


