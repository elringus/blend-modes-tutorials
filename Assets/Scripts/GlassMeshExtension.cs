using BlendModes;
using System.Linq;
using UnityEngine;

[ExtendedComponent(typeof(MeshRenderer))]
public class GlassMeshExtension : MeshRendererExtension
{
    public override ShaderProperty[] GetDefaultShaderProperties ()
    {
        return base.GetDefaultShaderProperties().Concat(new[] {
            new ShaderProperty("_DistortionTex", ShaderPropertyType.Texture, Texture2D.whiteTexture),
            new ShaderProperty("_Distortion", ShaderPropertyType.Float, 10)
        }).ToArray();
    }

    public override string[] GetSupportedShaderFamilies ()
    {
        return base.GetSupportedShaderFamilies()
            .Concat(new[] { "GlassDistortion" }).ToArray();
    }
}
