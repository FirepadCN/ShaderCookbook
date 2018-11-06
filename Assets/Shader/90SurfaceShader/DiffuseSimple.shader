 Shader "Example/Diffuse Simple" {
	 Properties{
		 _MainTex("MainTex",2D)="white"{}
		 _BumpMap("Normal",2D)="white"{}
		 _RimColor("RimColor",Color)=(0.26,0.19,0.16,0.0)
		 _RimPower("Rimpower",Range(0.5,8.0))=3.0
	 }
    SubShader {
      Tags { "RenderType" = "Opaque" }
      CGPROGRAM
      #pragma surface surf Lambert
      struct Input {
		  float2 uv_MainTex;
		  float2 uv_BumpMap;
		  float3 viewDir;
      };

	  sampler2D _MainTex;
      sampler2D _BumpMap;
	  fixed4 _RimColor;
	  half _RimPower;

      void surf (Input IN, inout SurfaceOutput o) {
          o.Albedo = tex2D(_MainTex,IN.uv_MainTex).rgb;
		  o.Normal=UnpackNormal(tex2D(_BumpMap,IN.uv_BumpMap));
		  half rim=1-saturate(dot(normalize(IN.viewDir),o.Normal));
		  o.Emission=_RimColor.rgb*pow(rim,_RimPower);
      }
      ENDCG
    }
    Fallback "Diffuse"
  }