Shader "Custom/PsychedelicUnlit"
{
    Properties
    {
        // Color properties
        _Color1 ("Color 1", Color) = (1, 0, 0, 1)
        _Color2 ("Color 2", Color) = (0, 0, 1, 1)

        // Texture properties
        _ShapeTexture ("Shape Texture", 2D) = "white" { }
        _BackgroundTexture ("Background Texture", 2D) = "white" { }

        // Control properties
        _ShapeSize ("Shape Size", Float) = 0.1
        _NumShapes ("Number of Shapes", Float) = 5
        _RotationSpeed ("Rotation Speed", Float) = 0.5
        _ColorChangeSpeed ("Color Change Speed", Float) = 1.0
        _ShapeJitterSpeed ("Shape Jitter Speed", Float) = 0.1
        _TextureScale ("Texture Scale", Float) = 1.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Properties
            float _ShapeSize;
            float _NumShapes;
            float _RotationSpeed;
            float _ColorChangeSpeed;
            float _ShapeJitterSpeed;
            float _TextureScale;

            float4 _Color1;
            float4 _Color2;

            sampler2D _ShapeTexture;
            sampler2D _BackgroundTexture;

            // Built-in _Time variable is automatically provided by Unity
            // Don't redefine _Time, use unity_Time.x, unity_Time.y, etc. for time-based operations

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Vertex Shader
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Apply jitter effect to UVs based on time
                float jitter = sin(v.vertex.x * _ShapeJitterSpeed + _Time.x) * 0.1;
                o.uv = v.uv + jitter;

                // Apply rotation effect based on time
                float angle = _Time.x * _RotationSpeed;
                float2 rotatedUV = float2(
                    cos(angle) * o.uv.x - sin(angle) * o.uv.y,
                    sin(angle) * o.uv.x + cos(angle) * o.uv.y
                );

                o.uv = rotatedUV;

                o.uv *= _TextureScale;  // Scale the texture UV
                return o;
            }

            // Fragment Shader
            half4 frag(v2f i) : SV_Target
            {
                // Smooth color change effect based on time
                float colorLerp = (sin(_Time.x * _ColorChangeSpeed) + 1.0) * 0.5;
                half4 color = lerp(_Color1, _Color2, colorLerp);

                // Sample the background and shape textures
                half4 shapeTex = tex2D(_ShapeTexture, i.uv);
                half4 backgroundTex = tex2D(_BackgroundTexture, i.uv);

                // Combine background and shape textures
                half4 finalColor = lerp(backgroundTex, shapeTex, shapeTex.a);

                // Apply the color change effect to the final color
                finalColor *= color;

                // Apply shape size scaling
                finalColor *= _ShapeSize;

                return finalColor;
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
