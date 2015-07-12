Shader "Custom/unityCookie/03c.2" {
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
				float4 objectPosition:TEXCOORD0;
				float3 normalDirection:TEXCOORD1;
				float4 col : COLOR;
			};
			
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				o.objectPosition=v.vertex;
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
				o.normalDirection=mul(_Object2World,v.normal);
				return o;
			}
			float4 frag (vertexOutput  i) : COLOR
			{
				//direction
				float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);
				float3 normalDirection=normalize(i.normalDirection);
				float3 viewDirection=normalize(_WorldSpaceCameraPos.xyz-mul(_Object2World,i.objectPosition).xyz );
				float3 halfDirection=normalize(viewDirection+lightDirection);
				float atten = 1.0;
				//light
				float specularReflection;
				float diffuseReflection=atten*max(0.0,dot(normalDirection,lightDirection));
				float3 diffuseColor=diffuseReflection*_LightColor0.xyz;
				//float3 specularReflection=max(0.0,dot(normalDirection,lightDirection))*_SpecColor.rgb*pow(max(0.0,dot(reflect(-lightDirection,normalDirection),viewDirection)),_Shininess);
				
				if(diffuseReflection<=0.0)
					specularReflection=0.0;
				else
					specularReflection=dot(normalDirection,lightDirection)*pow(dot(halfDirection,normalDirection),_Shininess);
				float3 specularColor=_LightColor0.xyz*_SpecColor*specularReflection;
				float3 lightFinal=diffuseColor+specularColor+UNITY_LIGHTMODEL_AMBIENT;
				i.col=float4(lightFinal*_Color.rgb,1.0);
				return i.col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"	
}
