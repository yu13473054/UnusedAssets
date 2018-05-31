-- 界面
DlgCreateName = {};
local _dlg = nil;
local _userNameText;
local _userSexToggle;

-- 打开界面
function DlgCreateName.Open()
	_dlg = UIManager.instance:Open( "DlgCreateName" );
end

-- 隐藏界面
function DlgCreateName.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgCreateName.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == 1 then
            DlgCreateName.Message();
        end
	end
end

-- 载入时调用
function DlgCreateName.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _userNameText = objs[0]:GetComponent(typeof( UIInputField ));
    _userSexToggle = objs[1]:GetComponent(typeof( UIToggle ));

    -- 监听网络信息，在登陆成功后移除
    Event.Net:AddListener(Res_CreatePlayer, DlgCreateName.OnCreatePlayer);
end

-- 界面初始化时调用
function DlgCreateName.OnStart( gameObject )
	 
end

-- 界面显示时调用
function DlgCreateName.OnEnable( gameObject )
end

-- 界面隐藏时调用
function DlgCreateName.OnDisable( gameObject )

end

-- 界面删除时调用
function DlgCreateName.OnDestroy( gameObject )
	_dlg = nil;
end


----------------------------------------
-- 自定
----------------------------------------

-- 发送角色信息
function DlgCreateName.Message()
    --发送创建角色的协议
    local msg = Req_CreatePlayerMsg();
    msg.playerName = _userNameText.text;
    msg.sex = _userSexToggle.isOn and 1 or 0;
    msg.secureCode = DlgLogin.SecureCode;
    Network.Send(msg);

    -- 等待
    DlgWait.Open();
end

-- 角色创建消息
function DlgCreateName.OnCreatePlayer(data)
    DlgWait.Close();

    local msg = Res_CreatePlayerMsg():Unpack(data);
    if msg.resCode == "0" then
        -- 成功
        DlgLogin.LoginOver();
        DlgCreateName.Close();  
    elseif msg.resCode == "1" then    
        -- 失败
        LogErr( "<DlgCreateName> 创建角色失败：" .. msg.errMsg );
    end
end