Shader "Unlit/AdvancedSwirlyTunnel"
{
    Properties
    {
        _ReactiveSpeed("ReactiveSpeed", Range(0.0, 5.0)) = 0.5
        _Speed("Speed", Range(0.0, 5.0)) = 0.5
        _Scale("Scale", Range(0.1, 20.0)) = 2.0
        _Linethicness("Line Thickness", Range(0.01, 2.0)) = 0.15
        
        _ColorPulseBeat("Color Pulse Beat", Float) = 0.0
        
        _PulseDuration("Pulse Duration", Range(0.1, 5.0)) = 1.0
        _ColorPulseDuration("Color Pulse Duration", Range(0.1, 5.0)) = 1.0
        
//        _CirclePulseBeat("Circle Pulse Beat", Float) = 0.0
//        _CirclePulse("Circle Pulse Intensity", Range(0.0, 5.0)) = 1.0
        
        _GlowPulseBeat("Glow Pulse Beat", Float) = 0.0
        _GlowPulse("Glow Pulse Intensity", Range(0.0, 5.0)) = 1.0
        _GlowIntensity("Base Glow Intensity", Range(0.0, 5.0)) = 0.0
        
//        _MinCircleSize("Min Circle Size", Range(0.01, 1.0)) = 0.1
//        _MaxCircleSize("Max Circle Size", Range(0.05, 5.0)) = 1.0
        
        // New color properties for pulse effect
        _PulseColor("Pulse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _PulseColorIntensity("Pulse Color Intensity", Range(0.0, 5.0)) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            fixed _Speed, _Scale, _Linethicness, _ReactiveSpeed;
            
            fixed _GlowPulse, _PulseDuration, _ColorPulseDuration;
            
            fixed _GlowPulseBeat, _ColorPulseBeat;
            
            //fixed _MinCircleSize, _MaxCircleSize;
            //fixed _CirclePulse;
            //fixed _CirclePulseBeat;
            
            float4 _PulseColor;
            fixed _PulseColorIntensity;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            static fixed n = 13.0;
            static fixed k = 1.0;

            fixed pattern(fixed2 p) // random pattern generation
            {
                return 0.6 * pow(abs(sin(p.x * 3.141) * sin(p.y * 3.141)), _Linethicness);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;
                fixed tt = _Time.y * _Speed;

                // Circle Pulse: Calculate pulse effect for circle size
                // fixed pulseTimeCircle = frac(_Time.y / _PulseDuration + _CirclePulseBeat);
                // fixed circlePulse = smoothstep(0.0, 1.0, _CirclePulseBeat) * sin(pulseTimeCircle * 3.141) * _CirclePulse;
                // fixed circleSize = lerp(_MinCircleSize, _MaxCircleSize, circlePulse);
                

                // Swirly Tunnel effect
                fixed2 m;
                fixed cr = k * pow((sin(tt * _ReactiveSpeed)), 1.0); // Apply reactive speed to swirls
                m.x = atan2(uv.x, uv.y) / 6.283 * n;
                m.x += 1.5 * sin(length(uv) * cr + 3.141);
                m.x += tt;
                m.y = 3. * 1e2 / pow(length(uv), 1e-2);
                m.y += tt + m.x / n;
                m.y += sin(length(uv) * cr * 1.5);

                // Apply the random pattern
                fixed col = pattern(m);

                // Apply Circle Pulse: Highlight area inside the circle size
                //fixed dist = length(uv);
                // if (dist < circleSize)
                // {
                //     col = lerp(col, 1.0, 0.5); // Enhance area inside the circle
                // }

                fixed pulseTimeGlow = frac(_Time.y / _PulseDuration + _GlowPulseBeat);
                fixed glowPulse = smoothstep(0.0, 1.0, _GlowPulseBeat) * sin(pulseTimeGlow * 3.141) * _GlowPulse;
                col += glowPulse;

                fixed pulseColorSpeed = frac(_Time.y / _ColorPulseDuration + _ColorPulseBeat);
                fixed colorPulse = smoothstep(0.0, 1.0, _ColorPulseBeat) * sin(pulseColorSpeed * 3.141) * _PulseColorIntensity;

                // Add color intensity based on pulse
                fixed4 pulseEffectColor = _PulseColor * colorPulse;

                // Final color: mix original color with pulsing color effect
                fixed4 finalColor = fixed4(fixed3(col, col, col), 1.0) + pulseEffectColor;

                return finalColor;
            }
            ENDCG
        }
    }
}
