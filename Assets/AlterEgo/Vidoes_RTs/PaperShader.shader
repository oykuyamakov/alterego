Shader "Unlit/RippedPaperAllEdges"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeDepth ("Edge Depth", Range(0.1, 0.5)) = 0.2
        _EdgeNoise ("Edge Noise Intensity", Range(0.0, 1.0)) = 0.5
        _SelectedEdge ("Selected Edge (0=Left, 1=Right, 2=Top, 3=Bottom)", Range(0, 3)) = 0
        _EdgeBoost ("Selected Edge Boost", Range(1.0, 3.0)) = 2.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _EdgeDepth;
            float _EdgeNoise;
            float _SelectedEdge; // 0: Left, 1: Right, 2: Top, 3: Bottom
            float _EdgeBoost;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Random noise function
            float rand(float2 co)
            {
                return frac(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
            }

            // Calculate transparency for one edge
            float computeTornEdge(float2 uv, float edgeValue, float edgeNoise, float edgeDepth, bool isSelected)
            {
                // Add random noise
                float noise = rand(uv * 50.0) * edgeNoise;

                // Increase depth for selected edge
                if (isSelected)
                    edgeDepth *= _EdgeBoost;

                // Smooth fade
                return smoothstep(0.0, edgeDepth + noise, edgeValue);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate torn effect for each edge
                float left = computeTornEdge(i.uv, i.uv.x, _EdgeNoise, _EdgeDepth, _SelectedEdge == 0);
                float right = computeTornEdge(i.uv, 1.0 - i.uv.x, _EdgeNoise, _EdgeDepth, _SelectedEdge == 1);
                float top = computeTornEdge(i.uv, i.uv.y, _EdgeNoise, _EdgeDepth, _SelectedEdge == 2);
                float bottom = computeTornEdge(i.uv, 1.0 - i.uv.y, _EdgeNoise, _EdgeDepth, _SelectedEdge == 3);

                // Combine effects (use min for transparency overlap)
                float tornEdge = min(min(left, right), min(top, bottom));

                // Sample texture
                fixed4 color = tex2D(_MainTex, i.uv);

                // Apply alpha transparency
                color.a *= tornEdge;

                return color;
            }
            ENDCG
        }
    }
    FallBack "Unlit/Transparent"
}
