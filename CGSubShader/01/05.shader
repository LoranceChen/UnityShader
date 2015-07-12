Shader "unityCookie/surfaceShader/05 Bump Specular" {
	Properties {
		_MainTex ("Diffuse  Texture", 2D) = "white" {}
		//_BumpTex("Normal Map",2D)="bump"{}
		_SpecColor("Specular Color",Color)=(1,1,1,1)
		_SpecPower("Specular Power",Range(0,1))=0.5
		//_ColorTint("Color Tint",Color)=(1,1,1,1)
		//_TintValue("Tint Intensity",Range(0.0,1.0))=0.4
		//_Drakness("Drakness",Float)=0.25
		//_Coord("Vector Coord",Vector)=(1,1,1,1)
		//_Cube("Cube Map",Cube)="" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		#pragma surface surf BlinnPhong

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTex;
		};
	    sampler2D _MainTex;
	//	sampler2D _BumpTex;
		//float4 _SpecColor;
		float _SpecPower;
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c=tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo =c.rgb;
			//o.Normal=UnpackNormal(tex2D(_BumpTex,IN.uv_BumpTex));
			o.Specular=_SpecPower;
			o.Gloss=c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
