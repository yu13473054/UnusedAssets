-- 界面
DlgLogin = { };
local _dlg = nil;
local _inputField;
local _serverName;

-- 打开界面
function DlgLogin.Open()
    _dlg = UIManager.instance:Open("DlgLogin");
end

-- 隐藏界面
function DlgLogin.Close()
    if _dlg == nil then
        return;
    end

    UIManager.instance:Close(_dlg);
end

------------------------------------------ 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgLogin.OnEvent(uiEvent, controlID, value, gameObject)
    if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgLogin.Close();
        elseif controlID == 1 then --开始游戏
            -- 显示遮罩
            DlgWait.Open();
            DlgLogin.ConnectServer();

--            DlgLogin.LoginOver();
        elseif controlID == 2 then -- 服务器选择
            DlgServerList.Open();
        elseif controlID == 3 then -- 重新登录
            DlgWait.Open();
            DlgLogin.LoginStart();
        end
    end
end

-- 载入时调用
function DlgLogin.OnAwake(gameObject)
    -- 控件赋值	
    local objs = gameObject:GetComponent(typeof(UISystem)).relatedGameObject;
    _inputField = objs[0]:GetComponent(typeof(UIInputField));
    _serverName = objs[2]:GetComponent(typeof(UIText));
end

-- 界面初始化时调用
function DlgLogin.OnStart(gameObject)
    -- 显示本地存储的uid ，如果属于新建的角色，随机一个uid
    local userName = Data.userini:ReadValue("UserName", "");
    if userName == "" then
        userName = "uid" .. math.random(10000000, 99999000);
    end
    _inputField.text = userName;

    -- 先隐藏部分UI
    _serverName.gameObject:SetActive(false);

    -- 请求服务器列表
    DlgWait.Open();
    DlgLogin.LoginStart();
end

-- 界面显示时调用
function DlgLogin.OnEnable(gameObject)
    Event.UI:AddListener("SERVERLIST",DlgLogin.OnServerChange);
end

-- 界面隐藏时调用
function DlgLogin.OnDisable(gameObject)
    Event.UI:RemoveListener("SERVERLIST",DlgLogin.OnServerChange);
end

-- 界面删除时调用
function DlgLogin.OnDestroy(gameObject)
    _dlg = nil;
end

----------------------------------------
-- 自定
----------------------------------------
function DlgLogin.OnServerChange(serverId)
    DlgLogin.SelectedServerId = serverId;
    _serverName.text = DlgLogin.ServerList[serverId].serverName;
end


----------------------------------------
-- 登陆流程，代码是从上到下的执行过程。
----------------------------------------
-- 账号ID
DlgLogin.AccountID = 0;
DlgLogin.SecureCode = 0;
-- serverId;服务器编号	host：服务器地址	port:端口	serverName;服务器名称	serverState:服务器状态0推荐1爆满2维护
DlgLogin.SelectedServerId=1;
DlgLogin.ServerList = { };      -- ID为索引的表
DlgLogin.ServerIDSorted = { };  -- ID排序的表，里面只有ID

-------------------------------------------------

-- 登录第一步，请求账号信息
function DlgLogin.LoginStart()
    -- 消息注册
    Event.Net:AddListener(EVENT_HTTP_LOGIN, DlgLogin.OnLogin);

    -- 从配置里拿账号密码
    local userName = _inputField.text;

    -- 协议编号,渠道,账号名,密码
    Network.HttpGet(AppConst.loginHost .. EVENT_HTTP_LOGIN .. "," .. AppConst.platID .. "," .. userName .. ",password", true);
end

-- 返回账号信息
-- resCode：0登陆成功,1失败	errMsg：失败内容	secureCode：安全码	accountId:账号ID
function DlgLogin.OnLogin(msg)
    -- 消息注册
    Event.Net:RemoveListenerAll(EVENT_HTTP_LOGIN);
    Event.Net:AddListener(EVENT_HTTP_SERVERLIST, DlgLogin.OnGetServerList);

    -- 结果
    if msg.resCode == "1" then
        -- 登录失败
        Log("<DlgLogin> 登录失败: " .. msg.errMsg);
        return;
    end

    -- 账号ID
    DlgLogin.AccountID = tonumber(msg.accountId);
    DlgLogin.SecureCode = msg.secureCode;

    -- 请求服务器列表
    Network.HttpGet(AppConst.loginHost .. EVENT_HTTP_SERVERLIST, true);
end

-- 请求服务器列表
function DlgLogin.OnGetServerList(msg)
    -- 消息注册
    Event.Net:RemoveListenerAll(EVENT_HTTP_SERVERLIST);

    -- 遍历，插入新表
    DlgLogin.ServerList = { };

    for i, server in pairs(msg.servers) do
        local serverId = tonumber(server.serverId);
        table.insert(DlgLogin.ServerList, serverId, {
            serverId = serverId,
            host = server.host,
            port = tonumber(server.port),
            serverName = server.serverName,
            serverState = tonumber(server.serverState)
        } );
        table.insert(DlgLogin.ServerIDSorted, serverId);
    end
    -- ID表排序
    table.sort(DlgLogin.ServerIDSorted, function(x, y) return x < y; end);

    --上次选择的服务器id
    DlgLogin.SelectedServerId = tonumber( Data.userini:ReadValue("ServerId", ""));
    if (DlgLogin.ServerList[DlgLogin.SelectedServerId] == nil) then
        DlgLogin.SelectedServerId = DlgLogin.ServerIDSorted[1];
    end

    -- 得到服务器列表后，显示UI
    DlgWait.Close();
    _serverName.gameObject:SetActive(true);
    _serverName.text = DlgLogin.ServerList[ DlgLogin.SelectedServerId].serverName;
end

function DlgLogin.ConnectServer()
    -- 连接服务器
    local firstServer = DlgLogin.ServerList[tonumber( DlgLogin.SelectedServerId)];
    if (firstServer.host == nil) then
        Log(string.format("<DlgLogin> %s区的的host为空！",firstServer.serverName));
        -- 隐藏遮罩
        DlgWait.Close();
        return;
    end
    if (firstServer.port == nil) then
        Log(string.format("<DlgLogin> %s区的的port为空！",firstServer.serverName));
        -- 隐藏遮罩
        DlgWait.Close();
        return;
    end
    --注册连接回调
    Event.Net:AddListener(EVENT_SOCKET_ONCONNECT, DlgLogin.OnConnect);
    -- 存储服务器ID
    Data.userini:WriteValue("ServerId",  DlgLogin.SelectedServerId);
    Network.Connect(firstServer.host, firstServer.port);
end

-- 服务器连接成功
function DlgLogin.OnConnect()
    -- 消息注册
    Event.Net:RemoveListener(EVENT_SOCKET_ONCONNECT, DlgLogin.OnConnect);
    Event.Net:AddListener(Res_Login, DlgLogin.OnGameLogin);

    local msg = Req_LoginMsg();
    msg.secureCode = DlgLogin.SecureCode;
    msg.version = "1.0.0";
    Network.Send(msg);
end

-- 登陆成功
function DlgLogin.OnGameLogin(data)
    -- 消息注册
    local msg = Res_LoginMsg():Unpack(data);    
    DlgWait.Close();
    
    -- 有角色，直接登陆
    if msg.isHavePlayer then
        DlgLogin.LoginOver();

    -- 没角色，打开创建角色界面
    else
        -- 存储uid
        Data.userini:WriteValue("UserName", _inputField.text);

        -- 打开创建角色界面
        DlgCreateName.Open();
    end
end

-- 登陆完毕
function DlgLogin.LoginOver()
    -- 清空登陆有关所有监听
    Event.Net:RemoveListenerAll( Res_Login );
    Event.Net:RemoveListenerAll( Res_CreatePlayer );

    -- 隐藏遮罩
    local bgGo = GameObject.Find("UIRoot/Layer_0_FULL/AssetsUpdate(Clone)");
    if bgGo ~= nil then
        GameObject.Destroy(bgGo);
        ResourceManager.instance:UnloadAssetBundle("AssetsUpdate"); --卸载ab包
    else
        LogErr("资源更新UI没有找到！");
    end
    DlgMain.Open();
end