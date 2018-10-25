Shader "BlendModesTutorial/MeshMultiTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OverlayTex1("Overlay Texture 1", 2D) = "white" {}
        _OverlayTex2("Overlay Texture 2", 2D) = "white" {}
        _OverlayTex3("Overlay Texture 3", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "RenderType" = "Opaque" }

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha 
        LOD 100

        GrabPass { }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Assets/BlendModes/Shaders/BlendModesCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                BLENDMODES_GRAB_POSITION(2)
            };

            sampler2D _MainTex, _OverlayTex1, _OverlayTex2, _OverlayTex3;
            float4 _MainTex_ST;
            float4 _GrabTexture_TexelSize;
            BLENDMODES_GRAB_TEXTURE_SAMPLER
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                BLENDMODES_COMPUTE_GRAB_POSITION(o, o.vertex)
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // Content of the background layer.
                half4 grabColor = tex2Dproj(_GrabTexture, i.BLENDMODES_GrabPosition);

                // Content of the main texture.
                fixed4 mainColor = tex2D(_MainTex, i.uv);
               
                // Content of the overlay textures.
                fixed4 overlayColor1 = tex2D(_OverlayTex1, i.uv);
                fixed4 overlayColor2 = tex2D(_OverlayTex2, i.uv);
                fixed4 overlayColor3 = tex2D(_OverlayTex3, i.uv);

                // Resulting color.
                fixed4 color;

                // Blending operations. Find all available blend functions at: ../BlendModes/Shaders/BlendFunctions.cginc
                color.rgb = Darken(grabColor.rgb, mainColor.rgb);
                color.rgb = Overlay(color.rgb, overlayColor1.rgb);
                color.rgb = Multiply(color.rgb, overlayColor2.rgb);
                color.rgb = Screen(color.rgb, overlayColor3.rgb);

                color.a = mainColor.a;
                return color;
            }
            ENDCG
        }
    }
}
