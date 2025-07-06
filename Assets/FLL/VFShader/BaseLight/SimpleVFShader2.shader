// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SimpleVFShader2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
        _Color ("Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM

            #pragma vertex vert  //编译指令：声明顶点着色器
            #pragma fragment frag  //编译指令：声明片段着色器

            //在CG代码中,我们需要定义一个与属性名称和类型都匹配的变量
            fixed4 _Color;


            //Unity支持的语义有:POSITION,TANGENT, NORMAL, 
            //TEXCOORD0,TEXCOORD1,TEXCOORD2,TEXCOORD3,COLOR等。
            // 类型 名字 ：语义
            struct appdata
            {
                //POSITION语义告诉Unity,用模型空间的顶点坐标填充vertex 变量
                float4 vertex : POSITION;
                //NORMAL语义告诉Unity,用模型空间的法线坐标填充normal 变量
                float3 normal : NORMAL;
                //TEXCOORD0语义告诉Unity,用模型的第一套纹理坐标填充uv 变量
                float4 uv : TEXCOORD0;
            };

            //顶点着色器的输出
            struct v2f
            {
                //SV_POSITION语义告诉Unity,用裁剪空间中的顶点坐标填充pos 变量
                float4 pos : SV_POSITION;  //<-- 输出中必须包含这个语义的变量
                //COLOR0语义告诉Unity,用顶点颜色填充color 变量
                fixed3 color : COLOR0;
            };

            
            //SV_POSITION告诉Unity,顶点着色器的输出是裁剪空间中的顶点坐标。
            v2f vert(appdata v)
            {
                v2f o;
                //将顶点从模型空间转换为裁剪空间
                //return mul(UNITY_MATRIX_MVP, v.vertex); //旧版本v.vertex
                o.pos = UnityObjectToClipPos(v.vertex);
                //v.normal 是模型空间的法线向量，分量范围是[-1,1]
                //乘以0.5并加上0.5，把分量范围映射到[0,1]
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            //片元着色器中的输入，实际上是把顶点着色器的输出进行插值后得到的结果。
            //SV_Target告诉Unity,把输出颜色存储到渲染目标中
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 c = i.color;
                c *= _Color.rgb; //使用_Color属性来控制颜色
                return fixed4(c, 1);
            }

            ENDCG
        }
    }
}
