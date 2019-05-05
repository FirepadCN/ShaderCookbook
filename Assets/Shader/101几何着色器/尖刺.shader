Shader "ShaderCookbook/GeometryShader/尖刺" {
    Properties {
        _MainTex("Texture", 2D) = "white" {}
        _Length("Length", float) = 0.5
    }
    SubShader {
        Tags {
            "RenderType" = "Opaque"
        }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };

            struct v2g {
                float4 pos: SV_POSITION;
                float2 uv: TEXCOORD0;
            };

            struct g2f {
                float2 uv: TEXCOORD0;
                float4 vertex: SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Length;


            void ADD_VERT(float3 v, g2f o, inout TriangleStream < g2f > tristream) {
                o.vertex = UnityObjectToClipPos(v);
                tristream.Append(o);
            }


            void ADD_TRI(float3 p0, float3 p1, float3 p2, g2f o, inout TriangleStream < g2f > tristream) {
                ADD_VERT(p0, o, tristream);
                ADD_VERT(p1, o, tristream);
                ADD_VERT(p2, o, tristream);
                tristream.RestartStrip();
            }


            v2g vert(appdata v) {
                v2g o = (v2g) 0;
                o.pos = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            [maxvertexcount(9)]
            void geom(triangle v2g input[3], inout TriangleStream < g2f > outStream) {
                g2f o;

                //-----------这里通过三角面的两个边叉乘来获得垂直于三角面的法线方向
                float3 s = (input[1].pos - input[0].pos).xyz;
                float3 t = (input[2].pos - input[0].pos).xyz;

                float3 normal = normalize(cross(s, t));

                float3 centerPos = (input[0].pos.xyz + input[1].pos.xyz + input[2].pos.xyz) / 3.0;
                float2 centerUv = (input[0].uv + input[1].uv + input[2].uv) / 3.0;

                o.uv = centerUv;

                centerPos += normal * _Length * abs(sin(_Time.y * 5));

                ADD_TRI(input[0].pos, centerPos, input[2].pos, o, outStream);
                ADD_TRI(input[2].pos, centerPos, input[1].pos, o, outStream);
                ADD_TRI(input[1].pos, centerPos, input[0].pos, o, outStream);


            }
            fixed4 frag(g2f i): SV_Target {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}