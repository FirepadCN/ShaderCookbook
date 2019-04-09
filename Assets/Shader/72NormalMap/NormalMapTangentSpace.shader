// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderCookbook/NormalMapTangentSpace"{
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
              float3 lightDir:TEXCOORD1;
              float3 viewDir:TEXCOORD2;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos=UnityObjectToClipPos(v.vertex);
                o.uv.xy=v.texcoord.xy*_MainTex_ST.xy+_MainTex_ST.zw;
                o.uv.zw=v.texcoord.xy*_BumpMap_ST.xy+_BumpMap_ST.zw;
                
                //计算副法线 （法线向量×切线向量）*切线向量w方向
                //float3 binormal=cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
                //创建一个将向量从模型空间转向去切线空间的矩阵(如果一个变化只存在平移或者旋转，那么这个变化的逆矩阵就是他的转置矩阵
				//。切空间到模型空间符合这种变化。)
                //float3x3 rotation=float3x3(v.tangent.xyz,binormal,v.normal);
                
                //Unity内置宏
                TANGENT_SPACE_ROTATION;
                o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex).xyz);

                return o;

            }

            float4 frag(v2f o):SV_TARGET{
                fixed3 tangentLightDir=normalize(o.lightDir);
                fixed3 tangentViewDir=normalize(o.viewDir);
                
                //获取法线贴图的像素值
                fixed4 packedNormal=tex2D(_BumpMap,o.uv.zw);
                fixed3 tangentNormal;
                //如果法线贴图没有设置为“NormalMap”，需要把像素信息映射到法线信息(像素范围0~，法线范围-1~1)
                //tangentNormal.xy=(packedNormal.xy*2-1)*_BumpScale;
                //通过xy值求的z值 1=x*x+y*y+z*z
                //tangentNormal.z=sqrt(1.0-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                //被设置为"NormalMap"的法线贴图，可以使用内建函数直接求得(表示为normalmap的贴图，unity会根据平台优化压缩
				//，手动计算可能出现错误，最好使用unity提供的UnpackNormal函数来计算)
                tangentNormal=UnpackNormal(packedNormal);
                tangentNormal.xy*=_BumpScale;
                tangentNormal.z=sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                fixed3 albedo=tex2D(_MainTex,o.uv).rgb*_Color.rgb;

				//在切线空间中计算光照
                fixed3 ambient =_LightColor0.rgb*albedo*max(0,dot(tangentNormal,tangentLightDir));
                fixed diffuse=_LightColor0.rgb*albedo*max(tangentNormal,tangentLightDir);
                fixed3 halfDir=normalize(tangentLightDir+tangentViewDir);
                fixed3 specular=_LightColor0.rgb*_Specular.rgb*pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

                return fixed4(ambient+diffuse+specular,1.0);
            }



            ENDCG
        }
    }

    Fallback "Specular"
}