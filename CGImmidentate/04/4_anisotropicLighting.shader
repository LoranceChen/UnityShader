Shader "unityCookie/tut/intermediate/4 - Anisotropic Lighting"{
	Properties {
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_SpecColor ("Specular Color", Color) = (1.0,1.0,1.0,1.0)
		_AniX ("Anisotropic X", Range(0.0,2.0)) = 1.0
		_AniY ("Anisotropic Y", Range(0.0,2.0)) = 1.0
		_Shininess ("Shininess", Float) = 1.0
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed _AniX;
			uniform fixed _AniY;
			uniform half _Shininess;
			
			//unity defined variables
			uniform half4 _LightColor0;
			
			//base input structs
			struct vertexInput{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;//传入的切向量与视角有关系吗
			};
			struct vertexOutput{
				half4 pos : SV_POSITION;
				fixed3 normalDir : TEXCOORD0;
				fixed4 lightDir : TEXCOORD1;
				fixed3 viewDir : TEXCOORD2;
				fixed3 tangentDir : TEXCOORD3;
			};
			
			//vertex Function
			vertexOutput vert(vertexInput v){
				vertexOutput o;
				
				//normalDirection
				o.normalDir = normalize( mul( half4( v.normal, 0.0 ), _World2Object ).xyz );
				//tangent direction
				o.tangentDir = normalize( mul( _Object2World, half4(v.tangent.xyz, 0.0) ).xyz );
				
				//unity transform position
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				//world position
				half4 posWorld = mul(_Object2World, v.vertex);
				//view direction
				o.viewDir = normalize( _WorldSpaceCameraPos.xyz - posWorld.xyz );
				//light direction
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
				//下面计算灯光方向，顺便用w分量记录光照强度
				o.lightDir = fixed4(
					normalize( lerp(_WorldSpaceLightPos0.xyz , fragmentToLightSource, _WorldSpaceLightPos0.w) ),//根据光源类型决定灯光方向，二选一
					lerp(1.0 , 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)//根据光源类型存储光照强度
				);
				
				return o;
			}
			
			//fragment function
			fixed4 frag(vertexOutput i) : COLOR
			{
				
				//Lighting
				fixed3 h = normalize(i.lightDir.xyz + i.viewDir); 
				half3 binormalDir = cross(i.normalDir,i.tangentDir);
				
				//dot product，收集各个方向的长度
				fixed nDotL = dot(i.normalDir, i.lightDir.xyz);
				fixed nDotH = dot(i.normalDir, h);//没用到
				fixed nDotV = dot(i.normalDir, i.viewDir);//没用到，坑爹
				fixed tDotHX = dot(i.tangentDir, h) / _AniX;
				fixed bDotHY = dot(binormalDir, h) / _AniY;
				
				//Diffuse，光照强度.w     灯光颜色     漫反射量 
				fixed3 diffuseReflection = i.lightDir.w * _LightColor0.xyz * saturate(nDotL);
				//Specular，
				fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * exp( -(tDotHX * tDotHX + bDotHY * bDotHY) ) * _Shininess;
				
				fixed3 lightFinal = specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				return fixed4(lightFinal * _Color.xyz, 1.0);
			}
			
			ENDCG
			
		}
	}
	//Fallback "Specular"
}