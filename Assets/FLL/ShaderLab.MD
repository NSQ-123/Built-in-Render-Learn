#
ShaderLab属性类型和CG变量类型的匹配关系
ShaderLab属性类型 :CG变量类型

Color, Vector : float4, half4, fixed4
Range, Float  : float, half, fixed
2D : sampler2D
Cube : samplerCube
3D : sampler3D

#
UNITY_UV_STARTS_AT_TOP用于判断当前平台是否是DirectX类型的平台
通过判断_MainTex_TexelSize.y是否小于0来检验是否开启抗锯齿

使用渲染到纹理技术，即把屏幕图像渲染到一张渲染纹理中时,
如果不采取行任何措请施的话,就会出现纹理翻转的情况
(DirectX 是左上为(0，0))
(OpenGL 是左下为(0,0))

一般情况下，在DirectX平台下，unity 会为我们翻转，但是如果开启了抗锯齿（并且处理多张渲染图像），则不会，
我们需要在顶点着色器中自己翻转渲染纹理

#if UNITY_UV_STARTS_AT_TOP
if (_MainTex_TexelSize.y < 0)
    uv.y = 1-uv.y;
#endif

#
如果我们的确需要在顶点着色器中访问纹理,需要使用tex2Dlod函数来替代,如:
tex2Dlod(tex, float4(uv, 0, 0))
而且我们还需要添加#pragma target3.0,因为tex2Dlod是Shader MIodel3.0中的特性。

#
float 最高精度浮点值 32位
half  中等精度 16位    精度范围 -60000~60000
fixed 最低精度 11位    精度范围 -2.0~2.0
不同平台可能不一样

#
标准光照模型
只关心直接光照，也就是那些直接从光源发射出来照射到物体表面后，经过物体表面一次反射直接进入摄像机的光线，可以分为四个部分
自发光    emissive
高光反射  specular
漫反射    diffuse
环境光    ambient

#
漫反射 Lambert law
C = k·max(0, dot(n, l))
k 为系数 = 漫反射颜色 · 入射光颜色和强度
n 为表面法线
l 为指向光源的单位矢量

#
高光反射 Phong 模型
C = k·max(0,v·r)^m
k 为系数 = 高光反射颜色 · 光源颜色
m 为材质光泽度（反光度），用于控制高光区域的"亮点"有多宽，越大，"亮点"越小
v 为指向视角的单位矢量
r 为反射方向 r=2(n·l)n-l
l 为指向光源的单位矢量

#
高光反射 Blinn 模型
C = k·max(0,n·h)^m
n 为表面法线
h 通过对v和l取平均再归一化后得到  h=(v+l)/|v+l|

#
逐像素和逐顶点--即在片元着色器中计算还是顶点着色器中计算

#
函数:saturate(x)
参数:x:为用于操作的标量或矢量,可以是float、float2、float3等类型。
描述:把x截取在[0,1]范围内,如果x是一个矢量,那么会对它它的每一个分量进行这样的操作。

#
法线变换需要使用逆转置矩阵 (使用原矩阵变化后可能不垂直，尤其是非等比缩放)
n'= (M⁻¹)ᵀ *n   M是模型空间到世界空间的矩阵 

#
有一个重要的数学关系：
n × M^(-1) = (M^(-T)) × n
即：向量乘逆矩阵 = 逆转置矩阵乘向量

#
半兰伯特光照模型
C = K(a·dot(n·l)+b)
k 为系数 = 漫反射颜色 · 入射光颜色和强度
n 为表面法线
l 为指向光源的单位矢量
a 对n和l的点积进行缩放
b 对n和l的点积进行偏移
a和b 通常都为0.5  这样点积的范围从[-1,1]映射到[0,1]内

#
如果一个变换中仅存在平移和旋转变换,那么这个变换的逆矩阵就等于它的转置矩阵

#
渐变纹理
fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
fixed3 diffuse = _LightColor0.rgb * diffuseColor;
使用halfLambert来构建一个纹理坐标，并使用这个坐标对纹理进行采样
由于RampTex是一维纹理(它在纵轴方向上颜色不变),因此纹理坐标的u和v方向我们都使用了halfLambert
把从渐变纹理采样得到的颜色和材质颜色Color相乘,得到最终的漫反射颜色

需要把渐变纹理的WrapMode设为Clamp模式
由于浮点精度的问题,当我们使用fixed2(halfLambert,halfLambert)对渐变纹理进行采样时,虽
然理论上halfLambert的值在[0,1]之间,但可能会有1.000 01这样的值出现。如果
我们使用的是Repeat模式,此时就会舍弃整数部分,只保留小数部分,得到的值
就是0.000001,对应了渐变图中最左边的值

#
透明度测试
只要一个月元的透明度不满足条件(通常是小于某个阈值),那么它对应的片元就会被舍弃。
否则就会进行 进行深度测试、深度写入--要么完全透明看不到，要么完全看不到

#
使用透明度混合时，会关闭深度写入（并没有关闭深度测试）-->可以得到半透明效果
它会使用当前片元的透明度作为混合因子,与已经存储在颜色缓冲中的颜色值进行混合,得到新的颜色。
使用透明度混合渲染一个片元时,还是会比较它的深度值与当前深度缓冲中的深度值,如果它的深度值距离摄像机更远,那么就不会再进行混合操作。因此，对于透明度混合来说，深度缓存是只读的。
-->如果不透明物体出现在一个透明物体前
-->如果先渲染不透明物体，可以遮挡透明物体
-->如果先渲染透明物体，。。。。