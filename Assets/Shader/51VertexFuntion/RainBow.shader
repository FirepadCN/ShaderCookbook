Shader "ShaderCookbook/RainBow"
{
	Properties
	{
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
           #define PI 3.141592653
		
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =v.uv;
				return o;
			}

            
			
			float plot(float2 st,float pct){
				return smoothstep(pct-0.02,pct,st.y)-smoothstep(pct,pct+0.02,st.y);
			}


			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 col;
                fixed3 mixCol;
                fixed3 colorA=fixed3(0.149,0.141,0.912);
                fixed3 colorB=fixed3(1.0,0.833,0.224);
                
				float2 st=i.uv.xy;

                fixed3 pct=st.x;
                pct.r=smoothstep(0.0,1.0,st.x);
                pct.g=sin(st.x*PI);
                pct.b=pow(st.x,0.5);
                
                mixCol=lerp(colorA,colorB,pct);
                col = lerp(col,fixed3(0.0,1.0,0.0),plot(st,-pow(st.x*2-1,2)+1));
                col=step(st.y,-pow(st.x*2-1,2)+1);
                col+=-step(st.y,-pow(st.x*2-1,2)+0.7);
                col=saturate(col)*mixCol;
				return fixed4 (col,1.0);
			}

			

			ENDCG
		}
	}
}
