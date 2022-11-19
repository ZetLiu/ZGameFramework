Shader "LZ/S3_VS_Specular"
{
	Properties
	{
		// 材质的漫反射颜色
		_Diffuse("Diffuse",Color) = (1.0,1.0,1.0,1.0)
		// 材质的高光颜色
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
			fixed4 _Specular;
			float _Gloss;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 color : COLOR0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				// 转换顶点坐标到裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex);

				// 计算环境光分量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 计算漫反射分量
				fixed3 objectNormal = normalize(v.normal);
				fixed3 objectLightDir = normalize(ObjSpaceLightDir(v.vertex));
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(objectLightDir, objectNormal));

				// 计算高光反射分量
				fixed3 objectViewDir = normalize(ObjSpaceViewDir(v.vertex));
				fixed3 reflectLightDir = normalize(reflect(-objectLightDir,v.normal));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(objectViewDir,reflectLightDir)),_Gloss);

				// 计算总颜色(一般的物体，除了光源都不会发光)
				o.color = ambient + diffuse + specular;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(i.color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Specular"
}