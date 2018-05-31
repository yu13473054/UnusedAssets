using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UIScrollbar : Scrollbar {
    public UIMod uiMod;
    public int controlID = 0;
    public int audioId = 0; // 迅速在声音表里预留一个ID，填到这里成默认值

    protected override void Awake()
    {
        base.Awake();
        onValueChanged.AddListener(OnValueChange);
    }

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

    private void OnValueChange(float currValue)
    {
        if (uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLBAR_ONVALUECHANGE, controlID, currValue);
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        base.OnPointerDown(eventData);

        if (this.IsActive() || this.IsInteractable() || eventData.button == PointerEventData.InputButton.Left ||
            uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLBAR_PRESS, controlID, 0);
        // 播放按钮音效
        if (audioId > 0)
        {
            AudioManager.instance.Play(audioId);
        }
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        base.OnPointerUp(eventData);
        if (this.IsActive() || this.IsInteractable() || eventData.button == PointerEventData.InputButton.Left ||
            uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLBAR_PRESS, controlID, 1);
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        onValueChanged.RemoveListener(OnValueChange);
    }

#if UNITY_EDITOR
    protected override void OnValidate()
    {
        base.OnValidate();
        if (handleRect)
        {
            handleRect.offsetMin=Vector2.zero;
            handleRect.offsetMax=Vector2.zero;
        }
    }
#endif
}
