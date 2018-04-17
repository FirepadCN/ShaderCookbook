Shader "Custom/LambertianShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_LightLevel("Light Level",Range(0.0,3.0))=1
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		/*
		SimpleLambert forces Cg to look for a function called
        LightingSimpleLambert(). Note Lighting at the beginning, 
		which is omitted in the directive.
		*/

		#pragma surface surf SimpleLambert
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;
        float _LightLevel;
		/*the surface output (which contains the physical properties 
		such as the albedo and transparency), the direction the light is coming 
		from, and its attenuation(衰减).*/
        half4 LightingSimpleLambert(SurfaceOutput s,half3 lightDir,half atten){
            half NdotL=dot(s.Normal,lightDir);
			half4 c;
			//The _LightColor0 variable contains the color of the light that is calculated.
			//Built-in shader variables https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
			c.rgb=s.Albedo*_LightColor0.rgb*(NdotL*atten*_LightLevel);
			c.a=s.Alpha;
			return c;
		}

        
		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
