Shader "Custom/NormalMap TangentSpace"
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
                float3 tangentLightDir : TEXCOORD1;//切线空间下的光照方向
                float3 tangentViewDir : TEXCOORD2;//切线空间下的观察方向
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                //计算切线空间下的光照方向和观察方向
                //binormal 是切线空间下的第三个坐标轴
                float3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                //rotation 是切线空间下的旋转矩阵  ??? 如何得到的==>TANGENT_SPACE_ROTATION;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                
                //将光照方向和观察方向从模型空间转换到切线空间
                o.tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.tangentViewDir = mul(rotation, ObjSpaceViewDir(v.vertex));
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
               fixed3 tangentLightDir = normalize(i.tangentLightDir);
               fixed3 tangentViewDir = normalize(i.tangentViewDir);
               //采样法线贴图
               fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
               fixed3 tangentNormal;
               //法线贴图中的法线方向是[-1,1]，所以需要将法线方向映射到[0,1]
               //(1)如果texture 没有标记为normal map 
               //tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
               //(2)如果texture 标记为normal map 
               tangentNormal = UnpackNormal(packedNormal);
               tangentNormal.xy *= _BumpScale;

               tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

               //计算切线空间下的光照
               //采集纹理
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                fixed3 color = ambient + diffuse + specular;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}