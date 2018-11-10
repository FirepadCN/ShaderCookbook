// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "WSH/PhongBlinLightingMode" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color",Color)=(1,1,1,1)
		_SpecPower("Specular Power",Range(0,30))=1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf PhongBlin

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};
		fixed4 _Color;
		float4 _SpecularColor;
		float _SpecPower;

		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}


        half4 LightingPhongBlin(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten){
            half4 result=0;
            
			//Blinn:L*pow(max(0,dot(n,ldir+vdir)))
			half3 h = normalize (lightDir + viewDir);

            float nh = max (0, dot (s.Normal, h));
            half3 Spec=_SpecularColor*atten* pow(nh,_SpecPower) ;

            //Phong:L*max(0,dot(n,ldir))
			half3 NdotL=max(0,dot(s.Normal,lightDir));
			half3 diffuse= _LightColor0*s.Albedo*NdotL*atten;
			result.rgb=diffuse+Spec;
			result.a=s.Alpha;
			return result;
            
		}

		ENDCG
	}
	FallBack "Diffuse"
}
