using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UISlider : Slider
{
    public UIMod uiMod;
    public int controlID = 0;
    public int audioId = 0; // 迅速在声音表里预留一个ID，填到这里成默认值

    protected override void Start()
    {
        base.Start();
#if UNITY_EDITOR
        // 挂载uiMod
        if (uiMod == null)
        {
            uiMod = gameObject.GetComponentInParent<UIMod>();
        }
#endif
    }

    private bool CanDrag(PointerEventData eventData)
    {
        return this.IsActive() && this.IsInteractable() && eventData.button == PointerEventData.InputButton.Left;
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        base.OnPointerDown(eventData);
        if (!CanDrag(eventData) || uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISLIDER_PRESS, controlID, 0);
        // 播放按钮音效
        if (audioId > 0)
        {
            AudioManager.instance.Play(audioId);
        }
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        base.OnPointerUp(eventData);
        if (eventData.button != PointerEventData.InputButton.Left || uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISLIDER_PRESS, controlID, 1);
    }


    public override void OnDrag(PointerEventData eventData)
    {
        base.OnDrag(eventData);
        if (!CanDrag(eventData) || uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISLIDER_DRAG, controlID, 1);
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();
        if (fillRect)
        {
            fillRect.offsetMin = Vector2.zero;
            fillRect.offsetMax = Vector2.zero;
        }
    }
#endif
}
