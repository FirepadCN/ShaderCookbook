Shader "ShaderCookbook/SinLine"
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
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed3 MyLine(fixed x,fixed y){
				fixed3 c=fixed3(0.0,1.0,0.0);
                if(abs(x-y)<0.01)
				    return c;
				else
				    return 0;
			}


			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 col;
				fixed ss=sin((i.uv.x*2+_Time*2)/3.14*10);
				col = MyLine(i.uv.y,ss*0.5+0.5);
				return fixed4 (col,ss);
			}

			

			ENDCG
		}
	}
}
