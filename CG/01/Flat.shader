Shader "Custom/unityCookie/01C-Flat Color" {
	Properties {
		_Color ("Color", Color) =  (1.0,1.0,1.0,1.0)
	}
	SubShader {
		Pass{
			//progmas	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma surface surf Lambert
			//user defined variables 
			uniform float4 _Color;
			//base input struct
			struct vertexInput{
				float4 vertex : POSITION;
			};
			struct vertexOutput{
				float4 pos:SV_POSITION;
			};
			
			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
				return o;
			}
			
			//fragant function
			float4 frag(vertexOutput i):COLOR
			{
				return _Color;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
