-- 界面
DlgPause = {};
local _dlg = nil;

-- 打开界面
function DlgPause.Open()
	_dlg = UIManager.instance:Open( "DlgPause" );
end

-- 隐藏界面
function DlgPause.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgPause.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgPause.Close();
        elseif controlID == 1 then -- 退出游戏
            UIManager.instance:UnloadAllUI();
            Fight.Exit();
            DlgMain.Open();
        end
	end
end

-- 载入时调用
function DlgPause.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
end

-- 界面初始化时调用
function DlgPause.OnStart( gameObject )
	
end

-- 界面显示时调用
function DlgPause.OnEnable( gameObject )
	
end

-- 界面隐藏时调用
function DlgPause.OnDisable( gameObject )
	
end

-- 界面删除时调用
function DlgPause.OnDestroy( gameObject )
	_dlg = nil;
end


----------------------------------------
-- 自定
----------------------------------------
