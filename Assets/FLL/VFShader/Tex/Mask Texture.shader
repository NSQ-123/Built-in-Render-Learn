Shader "Custom/Mask Texture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" { }
        _BumpMap ("Bump Map", 2D) = "bump" { }
        _BumpScale ("Bump Scale", Float) = 1.0 //控制凹凸程度
        _SpecularMask ("Specular Mask", 2D) = "white" { }
        _SpecularScale ("Specular Scale", Float) = 1.0 //控制遮罩对高光的贡献
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
            float4 _MainTex_ST;//纹理缩放和偏移 主纹理、凹凸纹理、遮罩纹理共同使用
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;


            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION; //顶点坐标在裁剪空间中的位置
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;//切线空间下的光照方向
                float3 viewDir : TEXCOORD2;//切线空间下的观察方向
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                //o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);//等价于
                //计算切线空间下的光照方向和观察方向
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                //使用法线纹理对光照方向和观察方向进行变换
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - dot(tangentNormal.xy, tangentNormal.xy));
                //计算漫反射
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                //计算高光
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                //使用遮罩纹理控制高光反射
                //对遮罩纹理进行采样,得到遮罩值，与_SpecularScale相乘，一起控制高光的强度
                fixed3 specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
                //计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}