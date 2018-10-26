Shader "My/深度扫描" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
		_StartValue("Start Value",Range(0.0,1.0))=0
		_Width("Width",float)=0.1
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
            fixed _StartValue;
			fixed _Width;
            uniform fixed4 _Color;
			uniform sampler2D _CameraDepthTexture;
            

            struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

            fixed4 frag(v2f v) : SV_Target
            {
				float depth=UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture,v.uv));
                float linearDepth = Linear01Depth(depth);

                fixed4 c = tex2D(_MainTex, v.uv);
                if(linearDepth>_StartValue-_Width&&linearDepth<_StartValue)
                c*=_Color;
                return c;

                //return float4(offset,offset,offset,1);
            }
            ENDCG
        }
    } 
    FallBack "Diffuse"

}