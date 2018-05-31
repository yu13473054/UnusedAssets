using UnityEngine;
using System.Collections;

//[ExecuteInEditMode]
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
public class GeoPlane : MonoBehaviour 
{
	public Vector3[] 			vertices;
	public Vector2[] 			uv;
	public int[] 				triangles;

	MeshFilter					_meshFilter;
	MeshRenderer				_meshRender;

	void Awake()
	{
		_meshFilter = GetComponent<MeshFilter>();
		if( _meshFilter == null )
			_meshFilter = gameObject.AddComponent<MeshFilter>();

		_meshRender = GetComponent<MeshRenderer>();
		if( _meshRender == null )
			_meshRender = gameObject.AddComponent<MeshRenderer>();
	}

    void Start()
    {
        Set();
    }

    public void Set()
    {
        Set(vertices, uv, triangles);
    }

	public void Set( Vector3[] newVertices, Vector2[] newUV, int[] newTriangles )
	{
		if( _meshFilter.sharedMesh == null )
			_meshFilter.sharedMesh = new Mesh();

		_meshFilter.sharedMesh.Clear();
		vertices = newVertices;
		uv = newUV;
		triangles = newTriangles;

		_meshFilter.sharedMesh.vertices = newVertices;
		_meshFilter.sharedMesh.uv = newUV;
		_meshFilter.sharedMesh.triangles = newTriangles;
	}

	public void SetColor( Color color )
	{
		_meshRender.material.color = color;
	}

    //void OnDestroy()
    //{
    //    DestroyImmediate( _meshRender.material );
    //}

//#if UNITY_EDITOR
//    void Update()
//    {
//        Set( vertices, uv, triangles );
//    }
//#endif
}
