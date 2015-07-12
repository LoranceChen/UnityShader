Shader "Custom/unityCookie/02c.2" {
	Properties {
		_Color ("Color", Color) =  (1.0,1.0,1.0,1.0)
	}
	SubShader {
		Pass{
			Tags{"LightMode"="ForwardBase"}
			//progmas	
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma surface surf Lambert
			//user defined variables 
			uniform float4 _Color;
			uniform float4 _LightColor0={1,1,0,1};
			
			//unity defines variables
			//float4*4 _ObjectWorld
			//...      _
			//base input struct
			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal:NORMAL;//输入的法线为世界坐标系下的法向量？？？？
			};
			struct vertexOutput{
				float4 pos:SV_POSITION;
				float4 col:COLOR;
			};
			
			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				float3 normalDirection=normalize( mul (float4(v.normal,0.0),_World2Object).xyz);//获取自身坐标系下的法向量
										//为什么不使用世界坐标系的法向量
				float3 lightDirection;
				float atten=1.0;
				lightDirection=normalize(_WorldSpaceLightPos0.xyz);//？？？？Pos0？
				float3 diffuseReflection=atten*_LightColor0.xyz*max(0.0,dot(normalDirection,lightDirection));
				diffuseReflection+=UNITY_LIGHTMODEL_AMBIENT.xyz;
				o.col=float4(diffuseReflection*_Color.xyz,1.0);
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);//1.Model  Matrix（模型->世界）2.View   3.Projection
				
				return o;
			}
			
			//fragant function
			float4 frag(vertexOutput i):COLOR
			{
				return i.col;
			}
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
