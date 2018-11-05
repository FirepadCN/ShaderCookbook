using UnityEngine;
using System.Collections;
using UnityEngine.SocialPlatforms;
using System.Security.Cryptography;

public class EdgeCheck : PostEffectsBase
{
    public enum ScanDir
    {
        Vertical,
        Horizontal
    }

    public Shader shader;
    private Material edgeCheckMat;
    public Material mat
    {
        get
        {
            if (edgeCheckMat == null)
            {
                edgeCheckMat = CheckShaderAndCreateMaterial(shader, edgeCheckMat);
            }
            return edgeCheckMat;
        }
    }
    [Range(0f, 1f)]
    public float edgeOnly = 0.1f;

    public ScanDir Dir = ScanDir.Horizontal;
    public Color edgeColor = Color.black;
    [Range(0.01f,0.5f)]
    public float edgeWidth = 0.01f;
    public float edgeSpeed = 1f;


    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (mat != null)
        {
            mat.SetFloat("_EdgeValue", edgeOnly);
            mat.SetColor("_EdgeColor", edgeColor);
            mat.SetFloat("_EdgeWidth", edgeWidth);
            mat.SetFloat("_Speed", edgeSpeed);
            mat.SetFloat("_ScanDir", Dir== ScanDir.Vertical?1.0f:0.0f);
            Graphics.Blit(src, dest, mat);

        }
        else
        {
            Graphics.Blit(src, dest);
        }

    }


}