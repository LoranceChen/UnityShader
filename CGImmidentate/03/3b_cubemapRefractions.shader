Shader "unityCookie/tut/intermediate/3b CubeMap Refractions" {
	Properties{
		_Cube ("Cube Map", Cube) = "" {}
	}
	SubShader{
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			uniform samplerCUBE _Cube;
			
			//Base Input Structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float3 normalDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};
			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				
				o.normalDir = normalize( mul(float4(v.normal, 0.0), _World2Object).xyz );
				o.viewDir = float3(mul(_Object2World, v.vertex) - _WorldSpaceCameraPos).xyz;
				
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				
				//refract the ray based on the normals to get the cube coordinates
				float3 refractDir = refract(i.viewDir, i.normalDir, 1/1.3);
				
				//texture maps
				float4 texC = texCUBE(_Cube, refractDir);
				
				return texC;
			}
			ENDCG
		}
	}
	//Fallback "Diffuse"
}