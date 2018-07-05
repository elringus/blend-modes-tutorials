using BlendModes;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExtendedComponent(typeof(MeshRenderer))]
public class GlassMeshExtension : MeshRendererExtension
{
    public override List<ShaderProperty> DefaultShaderProperties
    {
        get
        {
            return new List<ShaderProperty> {
                    new ShaderProperty("_MainTex", ShaderPropertyType.Texture, Texture2D.whiteTexture),
                    new ShaderProperty("_DistortionTex", ShaderPropertyType.Texture, Texture2D.whiteTexture),
                    new ShaderProperty("_Distortion", ShaderPropertyType.Float, 10)
                };
        }
    }
    public override List<string> GetSupportedShaderFamilies ()
    {
        var families = base.GetSupportedShaderFamilies();
        families.Add("GlassDistortion");
        return families;
    }
}
