-- 网络交互部分，收到的消息分发出去不处理逻辑
--[[ 
命名：data为与服务器交互的数据，msg为反序列化的Lua Table
1.回包：
    1) Socket:
        监听：Event.Net:AddListener( Res_ResLogin, function( data ) end );
        解包：local msg = Res_LoginMsg():Unpack( data );

    2) Http:
        监听：Event.Net:AddListener( EVENT_HTTP_LOGIN, function() end );

2.发包：(嵌套时同理)
    local msg = Req_LoginMsg();
    msg.secureCode = Login.SecureCode;
    msg.version = "1.0.0";
    Network.Send( msg );
]]

Network = {};
Network.Connected = false;

require "protocols/C2GResponseMsg_pb"
require "protocols/C2GRequestMsgProto_pb"
require "protocols/VO_pb"

-- 每次发消息都会+1
local _msgCount = 0;
local _sessionId = "";

-- 连接游戏服务器
function Network.Connect( host, port )
    -- 只允许连接1次，断开后重置
    if Network.Connected then
        return;
    end

    _msgCount = 0;

    NetworkManager.instance:SendConnect( host, port );
end

-- Socket消息
function Network.Response( id, data )
    -- 特殊消息处理
    if id == EVENT_SOCKET_ONCONNECT then
        -- 连接成功
        Log( "<Socket> 连接服务器成功!" );
        Event.Net:DispatchEvent( EVENT_SOCKET_ONCONNECT );
        --Network.Connected = true;
        return;
    elseif id == EVENT_SOCKET_DISCONNECT then
        -- 连接异常断开
        Log( "<Socket> 与服务器连接异常!" );
        Network.Connected = false;
        -- 尝试重新连接
        return;
    elseif id == EVENT_SOCKET_EXCEPTION then
        -- 连接正常断开
        Log( "<Socket> 与服务器连接断开!" );
        Network.Connected = false;
        return;
    end

    -- 处理正常消息
    -- 先解母包
    local msg = G2CResponse():Unpack( data );

    -- 然后把本体分发出去
    Log( "<Socket> 接收协议: " .. msg.msgType );
    Event.Net:DispatchEvent( msg.msgType, msg.msgBody, msg.msgType );
end

-- 序列化消息，传过来的是本体，需要包装一层
function Network.Send( msgBody )
    local msgType = msgBody.msgType;
    if msgType == nil then
        return;
    end

    -- 计数
    _msgCount = _msgCount + 1;
    
    -- 先封母包
    local msg = C2GRequest();
    msg.msgType = msgType;
    msg.msgCount = _msgCount;
    msg.sessionId = _sessionId;
    msg.msgBody = msgBody:SerializeToString();

    -- 发包
    Log( "<Socket> 发送协议: " .. msgType );
    NetworkManager.instance:Send( msg:SerializeToString() );
end

-- 接受登陆成功包，保存网络scessionID
function Network.OnLogin( data )
    local msg = Res_LoginMsg():Unpack(data);
    _sessionId = msg.sessionId;
end
Event.Net:AddListener( Res_Login, Network.OnLogin );

-- Http发消息, 如果needResponse将会接受返回事件
function Network.HttpGet( url )
    NetworkManager.instance:HttpGet( url );
end

-- Http回消息
function Network.HttpResponse( err, data )
    -- 判错
    if err > 0 then
        LogErr( "<Http> " .. data );
        return;
    end
    Log( "<Http> " .. data );

    -- json拆包
    local json = require "cjson";
	local msg = json.decode( data );
	if msg == nil or msg["protocolId"] == nil then
        LogErr( "<Http> 无效的返回值！" );
		return;
	end
    
    -- 然后把解析好的表分发出去
    Event.Net:DispatchEvent( msg["protocolId"], msg );
end