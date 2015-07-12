Shader "Custom/unityCookie/04c" {
	Properties {
		_Color ("Color", Color) =  (1.0,1.0,1.0,1.0)
		_SpecColor("SpecColor",Color) =  (1.0,1.0,1.0,1.0)
		_Shininess("Shininess",Float) = 10
		_RimColor("RimColor",Color) =  (1.0,1.0,1.0,1.0)
		_RimPower("RimPower",Range(0.1,10.0)) = 3.0
		}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase"}
		
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//self set color
			uniform float4  _Color ;
			uniform float4  _SpecColor;
			uniform float4 _RimColor;
			//self set constant
			uniform float _RimPower;
			uniform float  _Shininess;
			 
			 //build in color
			uniform float4  _LightColor0;

			struct vertexInput {
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			struct vertexOutput{
				float4 posWorld:TEXCOORD0;
				float4 pos:SV_POSITION;
				float3 normalDirection:TEXCOORD1;
			};
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				o.normalDirection=mul(_Object2World,v.normal).xyz;	
				o.posWorld=mul(_Object2World,v.vertex);
				o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
				return o;	
			}
			float4 frag(vertexOutput i):COLOR
			{
				//Direction
				float3 normalDirection=normalize(i.normalDirection);	
				float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);	
				float3 viewDirection=normalize(_WorldSpaceCameraPos.xyz-i.posWorld.xyz);	
				float3 halfDirection=normalize(viewDirection+lightDirection);
				float atten=1.0;
				//middleVar
				float rim=1.0-saturate(dot(viewDirection,normalDirection));
				//light
				float diffuseReflection=atten*max(0.0,dot(lightDirection,normalDirection));
				float specularReflection;
//				if(diffuseReflection<=0.0)
//						specularReflection=0.0;
//				else
//						specularReflection=atten*diffuseReflection*pow(dot(halfDirection,normalDirection),_Shininess);
				specularReflection=diffuseReflection<=0.0 ? 0.0:atten*dot(lightDirection,normalDirection)*pow(dot(halfDirection,normalDirection),_Shininess);
				float rimReflection=atten*saturate( dot(lightDirection,normalDirection) )*pow(rim,_RimPower);
				float3 diffuseColor=_LightColor0.rgb*diffuseReflection;
				float3 specularColor=_LightColor0.xyz*specularReflection*_SpecColor;
				float3 rimColor=rimReflection*_RimColor.rgb*_LightColor0.xyz;
				float3 colFinal=diffuseColor+specularColor+rimColor+UNITY_LIGHTMODEL_AMBIENT.rgb;
				//float3 colFinal=rimColor;
				return float4(colFinal*_Color.rgb,1.0);
			}
			
			ENDCG
			}
	} 
	//FallBack "Diffuse"
}
