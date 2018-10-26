Shader "ShaderCookbook/SinLineGLSL"
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
				float2 st=i.uv.xy;
                //float y = st.x;
                //float y=smoothstep(0.1,0.9,st.x);
                float y=sin(st.x*4+_Time)*0.5+0.5;

                fixed3 color=y;

                float pct =plot(st,y);
                col=(1.0-pct)*color+pct*fixed3(0,1,0);
				return fixed4 (col,1);
			}

			

			ENDCG
		}
	}
}
