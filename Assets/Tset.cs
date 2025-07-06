using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Tset : MonoBehaviour
{
    private Vector4 v = new Vector4(0, 0, 1, 1);
    private void Start()
    {
        var s = MatrixUtility.RotationMatrix_Y(MatrixUtility.GetRadians(90)) * v;
        Debug.Log(s);
    }
}