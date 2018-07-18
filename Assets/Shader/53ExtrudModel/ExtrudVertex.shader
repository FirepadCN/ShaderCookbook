// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "ShaderCookbook/ExtudVertex" {
	Properties {  
       _MainTex ("Base (RGB)", 2D) = "white" {}
       _Amount ("Extrusion Amount", Range(-1,1)) = 0
    }  

    SubShader {  
        Tags { "RenderType"="Opaque"}  
        LOD 200  
          
        CGPROGRAM  
        #pragma surface surf Lambert vertex:vert
  
       float _Amount;
       sampler2D _MainTex;

       struct Input{
           float2 uv_MainTex;
           float3 vertColor;
       };

        void vert(inout appdata_full v, out Input o)
        {
            
            UNITY_INITIALIZE_OUTPUT(Input, o);  //Fix error:'vert': output parameter 'o' not completely initialized
           v.vertex.xyz += v.normal * _Amount;
        }

        void surf (Input IN, inout SurfaceOutput o) {  
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha=c.a;
        }  
        ENDCG  
	}
	FallBack "Diffuse"
}
