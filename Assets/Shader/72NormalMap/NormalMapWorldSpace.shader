// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderCookbook/NormalMapWorldSpace"{
	Properties{
       _Color("Color Tint",Color)=(1,1,1,1)
        _MainTex("Main Tex",2D)="white"{}
        _BumpScale("Bump Scale",Float)=1.0
        _BumpMap("Normal Map",2D)="bump"{}
        _Specular("Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256))=20
	
    }

    SubShader{
        pass{
            Tags { "LightMode"="ForwardBase" }
		    LOD 200
            
            CGPROGRAM
            
            #pragma vertex vert
		    #pragma fragment frag
            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            float4 _Specular;
            float _Gloss;


            struct a2v{
              fixed4 vertex:POSITION;
              fixed3 normal:NORMAL;
              fixed4 tangent:TANGENT;
              float4 texcoord:TEXCOORD;
            };

            struct v2f{
              float4 pos:SV_POSITION;
              float4 uv:TEXCOORD0;
              float4 TtoW0:TEXCOORD1;
              float4 TtoW1:TEXCOORD2;
			  float4 TtoW2:TEXCOORD3;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
                
                float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
				fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBiNormal=cross(worldNormal,worldTangent)*v.tangent.w;


                //构建转换切线坐标到世界坐标的矩阵
				//这里将worldPos坐标信息放在w象限来优化存储空间
				o.TtoW0=float4(worldTangent.x,worldBiNormal.x,worldNormal.x,worldPos.x);
				o.TtoW1=float4(worldTangent.y,worldBiNormal.y,worldNormal.y,worldPos.y);
				o.TtoW2=float4(worldTangent.z,worldBiNormal.z,worldNormal.z,worldPos.z);

                return o;

            }

            float4 frag(v2f i):SV_TARGET{
                float3 worldPos=float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);

				fixed3 lightDir=normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir=normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump=UnpackNormal(tex2D(_BumpMap,i.uv.zw));
				bump.xy*=_BumpScale;
				bump.z=sqrt(1.0-saturate(dot(bump.xy,bump.xy)));
				bump=normalize(half3(dot(i.TtoW0.xyz,bump),dot(i.TtoW1.xyz,bump),dot(i.TtoW2.xyz,bump)));

				fixed3 albedo=tex2D(_MainTex,i.uv).rgb*_Color.rgb;
                fixed3 ambient =UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed diffuse=_LightColor0.rgb*albedo*max(bump,lightDir);
                fixed3 halfDir=normalize(lightDir+viewDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(bump,halfDir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);
            }

		
        ENDCG
	}

	}

    Fallback "Diffuse"

}