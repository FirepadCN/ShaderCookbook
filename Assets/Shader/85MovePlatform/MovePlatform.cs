using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class MovePlatform : MonoBehaviour
{
    public Texture MainTx;
    public Texture Noise;
    public Transform CenterTrans;
    public Color CenterColor;
    private Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().sharedMaterial;

        mat.SetColor("_CenterColor", CenterColor);
        mat.SetTexture("_MainTex", MainTx);
        mat.SetTexture("_Noise", Noise);
    }
	
	// Update is called once per frame
	void Update () {
	    mat.SetTexture("_MainTex", MainTx);

        mat.SetVector("_CenterPos", CenterTrans.position);
	}
}
