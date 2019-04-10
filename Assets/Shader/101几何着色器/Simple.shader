Shader "ShaderCookbook/几何着色器/SimplePoint"
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
			
			v2g vert (appdata v)
			{
				v2g o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

            //-------静态制定单个调用的最大顶点个数
            [maxvertexcount(3)]
			void geom(triangle v2g input[3],inout TriangleStream<g2f> outStream){
				for(int i=0;i<3;i++){
					g2f o=(g2f)0;
                    o.vertex=input[i].vertex;
					o.uv=input[i].uv;

					//-----将一个顶点添加到输出流列表
					outStream.Append(o);
				}
				
				//-------restart strip可以模拟一个primitives list
				outStream.RestartStrip();
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
