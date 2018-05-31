using UnityEngine;
using System.Collections;
using LuaInterface;

public class LobbyCamera : Camera2D
{
    public Transform trail;
    // 分层拖动
    public Transform[] layers;
    public Vector2[] layersMoveRatios;
    public Vector2[] layersScaleRatios;

    private Vector3[] _layerOriginPos;

    protected override void Start()
    {
        base.Start();
        _layerOriginPos = new Vector3[layers.Length];
        for (int i = 0; i < layers.Length; i++)
        {
            _layerOriginPos[i] = layers[i].localPosition;
        }
    }

    protected override void OnDragStart(Vector2 pos)
    {
        if (trail != null)
            trail.transform.position = pos;
    }

    protected override void OnDrag(Vector2 pos)
    {
        if (trail != null)
            trail.transform.position = pos;
    }

    protected override void OnDragEnd()
    {
    }

    protected override void OnClick(Transform obj)
    {
        if (obj.CompareTag("ClickAble"))
        {
            if (uiMod == null) return;
            uiMod.OnEvent(UIEVENT.CAMERA_CLICK, -1000, obj.name);
        }
    }

    protected override void OnPress(Transform obj)
    {
        if (obj.CompareTag("ClickAble"))
        {
            if (uiMod == null) return;
            uiMod.OnEvent(UIEVENT.CAMERA_PRESS,-1000, obj.name);
        }
    }

    protected override void Move(float offsetX, float offsetY)
    {
        base.Move(offsetX, offsetY);
        RefreshLayersMove();
    }

    // 控制每层的移动
    void RefreshLayersMove()
    {
        Vector3 offset = _Camera.transform.position;
        for (int i = 0; i < layersMoveRatios.Length; i++)
        {
            float z = _layerOriginPos[i].z;
            layers[i].localPosition = new Vector3(_layerOriginPos[i].x + layersMoveRatios[i].x * offset.x, _layerOriginPos[i].y + layersMoveRatios[i].y * offset.y, z);
        }
    }

    protected override void Zoom(float length, Vector3 focus)
    {
        base.Zoom(length, focus);
        RefreshLayersSize();
    }

    protected override void ZoomMove(float length, Vector3 focus, Vector3 direction)
    {
        base.ZoomMove(length, focus, direction);
        RefreshLayersSize();
    }

    //控制每层的缩放
    void RefreshLayersSize()
    {
        for (int i = 0; i < layersScaleRatios.Length; i++)
        {
            layers[i].localScale = new Vector3(1 + (_Camera.orthographicSize / _initOrthographicSize - 1) * layersScaleRatios[i].x, 1 + (_Camera.orthographicSize / _initOrthographicSize - 1) * layersScaleRatios[i].y, 1);
        }
    }

    protected override void OnTween()
    {
        base.OnTween();
        RefreshLayersMove();
        RefreshLayersSize();
    }
}
