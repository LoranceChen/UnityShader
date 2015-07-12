Shader "unityCookie/surfaceShader/04 NormalMap" {
	Properties {
		_MainTex ("Diffuse  Texture", 2D) = "white" {}
		_BumpTex("Normal Map",2D)="bump"{}
		//_ColorTint("Color Tint",Color)=(1,1,1,1)
		//_TintValue("Tint Intensity",Range(0.0,1.0))=0.4
		//_Drakness("Drakness",Float)=0.25
		//_Coord("Vector Coord",Vector)=(1,1,1,1)
		//_Cube("Cube Map",Cube)="" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }

		CGPROGRAM
		#pragma surface surf Lambert

		
		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTex;
			float4 color:COLOR;
		};
	    sampler2D _MainTex;
		sampler2D _BumpTex;
		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;//*_Drakness;
			//o.Alpha = c.a;
			o.Normal=UnpackNormal(tex2D(_BumpTex,IN.uv_BumpTex));
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
