Shader "Custom/PsychedelicEyeWithFloatingTexture"
{
    Properties
    {
        _EyeColor ("Eye Color", Color) = (0, 0, 1, 1)   // Default: blue
        _PupilColor ("Pupil Color", Color) = (0, 0, 0, 1) // Default: black
        _PulseColor ("Pulse Color", Color) = (1, 0, 0, 1) // Default: red
        _FloatingTexture ("Floating Texture", 2D) = "white" {} // Exposed texture
        _TimeSpeed ("Time Speed", Range(0, 1)) = 0.1
        _FloatSpeed ("Float Speed", Range(0, 5)) = 1.0 // Controls how fast the texture floats away
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Exposed properties
            float4 _EyeColor;
            float4 _PupilColor;
            float4 _PulseColor;
            sampler2D _FloatingTexture; // Floating texture sampler
            float _TimeSpeed;
            float _FloatSpeed;

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Fractal noise function for psychedelic effect
            float fractalNoise(float2 p)
            {
                float n = 0.0;
                float freq = 1.0;
                for (int i = 0; i < 4; ++i)
                {
                    n += sin(p.x * freq + p.y * freq + _Time.y * _TimeSpeed);
                    freq *= 2.0;
                }
                return n;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Eye texture - Placeholder or texture can be added here
                float4 tex = _EyeColor; // Use EyeColor as the default base color

                // Apply fractal noise for psychedelic effect
                float noise = fractalNoise(uv);

                // Apply pulse color modulation over time
                float4 pulseColor = _PulseColor * (sin(_Time.y * 0.5) + noise * 0.5);

                // Combine EyeColor and PulseColor for the final effect
                float4 color = tex + pulseColor;

                // Add pupil (black or dark color) at the center
                float dist = length(uv - float2(0.5, 0.5)); // Distance from center
                float pupilRadius = 0.1; // Radius of the pupil
                if (dist < pupilRadius)
                {
                    color = _PupilColor; // Override with pupil color if inside the radius
                }

                // ** Floating Texture Logic **
                // Modify the UV coordinates based on time and FloatSpeed to create the floating effect
                float2 floatUV = uv + float2(sin(_Time.y * _FloatSpeed) * 0.2, cos(_Time.y * _FloatSpeed) * 0.2);
                // Sampling the floating texture with modified UV coordinates
                float4 floatingTex = tex2D(_FloatingTexture, floatUV);

                // Blend the floating texture with the eye color
                color = lerp(color, floatingTex, 0.5); // Adjust blending factor as needed

                return color;
            }
            ENDCG
        }
    }
}
