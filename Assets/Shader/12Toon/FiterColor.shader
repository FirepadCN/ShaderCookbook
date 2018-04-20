// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderCookbook/FitColor"
{
        Properties
        {
                _MainTex("主纹理", 2D) = "white" { }
                _TransparentColourKey("过滤的颜色", Color) = (0,0,0,1)
                _TransparencyToleranceR("透明公差R", Range(0.01, 1.0)) = 0.01
                _TransparencyToleranceG("透明公差G", Range(0.01, 1.0)) = 0.01
                _TransparencyToleranceB("透明公差B", Range(0.01, 1.0)) = 0.01
        }
 
        SubShader
        {
                Pass
                {
                        Tags{ "RenderType" = "Opaque" "Queue" = "Transparent" }
                        //Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
                        Blend SrcAlpha OneMinusSrcAlpha
                        //Blend One One
                        LOD 200
                        CGPROGRAM
 
                        #pragma vertex vert
                        #pragma fragment frag
                        #include "UnityCG.cginc"
 
                        struct vertInput
                        {
                                float4 pos : POSITION;
                                float2 uv : TEXCOORD0;
                        };
 
                        struct vertOnput
                        {
                                float4 pos : SV_POSITION;
                                float2 uv : TEXCOORD0;
                        };
 
                        vertOnput vert(vertInput input)
                        {
                                vertOnput output;
                                output.pos = UnityObjectToClipPos(input.pos);
                                output.uv = input.uv;
                                return output;
                        }
 
                        sampler2D _MainTex;
                        sampler2D _Background;
                        float3 _TransparentColourKey;
                        float _TransparencyToleranceR;
                        float _TransparencyToleranceG;
                        float _TransparencyToleranceB;
 
 
                        float4 frag(vertInput input) : COLOR//SV_Target
                        {
                                float4 color = tex2D(_MainTex, input.uv);
                                float deltaR = abs(color.r - _TransparentColourKey.r);
                                float deltaG = abs(color.g - _TransparentColourKey.g);
                                float deltaB = abs(color.b - _TransparentColourKey.b);
                                if (deltaR < _TransparencyToleranceR && deltaG < _TransparencyToleranceG && deltaB < _TransparencyToleranceB)
                                {
                                        return float4(0.0f, 0.0f, 0.0f, 0.0f);
                                }
                                else
                                {                
                                        return color;
                                }                
                        }
                        ENDCG
                }
        }
        Fallback "Diffuse"
}