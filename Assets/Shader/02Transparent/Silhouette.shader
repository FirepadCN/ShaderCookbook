// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "ShaderCookbook/Silhouette" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_DotProduct("Rim effect",Range(-1,1))=0.25
	}
	SubShader {
		//想要表现透明材质，需要添加如下Tag
		Tags
		 {
			"Queue"="Transparent"  
			"Ignoreprojector"="True"
			"RenderType"="Tranparent" 
		}
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert alpha:fade nolighting
		#pragma target 3.0

		sampler2D _MainTex;

        //修改结构体，unity将会自主填充viewdir,worldnormal
		struct Input {
			float2 uv_MainTex;
			float3 WorldNormal;
			float3 ViewDir;
		};

		fixed4 _Color;
		float _DotProduct;

		#pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			float border=1-(abs(dot(IN.ViewDir,IN.WorldNormal)));
			float alpha=(border*(1-_DotProduct)+_DotProduct);
			o.Alpha = c.a*alpha;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
