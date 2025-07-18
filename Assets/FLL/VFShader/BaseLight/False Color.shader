Shader "Custom/False Color"
{
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            struct v2f      
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
                float4 coord : COLOR1;
            };

            //通过添加或者取消注释 来控制可视化内容 观察运算结果
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //可视化法线方向
                o.color = fixed4(v.normal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                //可视化切线方向
                o.color = fixed4(v.tangent * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                //可视化副切线方向
                fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.color = fixed4(binormal * 0.5 + fixed3(0.5, 0.5, 0.5), 1.0);

                //可视化第一组纹理坐标
                o.coord = fixed4(v.texcoord.xy * 0.5 ,0.0, 1.0);

                //可视化第二组纹理坐标
                o.coord = fixed4(v.texcoord1.xy * 0.5 ,0.0, 1.0);

                //可视化第一组纹理坐标的小数部分
                o.color = frac(v.texcoord);
                if(any(saturate(v.texcoord) - v.texcoord))
                {
                    o.color.b = 0.5;
                }
                o.color.a = 1.0;

                //可视化第二组纹理坐标的小数部分
                o.color = frac(v.texcoord1);
                if(any(saturate(v.texcoord1) - v.texcoord1))
                {
                    o.color.b = 0.5;
                }
                o.color.a = 1.0;

                //可视化顶点颜色
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }

            ENDCG
        }
    }
}