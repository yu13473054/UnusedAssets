using UnityEngine;
using LuaInterface;

// 需要传递事件到lua的Mod挂载。不需lua的Mod无需挂载。有cs的并需要调用lua的Mod继承此类。
// UISystem用于对话框，继承UIMod的消息处理模式！

public class UIEVENT
{
	public const int UIBUTTON_CLICK = 10;                // UIButton单击					无参
    public const int UIBUTTON_PRESS = 11;		         // UIButton按下					0 按下，1 抬起

	public const int UITOGGLE_CLICK = 22;                // UIToggle单击					无参
	public const int UITOGGLE_PRESS = 23;		         // UIToggle按下					0 按下，1 抬起
    public const int UITOGGLE_ONVALUECHANGE = 21;	     // UIToggle内容发生变化时       bool值

    public const int UISLIDER_DRAG = 31;                 // UISlider拖动                0 开始拖动，1 拖动中，2 结束拖动
    public const int UISLIDER_PRESS = 34;                // UISlider按下				    0 按下，1 抬起

    public const int CAMERA_CLICK = 41;                  // Camera单击，也是抬起			组件的名称作为标志值。无controlID
	public const int CAMERA_PRESS = 42;                  // Camera按下					组件的名称作为标志值。无controlID

    public const int UISCROLLVIEW_DRAG = 51;		     // UIScrollView拖动             0 开始拖动，1 拖动中，2 结束拖动
    public const int UISCROLLVIEW_ONVALUECHANGE = 52;	 // UIScrollView内容发生变化时    Vector2对象
    public const int WRAPCONTENT_ONITEMUPDATE = 53;	     // WrapContent中Item更新        自定义对象：index，Transform
    public const int WRAPCONTENT_ONINITDONE = 54;	     // WrapContent中初始化完成       无

    public const int UIINPUT_SUBMIT = 61;                           
        		
    public const int UISCROLLBAR_ONVALUECHANGE = 71;	 // UIScrollbar内容发生变化时     float值
    public const int UISCROLLBAR_PRESS = 72;	         // UIScrollbar按下				 0 按下，1 抬起
}
                                                                                		
public class UIMod : MonoBehaviour 
{
	public GameObject[] relatedGameObject;
	public string       uiName = "";
	// 事件函数
	protected LuaFunction _onEnable;
	protected LuaFunction _onDisable;
	protected LuaFunction _onEvent;

	protected virtual void Awake ()
	{
		// 找到对应脚本的函数 事件函数命名为：obj名字加事件名
	    if (uiName == "")
	        uiName = gameObject.name.Replace("(Clone)", "").TrimEnd(' ');

        _onEvent = LuaManager.instance.GetFunction( uiName + ".OnEvent" );
		_onEnable = LuaManager.instance.GetFunction( uiName + ".OnEnable" );
		_onDisable = LuaManager.instance.GetFunction( uiName + ".OnDisable" );

        LuaFunction onAwake = LuaManager.instance.GetFunction( uiName + ".OnAwake" );
		if( onAwake != null )
		{
			onAwake.Call( gameObject );
		}
	}

	protected virtual void Start()
	{
        LuaFunction onStart = LuaManager.instance.GetFunction( uiName + ".OnStart" );
		if( onStart != null )
			onStart.Call( gameObject );
	}

	protected virtual void OnEnable()
	{
		if( _onEnable != null )
			_onEnable.Call( gameObject );
	}

	protected virtual void OnDisable()
	{
		if( _onDisable != null ) 
			_onDisable.Call( gameObject );
	}

	protected virtual void OnDestroy()
	{
        LuaFunction onDestroy = LuaManager.instance.GetFunction( uiName + ".OnDestroy" );
        if (onDestroy != null )
            onDestroy.Call( gameObject );
	}

	public virtual void OnEvent( int eventID, int controlID, object value )
	{
		if( _onEvent != null )
            _onEvent.Call<int,int,object,GameObject>( eventID, controlID, value, gameObject );
	}
}
