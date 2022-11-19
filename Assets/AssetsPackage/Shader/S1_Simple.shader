Shader "LZ/S1_Simple"
{
	Properties
	{
		// 漫反射颜色
		_Color("Color Tint",Color) = (1.0,1.0,1.0,1.0)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _Color;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;

				// 坐标转换到裁剪空间
				o.vertex = UnityObjectToClipPos(v.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// 直接返回材质的漫反射颜色
				return _Color;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}