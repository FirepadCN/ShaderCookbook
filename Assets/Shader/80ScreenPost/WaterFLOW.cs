using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterFLOW : PostEffectsBase {

    public float Height;
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
            Material.SetFloat("_WaterHeight", Height);
            Material.SetColor("_WaterColor", Color);

            Graphics.Blit(src, dest, Material);
        }
        else
            Graphics.Blit(src, dest);

    }
}
