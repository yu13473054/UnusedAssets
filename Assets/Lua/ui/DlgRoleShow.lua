-- 界面
DlgRoleShow = {};
local _dlg = nil;

local _roleImg;

-- 打开界面
function DlgRoleShow.Open()
	_dlg = UIManager.instance:Open( "DlgRoleShow" );
end

-- 隐藏界面
function DlgRoleShow.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgRoleShow.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgRoleShow.Close();
        end
	end
end

-- 载入时调用
function DlgRoleShow.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _roleImg = objs[0]:GetComponent( typeof( UIImage ) );
end

-- 界面初始化时调用
function DlgRoleShow.OnStart( gameObject )
	
end

-- 界面显示时调用
function DlgRoleShow.OnEnable( gameObject )
	
end

-- 界面隐藏时调用
function DlgRoleShow.OnDisable( gameObject )
	
end

-- 界面删除时调用
function DlgRoleShow.OnDestroy( gameObject )
	_dlg = nil;
end


----------------------------------------
-- 自定
----------------------------------------
function DlgRoleShow.Show( unit )
    DlgRoleShow.Open();

    _roleImg.sprite = Load_Char_Role( _dlg.name, Data.Character()[unit.charID].res );
    _roleImg:SetNativeSize();
end