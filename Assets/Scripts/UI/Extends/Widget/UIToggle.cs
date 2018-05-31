using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UIToggle : Toggle
{
    public UIMod uiMod;
    public int controlID = 0;
    public int audioId = 0; // 迅速在声音表里预留一个ID，填到这里成默认值

    private bool _lastValue;

    protected override void Awake()
    {
        base.Awake();
        onValueChanged.AddListener(OnValueChange);
    }

    private void OnValueChange(bool value)
    {
        if (uiMod == null) return;
        if (_lastValue == value) return;
        _lastValue = value;
        uiMod.OnEvent(UIEVENT.UITOGGLE_ONVALUECHANGE, controlID, value);
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

    public override void OnPointerClick(PointerEventData eventData)
    {
        base.OnPointerClick(eventData);

        if (!IsInteractable() || eventData.button != PointerEventData.InputButton.Left || uiMod == null)return;
        uiMod.OnEvent(UIEVENT.UITOGGLE_CLICK, controlID, 0);
        // 播放按钮音效
        if (audioId > 0)
        {
            AudioManager.instance.Play(audioId);
        }
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        onValueChanged.RemoveListener(OnValueChange);
    }
}
