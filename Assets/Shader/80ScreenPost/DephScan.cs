using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DephScan : PostEffectsBase
{
    [Range(0.0f,1.0f)]
    public float StartValue;
    public float Width;
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
            Material.SetFloat("_StartValue", StartValue);
            Material.SetFloat("_Width", Width);
            Material.SetColor("_Color", Color);

            Graphics.Blit(src, dest, Material);
        }
        else
            Graphics.Blit(src, dest);
    }

}
