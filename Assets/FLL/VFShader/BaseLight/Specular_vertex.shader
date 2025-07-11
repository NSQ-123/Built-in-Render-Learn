Shader "Custom/Specular_vertex"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1) //漫反射颜色    
        _Specular ("Specular", Color) = (1,1,1,1) //镜面反射颜色
        _Gloss ("Gloss", Range(8.0, 256)) = 20 //光泽度
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
            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                //镜面反射方向
                //reflect(-l,n) 计算反射方向 worldLightDir是由顶点指向光源的单位向量，所以要取反
                fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));
                //观察方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
                //计算镜面反射
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                o.color = ambient + diffuse + specular;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}