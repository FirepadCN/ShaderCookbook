Shader "ShaderCookbook/Blend"{ 
Properties{ 
    [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 1
    [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1

    _Color("Color", Color) = (1, 1, 1, 1) 
    _MainTex("MainTex", 2D) = "White" {} 
    _AlphaScale("AlphaScale", Range(0, 1)) = 1 
} 
SubShader{
 Tags{ "Queue" = "Transparent" "Ignoreprojector" = "True" "RenderType" = "Transparent" } 
 Pass{ 
 
  ZWrite off
 
  Blend [_SrcBlend][_DstBlend]

     CGPROGRAM 
     #pragma vertex vert 
     #pragma fragment frag

     fixed4 _Color; 
     sampler2D _MainTex; 
     float4 _MainTex_ST; 
     float _AlphaScale; 
     
	 struct a2v{ 
         float4 pos : POSITION; 
         float4 normal : NORMAL; 
         float texcoord : TEXCOORD0; 
     }; 

     struct v2f{
         float4 pos : SV_POSITION; 
         float3 worldNormal : TEXCOORD0; 
         float3 worldPos : TEXCOORD1; 
         float4 uv : TEXCOORD2; 
     }; 

     v2f vert(a2v v)
     { 
         v2f o; 
		 o.pos = UnityObjectToClipPos(v.pos);
         return o; 
     } 

     fixed4 frag(v2f i) : SV_Target{
         return fixed4(_Color.rgb, _Color.a * _AlphaScale); 
    } 
     ENDCG 
     } 
  }
}