using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class UIText : Text 
{
	public int localizationID = 0;
    protected void SetBase( string str )
    {
        base.text = str;
    }

    protected override void Awake ()
	{
		base.Awake();

#if UNITY_EDITOR
        if (!Localization.isInited)
        {
            Localization.Init();
        }
#endif

        if ( localizationID != 0 )
		{
            string dataText = Localization.Get(localizationID);
            if (!string.IsNullOrEmpty(dataText))
            {
                this.text = dataText;
            }
        }

#if UNITY_EDITOR
//        if ( font.name == "Arial" )//这个地方的name可以改为原来的字体的名称  
//        {
//            Font mFont = Resources.Load<Font>( "Fonts/arial" );//注意这个地方是要替换成的字体的路径  
//            if ( mFont == null )
//            {
//                Debug.LogError( " Font not found ! " );
//                return;
//            }
//            font = mFont;
//        }
#endif
    }
}
