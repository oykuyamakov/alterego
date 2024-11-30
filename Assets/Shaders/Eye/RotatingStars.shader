Shader "Custom/URP/UnlitPsychedelicGeometricShapes"
{
    Properties
    {
        _ShapeColor ("Shape Color", Color) = (1, 0, 0, 1) // Default Red
        _RotationSpeed ("Rotation Speed", Range(0, 10)) = 1.0 // Rotation speed
        _ShapeSize ("Shape Size", Range(0.1, 1.0)) = 0.5 // Size of shapes
        _NumShapes ("Number of Shapes", Range(1, 10)) = 5 // Number of shapes to render
        _AnimationSpeed ("Animation Speed", Range(0.1, 5.0)) = 1.0 // Animation speed for chaos
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            // Exposed properties
            float4 _ShapeColor;
            float _RotationSpeed;
            float _ShapeSize;
            float _NumShapes;
            float _AnimationSpeed;

            // Struct to hold input vertex data
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Struct for passing data between stages
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Vertex function: Transform object space to clip space
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);  // Unity’s built-in function
                o.uv = v.uv;
                return o;
            }

            // Function to generate rotated UVs
            float2 rotateUV(float2 uv, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float2x2 rotationMatrix = float2x2(c, -s, s, c);
                return mul(rotationMatrix, uv - 0.5) + 0.5; // Rotate around the center (0.5, 0.5)
            }

            // Create psychedelic colors based on time
            float3 getPsychedelicColor(float time)
            {
                return float3(sin(time), cos(time), sin(time * 0.5)); // Color oscillation
            }

            // Main fragment shader function
            float4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Animate rotation and change colors over time
                float time = _Time.y * _AnimationSpeed;  // Use built-in _Time variable from Unity

                // Create a rotation effect based on time and rotation speed
                float angle = time * _RotationSpeed; // Rotation speed based on time
                uv = rotateUV(uv, angle);

                // Generate psychedelic color shifting
                float3 psychedelicColor = getPsychedelicColor(time);

                // Generate shapes
                float dist = length(uv - float2(0.5, 0.5)); // Distance from the center
                float size = _ShapeSize * 0.5; // Scale based on _ShapeSize
                dist = step(dist, size); // Make a shape (circle-like)
                
                // Combine shape with psychedelic colors
                float4 finalColor = float4(psychedelicColor, 1.0) * dist;

                // Create chaos by rendering multiple shapes with offset positions
                for (int i = 0; i < _NumShapes; ++i)
                {
                    // Create random offsets for each shape based on the time
                    float2 offset = float2(sin(i + time) * 0.5, cos(i + time) * 0.5);
                    float2 newUV = uv + offset;
                    newUV = frac(newUV); // Wrap UVs between 0 and 1
                    dist = length(newUV - float2(0.5, 0.5));
                    dist = step(dist, size);
                    finalColor += float4(psychedelicColor, 1.0) * dist * 0.5; // Add to the final color
                }

                return finalColor; // Return the final color with psychedelic effects
            }

            ENDCG
        }
    }

    Fallback "Unlit/Color"
}
