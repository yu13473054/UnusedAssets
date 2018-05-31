-- 界面
DlgWait = {};
local _dlg = nil;
local _waitUI;
local _timer;
local _delayTime;

-- 打开界面
function DlgWait.Open(delayTime)
    _delayTime = delayTime or 2;
	_dlg = UIManager.instance:Open( "DlgWait" );
end

-- 隐藏界面
function DlgWait.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgWait.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgWait.Close();
        end
	end
end

-- 载入时调用
function DlgWait.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _waitUI = objs[0]:GetComponent(typeof(UIImage));

    _timer = Timer.New(DlgWait.OnShowHint, _delayTime);
end

-- 界面初始化时调用
function DlgWait.OnStart( gameObject )
end

-- 界面显示时调用
function DlgWait.OnEnable( gameObject )
	--超时显示菊花
	_timer:Start();
    _waitUI.gameObject:SetActive(false);
end

-- 界面隐藏时调用
function DlgWait.OnDisable( gameObject )
	_timer:Stop();
end

-- 界面删除时调用
function DlgWait.OnDestroy( gameObject )
	_dlg = nil;
end

----------------------------------------
-- 自定
----------------------------------------
function DlgWait.OnShowHint( )
    _waitUI.gameObject:SetActive(true);
end
