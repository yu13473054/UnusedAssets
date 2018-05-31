using UnityEngine;
using System.Collections;
using UnityEngine.UI;
#if UNITY_EDITOR
using UnityEditor;
#endif
[RequireComponent( typeof( PolygonCollider2D ) )]
public class UIPolygonRaycast : UIRaycast,ICanvasRaycastFilter
{
    private PolygonCollider2D _polygon = null;

    protected override void Awake()
    {
        base.Awake();
        _polygon = GetComponent<PolygonCollider2D>();
    }

    public bool IsRaycastLocationValid(Vector2 screenPoint, Camera eventCamera)
    {
        Vector3 worldPos;
        if (!RectTransformUtility.ScreenPointToWorldPointInRectangle(rectTransform, screenPoint, eventCamera, out worldPos))
        {
            return false;
        }
        return _polygon.OverlapPoint(worldPos);
    }

#if UNITY_EDITOR
    protected override void Reset()
    {
        base.Reset();
        transform.localPosition = Vector3.zero;
        float w = (rectTransform.sizeDelta.x * 0.5f) + 0.1f;
        float h = (rectTransform.sizeDelta.y * 0.5f) + 0.1f;
        _polygon.points = new Vector2[]
        {
            new Vector2(-50,-50),
            new Vector2(50,-50),
            new Vector2(50,50),
            new Vector2(-50,50)
        };
    }
#endif
}
