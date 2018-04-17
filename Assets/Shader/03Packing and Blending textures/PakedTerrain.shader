Shader "ShaderCookbook/PakedTerrain" {
	Properties {
        _MainTinit("Diffuse Tint",Color)=(1,1,1,1)

		_ColorA ("Terrain Color A", Color) = (1,1,1,1)
		_ColorB ("Terrain Color B", Color) = (1,1,1,1)
        _RTexture("Red Channel Tx",2D)=""{}
        _GTexture("Green Channel Tx",2D)=""{}
        _BTexture("Blue Channel Tx",2D)=""{}
        _ATexture("Alpha Channel Tx",2D)=""{}
        _BlendTexture("Blend Channel Tx",2D)=""{}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		float4 _MainTinit;
		float4 _ColorA;
		float4 _ColorB;
		sampler2D _RTexture;
		sampler2D _GTexture;
		sampler2D _BTexture;
		sampler2D _ATexture;
		sampler2D _BlendTexture;

#pragma target 4.0
		struct Input {
			float2 uv_RTexture;
			float2 uv_GTexture;
			float2 uv_BTexture;
			float2 uv_ATexture;
			float2 uv_BlendTexture;
		};




		void surf (Input IN, inout SurfaceOutput o) {
            float4 blendData=tex2D(_BlendTexture,IN.uv_BlendTexture);

            float4 rTxData=tex2D(_RTexture,IN.uv_RTexture);
            float4 gTxData=tex2D(_GTexture,IN.uv_GTexture);
            float4 bTxData=tex2D(_BTexture,IN.uv_BTexture);
            float4 aTxData=tex2D(_ATexture,IN.uv_ATexture);
			
			float4 finalColor;
			finalColor =lerp(rTxData,gTxData,blendData.g);
			finalColor =lerp(finalColor,bTxData,blendData.b);
			finalColor =lerp(finalColor,rTxData,blendData.r);
			finalColor.a=1.0;
			
			float4  terrainLayers=lerp(_ColorA,_ColorB,blendData.a);
			finalColor*=terrainLayers;
			finalColor=saturate(finalColor);

			o.Albedo=finalColor.rgb*_MainTinit.rgb;
			o.Alpha=finalColor.a;

		}
		ENDCG
	}
	FallBack "Diffuse"
}
