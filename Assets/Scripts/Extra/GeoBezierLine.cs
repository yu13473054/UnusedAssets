using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
[RequireComponent(typeof(LineRenderer))]

public class GeoBezierLine : MonoBehaviour
{
    public Vector3[]    points;
    public int          smooth;

    Bezier              _bezier;
	LineRenderer	    _renderer;

    void Awake()
    {
		_renderer = GetComponent<LineRenderer>();
        _bezier = new Bezier( points[0], points[1], points[2], points[3] );
    }

    public void Refresh()
    {        
        if( smooth <= 0 )
            smooth = 8;

		_renderer.positionCount = smooth;
		for( int i = 0; i < smooth; i++ )
		{
            _bezier.Set( points[0], points[1], points[2], points[3] );
			_renderer.SetPosition( i, _bezier.Lerp( (float)i / (float)( smooth - 1 ) ) );
		}
    }

    void Update()
    {
        Refresh();
    }
}
