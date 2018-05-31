using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.EventSystems;

public class UIButton : Button
{
    public UIMod        uiMod;
	public int 			controlID = 0;
    public int          clickInterval = 0;
	public int	        audioId = 0; // 迅速在声音表里预留一个ID，填到这里成默认值

	protected override void Start()
	{
		base.Start();
#if UNITY_EDITOR
        // 挂载uiMod
        if ( uiMod == null )
		{
			uiMod = gameObject.GetComponentInParent<UIMod>();
		}
#endif
	}

	public override void OnPointerClick( PointerEventData eventData )
	{
		base.OnPointerClick( eventData );
        if( !IsInteractable() || uiMod == null )
            return;

        uiMod.OnEvent( UIEVENT.UIBUTTON_CLICK, controlID, 0 );
        // 播放按钮音效
	    if (audioId>0)
	    {
	        AudioManager.instance.Play(audioId);
	    }
	}
	
	public override void OnPointerDown( PointerEventData eventData )
	{
        base.OnPointerDown( eventData );
        if ( !IsInteractable() || uiMod == null )
            return;

        uiMod.OnEvent( UIEVENT.UIBUTTON_PRESS, controlID, 0 );
	}
	
	
	public override void OnPointerUp( PointerEventData eventData )
	{
		base.OnPointerUp( eventData );
        if ( !IsInteractable() || uiMod == null )
            return;

        uiMod.OnEvent( UIEVENT.UIBUTTON_PRESS, controlID, 1 );
	}
}
