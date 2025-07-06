// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SimpleVFShader1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM

            #pragma vertex vert  //编译指令：声明顶点着色器
            #pragma fragment frag  //编译指令：声明片段着色器

            //POSITION告诉Unity,把模型的顶点坐标填充到输入参数v中
            //SV_POSITION告诉Unity,顶点着色器的输出是裁剪空间中的顶点坐标。
            float4 vert(float4 v : POSITION) : SV_POSITION
            {
                //将顶点从模型空间转换为裁剪空间
                //return mul(UNITY_MATRIX_MVP, v); //旧版本
                return UnityObjectToClipPos(v);
            }

            //SV_Target告诉Unity,把输出颜色存储到渲染目标中
            fixed4 frag() : SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }

            ENDCG
        }
    }
}
