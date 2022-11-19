Shader "LZ/S6_BumpMap_WorldSpace"
{
	Properties
	{
		// 材质的漫反射颜色
		_Diffuse("Diffuse",Color) = (1.0,1.0,1.0,1.0)
		// 材质的主要贴图
		_MainTex("MainTex",2D) = "white"{}
		// 凹凸贴图
		_BumpTex("BumpTex",2D) = "bump"{}
		_BumpScale("BumpScale",Range(0,1)) = 0.5
		// 高光
		_Specular("Specular",Color) = (1.0,1.0,1.0,1.0)
		// 高光系数
		_Gloss("_Gloss",Range(8,256)) = 20
	}

	SubShader
	{
		Pass
		{
			// 只有前向渲染才能获取到正常的光照变量，比如 _LightColor0
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			v2f vert(appdata_full v)
			{
				v2f o;

				// 转换顶点坐标到裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex);

				// 转换纹理坐标
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpTex);

				// 顶点坐标转换到世界空间
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

				// 构造切线空间到世界空间的矩阵
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBioNormal = cross(worldNormal,worldTangent) * v.tangent.w;
				o.TtoW0 = float4(worldTangent.x,worldBioNormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBioNormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBioNormal.z,worldNormal.z,worldPos.z);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 计算环境光分量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 计算漫反射分量
				float3 worldPos = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				fixed3 worldNormal = UnpackNormal(tex2D(_BumpTex,i.uv.zw));
				worldNormal.xy *= _BumpScale;
				worldNormal.z = sqrt(1 - saturate(dot(worldNormal.xy,worldNormal.xy)));
				worldNormal = normalize(half3(dot(i.TtoW0.xyz,worldNormal),dot(i.TtoW1.xyz,worldNormal),dot(i.TtoW2.xyz,worldNormal)));
				fixed3 albedo = _Diffuse.rgb * tex2D(_MainTex,i.uv.xy);
				fixed3 diffuse = _LightColor0.rgb *  albedo *(dot(worldLightDir, worldNormal) * 0.5 + 0.5);

				// 计算高光分量
				fixed3 halfDir = normalize(worldLightDir + worldViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				// 计算总颜色
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}