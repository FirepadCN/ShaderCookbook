Shader "ShaderCookbook/Toon2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture",2D)="white"{}
		_CelShadingLevels("_CelShading Levels",Range(0,10))=1
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf CustomLambert
		#pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;
		int _CelShadingLevels;

		struct Input {
			float2 uv_MainTex;
		};

		half4 LightingCustomLambert (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
        half NdotL = dot (s.Normal, lightDir);
		
		//使用floor方法将按_CelshadingLevels等份得到的值向下取整，依然保[0-1]范围内的cel值
        half cel = floor(NdotL * _CelShadingLevels) / (_CelShadingLevels -0.10); //Snap
        half4 c;
        c.rgb = s.Albedo * _LightColor0.rgb * cel * atten;
        c.a = s.Alpha;
        return c;
}
        

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c=tex2D(_MainTex,IN.uv_MainTex)*_Color;
			o.Albedo=c.rgb;
			o.Alpha=c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
