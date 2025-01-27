Shader "Custom/FresnelWithNormalMap"
{
    Properties
    {
        _Count("Line Count", Range(1, 100)) = 30
        _MainTex("Base Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue" = "Overlay" }
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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float _Count;
            float _Cutoff;

            #define PI 3.141592
            #define TAU 2.*PI
            #define hue(v) ( .6 + .6 * cos( 6.3*(v) + float3(0,23,21) ) )
            #define rot(a) float2x2(cos(a), sin(a), -sin(a), cos(a))
            #define DISTORT .7
            #define SQR(x) ((x)*(x))

            float tt;

            float2 kalei(float2 uv) 
            { 
                float n = 5.;
                float r = TAU / n;
                
                [unroll(100)]
                for (float i = 0.; i < n; i++) 
                {     
                    uv = abs(uv);
                    uv.x -= .2 * i + .2;
                    uv = mul(uv, rot(r * i - .09 * tt));
                }
                
                uv = abs(uv) - (sin(.15 * tt) + 1.2);

                return uv;
            }

            float flower(float2 uv, float r) 
            {
                float n = 3.;
                float a = atan2(uv.x, uv.y);

                float d = length(uv) - cos(a * n);
                return smoothstep(fwidth(d), 0., abs(d));    
            }

            float3 spiral(float2 uv, float i) 
            {  
                uv = mul(uv, rot(i * 3.14 + tt * .3));
                uv += DISTORT * sin(float2(5, 5) * uv.yx);
                return flower(uv, .8) * SQR(hue(i + tt * .2));
            }

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal = normalize(mul((float3x3)unity_ObjectToWorld, float3(0, 0, 1)));
                return o;
            }

            float4 frag(VertexOutput i) : SV_Target
            {
                // Sample the normal map
                float3 normalTex = tex2D(_NormalMap, i.uv).rgb * 2.0 - 1.0;
                normalTex = normalize(normalTex);

                // Sample the base texture for alpha
                float alpha = tex2D(_MainTex, i.uv).a;

                // Discard based on alpha cutoff
                if (alpha < _Cutoff)
                    discard;

                float2 uv = (i.uv - .5 * 1) / 1;
                float3 col = float3(0, 0, 0);
                tt = _Time.y;

                uv *= 5.;
                uv = kalei(uv);

                float s = 1. / _Count;

                [unroll(100)]
                for (float i = 0.; i < 1.0; i += s)
                {   
                    float z = frac(i - .1 * tt);
                    float fade = smoothstep(1., .88, z);
                    float2 UV = uv;
                    col += spiral(UV * z, i) * 0.1f;
                }

                col = sqrt(col);

                return float4(col, alpha);
            }
            ENDCG
        }
    }
}
