Shader "Custom/Ramp Texture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _RampTex ("Ramp Tex", 2D) = "white" { }
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;


            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION; //顶点坐标在裁剪空间中的位置
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);//等价于o.uv = v.texcoord.xy * _RampTex_ST.xy + _RampTex_ST.zw;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;
                //计算漫反射  使用texture 采样漫反射颜色
                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                //使用halfLambert来构建一个纹理坐标，并使用这个坐标对纹理进行采样
                //由于RampTex是一维纹理(它在纵轴方向上颜色不变),因此纹理坐标的u和v方向我们都使用了halfLambert
                //把从渐变纹理采样得到的颜色和材质颜色Color相乘,得到最终的漫反射颜色
                //需要把渐变纹理的WrapMode设为Clamp模式
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;
                //计算高光
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);//半向量=光照方向+观察方向
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);   
            }
            ENDCG
        }
    }
    FallBack "Specular"
}