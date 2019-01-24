 `GLKitde1GLKVector3Normalize(GLKVector3 vectorA)`函数需要多点解释。这个函数的目的是返回一个与矢量A方向相同但是大小等于1.0的单位向量。一个矢量的大小是这个矢量的长度，这个长度可以用标准距离公式$$\sqrt{vectorA.x^2 + vectorA.y^2 + vectorA.z^2}$$计算得到。
 下面的对于`SceneVector3Length()`和`SceneVector3Normalize()`函数的实现与对应的`GLKVector3Length()`和`GLKVector3Normalize()`
 

