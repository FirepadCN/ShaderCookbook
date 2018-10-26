Shader "My/ScreenPost" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _OtherTex("OtherTex",2D)="white"{}
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            float4 _MainTex_ST;
            uniform sampler2D _OtherTex;
            float4 _OtherTex_ST;
            uniform fixed4 _Color;
			uniform sampler2D _CameraDepthTexture;
            uniform fixed4 _previewtex;

            struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
                float4 uv2:TEXCOORD1;
                float3 normal:NORMAL;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
                float4 uv2:TEXCOORD1;
				float4 vertex : SV_POSITION;
                float3 worldNormal:TEXCOORD2;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
				o.uv = v.uv;
                o.uv2= v.uv2;
				return o;
			}

            fixed4 frag(v2f v) : SV_Target
            {
				float depth=UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture,v.uv));
                float linearDepth = Linear01Depth(depth);

                fixed4 c = tex2D(_MainTex, v.uv);
                fixed4 other=tex2D(_OtherTex,v.uv);
                
				float offset=dot(v.worldNormal,float3(0,1,0));

                if(linearDepth<1){
                    c*= other*(1-linearDepth);
                }
            
                return c;

                //return float4(offset,offset,offset,1);
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"

}