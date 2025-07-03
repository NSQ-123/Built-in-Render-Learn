using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class MatrixUtility
{

    /// <summary>
    /// 获取弧度
    /// </summary>
    /// <param name="degrees"></param>
    /// <returns></returns>
    public static float GetRadians(float degrees)
    {
        return degrees * Mathf.Deg2Rad;
    }
    
    /// <summary>
    /// 单位矩阵
    /// </summary>
    /// 主对角线（m00, m11, m22, m33）为1，表示各轴的缩放系数为1，不发生缩放
    /// 其余元素为0，表示没有旋转、平移或错切
    /// 任何向量或矩阵与单位矩阵相乘，结果都是自身
    public static Matrix4x4 Identity = new Matrix4x4
    {
        m00 = 1, m01 = 0, m02 = 0, m03 = 0,
        m10 = 0, m11 = 1, m12 = 0, m13 = 0,
        m20 = 0, m21 = 0, m22 = 1, m23 = 0,
        m30 = 0, m31 = 0, m32 = 0, m33 = 1
    };

    /// <summary>
    /// 旋转矩阵X
    /// </summary>
    /// <param name="theta"></param>
    /// <returns></returns>
    public static Matrix4x4 RotationMatrix_X(float theta)
    {
        var cos = Mathf.Cos(theta);
        var sin = Mathf.Sin(theta);
        return new Matrix4x4
        {
            m00 = 1, m01 = 0,   m02 = 0,    m03 = 0,
            m10 = 0, m11 = cos, m12 = -sin, m13 = 0,
            m20 = 0, m21 = sin, m22 = cos,  m23 = 0,
            m30 = 0, m31 = 0,   m32 = 0,    m33 = 1
        };
    }

    /// <summary>
    /// 旋转矩阵Y
    /// </summary>
    /// <param name="theta"></param>
    /// <returns></returns>
    public static Matrix4x4 RotationMatrix_Y(float theta)
    {
        var cos = Mathf.Cos(theta);
        var sin = Mathf.Sin(theta);
        return new Matrix4x4
        {
            m00 = cos,  m01 = 0, m02 = sin, m03 = 0,
            m10 = 0,    m11 = 1, m12 = 0,   m13 = 0,
            m20 = -sin, m21 = 0, m22 = cos, m23 = 0,
            m30 = 0,    m31 = 0, m32 = 0,   m33 = 1
        };
    }

    /// <summary>
    /// 旋转矩阵Z
    /// </summary>
    /// <param name="theta">弧度：如果传入0，则矩阵就变为单位矩阵</param>
    /// <returns></returns>
    public static Matrix4x4 RotationMatrix_Z(float theta)
    {
        var cos = Mathf.Cos(theta);
        var sin = Mathf.Sin(theta);
        return new Matrix4x4
        {
            m00 = cos,  m01 = -sin, m02 = 0,   m03 = 0,
            m10 = sin,  m11 = cos,  m12 = 0,   m13 = 0,
            m20 = 0,    m21 = 0,    m22 = 1,   m23 = 0,
            m30 = 0,    m31 = 0,    m32 = 0,   m33 = 1
        };
    }
    
    /// <summary>
    /// 旋转ZXY(Unity的顺序）
    /// </summary>
    /// <param name="z">弧度</param>
    /// <param name="x">弧度</param>
    /// <param name="y">弧度</param>
    /// <returns></returns>
    public static Matrix4x4 RotationZXY(float z, float x, float y)
    {
        // 注意乘法顺序：先Z，后X，最后Y
        return RotationMatrix_Y(y) * RotationMatrix_X(x) * RotationMatrix_Z(z);
    }
    
    /// <summary>
    /// 平移矩阵
    /// </summary>
    /// <param name="tx"></param>
    /// <param name="ty"></param>
    /// <param name="tz"></param>
    /// <returns></returns>
    public static Matrix4x4 TranslationMatrix(float tx, float ty, float tz)
    {
        return new Matrix4x4
        {
            m00 = 1, m01 = 0, m02 = 0, m03 = tx,
            m10 = 0, m11 = 1, m12 = 0, m13 = ty,
            m20 = 0, m21 = 0, m22 = 1, m23 = tz,
            m30 = 0, m31 = 0, m32 = 0, m33 = 1
        };
    }
    
    
    
    /*
     * 设 M 为4x4矩阵，v为列向量
       结果 v' = M * v
       向量 4 X 1
       矩阵 4 X 4
       结果 4 X 1
       口诀:
       向量和矩阵相乘：前者的“列数”等于后者的“行数”才能相乘，结果是“外面的数”。
       记忆：“行×列” × “行×列” → “行×列”
       
       v'.x = m00 * x + m01 * y + m02 * z + m03 * w;
       v'.y = m10 * x + m11 * y + m12 * z + m13 * w;
       v'.z = m20 * x + m21 * y + m22 * z + m23 * w;
       v'.w = m30 * x + m31 * y + m32 * z + m33 * w;
     */
}