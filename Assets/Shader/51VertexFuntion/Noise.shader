Shader "ShaderCookbook/Noise"
{
	Properties
	{
		[KeywordEnum(ONED,TWOD,SIMPLE,LINE,WOOD,LAVA)]Demintion("维度",float) =0
        NoisePow("噪声复杂度",Range(1,128))=5
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

            #pragma shader_feature DEMINTION_ONED DEMINTION_TWOD DEMINTION_SIMPLE  DEMINTION_LINE DEMINTION_WOOD DEMINTION_LAVA
			
			#include "UnityCG.cginc"
           
           float NoisePow;
		
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

            //画线
            float plot(float2 st,float pct){
				return smoothstep(pct-0.02,pct,st.y)-smoothstep(pct,pct+0.02,st.y);
			}

            float lines(float2 pos, float b){
                float scale = 10.0;
                pos *= scale;
                return smoothstep(0.0,.5+b*.5,abs((sin(pos.x*3.1415)+b*2.0))*.5);
            }

            //获取随机值
            float random (float2 st) {
                return frac(sin(dot(st.xy,float2(12.9898,78.233)))*43758.5453123);
            }

            //旋转
            float2x2 rotate2d(float angle){
                return float2x2(cos(angle),-sin(angle),sin(angle),cos(angle));
            }

            // 2D 噪声 基于 Morgan McGuire @morgan3d
            // https://www.shadertoy.com/view/4dS3Wd
            float noise (in float2 st) {
                float2 i = floor(st);
                float2 f = frac(st);
            
                // Four corners in 2D of a tile
                float a = random(i);
                float b = random(i + float2(1.0, 0.0));
                float c = random(i + float2(0.0, 1.0));
                float d = random(i + float2(1.0, 1.0));
            
                // Smooth Interpolation
            
                // 三次多项式作用同 SmoothStep()
                float2 u = f*f*(3.0-2.0*f);
                // u = smoothstep(0.,1.,f);
            
                // Mix 4 coorners percentages
                return lerp(a, b, u.x) +(c - a)* u.y * (1.0 - u.x) +(d - b) * u.x * u.y;
            }



            // Some useful functions
            float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
            float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
            float3 permute(float3 x) { return mod289(((x*34.0)+1.0)*x); }

            //simple noise
            float snoise(float2 v) {

                // Precompute values for skewed triangular grid
                const float4 C = float4(0.211324865405187,
                                    // (3.0-sqrt(3.0))/6.0
                                    0.366025403784439,
                                    // 0.5*(sqrt(3.0)-1.0)
                                    -0.577350269189626,
                                    // -1.0 + 2.0 * C.x
                                    0.024390243902439);
                                    // 1.0 / 41.0
            
                // First corner (x0)
                float2 i  = floor(v + dot(v, C.yy));
                float2 x0 = v - i + dot(i, C.xx);
            
                // Other two corners (x1, x2)
                float2 i1 = 0.0;
                i1 = (x0.x > x0.y)? float2(1.0, 0.0):float2(0.0, 1.0);
                float2 x1 = x0.xy + C.xx - i1;
                float2 x2 = x0.xy + C.zz;
            
                // Do some permutations to avoid
                // truncation effects in permutation
                i = mod289(i);
                float3 p = permute(
                        permute( i.y + float3(0.0, i1.y, 1.0))
                            + i.x + float3(0.0, i1.x, 1.0 ));
            
                float3 m = max(0.5 - float3(
                                    dot(x0,x0),
                                    dot(x1,x1),
                                    dot(x2,x2)
                                    ), 0.0);
            
                m = m*m ;
                m = m*m ;
            
                // Gradients:
                //  41 pts uniformly over a line, mapped onto a diamond
                //  The ring size 17*17 = 289 is close to a multiple
                //      of 41 (41*7 = 287)
            
                float3 x = 2.0 * frac(p * C.www) - 1.0;
                float3 h = abs(x) - 0.5;
                float3 ox = floor(x + 0.5);
                float3 a0 = x - ox;
            
                // Normalise gradients implicitly by scaling m
                // Approximation of: m *= inversesqrt(a0*a0 + h*h);
                m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);
            
                // Compute final noise value at P
                float3 g = 0.0;
                g.x  = a0.x  * x0.x  + h.x  * x0.y;
                g.yz = a0.yz * float2(x1.x,x2.x) + h.yz * float2(x1.y,x2.y);
                return 130.0 * dot(m, g);
            }
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =v.uv;
				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
			    fixed3 col=0;
                float2 st=i.uv.xy;
                
                #if DEMINTION_ONED
                float y;
                st*=NoisePow;

                float fx=floor(st.x);
                float f=frac(st.x);

                y=random(fx);
                y=lerp(random(fx),random(fx+1.0),f);
                y= lerp(random(fx),random(fx+1.0),smoothstep(0.0,1.0,f));
                col+=plot(st,y*NoisePow*0.5);

                #elif DEMINTION_TWOD
                fixed2 pos=st*NoisePow;
                float n=noise(pos);
                col=n;

                #elif DEMINTION_SIMPLE
                st*=NoisePow;
                col=snoise(st)*0.5+0.5;
                #elif DEMINTION_LINE
                st*=NoisePow;
                col=snoise(st*0.5)+0.5;
                #elif DEMINTION_WOOD
                float2 pos=st.yx*float2(10.,3);
                float pattern=pos.x;

                pos=mul(rotate2d(noise(pos)),pos);

                pattern=lines(pos,0.5);
                col=pattern;
                #elif DEMINTION_LAVA
                float2 pos=st*NoisePow;
                float DF=0.0;
                float a=0.0;
                float2 vel=_Time.y*.1;
                DF+=snoise(pos+vel)*.25+.25;

                a=snoise(pos*float2(cos(_Time.y*0.15),sin(_Time.y*0.1))*0.1)*3.1415;
                vel = float2(cos(a),sin(a));
                
                DF+=snoise(pos+vel)*.25+.25;

                col=1-smoothstep(.7,.75,frac(DF));
                #endif

				return fixed4 (col,1.0);
			}			

			ENDCG
		}
	}
}
