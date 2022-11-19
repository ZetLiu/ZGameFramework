Shader "LZ/S6_BumpMap_TangentSpace"
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
		_Gloss("Gloss",Range(8,256)) = 20
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
				float3 tanLightDir : TEXCOORD1;
				float3 tanViewDir : TEXCOORD2;
			};

			v2f vert(appdata_full v)
			{
				v2f o;

				// 转换顶点坐标到裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex);

				// 转换纹理坐标
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpTex);

				// 得到模型空间到切线空间的矩阵
				TANGENT_SPACE_ROTATION;

				// 顶点坐标变换到世界空间
				o.tanLightDir = normalize(mul(rotation,ObjSpaceLightDir(v.vertex)));
				// 本地法线变换到世界空间
				o.tanViewDir = normalize(mul(rotation,ObjSpaceViewDir(v.vertex)));

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 计算环境光分量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 计算漫反射分量
				float3 tanNormal = UnpackNormal(tex2D(_BumpTex,i.uv.zw));
				tanNormal.xy *= _BumpScale;
				tanNormal.z = sqrt(1 - saturate(dot(tanNormal.xy,tanNormal.xy)));
				fixed3 albedo = _Diffuse.rgb * tex2D(_MainTex,i.uv.xy);
				fixed3 diffuse = _LightColor0.rgb * albedo * (dot(i.tanLightDir, tanNormal) * 0.5 + 0.5);

				// 计算高光分量
				fixed3 halfDir = normalize(i.tanViewDir + i.tanLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tanNormal,halfDir)),_Gloss);

				// 计算总颜色
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}