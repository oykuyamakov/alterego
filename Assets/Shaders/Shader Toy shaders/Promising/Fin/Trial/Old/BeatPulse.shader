Shader "Unlit/AdvancedBeatPulse"
{
    Properties
    {
        _ReactiveSpeed("Reactive Speed", Range(0.0, 25.0)) = 0.5
        _Speed("Speed", Range(0.0, 5.0)) = 0.5
        _Scale("Scale", Range(1.0, 5.0)) = 2.0
        _LineThickness("Line Thickness", Range(0.01, 1.0)) = 0.15
        
        _PulseDuration("Pulse Duration", Range(0.1, 5.0)) = 1.0
        
        _CirclePulseBeat("Circle Pulse Beat", Float) = 0.0
        _CirclePulse("Circle Pulse Intensity", Range(0.0, 5.0)) = 1.0
        
        _GlowPulseBeat("Glow Pulse Beat", Float) = 0.0
        _GlowPulse("Glow Pulse Intensity", Range(0.0, 5.0)) = 1.0
        _GlowIntensity("Base Glow Intensity", Range(0.0, 5.0)) = 1.0
        
        _MinCircleSize("Min Circle Size", Range(0.01, 1.0)) = 0.1
        _MaxCircleSize("Max Circle Size", Range(0.05, 5.0)) = 1.0
       
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

            fixed _ReactiveSpeed, _Speed, _Scale, _LineThickness;
            fixed _CirclePulse, _GlowPulse, _MinCircleSize, _MaxCircleSize, _GlowIntensity;
            fixed _PulseDuration;
            fixed _CirclePulseBeat, _GlowPulseBeat;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            static fixed n = 13.;

            fixed pattern(fixed2 p) // random pattern
            {
                return 0.6 * pow(abs(sin(p.x * 3.141) * sin(p.y * 3.141)), _LineThickness);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // UV transformation for the tunnel
                fixed2 uv = (i.uv - 0.5) * _Scale;

                // Base wobble effect (not affected by BeatPulse)
                fixed tt = _Time.y * _Speed;
                
                // Individual pulses for different effects
                // Circle Pulse
                fixed pulseTimeCircle = frac(_Time.y / _PulseDuration + _CirclePulseBeat); // Offset pulse for the circle
                fixed circlePulse = smoothstep(0.0, 1.0, _CirclePulseBeat) * sin(pulseTimeCircle * 3.141) * _CirclePulse;
                fixed circleSize = lerp(_MinCircleSize, _MaxCircleSize, circlePulse);

                // Glow Pulse
                fixed pulseTimeGlow = frac(_Time.y / _PulseDuration + _GlowPulseBeat); // Offset pulse for glow
                fixed glowPulse = smoothstep(0.0, 1.0, _GlowPulseBeat) * sin(pulseTimeGlow * 3.141) * _GlowPulse;
                

                // Generate pattern
                fixed2 m;
                m.x = atan2(uv.x, uv.y) / 6.283 * n;
                m.x += tt;
                m.y = length(uv) * 20.0;

                fixed col = pattern(m);

                // Apply the pulsating circle effect
                fixed dist = length(uv);
                if (dist < circleSize)
                {
                    col = lerp(col, 1.0, 0.5); // Highlight the circle
                }

                // Apply glow effect
                col += glowPulse * _GlowIntensity;

                return fixed4(fixed3(col, col, col), 1.0);
            }
            ENDCG
        }
    }
}
