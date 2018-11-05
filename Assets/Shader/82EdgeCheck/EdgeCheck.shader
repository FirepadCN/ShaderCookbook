// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderCookbook/EdgeCheck"
{
	Properties
    {
		[KeywordEnum(H,V)]_ScanDir("ScanDir",float)=0
        _MainTex("Main Texture", 2D) = "white" {}
        _EdgeColor("Edge Color", Color) = (1,1,1,1)
		_EdgeValue("Edge Value",Range(0,3))=1
		_EdgeWidth("EdgeWidth",Range(0.01,0.5))=0.1
		_Speed("Speed",float)=0.1
		_Offset("Offset",float)=1
    }

    SubShader
    {
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#include "UnityCG.cginc"

			#pragma shader_feature _SCANDIR_H _SCANDIR_V

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed4 _EdgeColor;
			float _EdgeValue;
			float _EdgeWidth;
			float _Speed;
			float _Offset;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv[9] : TEXCOORD0;
            };

            //Draw Line:Horizontal,Vertical
            float plot(float2 st,float pct){
				#if _SCANDIR_H
				return smoothstep(pct-_EdgeWidth,pct,st.x)-smoothstep(pct,pct+_EdgeWidth,st.x);
				#elif _SCANDIR_V
				return smoothstep(pct-_EdgeWidth,pct,st.y)-smoothstep(pct,pct+_EdgeWidth,st.y);
				#endif
			}

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(1, 1);
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = v.uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = v.uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[7] = v.uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[8] = v.uv + _MainTex_TexelSize.xy * half2(1, -1);
                return o;
            }

            //Color to luminance
            float luminance(float3 color)
            {
                return dot(fixed3(0.2125, 0.7154, 0.0721), color);
            }

            //sober operator Edge check
            half sobel(half2 uvs[9])
            {
                half gx[9] = {    -1, 0, 1,
                                -2, 0, 2,
                                -1, 0, 1};
                half gy[9] = {    -1, -2, -1,
                                0, 0, 0,
                                1, 2, 1};

                float edgeX = 0;
                float edgeY = 0;

                for(int i = 0; i < 9; i++)
                {
                    fixed3 c = tex2D(_MainTex, uvs[i]).rgb;
                    float l = luminance(c);
                    edgeX += l * gx[i];
                    edgeY += l * gy[i];
                }

                return abs(edgeX) + abs(edgeY);
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                half edge = sobel(i.uv);
                fixed4 tex = tex2D(_MainTex, i.uv[4]);

                float scanline=0.0;
				float2 st=i.uv[4];
				scanline=plot( st,frac(_Time.y*_Speed));
                return lerp(tex, _EdgeColor, edge*_EdgeValue*scanline);                                                                                                                                                                                                                
            }
            
            ENDCG
        }	
    }
    FallBack "Diffuse"
}