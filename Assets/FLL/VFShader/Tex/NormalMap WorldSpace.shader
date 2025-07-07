Shader "Custom/NormalMap WorldSpace"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" { }
        _BumpMap ("Normal Map", 2D) = "bump" { }
        _BumpScale ("Bump Scale", Float) = 1.0  //法线贴图的凹凸程度
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
            sampler2D _MainTex;
            float4 _MainTex_ST;//纹理缩放和偏移 .xy控制缩放，zw控制偏移
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            //切线空间是由顶点法线和切线构建的坐标空间

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;//切线 使用tangent.w来决定切线空间中的第三个坐标轴：如果tangent.w为1，则切线空间的第三个坐标轴为法线的方向，如果tangent.w为-1，则切线空间的第三个坐标轴为法线的方向的反方向
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION; //顶点坐标在裁剪空间中的位置
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;//切线空间到世界空间的变换矩阵的行0
                float4 TtoW1 : TEXCOORD2;//切线空间到世界空间的变换矩阵的行1
                float4 TtoW2 : TEXCOORD3;//切线空间到世界空间的变换矩阵的行2
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
             float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
             fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
             fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
             //采样法线贴图
             fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
             bump.xy *= _BumpScale;
             bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
             //将法线从切线空间转换到世界空间
             bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
             //计算光照
             fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
             fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
             fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
             fixed3 halfDir = normalize(lightDir + viewDir);
             fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
             fixed3 color = ambient + diffuse + specular;
             return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}