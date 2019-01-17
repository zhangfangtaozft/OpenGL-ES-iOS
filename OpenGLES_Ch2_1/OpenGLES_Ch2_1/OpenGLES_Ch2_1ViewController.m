//
//  OpenGLES_Ch2_1ViewController.m
//  OpenGLES_Ch2_1
//
//  Created by frank.Zhang on 11/02/2018.
//  Copyright © 2018 Frank.Zhang. All rights reserved.
//

#import "OpenGLES_Ch2_1ViewController.h"



@implementation OpenGLES_Ch2_1ViewController
@synthesize baseEffect;

typedef struct {
    GLKVector3 positionCoords;
}SceneVertex;

static const SceneVertex vertices[] = {
    {{-1.0f,-1.0f,1.0f}},
    {{1.0f,-1.0f,0.0f}},
    {{1.0f,1.0f,0.0f}},
};
/*
 viewDidLoad方噶会将它继承的view属性的值转换为GLKView类型，类似OpenGLES_Ch2_1ViewController的GLKViewController的子类只能与GLKView实例或者是GLKView子类的实例一起正确工作。但是这个离子的storyboard文件定义了哪一个是与应用的GLKViewController实例相关联的视图。使用Assert（）函数的一个运行时验证会验证在运行时从storyboard加载的视图是否是正确的类型。如果验证的条件为false，那么NSAssert()会向调试器活iOS设备控制台发送一个错误消息。NSAssert()还会还会生成一个如果不做处理就停止应用的NSInternallnconsistencyException。在这个例子中，无法从一个加载自storyboard的错误视图还原应用的界面，因此在运行时监测到错误时，最好先停止应用。
 如在第一章介绍的，OpenGL ES的上下文不仅会保存OpenGL ES的状态，还会控制GPU去执行渲染运算，OpenGLES_Ch2_1ViewController的viewDidLoad方法会分配并且初始化一个內建的EAGLContext类的实例，这个实例会封装一个特定于某个平台的OpenGL ES 上下文。苹果还没有说明开头的EAGL前缀代表什么，但是它可能代表的是“Embedded Apple GL”。苹果iOS中的OpenGL ES 框架一般是以EAGL 为前缀来声明Objective-C类和函数的。
 **/
- (void)viewDidLoad {
    [super viewDidLoad];
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's view is not a GLKView");
    //在任何其他的OpenGL ES 配置或者渲染发生之前，应用的GLKView实例的上下文属性都需要设置为当前。EAGLContext实例既支持OpenGL ES 1.1，又支持OpenGL ES2.0。本书中的例子是2.0的版本。下面的代码行在为视图的上下文属性赋值之前，分配了一个新的EAGLContext的实例，并用粗体标注的常量将他们初始化为OpenGL ES 2.0
    view.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    //-ViewDidLoad方法接着设置OpenGLES_Ch2_1ViewController的baseEffect属性为一个新分配并初始化的GLKBaseEffect类型的实例，同时设置GLKBaseEffect实例的一些属性为比较适合这个例子的值。
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;//如果这个设置成GL_FALSE，绘制的图形就是白色的
    //GLKBaseEffect 类提供了一个不依赖于所使用的OpenGL ES 笨笨的控制OpenGL ES 渲染的方法，OpenGL ES 1.1跟OpenGL ES 2.0内部工作机制是非常不同的。2.0版本执行为GPU专门定制的程序。如果没有GLKit和GLKBaseEffect类，完成这个简单的例子就需要使用OpenGL ES 2.0的“Shading Language”变成写一个小的GPU程序。GLKBaseEffect会在需要的时候自动地构建GPU程序并极大地简化本书中的例子。
    //控制渲染像素颜色的方式有很多种。这个应用的GLBaseEffect实例使用一个恒定不变的白色来渲染三角形。这就意味着在三角形中没一个像素都有相同的颜色。下面的代码使用在GLKit中定义的用于保存4个颜色元素值的C数据结构体GLKVector4来设置这个恒定的颜色。
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 0.0f, 1.0f, 1.0f);//需要渲染的图形的颜色
    //前三个颜色值是第一章中介绍的红，绿，蓝，第四个是透明度。它决定像素是半透明还是不透明。透明度元素会在第三章做详细的介绍。设置红绿蓝为满值的1.0，以设置成为白色。设置透明度的值为1.0，颜色完全不透明。红绿蓝和透明度值统称为一个RGBA颜色。GLKVector4Make()函数返回一个用指定的值初始化的GLKit GLKVector4结构体。
    //GLClearColor()函数设置当前OpenGL ES的上下文的“清除颜色”为不透明的黑色。清除颜色由RGBA颜色元素值组成，用于在上下文的缓存被清除时初始化每一个像素的颜色值。
     glClearColor(0.0f, 1.0f, 0.0f, 1.0f);//背景颜色
    /*
     第一章介绍了用于在CPU控制的内存和GPU控制的内存之间交换数据的缓存的概念。用于定义要绘制的三角形的顶点位置数据必须要发送到GPU来渲染。创建并使用一个用于保存顶点数据集的顶点属性数组缓存。前三个步骤如下：
     1）为缓存生成一个独一无二的标识符。
     2）为接下来的运算绑定缓存。
     3）复制数据到缓存中
     下面来自-viewDidLoad方法的实现的代码执行了前3步：
     
     **/
    //在第一个步骤中，glGenBuffers()函数的第一个参数用于指定要生成的缓存标识符的数量，第二个参数是一个指针，指向生成的标识符的内存保存位置。在当前情况下，一个标识符被生成，并且保存在vertexBufferID实例变量中。
    glGenBuffers(1, &vertexBufferID);//(第一步，为缓存生成一个独一无二的标识符）
    //在第二个步骤中，glBindBuffer()函数绑定用于指定标识符的缓存到当前缓存。OpenGL ES 保存不同类型的缓存标识符到当前OpenGL ES上下文的不同部位。但是，在任意时刻，每种类型只能绑定一个缓存。如果在这个例子中使用了两个顶点属性数组缓存，那么在同一时刻，他们不能都被绑定。
    //glBindBuffer()的第一个参数是一个常量，用于指定要绑定哪种类型的缓存。OpenGL ES 2.0对于glBindBuffer()的实现只支持两种类型的缓存，GL_ARAY_BUFFER和GL_ELEMENT_ARRAY_BUFFER。GL_ELEMENT_ARRAY_BUFFER将会在第六章中详细解释。GL_ARRAY_buffer类型用于指定一个顶点属性数组。例如本例中三角形定点的位置。glBindBuffer()的第二个参数是要绑定的缓存的标识符。
    //注意：缓存标识符实际上是无符号整型。0值表示没有缓存。用0作为第二个参数调用glBindBuffer()函数来配置当前上下文的话，没有制定类型的缓存会被绑定。缓存标识符在OpenGL ES 文档中又叫做“names”。
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);//(第二步：为接下来的运算绑定缓存)
    //在第三个步骤中，glBufferData函数赋值应用的顶点数据到当前上下文所绑定的定点缓存中。
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);//(第三步：复制数据到缓存中)
    //glBufferData()的第一个参数用于指定要更新当前上下文所绑定的是哪一个缓存。第二个参数指定要赋值进这个缓存的字节的数量。第三个参数是要复制的字节的地址。最后，第四个参数提示了缓存在未来运算中更可能要被怎么使用。GL_STATIC_DRAW提示会告诉上下文，缓存中的内容适合复制到GPU控制的内存，因为很少对其进行修改。这个信息可以帮助OpenGL ES 优化内存使用。使用GL_DYNAMIC_DRAW作为提示会告诉上下文，环村内的数据会频繁改变，同时提示OpenGL ES以不同的方式处理缓存的存储。
}
//每当一个GLView实例需要被重绘时，他都会让保存在视图的上下文属性中的OpenGL ES 的上下文成为当前上下文。如果需要的话，GLKView实例会绑定一个与Core Animation层分享的帧缓存，执行其他的标准OpenGL ES配置，并发送一个消息来调用OpenGLES_Ch2_1ViewController的-glkView: drawRect:方法，-glkView: drawRect:是GLKView类的委托方法。作为GLKViewCotroller的子类,OpenGLES_Ch2_1ViewController会自动成为从storyboard文件加载的关联视图的委托。
//下面委托方法的实现高速baseEffect准备好当前OpenGL ES的上下文，以便为使用baseEffect生成的属性和Shading Language程序的绘图做好准备。接着调用像素的颜色为前面使用glClearColor()函数设定的值。正如2.1届锁描述的，帧缓存可能有除了像素颜色渲染之外的其他附加的缓存，并且如果其他的缓存被使用了，它们可通过在glClear()函数中指定的不同的参数来清除，glClear()函数会有效地设置帧缓存中的没一个像素的颜色为背景色。
//在甄嬛村被清理之后，是时候使用存储在当前绑定的OpenGL ES 的GL_ARRAY_BUFFER类型的缓存中的顶点数据绘制例子中等三角形了。使用缓存当前的前三步已经在-viewDidLoad方法中被执行了。正如第一章所描述的，OpenGLES_Ch2_1ViewController的‘glkView:drawInRect:’方法会执行剩下的几个步骤：
//4）启动，
//5）设置指针
//6) 绘图
//在第4个步骤中通过调用glEnableVertexAttribArray()来启动顶点缓存渲染操作，OpenGL ES 所支持的每一个渲染操作都可以单独地使用刚保存在当前OpenGL ES 上下文中的设置来开启或关闭。
//在第5步中，glVertextAttribPointer()函数会告诉OpenGL ES 顶点数据在哪里，以及怎么解释为每个顶点保存的数据。在这个例子中，glVertextAttribPointer()的第一个参数指示当前绑定的缓存包含每一个顶点的位置信息。第二个参数指示每一个位置有三个部分。第三个参数告诉OpenGL ES 每个部分都保存为一个浮点类型的值。第四个参数告诉OpenGL ES 小数点固定数据是否可以被改变。本书中没有例子会使用小数点固定的数据，因此这个参数值是GL_FALSE。
//注意：小数点固定类型是OpenGL ES 支持的对于浮点类型的一种替代。小数点规定类型用牺牲精度的方法来节省内存。所有现代GPU都对浮点类型的使用做了优化，并且小数点固定数据在使用之前最终都会被转换成浮点数。因此坚持使用浮点数可以减少GPU的运算量，并且可以提高精度。
//第五个参数叫做“步幅”，它指定了每个顶点的保存需要多少个字节，换句话说，步幅指定了GPU从一个顶点的内存开始位置到下一个顶点的内存开始位置需要跳过多少字节。sizeOf(GLKVector3)指示在缓存中没有额外的字节，既顶点位置数据是密封的，在一个顶点缓存中保存出了每个顶点位置的X,Y,Z坐标之外的其他数据也是可能的。图2-8中的顶点数据内存模型显示了顶点存储器的一些选项，第一个图显示的是每个顶点的3D顶点位置坐标都紧密地保存在12字节中，就像OpenGLES_Ch2_1那个例子一样，第二个图显示的是用于每一个顶点存储器的额外字节，因此在内存中在一个顶点与下一个顶点位置坐标之间有缺口。
//glVertexAttribPointer()的最后我一个参数就是NULL这告诉OpenGL ES可以从“当前”绑定的顶点缓存的开始位置访问顶点数据。
//在第六步中，通过调用glDrawArrays()来执行绘图，glDrawArrays()的第一个参数会告诉CPU怎么处理在绑定的顶点缓存内的顶点数据。这个例子会指示OpenGL ES去渲染三角形，glDrawArray()的第二个参数和第三个参数分别指定缓存内的需要渲染的第一个顶点的位置和需要渲染的顶点的数量。至此，在图2-3中显示的场景已经被完全地渲染出来或者至少在GPU处理完成后它就被完全地渲染出来。请记住GPU运算与CPU运算时异步的，在这个例子中所有的代码都是运行在CPU上面的，然后在需要进一步处理的时候想GPU发送命令，GPU可能也会处理发送自iOS的Core Animation的命令，因此在任何给定的时刻GPU总共需要执行多少处理并不一定。
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    /*告诉OpenGL ES顶点数据在哪里，以及怎么解释为没一个顶点保存的数据。下面是对于每一个参数的解释：
     第一个参数表示当前保存的缓存包含每一个顶点的位置信息。
     第二个参数表示每一个定点包含三个部分。
     第三个参数告诉OpenGL ES每部分保存为一个浮点类型的值。
     第四个部分告诉Opengl ES小数点固定数据是否可以被改变。这个例子中没有使用小数点固定的数据，所以选择GL_FALSE。
     第五个参数叫做“步幅”，它指定了每一个定点的保存需要多少个字节。换句话说，步幅指定了GPU从一个定点内存位置开始到下一个定点内存位置转到下一个顶点的内存开始位置需要跳过多少字节。sizeof(GLKVector3)指示在缓存中没有额外的字节，也就是说，顶点位置数据是密封的，在一个顶点缓存中保存了每一个顶点的X,Y,Z坐标之外的其他数据也是有可能的。因此，在内存中，在一个顶点与下一个顶点的位置坐标之间有缺口也是有可能的。
     第六个参数是NULL，表示可以从当前绑定的顶点缓存的开始位置访问顶点数据。
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    /*
    glDrawArrays()是执行回吐的最后一个步骤，下面是对于每一个参数的解释：
     第一个参数：会告诉GPU怎么处理在绑定顶点缓存内的顶点数据，
     第二个参数和第三个参数分别指定缓存内的需要渲染的第一个顶点的位置和顶点的数量。
     */
    glDrawArrays(GL_TRIANGLES, 0, 3);
    /*
     这个例子中的所有的代码试运行在CPU上的，然后再需要进一步处理的时候向GPU发送命令，GPU也可能会处理来自iOS的Core Animation的命令，因此在任何给定的时刻GPU总共需要执行多少处理并不一定。
     */
}

//这个方法在树上是说的viewdidunload方法、第七步是删除不需要的定点缓存和上下文，设置vertexbufferID为0避免了对应的缓存被删除以后还使用其无效的标识符，设置试图上下文为nil并且设置当前的上下文为nil以便于让cocoaTouch收回所有的上下文使用的内存和其他资源。
-(void)dealloc{
    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
