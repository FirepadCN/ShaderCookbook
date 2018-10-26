using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TxPostEffect : PostEffectsBase
{

    public Texture Other;
    public Color Color;
    public Shader shader;
    private Material material;

    public Material Material
    {
        get
        {
            material = CheckShaderAndCreateMaterial(shader, material);
            return material;
        }
    }


    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
            if (Material != null)
            {
                Material.SetTexture("_OtherTex", Other);
                Material.SetColor("_Color", Color);

                Graphics.Blit(src,dest, Material);
            }
            else
                Graphics.Blit(src, dest);

    }
}
