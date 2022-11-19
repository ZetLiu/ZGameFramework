// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "LZ/S2_PS_Diffuse"
{
	Properties
	{
		// 材质的漫反射颜色
		_Color("DiffuseColor",Color) = (1.0,1.0,1.0,1.0)
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

			fixed4 _Color;

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 worldPos : TEXCOORD0;
				fixed3 normal : COLOR0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				// 转换顶点坐标到裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex);
				// 顶点坐标变换到世界空间
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				// 法线传递给 frag shader
				o.normal = normalize(UnityObjectToWorldNormal(v.normal));

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 计算环境光分量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 计算漫反射分量
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldLightDir, i.normal));

				// 计算总颜色
				fixed3 color = ambient + diffuse;

				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}