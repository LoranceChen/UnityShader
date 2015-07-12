Shader "Custom/unityCookie/03c.1" {
	Properties {
		_Color ("Color", Color) =  (1.0,1.0,1.0,1.0)
	
		_SpecColor("Color",Color)=(1.0,1.0,1.0,1.0)
		_Shininess("Shinness",Float)=10
	}
	SubShader {
		Pass{
			Tags{"LightMode"="ForwardBase"}
	
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#include"UnityCG.cginc"
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			
			uniform float4 _LightColor0;
			//uniform float4 _LightColor0={1,1,0,1};
			struct vertexInput{
				float4 vertex: POSITION;
				float3 normal :NORMAL;
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 col  : COLOR;
			};
			
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				//float3 normalDirection=normalize( mul (float4(v.normal,0.0),_World2Object).xyz);//获取自身坐标系下的法向量
										//为什么不使用世界坐标系的法向量
				//float3 lightDirection;
				//float atten=1.0;
				//lightDirection=normalize(_WorldSpaceLightPos0.xyz);//？？？？Pos0？
				//float3 diffuseReflection=atten*_LightColor0.xyz*_Color.xyz*max(0.0,dot(normalDirection,lightDirection));
				//vertors向量
				float3 normalDirection=normalize(mul(float4(v.normal,0.0),_World2Object).xyz);
				float3 viewDirection=normalize(float4(_WorldSpaceCameraPos.xyz,1.0)-mul(_Object2World,v.vertex) ).xyz;
				float3 lightDirection;
				
				float atten =1.0;
				//light
				lightDirection=normalize(_WorldSpaceLightPos0.xyz);
				float diffuseReflection=atten*max(0.0,dot(normalDirection,lightDirection));
				float3 diffuseColor=diffuseReflection*_LightColor0.xyz;
				//float3 specularReflection=max(0.0,dot(normalDirection,lightDirection))*_SpecColor.rgb*pow(max(0.0,dot(reflect(-lightDirection,normalDirection),viewDirection)),_Shininess);
				float specularReflection;
				if(diffuseReflection<=0.0)
					specularReflection=0.0;
				else
					specularReflection=atten*dot(normalDirection,lightDirection)*pow(dot(normalize(viewDirection+lightDirection),normalDirection),_Shininess);
				float3 specularColor=_LightColor0.xyz*_SpecColor*specularReflection;
				float3 lightFinal=diffuseColor+specularColor+UNITY_LIGHTMODEL_AMBIENT;
				o.col=float4(lightFinal*_Color.rgb,1.0);
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
				return o;
			}
			float4 frag (vertexOutput  i) : COLOR
			{
				return i.col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"	
}
