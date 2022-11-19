Shader "LZ/S8_Transparent_AlphaBlend"
{
	Properties
	{
		// 材质的漫反射颜色
		_Color("Color Tint",Color) = (1.0,1.0,1.0,1.0)
		// 材质的主要贴图
		_MainTex("MainTex",2D) = "white"{}
	}

	SubShader
	{
		// 中间不需要逗号隔开
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}

		Pass
		{
			// 只有前向渲染才能获取到正常的光照变量，比如 _LightColor0
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			// 漫反射参数
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				float2 uv:TEXCOORD2;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				// 转换顶点坐标到裁剪空间
				o.pos = UnityObjectToClipPos(v.vertex);
				// 顶点坐标变换到世界空间
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				// 本地法线变换到世界空间
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				// 转换纹理坐标
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 透明度测试
				fixed4 texColor = tex2D(_MainTex,i.uv);

				// 计算漫反射分量
				fixed3 albedo = texColor.rgb * _Color.rgb;
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuse = _LightColor0.rgb * albedo * (dot(worldLightDir, i.worldNormal) * 0.5 + 0.5);

				// 计算环境光分量
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// 计算总颜色
				fixed3 color = ambient + diffuse;
				return fixed4(color,1.0);
			}

			ENDCG
		}
	}

	FallBack "Transparent/VertexLit"
}