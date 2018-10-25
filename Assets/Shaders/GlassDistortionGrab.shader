Shader "Hidden/BlendModes/GlassDistortion/Grab"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionTex ("Distortion Texture", 2D) = "bump" {}
        _Distortion ("Distortion Power", range (0,9999)) = 1000
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType" = "Opaque" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha 
        LOD 100

        // Perform a grab pass before the main pass to store the pixels drawn before the object.
        GrabPass { }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            // Add directive to compile variants of this shader for each blend mode.
            #pragma multi_compile BLENDMODES_MODE_DARKEN BLENDMODES_MODE_MULTIPLY BLENDMODES_MODE_COLORBURN BLENDMODES_MODE_LINEARBURN BLENDMODES_MODE_DARKERCOLOR BLENDMODES_MODE_LIGHTEN BLENDMODES_MODE_SCREEN BLENDMODES_MODE_COLORDODGE BLENDMODES_MODE_LINEARDODGE BLENDMODES_MODE_LIGHTERCOLOR BLENDMODES_MODE_OVERLAY BLENDMODES_MODE_SOFTLIGHT BLENDMODES_MODE_HARDLIGHT BLENDMODES_MODE_VIVIDLIGHT BLENDMODES_MODE_LINEARLIGHT BLENDMODES_MODE_PINLIGHT BLENDMODES_MODE_HARDMIX BLENDMODES_MODE_DIFFERENCE BLENDMODES_MODE_EXCLUSION BLENDMODES_MODE_SUBTRACT BLENDMODES_MODE_DIVIDE BLENDMODES_MODE_HUE BLENDMODES_MODE_SATURATION BLENDMODES_MODE_COLOR BLENDMODES_MODE_LUMINOSITY
            
            #include "UnityCG.cginc"
            // Include blend modes shader APIs.
            #include "Assets/BlendModes/Shaders/BlendModesCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 distuv : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
                // Declare required vertex output properties for the grab shader variant.
                // Notice we use `3` index here, because indexes 0-2 are already occupied by the previous properties.
                BLENDMODES_GRAB_POSITION(3)
            };

            sampler2D _MainTex;
            sampler2D _DistortionTex;
            float4 _MainTex_ST;
            float4 _DistortionTex_ST;
            float4 _GrabTexture_TexelSize;
            float _Distortion;
            // Declare required samplers for the grab shader variant.
            BLENDMODES_GRAB_TEXTURE_SAMPLER
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Perform required vertex computations for the grab shader variant.
                // First argument is the vertex output variable and the second one is the vertex position in camera space.
                // Make sure to always provide vertex position in camera space (after executing UnityObjectToClipPos).
                BLENDMODES_COMPUTE_GRAB_POSITION(o, o.vertex)
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.distuv = TRANSFORM_TEX(v.uv, _DistortionTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                half2 bump = UnpackNormal(tex2D(_DistortionTex, i.distuv)).rg; 
                float2 offset = bump * _Distortion * _GrabTexture_TexelSize.xy;
                i.BLENDMODES_GrabPosition.xy = offset * i.BLENDMODES_GrabPosition.z + i.BLENDMODES_GrabPosition.xy;

                fixed4 col = tex2D(_MainTex, i.uv);
                // Perform required pixel computations for the grab shader variant.
                // First argument is the color of the foreground layer (texture of the object in this case) and the second one is the vertex output variable.
                BLENDMODES_BLEND_PIXEL_GRAB(col, i)
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
