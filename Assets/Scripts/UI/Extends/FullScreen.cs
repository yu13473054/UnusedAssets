using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FullScreen : MonoBehaviour
{
    [SerializeField] private bool _keepAspect = true;
    //手动设置基础宽高, 否则按资源的原始宽高来计算
    [SerializeField] private bool _manualSet = false;
    [SerializeField] private int _manualWidth = 1;
    [SerializeField] private int _manualHeight = 1;
    [SerializeField]
    private int _offsetWidth = 0;
    [SerializeField]
    private int _offsetHeight = 0;

//    void Awake()
//    {
//        Adjust();
//    }

    void Start()
    {
        Adjust();
    }

#if UNITY_EDITOR
    void Update()
    {
        if (Application.isPlaying) return;
        Adjust();
    }
#endif

    public void Adjust()
    {
        RectTransform wid = GetComponent<RectTransform>();
        if (wid != null)
        {
#if UNITY_EDITOR
            Vector2 screenSize = Application.isPlaying ? ((RectTransform)UIManager.instance.GetCanvas().transform).sizeDelta : ((RectTransform)wid.GetComponentInParent<Canvas>().rootCanvas.transform).sizeDelta;
#else
            Vector2 screenSize = ((RectTransform)UIManager.instance.GetCanvas().transform).sizeDelta;
#endif
            if (_keepAspect)
            {
                Vector2 originSize = _manualSet ? new Vector2(_manualWidth, _manualHeight) : wid.sizeDelta;
                Vector2 ret = originSize;

                int tw = (int)originSize.x;
                int th = (int)originSize.y;

                int sw = (int)screenSize.x;
                int sh = (int)screenSize.y;

                float scale_w = sw / (tw * 1.0f);
                float scale_h = sh / (th * 1.0f);

                if (scale_w > scale_h)
                {
                    ret.x = sw;
                    ret.y = Mathf.CeilToInt(scale_w * th);
                }
                else
                {
                    ret.x = Mathf.CeilToInt(scale_h * tw);
                    ret.y = sh;
                }
                ret.x += _offsetWidth;
                ret.y += _offsetHeight;

                wid.sizeDelta = ret;
            }
            else
            {
                wid.sizeDelta = screenSize;
            }
        }
    }
}
