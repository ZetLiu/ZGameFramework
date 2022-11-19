// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "LZ/S4_PS_HalfLambert_BlinnPhong"
{
	Properties
	{
		// 材质的漫反射颜色
		_Diffuse("Diffuse",Color) = (1.0,1.0,1.0,1.0)
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
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				fixed3 worldNormal : COLOR;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				// 转换顶点坐标到裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex);
				// 顶点坐标变换到世界空间
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				// 本地法线变换到世界空间
				o.worldNormal = UnityObjectToWorldNormal(v.normal);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 计算环境光分量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 计算漫反射分量
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				// HalfLambert
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldLightDir, i.worldNormal) * 0.5 + 0.5);

				// 计算高光分量
				fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldViewDir + worldLightDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(i.worldNormal,halfDir)),_Gloss);

				// 计算总颜色
				fixed3 color = ambient + diffuse + specular;
				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}