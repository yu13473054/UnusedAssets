require "logic/Include";

-- Lua启动入口
function LuaStart() 
    -- 设随机种子
    math.randomseed( Time.realtimeSinceStartup );

	--加载数据
	Data.OnInit();

	--启动登陆UI
	DlgLogin.Open();
end