-- 模块
#NAME# = {};
local _mod;

----------------------------------------
-- 事件
----------------------------------------

-- 所属按钮点击时调用
function #NAME#.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_CLICK then
		print( "Button Clicked, nControlID:" .. controlID );
	elseif uiEvent == UIEVENT_PRESS then
		if value then
			print( "Button Pressed Down, nControlID:" .. controlID );
		elseif not value then
			print( "Button Pressed UP, nControlID:" .. controlID );
		end
	end
end

-- 载入时调用
function #NAME#.OnAwake( gameObject )
	_mod = gameObject:GetComponent( typeof( UISystem ) );
	local objs = _mod.relatedGameObject;
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
	_mod = nil;
end

----------------------------------------
-- 自定
----------------------------------------
