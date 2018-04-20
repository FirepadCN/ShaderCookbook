Shader "ShaderCookbook/HalfLight" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Half

		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;

		fixed4 LightingHalf(SurfaceOutput s,fixed2 lightDir,fixed atten){
           half NdotL= dot(s.Normal,lightDir);
		   NdotL=NdotL*0.5+0.5;
           half4 c;
		   c.rgb=s.Albedo*_LightColor0.rgb*NdotL*atten;
		   c.a=s.Alpha;
		   return c;
		}


		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
