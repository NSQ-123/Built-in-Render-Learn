//逐顶点计算的 漫反射
Shader "Custom/Diffuse_vertex"
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
                fixed3 color : COLOR;
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
                //环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                //法线 -- 将法线从模型空间转换到世界空间
                //法线变换需要使用逆转置矩阵 worldNormal= (M⁻¹)ᵀ *v.normal  M是模型空间到世界空间的矩阵
                //unity_WorldToObject 是unity_ObjectToWorld的逆矩阵
                //逆转置矩阵乘向量 =向量乘逆矩阵 
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                //光源方向
                //_WorldSpaceLightPos0.xyz 是光源方向 (只有一个光源且是平行光 才能使用这个)
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                //漫反射
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                //将环境光和漫反射颜色相加
                o.color = ambient + diffuse;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
               
                fixed4 col = fixed4(i.color, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
