Shader "ShaderCookbook/DrawRectangle"
{
	Properties
	{
        [Header(Jian Gui Le)]
        [Space(10)]
		[KeywordEnum(S,SS,M,C,MC,SN)] _DrawType ("DrawType",Float) = 0
        [Toggle] _BackColor("BackColor",float)=0
        [PowerSlider(1.0)] _RValue("RValue",Range(0.01,1))=0.7
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
		   
            #pragma shader_feature _DRAWTYPE_S _DRAWTYPE_SS _DRAWTYPE_M _DRAWTYPE_C _DRAWTYPE_MC _DRAWTYPE_SN
            #pragma shader_feature _BACKCOLOR_ON


            float _RValue;

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
				o.uv = v.uv;
				return o;
			}

            //画线
            float plot(float2 st,float pct){
				return smoothstep(pct-0.02,pct,st.y)-smoothstep(pct,pct+0.02,st.y);
			}
            
            //矩形绘制函数
            float DrawRectangel(float2 rect,float2 center,fixed2 st){
                
                fixed2 bl =step(rect,st-center);
                fixed2 tr =step(rect,1-st+center);
                fixed2 bl2=step(rect-0.1,st-center);
                fixed2 tr2=step(rect-0.1,1.0-st+center);

                return abs(bl2.x*bl2.y*tr2.x*tr2.y- bl.x*bl.y*tr.x*tr.y-1);
            }
            
            //绘制圆形函数
            float circle(fixed2 _st,float _radius){
                fixed2 dist=_st-fixed2(0.5,0.5);
                return 1-smoothstep(_radius-(_radius*0.01),_radius+(_radius*0.01),dot(dist,dist)*4);
            }
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 col=1;
                float pct;
                fixed2 st=i.uv;

                #if _DRAWTYPE_S
                //-----step矩形------------
                fixed2 bl=step(fixed2(0.3,0.3),st);
                fixed2 tr=step(fixed2(0.3,0.3),1.0-st);
                fixed2 bl2=step(fixed2(0.2,0.2),st);
                fixed2 tr2=step(fixed2(0.2,0.2),1.0-st);
                pct=abs(bl2.x*bl2.y*tr2.x*tr2.y - bl.x*bl.y*tr.x*tr.y-1);
                
                #elif _DRAWTYPE_SS
                //----smoothStep矩形-------
                pct=smoothstep(0,0.1,st.x)*smoothstep(0,0.1,1-st.x);
                pct*=smoothstep(0,0.1,st.y)*smoothstep(0,0.1,1-st.y);
                
                #elif _DRAWTYPE_M
                //----多个矩形绘制----------
                fixed3 c=0;
                pct=DrawRectangel(fixed2(0.45,0.45),fixed2(0.2,0.2),st);
                c=fixed3(1,0,0)*pct;
                pct*=DrawRectangel(fixed2(0.4,0.4),fixed2(0.1,0.1),st);
                c*=lerp(c,fixed3(0,1,0),pct);
                pct*=DrawRectangel(fixed2(0.35,0.35),fixed2(-0.1,-0.1),st);
                c=lerp(c,fixed3(0,1,0),pct);
                pct=1;
                col=c;

                //-----圆------------------
                #elif _DRAWTYPE_C
                pct=fixed(circle(st,0.8));

                //----变化圆环-------------
                #elif _DRAWTYPE_MC
                st=st*2-1;
                float d=length(abs(st)-_SinTime);
                pct=frac(d*10);

                //----雪花-----------------
                #elif _DRAWTYPE_SN
                fixed2 pos=fixed2(0.5,0.5)-st;

                float r = length(pos)*2.0;
                float a = atan(pos.y/pos.x);

                float f=cos(a*3.0);
                f = abs(cos(a*12.)*sin(a*3.))*.8+.1;
                pct= 1-smoothstep(f,f+0.02,r);
                #endif
                
                col*=pct;
                
                #if _BACKCOLOR_ON
                col*=fixed3(_RValue,0.3,0.1);
                #endif

				return fixed4(col,1.0);
			}
			ENDCG
		}
	}
}
