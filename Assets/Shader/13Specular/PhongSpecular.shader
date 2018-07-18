Shader "ShaderCookbook/PhongSpecular" {
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
		#pragma surface surf Phong
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		float4 _Color;
		float4 _SpecularColor;
		float _SpecPower;

		fixed4 LightingPhong(SurfaceOutput s,fixed3 lightDir,half3 viewDir,fixed atten){
			//reflection 反射
			float NdotL=dot(s.Normal,lightDir);
			float3 reflectionVector=normalize(2.0*s.Normal*NdotL-lightDir);

			//specular 镜面
			float spec=pow(max(0,dot(reflectionVector,viewDir)),_SpecPower);
			float3 finalSpec=_SpecularColor.rgb*spec;

			//最后的效果
			fixed4 c;
			c.rgb=(s.Albedo*_LightColor0.rgb*max(0,NdotL)*atten)+(_LightColor0.rgb*finalSpec);
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
