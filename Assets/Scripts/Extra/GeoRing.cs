using UnityEngine;
using System.Collections.Generic;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(LineRenderer))]
public class GeoRing : MonoBehaviour {
	
	public int pointCount	= 10;
	public float radius		= 10f;

	float angle;
	List<Vector3>	_point  	= new List<Vector3>();
	LineRenderer	_renderer;

	void Start ()
	{
		_renderer = GetComponent<LineRenderer>();
        _renderer.useWorldSpace = false;

        Calculation_point();
	}
	
	void Calculation_point()
	{
		_renderer.positionCount = pointCount + 1;
		angle = 360f / pointCount;
        _point.Clear();
		for(int i = 1;i < pointCount + 1; i++ )
		{
			Quaternion q = Quaternion.Euler( 0, ( i - 1 ) * angle, 0 );
			Vector3 v = q * Vector3.forward * radius;
			_point.Add( v );
		}
	}

	void Drow_point()
	{
		for( int i = 0; i < _point.Count; i++ )
		{
			_renderer.SetPosition( i, _point[i] );
		}
		if ( _point.Count >  0)
			_renderer.SetPosition( pointCount, _point[0]);
	}

	void Update () 
	{
        // 计算，正式包注释
#if UNITY_EDITOR
		Calculation_point();
#endif
        // 刷新
		Drow_point();
	}
}
