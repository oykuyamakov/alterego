Shader "Unlit/SwirlyTiledTunnelWithBPM"
{
    Properties
    {
        _Speed("Speed", Range(0.0, 5.0)) = 0.5
        _Scale("Scale", Range(1.0, 5.0)) = 2.0
        _Linethicness("Line Thickness", Range(0.01, 1.0)) = 0.15
        _BPM("Beats Per Minute", Range(60, 180)) = 100
        _MinSize("Circle Min Size", Range(0.1, 1.0)) = 0.2
        _MaxSize("Circle Max Size", Range(0.5, 2.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed _Speed, _Scale, _Linethicness, _BPM, _MinSize, _MaxSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            static fixed n = 13.0;
            static fixed k = 1.0;

            // Function to calculate the circle's size with easing
            fixed GetCircleSize(fixed time)
            {
                fixed bpmTime = 60.0 / _BPM; // Time per beat
                fixed t = frac(time / bpmTime); // Normalized time within a beat cycle

                // Smooth easing: scale up, overshoot, and return
                fixed eased = smoothstep(0.0, 0.5, t) - smoothstep(0.5, 1.0, t);
                return lerp(_MinSize, _MaxSize, eased + t * 0.2); // Add slight overshoot
            }

            // Pattern function (existing code)
            fixed pattern(fixed2 p)
            {
                return 0.6 * pow(abs(sin(p.x * 3.141) * sin(p.y * 3.141)), _Linethicness);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale; // Center UV coordinates
                fixed tt = _Time.y * _Speed;

                // Swirly tunnel
                fixed2 m;
                fixed cr = k * pow((sin(tt * 0.5) * 3.5 + 0.5), 1.0);
                m.x = atan2(uv.x, uv.y) / 6.283 * n;
                m.x += 1.5 * sin(length(uv) * cr + 3.141);
                m.x += tt;
                m.y = 3. * 1e2 / pow(length(uv), 1e-2);
                m.y += tt + m.x / n;
                m.y += sin(length(uv) * cr * 1.5);

                fixed tunnelCol = pattern(m);

                // Circle at center
                fixed circleSize = GetCircleSize(_Time.y); // Calculate current circle size
                fixed circleDist = length(uv); // Distance from center
                fixed circleAlpha = smoothstep(circleSize, circleSize - 0.05, circleDist); // Fade circle edge

                // Combine
                fixed finalCol = max(tunnelCol, circleAlpha); // Overlay circle on tunnel
                return fixed4(finalCol, finalCol, finalCol, 1.0);
            }
            ENDCG
        }
    }
}
