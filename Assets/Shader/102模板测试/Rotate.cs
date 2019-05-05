using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class Rotate : MonoBehaviour {

    float timer;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		timer=Time.deltaTime;
        transform.RotateAround(Vector3.zero, Vector3.up,timer*20.0f);
		
	}
}
