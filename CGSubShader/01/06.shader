Shader "unityCookie/surfaceShader/06 Cubemap Reflection" {
	Properties {
		_MainTex ("Diffuse  Texture", 2D) = "white" {}
		_BumpTex("Normal Map",2D)="bump"{}
		//_SpecColor("Specular Color",Color)=(1,1,1,1)
		//_SpecPower("Specular Power",Range(0,2))=0.5
		//_ColorTint("Color Tint",Color)=(1,1,1,1)
		//_TintValue("Tint Intensity",Range(0.0,1.0))=0.4
		//_Drakness("Drakness",Float)=0.25
		//_Coord("Vector Coord",Vector)=(1,1,1,1)
		_Cube("Cube Map",Cube)="" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		
		CGPROGRAM
		#pragma surface surf BlinnPhong
		
		#pragma target 3.0
		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTex;
			float3 worldRefl;//在编译中编译了该变量，编译器如何识别的？
								   //很明显worldRefl是内置变量换个名字都不能识别，但它在哪里声明的？
			INTERNAL_DATA
		};
		
	    sampler2D _MainTex;
		sampler2D _BumpTex;
		samplerCUBE _Cube;
		
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c=tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo =c.rgb;
			o.Normal=UnpackNormal(tex2D(_BumpTex,IN.uv_MainTex));
			o.Emission=texCUBE(_Cube,WorldReflectionVector (IN, o.Normal)).rgb;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
