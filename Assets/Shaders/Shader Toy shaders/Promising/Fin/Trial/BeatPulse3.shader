Shader "Unlit/AdvancedSwirlyTunnel"
{
    Properties
    {
        // Core properties
        _ReactiveSpeed("Reactive Speed", Range(0.0, 5.0)) = 0.5
        _Speed("Speed", Range(0.0, 5.0)) = 0.5
        _Scale("Scale", Range(0.1, 20.0)) = 2.0
        _Linethicness("Line Thickness", Range(0.0, 2.0)) = 0.15

        // Glow pulse properties
        _GlowPulseBeat("Glow Pulse Beat", Float) = 0.0
        _GlowPulse("Glow Pulse Intensity", Range(0.0, 5.0)) = 1.0
        _GlowIntensity("Base Glow Intensity", Range(0.0, 5.0)) = 0.0

        // Color pulse properties
        _PulseDuration("Pulse Duration", Range(0.1, 5.0)) = 1.0
        _ColorPulseDuration("Color Pulse Duration", Range(0.1, 5.0)) = 1.0
        _PulseColor("Pulse Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _PulseColorIntensity("Pulse Color Intensity", Range(0.0, 5.0)) = 1.0

        // Shape customization
        _ShapeType("Shape Type (0: Circle, 1: Hexagon)", Int) = 0

        // Background texture
        _BackgroundTex("Background Texture", 2D) = "white" {}
        _BGScale("Background Scale", Float) = 1.0
        _BGOffset("Background Offset", Vector) = (0, 0, 0, 0)

        // Wave distortion
        _WaveSpeed("Wave Speed", Range(0.0, 5.0)) = 1.0
        _WaveIntensity("Wave Intensity", Range(0.0, 2.0)) = 0.1

        // Gradient effect
        _GradientMix("Gradient Mix", Range(0.0, 1.0)) = 0.5

        // Noise effect
        _NoiseIntensity("Noise Intensity", Range(0.0, 1.0)) = 0.1

        // Radial blur
        _BlurIntensity("Blur Intensity", Range(0.0, 1.0)) = 0.5
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

            // Shader properties
            fixed _Speed, _Scale, _Linethicness, _ReactiveSpeed;
            fixed _GlowPulse, _PulseDuration, _ColorPulseDuration;
            fixed _GlowPulseBeat, _ColorPulseBeat;
            int _ShapeType;

            float4 _PulseColor;
            fixed _PulseColorIntensity;
            sampler2D _BackgroundTex;
            fixed _BGScale;
            float4 _BGOffset;

            fixed _WaveSpeed, _WaveIntensity;
            fixed _GradientMix;
            fixed _NoiseIntensity;
            fixed _BlurIntensity;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed customMod(fixed x, fixed y)
            {
                return x - y * floor(x / y);
            }

            // Pattern function for shapes
            fixed pattern(fixed2 p)
            {
                if (_ShapeType == 0) // Circle
                {
                    return pow(abs(sin(p.x * 3.141) * sin(p.y * 3.141)), _Linethicness);
                }
                else if (_ShapeType == 1) // Hexagon
                {
                    fixed2 q = customMod(p, 2.0) - 1.0;
                    return pow(abs(sin(q.x * 3.141) * sin(q.y * 3.141)), _Linethicness);
                }
                return 0.0;
            }

            // Noise function
            fixed noise(fixed2 uv)
            {
                return frac(sin(dot(uv, fixed2(12.9898, 78.233))) * 43758.5453);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 uv = (i.uv - 0.5) * _Scale;
                fixed tt = _Time.y * _Speed;

                // Apply wave distortion
                fixed2 distortedUV = uv + sin(uv.yx * 10.0 + tt * _WaveSpeed) * _WaveIntensity;

                // Swirly tunnel effect
                fixed2 m;
                fixed cr = pow(abs(sin(tt * _ReactiveSpeed)), 1.0);
                m.x = atan2(distortedUV.x, distortedUV.y) / 6.283 * 13.0;
                m.x += 1.5 * sin(length(distortedUV) * cr + 3.141);
                m.x += tt;
                m.y = 3. * 1e2 / pow(length(distortedUV), 1e-2);
                m.y += tt + m.x / 13.0;
                m.y += sin(length(distortedUV) * cr * 1.5);

                // Pattern
                fixed col = pattern(m);

                // Glow pulse
                fixed pulseTimeGlow = frac(_Time.y / _PulseDuration + _GlowPulseBeat);
                fixed glowPulse = smoothstep(0.0, 1.0, _GlowPulseBeat) * sin(pulseTimeGlow * 3.141) * _GlowPulse;
                col += glowPulse;

                // Color pulse
                fixed pulseColorSpeed = frac(_Time.y / _ColorPulseDuration + _ColorPulseBeat);
                fixed colorPulse = smoothstep(0.0, 1.0, _ColorPulseBeat) * sin(pulseColorSpeed * 3.141) * _PulseColorIntensity;
                fixed4 pulseEffectColor = _PulseColor * colorPulse;

                // Gradient
                fixed dist = length(distortedUV);
                fixed3 gradientColor = lerp(fixed3(1.0, 0.0, 0.0), fixed3(0.0, 0.0, 1.0), dist);
                col = lerp(col, gradientColor, _GradientMix);

                // Noise effect
                col += noise(distortedUV) * _NoiseIntensity;

                // Radial blur
                fixed blur = smoothstep(0.0, 1.0, dist);
                col *= (1.0 - blur * _BlurIntensity);

                // Background texture
                fixed4 bgColor = tex2D(_BackgroundTex, i.uv * _BGScale + _BGOffset.xy);
                fixed4 finalColor = fixed4(fixed3(col, col, col), 1.0) + pulseEffectColor;
                finalColor = lerp(bgColor, finalColor, 0.5); // Blend with background

                return finalColor;
            }
            ENDCG
        }
    }
}
