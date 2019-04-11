// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderCookbook/几何着色器/LineBox"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			//-------声明几何着色器
			#pragma geometry geom
			#pragma fragment frag
      			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

            //-------顶点向几何阶段传递数据
			struct v2g{
                float4 vertex:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

            //-------几何阶段向片元阶段传递数据
			struct g2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Size;

			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

            //-------静态制定单个调用的最大顶点个数
            [maxvertexcount(4)]
			void geom(point v2g input[1],inout TriangleStream<g2f> outStream){
				
                g2f o=(g2f)0;

                input[0].vertex=mul(unity_ObjectToWorld,input[0].vertex);
                float3 UpDir=float3(0.0,1.0,0.0);
                float3 lookDir=_WorldSpaceCameraPos-input[0].vertex;
                lookDir.y=0;
                lookDir=normalize(lookDir);
                float right=normalize(cross(UpDir,lookDir));

                float halfSize=0.5*_Size;

                float4 v[4];
                v[0] = float4(input[0].vertex + halfSize * right - halfSize * UpDir, 1.0f);
                v[1] = float4(input[0].vertex + halfSize * right + halfSize * UpDir, 1.0f);
                v[2] = float4(input[0].vertex - halfSize * right - halfSize * UpDir, 1.0f);
                v[3] = float4(input[0].vertex - halfSize * right + halfSize * UpDir, 1.0f);

                o.vertex =  (v[0]);
                o.uv = float2(1.0f, 0.0f);
                outStream.Append(o);

                o.vertex = UnityWorldToClipPos(v[1]);
                o.uv = float2(1.0f, 1.0f);
                outStream.Append(o);

                o.vertex = UnityWorldToClipPos(v[2]);
                o.uv = float2(0.0f, 0.0f);
                outStream.Append(o);

                o.vertex = UnityWorldToClipPos(v[3]);
                o.uv = float2(0.0f, 0.0f);
                outStream.Append(o);

    
    		}
			
			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
