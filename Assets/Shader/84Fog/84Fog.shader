﻿Shader "ShaderCookbook/Fog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogDensity("FogDensity",float)=1
        _FogColor("FogColor",Color)=(1,1,1,1)
        _FogStart("Fog Start",float)=0.0
        _FogEnd("Fog End",float)=1.0

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		ZTest Always Cull Off ZWrite off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			float4x4 _FrustumCornersRay;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			half _FogDensity;
			fixed4 _FogColor;
			float _FogStart;
			float _FogEnd;

			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv : TEXCOORD0;
				half2 uv_depth:TEXCOORD1;
				float4 interpolatedRay:TEXCOORD2;
			};

			
			
			v2f vert (appdata_img v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				o.uv_depth=v.texcoord;

                #if UNITY_UV_STARTS_AT_TOP
                    if(_MainTex_ST.y<0)
				    {
				        o.uv_depth.y=1-o.uv_depth.y;
				    }
				#endif

                int index=0;
				if(v.texcoord.x<0.5&&v.texcoord.y<0.5){
					index=0;
				}
				else if(v.texcoord.x>0.5&&v.texcoord.y<0.5){
                    index =1;
				}
				else if(v.texcoord.x>0.5&&v.texcoord.y>0.5){
                    index =2;
				}
				else{
                    index =3;
				}
				
				#if UNITY_UV_STARTS_AT_TOP
                if(_MainTex_ST.y<0)
				  index =3-index;
				#endif

				o.interpolatedRay=_FrustumCornersRay[index];
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float linearDepth=LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv_depth));
				float3 worldPos=_WorldSpaceCameraPos+linearDepth*i.interpolatedRay.xyz;
				float fogDensity=(_FogEnd-worldPos.y)/(_FogEnd-_FogStart);
				fogDensity=saturate(fogDensity*_FogDensity);

				fixed4 col=tex2D(_MainTex,i.uv);
				col.rgb=lerp(col.rgb,_FogColor.rgb,fogDensity);
				return col;
			}
			ENDCG
		}

	}
	Fallback Off
}
