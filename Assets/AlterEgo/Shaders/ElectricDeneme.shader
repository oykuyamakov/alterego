// https://www.shadertoy.com/view/wlV3zy
Shader "Custom/PhreaxElectricSheep"
{

	Properties
	{
		_Count("Line Count",Range(1,100)) = 30
		_KaleiX("Kaleidoscope X Multip",Range(0,50)) = 0.5
		_Speed("Speed",Range(0.1,10)) = 1
		_FlowerN("Flower N",Range(1,10)) = 3
		_Scale("Scale",Range(1,15)) = 5
	}

	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct VertexInput 
			{
				fixed4 vertex : POSITION;
				fixed2 uv:TEXCOORD0;
			};


			struct VertexOutput
			{
				fixed4 pos : SV_POSITION;
				fixed2 uv:TEXCOORD0;
			};

			#define PI 3.141592
			#define TAU 2.*PI
			#define hue(v) ( .6 + .6 * cos( 6.3*(v) + fixed3(0,23,21) ) )
			#define rot(a) fixed2x2(cos(a), sin(a), -sin(a), cos(a))
			#define DISTORT .7
			#define SQR(x) ((x)*(x))

			fixed tt;

			fixed _Speed;

			fixed _Count;
			
			fixed _FlowerN;

			//fixed _KaleiN = 5;
			fixed _KaleiX;

			fixed2 kalei(fixed2 uv) 
			{ 
				fixed n = 5.;
				fixed r = TAU/n;
				
				[unroll(100)]
				for(fixed i=0.; i<n; i++) 
				{     
					uv = abs(uv);
					uv.x -= .2*_KaleiX+.2;
					uv = mul(uv,rot(r*i-.09*tt));
				}
				
				uv = abs(uv) - (sin(.15*tt)+1.2);

				return uv;
			}


			fixed flower(fixed2 uv, fixed r) 
			{
				fixed a = atan2(uv.x,uv.y);

				fixed d = length( uv) - cos(a*_FlowerN);
				return smoothstep(fwidth(d), 0., abs(d));    
			}

			fixed3 spiral(fixed2 uv, fixed i) 
			{  
				uv = mul( uv,rot(i*3.14+tt*.3));
				uv += DISTORT*sin(fixed2(5,5)*uv.yx);
				return flower(uv, .8)*SQR(hue(i+tt*.2));
			}

			VertexOutput vert (VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed _Scale;
			
			fixed4 frag(VertexOutput i) : SV_Target
			{
			
				fixed2 uv = (i.uv-.5*1)/1;
				fixed3 col = fixed3(0,0,0);
				tt = _Time.y * _Speed;
				
				uv *= _Scale;
				uv = kalei(uv);

				fixed s = 1./_Count;
				
				[unroll(100)]
				for(fixed i=0.; i<1.0; i+=s)
				{   
					fixed z = frac(i-.1*tt);
					fixed fade = smoothstep(1., .88, z);
					fixed2 UV = uv;
					col += spiral(UV*z, i);
				
				}
				col = sqrt(col);
				return fixed4(col,1.0);
			}
			ENDCG
		}
	}
}

