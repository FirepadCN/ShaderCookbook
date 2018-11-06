// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderCookbook/FloatPlatform"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Noise("Noise",2D)="white"{}
		_CenterColor("CenterColor",Color)=(0,0,0,0)
		_CenterPos("CenterTex",vector)=(0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		Blend SrcAlpha One
		Cull Off
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldPos:TEXCOORD1;
				float3 centerColor:TEXCOORD2;
			};

			sampler2D _MainTex;
			sampler2D _Noise;
			float4 _MainTex_ST;
			float4 _CenterColor;
			float3 _CenterPos;

			 //获取随机值
            float random (float2 st) {
                return frac(sin(dot(st.xy,float2(12.9898,78.233)))*43758.5453123);
            }
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos= mul(unity_ObjectToWorld,float4(0.5,0.5,0.5,v.vertex.w));

                float dis2center=distance(o.worldPos.xz,_CenterPos.xz);
                float stepdis=step(dis2center,2)*dis2center;

                o.centerColor=1;
				o.centerColor=stepdis*0.8;
                
				o.vertex.y-=pow(dis2center*0.8*step(dis2center,15),1.1);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb=lerp(col.rgb,_CenterColor.rgb,i.centerColor);
				return col;
			}
			ENDCG
		}
	}
}
