Shader "ShaderCookbook/FlowCharacters"
{
	Properties
	{
        BgColor("颜色",Color)=(1,1,1,1)
        MainTex("纹理",2D)="white"{}
		MaskTex("遮罩",2D)="blank"{}
        Column("分割数",float)=5
        Speed("速度",float)=1
        [Toggle] ColorRow("行列切换",float)=0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

     
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature COLORROW_ON

            fixed4 BgColor;
            sampler2D MainTex;
            sampler2D MaskTex;
            float Column;
            float Speed;
		
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

            //获取随机值
            float random (float2 st) {
                return frac(sin(dot(st.xy,float2(12.9898,78.233)))*43758.5453123);
            }

			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 col=1;
				float2 st=i.uv.xy;

                //拆分
                #if COLORROW_ON
                float RandomSpeed=Speed*random(ceil(st.x*Column))+0.1;
                st.y+=_Time.y*RandomSpeed;
                #else
                float RandomSpeed=Speed*random(ceil(st.y*Column))+0.1;
                st.x+=_Time.y*RandomSpeed;
                #endif

                fixed3 tx=tex2D(MainTex,st).xyz;

                col*=tx*BgColor;
                
				//遮罩处理
				fixed4 maskColor=tex2D(MaskTex,i.uv.xy);
				col+=step(0.5,maskColor.a)*step(0.3,col.r);

				return fixed4 (col,1);
			}

			ENDCG
		}
	}
}
