Shader "Hexagogb"
{
    Properties
    {
        _ShapeColor ("Shape Color", Color) = (1, 0, 0, 1)
        _RotationSpeed ("Rotation Speed", Range(0, 100)) = 1.0
        _ShapeSize ("Shape Size", Range(0.1, 1.0)) = 0.5
        _NumShapes ("Number of Shapes", Range(1, 10)) = 5
        _AnimationSpeed ("Animation Speed", Range(0, 100.0)) = 1.0
        _ColorChangeSpeed ("Color Change Speed", Range(0, 25.0)) = 1.0
        _ShapeJitterSpeed ("Shape Jitter Speed", Range(0, 10.0)) = 1.0

        _TopTexture ("Top Texture", 2D) = "white" {}
        _TextureScale ("Texture Scale", Range(0.1, 10.0)) = 1.0
        _BackgroundTexture ("Background Texture", 2D) = "black" {}
        _BackgroundColor ("Background Color", Color) = (0, 0, 0, 1)

        _ShapeType ("Shape Type", Int) = 0
    }

    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert

        // Exposed properties
        float4 _ShapeColor;
        float _RotationSpeed;
        float _ShapeSize;
        float _NumShapes;
        float _ShapeJitterSpeed;
        float _AnimationSpeed;
        float _ColorChangeSpeed;
        float _TextureScale;
        float4 _BackgroundColor;
        int _ShapeType;

        sampler2D _TopTexture;
        sampler2D _BackgroundTexture;

        struct Input
        {
            float2 uv_TopTexture;
            float2 uv_BackgroundTexture;
        };

        // Utility function to rotate UVs
        float2 rotateUV(float2 uv, float angle)
        {
            float s = sin(angle);
            float c = cos(angle);
            float2x2 rotationMatrix = float2x2(c, -s, s, c);
            return mul(rotationMatrix, uv - 0.5) + 0.5;
        }

        // Generate a hexagon shape
        float hexagon(float2 uv)
        {
            uv -= 0.5;
            uv.x *= 1.7320508075688772;
            float d = max(abs(uv.x) * 0.5 + abs(uv.y), abs(uv.y));
            return step(d, _ShapeSize);
        }

        // Generate a diamond shape
        float diamond(float2 uv)
        {
            uv -= 0.5;
            float d = abs(uv.x) + abs(uv.y);
            return step(d, _ShapeSize);
        }

        // Surface shader logic
        void surf(Input IN, inout SurfaceOutput o)
        {
            float2 uv = IN.uv_TopTexture;

            float time = _Time.y;//* (_AnimationSpeed *0.1);

            float colorTime = time * _ColorChangeSpeed;

            // Rotate UVs
            float angle = time * (_RotationSpeed);
            uv = rotateUV(uv, angle);

            // Generate psychedelic colors
            float3 psychedelicColor = float3(sin(colorTime), cos(colorTime), sin(colorTime * 0.5));

            // Choose shape type
            float dist = 0.0;
            if (_ShapeType == 0)
            {
                dist = hexagon(uv);
            }
            else
            {
                dist = diamond(uv);
            }

            float shapeTime = time * _ShapeJitterSpeed;

            // Add additional shapes for chaos
            float3 finalColor = float3(0, 0, 0);
            for (int i = 0; i < _NumShapes; ++i)
            {
                float2 offset = float2(sin(i + shapeTime) * 0.5, cos(i + shapeTime) * 0.5);
                float2 newUV = uv + offset;
                newUV = frac(newUV);
                if (_ShapeType == 0)
                {
                    dist = hexagon(newUV);
                }
                else
                {
                    dist = diamond(newUV);
                }
                finalColor += psychedelicColor * dist * 0.5;
            }

            // Background texture
            float3 backgroundColor = tex2D(_BackgroundTexture, IN.uv_BackgroundTexture).rgb * _BackgroundColor.rgb;

            // Combine background and shape colors
            finalColor = lerp(backgroundColor, finalColor, dist);

            // Apply top texture
            float2 topTextureUV = uv * _TextureScale;
            float3 topTextureColor = tex2D(_TopTexture, topTextureUV).rgb;

            // Final color
            o.Albedo = finalColor + topTextureColor * 0.5;
            o.Alpha = 1.0;
        }
        ENDCG
    }

    Fallback "Diffuse"
}
