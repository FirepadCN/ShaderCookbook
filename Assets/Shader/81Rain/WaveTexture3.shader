// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WaveTexture3" {
	Properties{
		_MainTex("水波纹理", 2D) = "" {}
	   _AlphaScale("_AlphaScale",Float) =1
	

	}
		SubShader{
		//Tags{"Queue" = "Transparent"  "RenderType" = "Transparent" }
			pass {
		//Tags{"LightMode" = "ForwardBase"}
		/*	Zwrite off
			Blend SrcAlpha OneMinusSrcAlpha*/
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _WaveTex;
				float _AlphaScale;

				struct v2f {
						float4 pos:POSITION;
						float2 uv:TEXCOORD0;
				};

				v2f vert(appdata_full v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = v.texcoord.xy;
					return o;
				}

				fixed4 frag(v2f IN) : COLOR /*: SV_Target*/
				{
					float2 uv = tex2D(_WaveTex, IN.uv).xy;
					uv = uv * 2 - 1; //把0~1转成-1~1
					uv *= 0.5;

					IN.uv += uv;

					fixed4 color = tex2D(_MainTex, IN.uv);

					return color/*, _AlphaScale)*/;
				}
				ENDCG
			}
	}
}