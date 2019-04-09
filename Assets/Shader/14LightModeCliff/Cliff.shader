Shader "Unlit/Cliff"
{
	//---------------参数---------------------------
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MainNormal("MainNormal",2D)="white"{}
		_GrassTex ("GrassTex", 2D) = "white" {}
		_GrassNormal ("GrassNormal", 2D) = "white" {}
        
		_Smooth("smooth",Range(0,1))=1
		_Gloss("Gloss",Range(0,128))=96
          
        _Height("Height",float)=0.5

		_Offset("Offset",float)=0.5
		_BumpScale("bumpscale",float)=0.5
	}

	//-------------subshader---------------------------
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

            
			//-----------传递数据用的结构体---------------------------
			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 lightDir:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
				float3 tanView:TEXCOORD3;
			};

            //----------传递参数数据---------------------------
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GrassTex;
			float4 _GrassTex_ST;
            sampler2D _MainNormal;
			sampler2D _GrassNormal;

			float _Offset;
            float _BumpScale;
			float _Height;
			float _Gloss;
			float _Smooth;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv.zw, _MainTex);

                //----------unity宏定义，用于得到从模型空间矩阵到切线空间矩阵rotation-----
				TANGENT_SPACE_ROTATION;

                //------------通过上一步得到rotation用于将模型空间下的光照法线转换到法线贴图对应的空间中去，这里的法线贴图位于切线空间----
				o.worldPos=UnityObjectToWorldDir(v.vertex);
				//------------需要借助法线贴图计算光照，这里计算出需要用到符合法线贴图空间的光照方向和视角方向
				o.lightDir=normalize(mul(rotation,ObjSpaceLightDir(v.vertex)).xyz);
				o.tanView=normalize(mul(rotation,ObjSpaceViewDir(v.vertex)));
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 halfDir=normalize(i.tanView+i.lightDir);

				fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed4 grass=tex2D(_GrassTex,i.uv.zw);
				
                float3 colNormal=UnpackNormal(tex2D(_MainNormal,i.uv.xy))*_BumpScale;
				float3 GrassNormal=UnpackNormal(tex2D(_GrassNormal,i.uv.zw))*_BumpScale;

				colNormal.z=sqrt(1.0-saturate(dot(colNormal.xy,colNormal.xy)));
				GrassNormal.z=sqrt(1.0-saturate(dot(GrassNormal.xy,GrassNormal.xy)));


				float angleY=1-saturate(dot(UnityObjectToWorldDir(colNormal),float3(0,1,0) )+_Offset);

				angleY-=i.worldPos.y>_Height?0:i.worldPos.y-_Height;
				
                fixed4 finalColor=lerp(grass,col,angleY);

				//---------------lambert光照---------------------------
				float3 diffuse=finalColor*max(0.0,dot(i.lightDir,colNormal))*_LightColor0.xyz;
				//---------------Blin-phong光照---------------------------
				float3 specular= _LightColor0.rgb  * pow(saturate(dot(halfDir, colNormal)), _Gloss)*_Smooth;

				return fixed4(diffuse+specular+UNITY_LIGHTMODEL_AMBIENT.xyz*finalColor,1);
			}
			ENDCG
		}//end pass
	}//end subshader

	Fallback "Diffuse"//阴影
}
