Shader "Custom/unityCookie/08C.1-Glass" {
	Properties {
		_Color ("Color", Color) =  (1.0,1.0,1.0,1.0)
		_SpecColor("SpecColor",Color) =  (1.0,1.0,1.0,1.0)
		_Shininess("Shininess",Float) = 10
		_RimColor("RimColor",Color) =  (1.0,1.0,1.0,1.0)
		_RimPower("RimPower",Range(0.1,10.0)) = 3.0
		_MainTex("Diffuse Texture",2D)="white"{}
		_DumpTex("Dump Texture",2D)="dump"{}
		_DumpDepth("DumpDepth",Range(0.0,2.0)) = 1
		}
	SubShader {
		Pass{
			Tags { "LightMode"="ForwardBase"}
		
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				
				uniform sampler2D _MainTex;
				uniform float4 _MainTex_ST;
				uniform sampler2D _DumpTex;
				uniform float4 _DumpTex_ST;
				
				//self set color
				uniform float4  _Color ;
				uniform float4  _SpecColor;
				uniform float4 _RimColor;
				//self set constant
				uniform float _RimPower;
				 uniform float  _Shininess;
				 uniform float _DumpDepth;
				 //build in color
				uniform float4  _LightColor0;

				struct vertexInput {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;
				};
				struct vertexOutput{
					float4 pos:SV_POSITION;
					float4 posWorld:TEXCOORD0;
					float4 tex:TEXCOORD1;
					float3 normalWorld:TEXCOORD2;
					float3 binormalWorld:TEXCOORD3;
					float3 tangentWorld:TEXCOORD4;
				};
				vertexOutput vert(vertexInput v){
					vertexOutput o;
					o.posWorld=mul(_Object2World,v.vertex);
					
					o.tangentWorld=normalize(mul(_Object2World,v.tangent));
					o.normalWorld=normalize(mul(_Object2World,v.normal));
					o.binormalWorld=normalize(cross(o.normalWorld,o.tangentWorld)*v.tangent.w);
					
					o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
					o.tex=v.texcoord;
					return o;	
				}
				float4 frag(vertexOutput i):COLOR
				{
					//texture maps
					float4 tex=tex2D(_MainTex,i.tex.xy*_MainTex_ST.xy+_MainTex_ST.zw);
					float4 texN=tex2D(_DumpTex,i.tex.xy*_DumpTex_ST.xy+_DumpTex_ST.zw);
					//uncompress texN
					float3 localCoords=float3(2.0*texN.ag-float2(1.0,1.0),0.0);  
					localCoords.z=_DumpDepth;
					//localCoords=texN.rgb;
					//localCoords.z=_DumpDepth;
					//normalDirection
					float3x3 tangentMatrix=float3x3(
						i.tangentWorld,
						i.binormalWorld,
						i.normalWorld
					);
					float3 normalDirection;//=mul(localCoords,tangentMatrix);
//					normalDirection.x=localCoords.x*i.tangentWorld;
//					normalDirection.y=localCoords.y*i.binormalWorld;
//					normalDirection.z=localCoords.z*i.normalWorld;
					normalDirection=normalize(mul(localCoords,tangentMatrix));
					//Direction
					//float3 normalDirection=normalize(i.normalDirection);	
					float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDirection=normalize(_WorldSpaceCameraPos.xyz-i.posWorld.xyz);		
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
							lightSource=_WorldSpaceLightPos0.xyz-i.posWorld.xyz;
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
					float3 colFinal=diffuseColor+specularColor * tex.a+rimColor+UNITY_LIGHTMODEL_AMBIENT.rgb;
					
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
				uniform sampler2D _DumpTex;
				uniform float4 _DumpTex_ST;
				
				//self set color
				uniform float4  _Color ;
				uniform float4  _SpecColor;
				uniform float4 _RimColor;
				//self set constant
				uniform float _RimPower;
				 uniform float  _Shininess;
				 uniform float _DumpDepth;
				 //build in color
				uniform float4  _LightColor0;

				struct vertexInput {
					float4 vertex:POSITION;
					float3 normal:NORMAL;
					float4 tangent:TANGENT;
					float4 texcoord:TEXCOORD0;
				};
				struct vertexOutput{
					float4 pos:SV_POSITION;
					float4 posWorld:TEXCOORD0;
					float4 tex:TEXCOORD1;
					float3 normalWorld:TEXCOORD2;
					float3 binormalWorld:TEXCOORD3;
					float3 tangentWorld:TEXCOORD4;
				};
				vertexOutput vert(vertexInput v){
					vertexOutput o;
					o.posWorld=mul(_Object2World,v.vertex);
					
					o.tangentWorld=normalize(mul(_Object2World,v.tangent));
					o.normalWorld=normalize(mul(_Object2World,v.normal));
					o.binormalWorld=normalize(cross(o.normalWorld,o.tangentWorld)*v.tangent.w);
					
					o.pos=mul(UNITY_MATRIX_MVP,v.vertex);
					o.tex=v.texcoord;
					return o;	
				}
				float4 frag(vertexOutput i):COLOR
				{
					//texture maps
					float4 tex=tex2D(_MainTex,i.tex.xy*_MainTex_ST.xy+_MainTex_ST.zw);
					float4 texN=tex2D(_DumpTex,i.tex.xy*_DumpTex_ST.xy+_DumpTex_ST.zw);
					//uncompress texN
					float3 localCoords=float3(2.0*texN.ag-float2(1.0,1.0),0.0);  
					localCoords.z=_DumpDepth;
					//localCoords=texN.rgb;
					//localCoords.z=_DumpDepth;
					//normalDirection
					float3x3 tangentMatrix=float3x3(
						i.tangentWorld,
						i.binormalWorld,
						i.normalWorld
					);
					float3 normalDirection;//=mul(localCoords,tangentMatrix);
//					normalDirection.x=localCoords.x*i.tangentWorld;
//					normalDirection.y=localCoords.y*i.binormalWorld;
//					normalDirection.z=localCoords.z*i.normalWorld;
					normalDirection=normalize(mul(localCoords,tangentMatrix));
					//Direction
					//float3 normalDirection=normalize(i.normalDirection);	
					float3 lightDirection=normalize(_WorldSpaceLightPos0.xyz);
					float3 viewDirection=normalize(_WorldSpaceCameraPos.xyz-i.posWorld.xyz);		
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
							lightSource=_WorldSpaceLightPos0.xyz-i.posWorld.xyz;
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
					float3 colFinal=diffuseColor+specularColor* tex.a+rimColor;
					
					return float4(colFinal*_Color.rgb,1.0);
					//return i.col;
				}
				
				ENDCG
			}
	}
	//FallBack"Diffuse"
}