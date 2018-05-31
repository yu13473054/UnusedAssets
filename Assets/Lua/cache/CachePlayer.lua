--玩家信息表格
CachePlayer = {};

function CachePlayer.SetData( data )
    setmetatable(CachePlayer, {
        __index = data;
    });

--    for i = 1 , #data.cards do
--        print(i, data.cards[i].id,data.cards[i].level,data.cards[i].star,data.cards[i].bornTime,data.cards[i].exp)
--    end
end

-- 登陆游戏，缓存
function CachePlayer.OnLogin( data, msgType )
    local msg;
    if msgType == Res_CreatePlayer then
        msg = Res_CreatePlayerMsg():Unpack(data);
    elseif msgType == Res_Login then
        msg = Res_LoginMsg():Unpack(data);
        if not msg.isHavePlayer then
            return;
        end
    end

    CachePlayer.SetData( msg.playerVO );
end
Event.Net:AddListener( Res_CreatePlayer, CachePlayer.OnLogin );
Event.Net:AddListener( Res_Login, CachePlayer.OnLogin );