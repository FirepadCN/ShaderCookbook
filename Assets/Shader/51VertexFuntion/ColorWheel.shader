Shader "ShaderCookbook/ColorWheel"
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
           #define TWO_PI 6.2831853
		
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

fixed3 hsb2rgb(fixed3 c ){
    //mod=x - y*floor(x/y) 
    
    fixed3 x=c.x*6.0+fixed3(0.0,4.0,2.0);
    fixed3 y=6.0;
    fixed3 m=x-y*floor(x/y);
    fixed3 rgb = clamp(abs(m-3.0)-1.0,0.0,1.0 );

    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z * lerp( fixed3(1.0,1.0,1.0), rgb, c.y);
}

			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 col;
                fixed2 st=i.uv;
                
                fixed2 toCenter=fixed2(0.5,0.5)-st;
                fixed angle=atan(toCenter.x);
                float radius=length(toCenter)*2.0;

                col=hsb2rgb(fixed3((angle/TWO_PI)+0.5,radius,1.0));

				return fixed4 (col,1.0);
			}

			

			ENDCG
		}
	}
}
