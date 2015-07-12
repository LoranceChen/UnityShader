Shader "UnityCookie/Surface/02" {
	SubShader{
			Tags{"Rendertype"="Oqaque"}
			CGPROGRAM
			#pragma surface surf Lambert
			struct Input{
				float4 color : COLOR;
			};
			void surf(Input IN,inout SurfaceOutput o){
					o.Albedo=1;
			}
			ENDCG
	}
	FallBack "Diffuse"
}
