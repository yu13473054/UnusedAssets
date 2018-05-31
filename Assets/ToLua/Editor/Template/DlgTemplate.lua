-- 界面
#NAME# = {};
local _dlg = nil;

-- 打开界面
function #NAME#.Open()
	_dlg = UIManager.instance:Open( "#NAME#" );
end

-- 隐藏界面
function #NAME#.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function #NAME#.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_CLICK then
        if controlID == -1 then
            #NAME#.Close();
        end
	end
end

-- 载入时调用
function #NAME#.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
end

-- 界面初始化时调用
function #NAME#.OnStart( gameObject )
	
end

-- 界面显示时调用
function #NAME#.OnEnable( gameObject )
	
end

-- 界面隐藏时调用
function #NAME#.OnDisable( gameObject )
	
end

-- 界面删除时调用
function #NAME#.OnDestroy( gameObject )
	_dlg = nil;
end


----------------------------------------
-- 自定
----------------------------------------
