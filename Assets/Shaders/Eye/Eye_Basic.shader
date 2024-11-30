Shader "Custom/BuiltIn/EyeWithLidAndIris"
{
    Properties
    {
        _EyeColor ("Eye Color", Color) = (1, 1, 1, 1)
        _PupilColor ("Pupil Color", Color) = (0, 0, 0, 1)
        _PupilSpeed ("Pupil Speed", Range(0.1, 5.0)) = 1.0
        _PupilMinSize ("Pupil Min Size", Range(0.0, 0.5)) = 0.1
        _PupilMaxSize ("Pupil Max Size", Range(0.5, 1.0)) = 0.4
        _EyeSize ("Eye Size", Range(0.2, 1.0)) = 0.5
        _LidHeight ("Lid Height", Range(0.0, 1.0)) = 0.5
        _LidSpeed ("Lid Speed", Range(0.1, 5.0)) = 1.0
        _IrisStripesColor ("Iris Stripes Color", Color) = (0.5, 0.3, 0.1, 1)
        _IrisNoiseStrength ("Iris Noise Strength", Range(0.0, 1.0)) = 0.2
        _Texture ("Eye Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Tags { "RenderType" = "Opaque" }
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            float4 _EyeColor;
            float4 _PupilColor;
            float _PupilSpeed;
            float _PupilMinSize;
            float _PupilMaxSize;
            float _EyeSize;
            float _LidHeight;
            float _LidSpeed;
            float4 _IrisStripesColor;
            float _IrisNoiseStrength;
            sampler2D _Texture;

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

            float fract(float x)
            {
                return x - floor(x);
            }

            float circle(float2 uv, float radius)
            {
                uv -= 0.5;
                return step(length(uv), radius);
            }

            float irisStripes(float2 uv, float radius)
            {
                uv -= 0.5;
                float angle = atan2(uv.y, uv.x);
                float stripeWidth = 0.05;
                float noise = fract(sin(angle * 10.0) * 1000.0);
                return smoothstep(0.0, stripeWidth, abs(noise - 0.5));
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;

                float eye = circle(uv, _EyeSize);

                float time = _Time.y * _PupilSpeed;
                float pupilSize = lerp(_PupilMinSize, _PupilMaxSize, (sin(time) + 1.0) * 0.5);

                float pupil = circle(uv, pupilSize);

                float iris = circle(uv, _EyeSize * 0.8);
                float irisStripesEffect = irisStripes(uv, _EyeSize * 0.8);
                float4 irisColor = lerp(_IrisStripesColor, float4(0, 0, 0, 0), irisStripesEffect);

                float lidHeight = smoothstep(0.0, 1.0, abs(uv.y - 0.5) - (_LidHeight * (sin(time * _LidSpeed) * 0.5 + 0.5)));
                float4 lidColor = float4(0.0, 0.0, 0.0, 1.0) * lidHeight;

                float4 texColor = tex2D(_Texture, uv);
                irisColor = texColor * irisColor;

                float4 finalColor = lerp(float4(1.0, 1.0, 1.0, 1.0), irisColor, iris);
                finalColor = lerp(finalColor, _PupilColor, pupil);

                finalColor = lerp(finalColor, lidColor, lidHeight);

                return finalColor;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
