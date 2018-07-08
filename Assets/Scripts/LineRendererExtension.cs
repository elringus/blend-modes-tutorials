using UnityEngine;
using BlendModes;

[ExtendedComponent(typeof(LineRenderer))]
public class LineRendererExtension : ComponentExtension
{
    public override string[] GetSupportedShaderFamilies ()
    {
        return new[] {
                "ParticlesAdditive"
            };
    }

    public override ShaderProperty[] GetDefaultShaderProperties ()
    {
        return new[] {
            new ShaderProperty("_MainTex", ShaderPropertyType.Texture, Texture2D.whiteTexture),
            new ShaderProperty("_TintColor", ShaderPropertyType.Color, Color.white),
            new ShaderProperty("_InvFade", ShaderPropertyType.Float, 1f)
        };
    }

    public override Material[] GetRenderMaterials ()
    {
        return GetExtendedComponent<LineRenderer>().sharedMaterials;
    }

    public override void SetRenderMaterials (Material[] materials)
    {
        GetExtendedComponent<LineRenderer>().sharedMaterials = materials;
    }

    public override void OnEffectDisabled ()
    {
        if (!IsExtendedComponentValid) return;
        GetExtendedComponent<LineRenderer>().sharedMaterials = new[] { new Material(Shader.Find("Particles/Additive")) };
    }
}
