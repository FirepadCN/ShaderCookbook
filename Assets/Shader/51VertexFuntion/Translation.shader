Shader "ShaderCookbook/Translation"
{
	Properties
	{
        [Header(Matrix)]
        [Space(10)]
		[KeywordEnum(TRANS,ROTATE,SCALE,ALL)] _MType("运动类型",float)=0
        [Toggle] _Pattern("拆分",float)=0
        [Toggle] _UseMod("偏移",float)=0
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

            #pragma shader_feature _MTYPE_TRANS _MTYPE_ROTATE _MTYPE_SCALE _MTYPE_ALL
            #pragma shader_feature _PATTERN_ON 
            #pragma shader_feature _USEMOD_ON
			
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
            
            float box(fixed2 _st,fixed2 _size){
                _size=0.5-_size*0.5;
                fixed2 uv=smoothstep(_size,_size+0.001,_st);
                uv*= smoothstep(_size,_size+0.001,1.0-_st);
                return uv.x*uv.y;

            }

            float cross(fixed2 _st,fixed _size){
                float box1=box(_st,fixed2(_size,_size/4.0));
                float box2=box(_st,fixed2(_size/4.0,_size));
                return box1+box2;
            }

            //2d旋转矩阵
            float2x2 rotate2d(float _angle){
                return float2x2(cos(_angle),-sin(_angle),sin(_angle),cos(_angle));
            }

            //2d缩放矩阵
            float2x2 scale(fixed2 _scale){
                return float2x2(_scale.x,0.0,0.0,_scale.y);
            }


			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 col;
				float2 st=i.uv.xy;
                
                #if _PATTERN_ON
                st*=5;
                    #if _USEMOD_ON
                    st.x+=step(1.0,st.y-2.0*floor(st.y/2.0))*0.5;
                    st.x+=_Time.y*(step(1.0,st.y-2.0*floor(st.y/2.0))-0.5);
                    #endif
                st=frac(st);
                #endif


                #if _MTYPE_TRANS
                //_TIME(t/20,t,t*2,t*3),_SinTime(t/8,t/4,t/2,t),_CosTimet/8,t/4,t/2,t 都是float4类型，
                float2 trans=float2(_CosTime.w,_SinTime.w);

                st+=trans*0.35;

                col=fixed3(st.x,st.y,0.0);
                col+= cross(st,0.25);
                #elif _MTYPE_ROTATE
                st-=0.5;
                float angle=_SinTime.w*PI;
                st=mul(rotate2d(angle),st);
                st+=0.5;

                col=fixed3(st.x,st.y,0.0);
                col+=cross(st,0.4);
                #elif _MTYPE_SCALE
                st-=0.5;
                st=mul(scale(_SinTime.w+1.0),st);
                st+=0.5;
                col=fixed3(st.x,st.y,0.0);
                col+=cross(st,0.2);
                #elif _MTYPE_ALL
                float2 trans=float2(_CosTime.w,_SinTime.w);
                st+=trans*0.2;
                float angle=_SinTime.w*PI;
                st-=0.5;
                st=mul(rotate2d(angle),st);
                st=mul(scale(_SinTime.w),st);
                st+=0.5;
                col=fixed3(st.x,st.y,0.0);
                col+= cross(st,0.25);

                #endif

				return fixed4 (col,1);
			}

			

			ENDCG
		}
	}
}
