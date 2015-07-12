﻿Shader "Custom/unityCookie/06C" {
	Properties {
		_Color ("Color", Color) =  (1.0,1.0,1.0,1.0)
		_SpecColor("SpecColor",Color) =  (1.0,1.0,1.0,1.0)
		_Shininess("Shininess",Float) = 10
		_RimColor("RimColor",Color) =  (1.0,1.0,1.0,1.0)
		_RimPower("RimPower",Range(0.1,10.0)) = 3.0
		_MainTex("Diffuse Texture",2D)="white"{}
		}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase"}
		
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
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
					float4 texcoord:TEXCOORD0;
				};
				struct vertexOutput{
					float4 objectPosition:TEXCOORD1;
					float4 pos:SV_POSITION;
					float3 normalDirection:TEXCOORD2;
					float4 tex:TEXCOORD3;
				};
				vertexOutput vert(vertexInput v){
					vertexOutput o;
					o.normalDirection=mul(_Object2World,v.normal);
					//o.normalDirection=v.normal;
					o.objectPosition=v.vertex;
					o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
					o.tex=v.texcoord;
					return o;	
				}
				float4 frag(vertexOutput i):COLOR
				{
					//Direction
					float3 normalDirection=normalize(i.normalDirection);	
					float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDirection=normalize(_WorldSpaceCameraPos.xyz-mul(_Object2World,i.objectPosition).xyz);		
					float3 halfDirection;
					float atten;
					//middleVar
					float rim=1.0-saturate(dot(viewDirection,normalDirection));
					//lightdirection
					float lightDistance;
					float3 lightSource;
					if(_WorldSpaceLightPos0.w==0)//direction light
					{
							lightDirection=normalize(_WorldSpaceLightPos0.xyz);
							atten=1.0;
					}
					else
					{
							lightSource=_WorldSpaceLightPos0.xyz-mul(_Object2World,i.objectPosition).xyz;
							lightDistance=length(lightSource);
							atten=1.0/lightDistance;	
							lightDirection=normalize(lightSource);							
					}
					halfDirection=normalize(viewDirection+lightDirection);
					//light
					float specularReflection;
					float diffuseReflection=atten*max(0.0,dot(lightDirection,normalDirection));
					if(diffuseReflection<=0.0)
							specularReflection=0.0;
					else
							specularReflection=atten*dot(lightDirection,normalDirection)*pow(dot(halfDirection,normalDirection),_Shininess);
					float rimReflection=atten*saturate(dot(lightDirection,normalDirection))*pow(rim,_RimPower);
					float3 diffuseColor=_LightColor0.xyz*diffuseReflection;
					float3 specularColor=_LightColor0.xyz*specularReflection*_SpecColor;
					float3 rimColor=rimReflection*_RimColor.rgb*_LightColor0.xyz;
					float3 colFinal=diffuseColor+specularColor+rimColor+UNITY_LIGHTMODEL_AMBIENT.rgb;
					float4 tex=tex2D(_MainTex,i.tex.xy*_MainTex_ST.xy+_MainTex_ST.zw);
					return tex*float4(colFinal*_Color.rgb,1.0);
					//return i.col;
				}
				
				ENDCG
			}
			Pass{
			Tags { "LightMode"="ForwardAdd"}
				Blend One One
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
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
					float4 texcoord:TEXCOORD0;
				};
				struct vertexOutput{
					float4 objectPosition:TEXCOORD1;
					float4 pos:SV_POSITION;
					float3 normalDirection:TEXCOORD2;
					float4 tex:TEXCOORD3;
				};
				vertexOutput vert(vertexInput v){
					vertexOutput o;
					o.normalDirection=mul(_Object2World,v.normal);
					//o.normalDirection=v.normal;
					o.objectPosition=v.vertex;
					o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
					o.tex=v.texcoord;
					return o;	
				}
				float4 frag(vertexOutput i):COLOR
				{
					//Direction
					float3 normalDirection=normalize(i.normalDirection);	
					float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDirection=normalize(_WorldSpaceCameraPos.xyz-mul(_Object2World,i.objectPosition).xyz);		
					float3 halfDirection;
					float atten;
					//middleVar
					float rim=1.0-saturate(dot(viewDirection,normalDirection));
					//lightdirection
					float lightDistance;
					float3 lightSource;
					if(_WorldSpaceLightPos0.w==0)//direction light
					{
							lightDirection=normalize(_WorldSpaceLightPos0.xyz);
							atten=1.0;
					}
					else
					{
							lightSource=_WorldSpaceLightPos0.xyz-mul(_Object2World,i.objectPosition).xyz;
							lightDistance=length(lightSource);
							atten=1.0/lightDistance;						
							lightDirection=normalize(lightSource);		
					}
					halfDirection=normalize(viewDirection+lightDirection);
					//light
					float specularReflection;
					float diffuseReflection=atten*max(0.0,dot(lightDirection,normalDirection));
					if(diffuseReflection<=0.0)
							specularReflection=0.0;
					else
							specularReflection=atten*dot(lightDirection,normalDirection)*pow(dot(halfDirection,normalDirection),_Shininess);
					float rimReflection=atten*saturate(dot(normalDirection,lightDirection))*pow(rim,_RimPower);
					float3 diffuseColor=_LightColor0.xyz*diffuseReflection;
					float3 specularColor=_LightColor0.xyz*specularReflection*_SpecColor;
					float3 rimColor=rimReflection*_RimColor.rgb*_LightColor0.xyz;
					float3 colFinal=diffuseColor+specularColor+rimColor;
					//float3 colFinal=rimColor+specularColor;
					float4 tex=tex2D(_MainTex,i.tex.xy*_MainTex_ST.xy+_MainTex_ST.zw);
					return float4(colFinal*_Color.rgb,1.0);
				}
				ENDCG
			}
	}
	//FallBack"Diffuse"
}