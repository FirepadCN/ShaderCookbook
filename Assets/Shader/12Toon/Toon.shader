Shader "ShaderCookbook/Toon" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex("Main Texture",2D)="white"{}
		_RampTex("Ramp",2D)="white"{}	
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf Toon
		#pragma target 3.0

        sampler2D _MainTex;
	    sampler2D _RampTex;	
        fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 LightingToon(SurfaceOutput s,fixed2 lightDir,fixed atten){
            half NdotL=dot(s.Normal,lightDir);
			//uv范围0~1，这里通过fixed2(NdotL,0.5)从rampmap上取样，固定V的值为0.5，通过NdotL的值
			//来在坡度图上取样，由此获得如cartoon中色彩分明的效果
			//如果色彩在V轴上是固定的，那么V取0~1内的值结果都一致
			NdotL=tex2D(_RampTex,fixed2(NdotL,0.5));
			fixed4 c;
			c.rgb=s.Albedo*_LightColor0*NdotL*atten;
			c.a=s.Alpha;
			return c;
		}
        

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c=tex2D(_MainTex,IN.uv_MainTex)*_Color;
			o.Albedo=c.rgb;
			o.Alpha=c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
