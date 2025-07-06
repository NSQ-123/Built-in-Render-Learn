//逐像素计算的 漫反射
Shader "Custom/Diffuse_HalfLambert"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Diffuse;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 worldNormal : TEXCOORD0;
            };

            //Lambert光照模型
            //Cdiffuse = Clight * Cmat * max(0, dot(N, L))
            //Cdiffuse:漫反射颜色
            //Clight:光源颜色
            //Cmat:材质颜色
            //N:法线
            //L:光源方向

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //法线变换需要使用逆转置矩阵 
                //逆转置矩阵*向量 =向量*逆矩阵 
                //n' = (M⁻¹)ᵀ *n = n * M⁻¹   M是模型空间到世界空间的矩阵
                o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
 

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //在世界空间中的法线
                fixed3 worldNormal = normalize(i.worldNormal);
                //在世界空间中的光源方向
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //漫反射
                //_LightColor0 是光源颜色 内置变量 需要设置LightMode
                //半兰伯特光照模型
                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                //将环境光和漫反射颜色相加
                fixed3 color = ambient + diffuse;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
}
