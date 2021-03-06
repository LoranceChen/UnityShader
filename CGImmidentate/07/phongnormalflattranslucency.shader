//basic phong CG shader with spec map


Shader "CG Shaders/Phong/Phong Texture Translucent"
{
	Properties
	{
		_diffuseColor("Diffuse Color", Color) = (1,1,1,1)
		_diffuseMap("Diffuse", 2D) = "white" {}
		_FrenselPower ("Rim Power", Range(1.0, 10.0)) = 2.5
		_FrenselPower (" ", Float) = 2.5
		_rimColor("Rim Color", Color) = (1,1,1,1)
		_specularPower ("Specular Power", Range(1.0, 50.0)) = 10
		_specularPower (" ", Float) = 10
		_specularColor("Specular Color", Color) = (1,1,1,1)
		_normalMap("Normal / Specular (A)", 2D) = "bump" {}
		_LightTransmissionColor ("Light Transmission Color", Color) = (1,1,1,1) 
		_TransmissionMask("Light Transmission - Color + Mask (A)", 2D) = "black" {}		
		_TransPower ("Translucency Power", Range(1.0, 10.0)) = 3
		_TransPower (" ", Float) = 3
		
	}
	SubShader
	{
		Tags {"Queue" = "Transparent" }
		//since we are only using clip, we can continue to z test
		//blending would need seperate samples for back and front - 4 passes - yikes
		AlphaTest Greater 0.3
		Cull Off
		Pass
		{
			Tags { "LightMode" = "ForwardBase" } 
			
			
            
			CGPROGRAM
			
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase
			//if you MUST compile for flash, you might have to remove some features
			//personally i'm not trying to render on a potato
			#pragma exclude_renderers flash
			
			uniform fixed3 _diffuseColor;
			uniform sampler2D _diffuseMap;
			uniform half4 _diffuseMap_ST;			
			uniform fixed4 _LightColor0; 
			uniform half _FrenselPower;
			uniform fixed4 _rimColor;
			uniform half _specularPower;
			uniform fixed3 _specularColor;
			uniform sampler2D _normalMap;
			uniform half4 _normalMap_ST;
			//light transmission
			sampler2D _TransmissionMask;
			uniform half4 _TransmissionMask_ST;
			uniform fixed4 _LightTransmissionColor; 
			half _TransPower;
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
				fixed4 tangent : TANGENT;
				
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs						:	TEXCOORD0;
				fixed3 normalDir						:	TEXCOORD1;	
				fixed3 binormalDir					:	TEXCOORD2;	
				fixed3 tangentDir					:	TEXCOORD3;	
				half3 posWorld						:	TEXCOORD4;	
				fixed3 viewDir						:	TEXCOORD5;
				fixed3 lighting						:	TEXCOORD6;
			};
			
			fixed lambert(fixed3 N, fixed3 L)
			{
				return saturate(dot(N, L));
			}
			fixed frensel(fixed3 V, fixed3 N, half P)
			{	
				return pow(1 - saturate(dot(V,N)), P);
			}
			fixed phong(fixed3 R, fixed3 L)
			{
				return pow(saturate(dot(R, L)), _specularPower);
			}
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
							
				OUT.pos = mul(WorldViewProjection, IN.vertex);
				OUT.uvs = IN.texCoord;					
				OUT.normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				OUT.tangentDir = normalize(mul(IN.tangent, WorldInverseTranspose).xyz);
				OUT.binormalDir = normalize(cross(OUT.normalDir, OUT.tangentDir)); 
				OUT.posWorld = mul(World, IN.vertex).xyz;
				OUT.viewDir = normalize( OUT.posWorld - _WorldSpaceCameraPos);

				//attempt to guess the face direction - reverse the vertex normals if needed 
				if (dot(OUT.viewDir, OUT.normalDir) > dot(OUT.viewDir, -OUT.normalDir))
				{		
					OUT.normalDir = -OUT.normalDir;
					OUT.tangentDir = -OUT.tangentDir;
					OUT.binormalDir = -OUT.binormalDir; 
				}
				
				//vertex lights
				fixed3 vertexLighting = fixed3(0.0, 0.0, 0.0);
				#ifdef VERTEXLIGHT_ON
				 for (int index = 0; index < 4; index++)
					{    						
						half3 vertexToLightSource = half3(unity_4LightPosX0[index], unity_4LightPosY0[index], unity_4LightPosZ0[index]) - OUT.posWorld;
						fixed attenuation  = (1.0/ length(vertexToLightSource)) *.5;	
						fixed3 diffuse = unity_LightColor[index].xyz * lambert(OUT.normalDir, normalize(vertexToLightSource)) * attenuation;
						vertexLighting = vertexLighting + diffuse;
					}
				vertexLighting = saturate( vertexLighting );
				#endif
				OUT.lighting = vertexLighting ;
				
				return OUT;
			}
			
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				half2 normalUVs = TRANSFORM_TEX(IN.uvs, _normalMap);
				fixed4 normalD = tex2D(_normalMap, normalUVs);
				normalD.xyz = (normalD.xyz * 2) - 1;
				
				//half3 normalDir = half3(2.0 * normalSample.xy - float2(1.0), 0.0);
				//deriving the z component
				//normalDir.z = sqrt(1.0 - dot(normalDir, normalDir));
               // alternatively you can approximate deriving the z component without sqrt like so:  
				//normalDir.z = 1.0 - 0.5 * dot(normalDir, normalDir);
				
				fixed3 normalDir = normalD.xyz;	
				fixed specMap = normalD.w;
				normalDir = normalize((normalDir.x * IN.tangentDir) + (normalDir.y * IN.binormalDir) + (normalDir.z * IN.normalDir));
	
				fixed3 ambientL = fixed3(UNITY_LIGHTMODEL_AMBIENT);
	
				
	
				//Main Light calculation - includes directional lights
				half3 pixelToLightSource =_WorldSpaceLightPos0.xyz - (IN.posWorld*_WorldSpaceLightPos0.w);
				fixed attenuation  = lerp(1.0, 1.0/ length(pixelToLightSource), _WorldSpaceLightPos0.w);				
				fixed3 lightDirection = normalize(pixelToLightSource);
				fixed diffuseL = lambert(normalDir, lightDirection);				
				
				//rimLight calculation
				fixed rimLight = frensel(normalDir, -IN.viewDir, _FrenselPower);
				rimLight *= saturate(dot(fixed3(0,1,0),normalDir)* 0.5 + 0.5);	
				fixed3 diffuse = fixed3(_LightColor0)* (diffuseL+ (rimLight * diffuseL) )* attenuation;
				rimLight *= (1-diffuseL);
				diffuse = saturate(IN.lighting + ambientL + diffuse+ (rimLight*_rimColor));
		
				//specular
				fixed specularHighlight = phong(reflect(IN.viewDir , normalDir) ,lightDirection)*attenuation;
				
				//lightTransmission
				fixed forwardTrans = pow(saturate(dot(lightDirection, IN.viewDir)), _TransPower);
				half2 transUVs = TRANSFORM_TEX(IN.uvs, _TransmissionMask);
				fixed4 texSampleTrans = tex2D(_TransmissionMask, transUVs);
				fixed3 transColor = forwardTrans * fixed3(_LightColor0) * texSampleTrans.xyz * fixed3(_LightTransmissionColor)* attenuation;
				
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _diffuseMap);
				fixed4 texSample = tex2D(_diffuseMap, diffuseUVs);
				//multiply transmission by alpha
				transColor *= texSampleTrans.w * texSample.w;
				fixed3 diffuseS = (diffuse * texSample.xyz) * _diffuseColor.xyz;
				fixed3 specular = (specularHighlight * _specularColor * specMap);
				//add transmission to color
				outColor = fixed4( diffuseS +transColor + specular ,texSample.w);
				return outColor;
			}
			
			ENDCG
		}	
		
		//the second pass for additional lights
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" } 
			Blend One One 
			
			CGPROGRAM
			#pragma vertex vShader
			#pragma fragment pShader
			#include "UnityCG.cginc"
			
			uniform fixed3 _diffuseColor;
			uniform sampler2D _diffuseMap;
			uniform half4 _diffuseMap_ST;
			uniform fixed4 _LightColor0; 		
			uniform half _specularPower;
			uniform fixed3 _specularColor;
			uniform sampler2D _normalMap;
			uniform half4 _normalMap_ST;	
			//light transmission
			sampler2D _TransmissionMask;
			uniform half4 _TransmissionMask_ST;
			uniform fixed4 _LightTransmissionColor; 
			half _TransPower;
			
			
			struct app2vert {
				float4 vertex 	: 	POSITION;
				fixed2 texCoord : 	TEXCOORD0;
				fixed4 normal 	:	NORMAL;
				fixed4 tangent : TANGENT;
			};
			struct vert2Pixel
			{
				float4 pos 						: 	SV_POSITION;
				fixed2 uvs						:	TEXCOORD0;	
				fixed3 normalDir						:	TEXCOORD1;	
				fixed3 binormalDir					:	TEXCOORD2;	
				fixed3 tangentDir					:	TEXCOORD3;	
				half3 posWorld						:	TEXCOORD4;	
				fixed3 viewDir						:	TEXCOORD5;
				fixed4 lighting					:	TEXCOORD6;	
			};
			
			fixed lambert(fixed3 N, fixed3 L)
			{
				return saturate(dot(N, L));
			}			
			fixed phong(fixed3 R, fixed3 L)
			{
				return pow(saturate(dot(R, L)), _specularPower);
			}
			vert2Pixel vShader(app2vert IN)
			{
				vert2Pixel OUT;
				float4x4 WorldViewProjection = UNITY_MATRIX_MVP;
				float4x4 WorldInverseTranspose = _World2Object; 
				float4x4 World = _Object2World;
				
				OUT.pos = mul(WorldViewProjection, IN.vertex);
				OUT.uvs = IN.texCoord;	
				
				//derived vectors
				//construct the derived vectors and pass to the pixel shader
				//Transorm the world Normal into world space
				OUT.normalDir = normalize(mul(IN.normal, WorldInverseTranspose).xyz);
				OUT.tangentDir = normalize(mul(IN.tangent, WorldInverseTranspose).xyz);
				//Unity does not provide biNormals, so we must calculate via crossProduct
				OUT.binormalDir = normalize(cross(OUT.normalDir, OUT.tangentDir)); 
				OUT.posWorld = mul(World, IN.vertex).xyz;
				OUT.viewDir = normalize( OUT.posWorld - _WorldSpaceCameraPos);
				
				//attempt to guess the face direction - reverse the vertex normals if needed 
				if (dot(OUT.viewDir, OUT.normalDir) > dot(OUT.viewDir, -OUT.normalDir))
				{		
					OUT.normalDir = -OUT.normalDir;
					OUT.tangentDir = -OUT.tangentDir;
					OUT.binormalDir = -OUT.binormalDir; 
				}
				
				return OUT;
			}
			fixed4 pShader(vert2Pixel IN): COLOR
			{
				half2 normalUVs = TRANSFORM_TEX(IN.uvs, _normalMap);
				fixed4 normalD = tex2D(_normalMap, normalUVs);
				normalD.xyz = (normalD.xyz * 2) - 1;
				
				//half3 normalDir = half3(2.0 * normalSample.xy - float2(1.0), 0.0);
				//deriving the z component
				//normalDir.z = sqrt(1.0 - dot(normalDir, normalDir));
               // alternatively you can approximate deriving the z component without sqrt like so: 
				//normalDir.z = 1.0 - 0.5 * dot(normalDir, normalDir);
				
				//pull the alpha out for spec before modification
				fixed3 normalDir = normalD.xyz;	
				fixed specMap = normalD.w;
				normalDir = normalize((normalDir.x * IN.tangentDir) + (normalDir.y * IN.binormalDir) + (normalDir.z * IN.normalDir));
						
				//Fill lights
				half3 pixelToLightSource =half3(_WorldSpaceLightPos0)- (IN.posWorld*_WorldSpaceLightPos0.w);
				fixed attenuation  = lerp(1.0, 1.0/ length(pixelToLightSource), _WorldSpaceLightPos0.w);				
				fixed3 lightDirection = normalize(pixelToLightSource);
				
				fixed diffuseL = lambert(normalDir, lightDirection);				
				fixed3 diffuseTotal = fixed3(_LightColor0)* diffuseL * attenuation;
				//specular highlight
				fixed specularHighlight = phong(reflect(IN.viewDir , normalDir) ,lightDirection)*attenuation;
				
				//lightTransmission
				fixed forwardTrans = pow(saturate(dot(lightDirection, IN.viewDir)), _TransPower);
				half2 transUVs = TRANSFORM_TEX(IN.uvs, _TransmissionMask);
				fixed4 texSampleTrans = tex2D(_TransmissionMask, transUVs);
				fixed3 transColor = forwardTrans * fixed3(_LightColor0) * texSampleTrans.xyz * fixed3(_LightTransmissionColor)* attenuation;
				
				
				
				fixed4 outColor;							
				half2 diffuseUVs = TRANSFORM_TEX(IN.uvs, _diffuseMap);
				fixed4 texSample = tex2D(_diffuseMap, diffuseUVs);
				transColor *= texSampleTrans.w * texSample.w;
				fixed3 diffuseS = (diffuseTotal * texSample.xyz) * _diffuseColor.xyz;
				fixed3 specular = specularHighlight * _specularColor * specMap;
				outColor = fixed4( diffuseS + transColor + specular,texSample.w);
				return outColor;
			}
			
			ENDCG
		}	
		
	}
}