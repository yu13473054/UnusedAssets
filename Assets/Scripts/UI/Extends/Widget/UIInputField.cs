using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;


public class UIInputField : InputField {

    public UIMod uiMod;
    public int controlID = 0;

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

    public override void OnSubmit(BaseEventData eventData)
    {
        base.OnSubmit(eventData);
        if (uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UIINPUT_SUBMIT, controlID, text);
    }
}
