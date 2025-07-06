Shader "Custom/ShaderLabProperties"
{
    Properties
    {
        _Int ("Int", Int) = 1
        _Float ("Float", Float) = 1.5
        _Range ("Range", Range(0.0, 5.0)) = 3.0
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Vector ("Vector", Vector) = (2, 3, 6, 1)
        _2D ("2D", 2D) = "" { }
        _3D ("3D", 3D) = "" { }
        _Cube ("Cube", Cube) = ""
        _MainTex ("Texture", 2D) = "white" { }
    }


    SubShader
    {
        Tags { "RenderType" = "Opaque" }//可选
        /*
           渲染队列      Queue                    -->  Tags {"Queue"= "Transparent"}
           渲染类型      Render Type              -->  Tags {"RenderType" = "Opaque" }
           关闭批处理    DisableBatching          -->  Tags ("DisableBatching" = "True" }
           投射阴影      ForceNoShadowCasting     -->  Tags {"ForceNoShadowCasting" ="True"}
           忽略投影      IgnoreProjector          -->  Tags {"IgnoreProjector" = "True" }
           能否应用于图集 CanUseSpriteAtlas        -->  Tags ("CanUseSpriteAtlas"="False"}   在使用 Legacy Sprite Packer 的项目中使用此子着色器标签可警告用户着色器依赖于原始纹理坐标，因此不应将其纹理打包到图集中
           预览魔兽      PreviewType              -->  Tags {"PreviewType"= "Plane" }
        */


        //[RenderSetup] 可选的渲染状态
        /*
            提出模式 Cull   --> Cull Back | Front | Off
            深度测试 ZTest  --> ZTest Less Greater | LEqual | GEqual | NotEqual | NotEqual | Always
            深度写入 ZWrite --> ZWrite On | Off
            混合模式 Blend  --> Blend SrcFactor DstFactor
        */
        
                        
        LOD 100

        //特殊Pass
        //1.UsePass 复用其他Unity Shader 中的Pass
        //2.GrabPass 抓取屏幕并将结果存储在一张纹理中


        Pass
        {
            //Pass 标签
            //1.LightMode               Tags {"LightMode" = "ForwardBase" }
            //2.RequireOptions          Tags {"RequireOptions"="SoftVegetation" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
