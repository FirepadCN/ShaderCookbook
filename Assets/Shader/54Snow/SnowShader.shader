Shader "ShaderCookbook/SnowShader" {
	Properties {
		_MainColor ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump("Bump",2D)="bump"{}
		_Snow("Level of snow",Range(1,-1))=1
		_SnowColor("Color of snow",Color)=(1.0,1.0,1.0,1.0)
		_SnowDirectoin("Direction of snow",vector)=(0,1,0)
		_SnowDepth("Depth of snow",Range(0,1))=0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard vertex:vert

		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Bump;

		struct Input {
			float2 uv_MainTex;
			float2 uv_Bump;
			float worldNormal;//世界坐标中的法线向量
			INTERNAL_DATA //世界坐标中的反射向量
		};

		float _Snow;
		float4 _SnowColor;
		float4 _MainColor;
		float4 _SnowDirectoin;
		float _SnowDepth;


		void vert(inout appdata_full v){
			//mul:返回矩阵相乘的积
			//UNITY_MATRIX_IT_MV	float4x4	Inverse transpose of model * view matrix.
			float4 sn=mul(UNITY_MATRIX_IT_MV,_SnowDirectoin);
			if(dot(v.normal,sn.xyz)>=_Snow)
			    v.vertex.xyz+=(sn.xyz+v.normal)*_SnowDepth*_Snow;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			////从_Bump纹理中提取法向信息
			o.Normal=UnpackNormal(tex2D(_Bump,IN.uv_Bump));

			if(dot(WorldNormalVector(IN,o.Normal),_SnowDirectoin.xyz)>=_Snow)
			    o.Albedo = _SnowColor.rgb;
			else
               o.Albedo=c.rgb*_MainColor;
			
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}