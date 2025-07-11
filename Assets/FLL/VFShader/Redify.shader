Shader "Custom/Redify"
{
    Properties
    {
        [Toggle(REDIFY_ON)] _Redify("Red?", Int) = 0 //Toggle 宏开关
        _MainTex ("Base (RGB)", 2D) = "white" { }
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200
        
        CGPROGRAM
        #pragma shader_feature REDIFY_ON //宏定义
        #pragma surface surf Lambert addshadow

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;

            #if REDIFY_ON
                o.Albedo.gb *= 0.5;
            #endif
        }
        ENDCG
    }
    //CustomEditor "CustomShaderGUI"  //自定义着色器GUI
}