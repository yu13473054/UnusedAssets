------------------------------------------------------------------
-- 战斗日志
------------------------------------------------------------------
FightDebugger = {};

-- 日志
local function Log( msg )
    FightLog.Log( msg );
end

-- 获得逻辑帧数
local function GetLogicFrameCount()
    local count = Fight.GetLogicFrameCount();
    --count = count - Data.FightConst().fight_RunTime / FIGHT_LOGICTIME - 1;
    return count;
end

-- 战斗开始
local function FightDebugger_Start()
    FightLog.Create();
end

-- 战斗结束
local function FightDebugger_End()
    FightLog.Close();
end

-- 战斗伤害
local function FightDebugger_HPChange( unit, change, source, isCrit )
    if change < 0 then
        Log( string.format( "<伤害:%s> 源:%s_%s, 目标:%s_%s, 伤害:%s, 暴击:%s, 剩余血量：%s", GetLogicFrameCount(), source.data.name, source.index,
            unit.data.name, unit.index, change, isCrit and 1 or 0, unit.attr.hp ) );
    end
end

-- 战斗波单位信息
local function FightDebugger_Wave( unitList, prefix )
    -- 左方
    for i = 1, #unitList[-1], 1 do
        local unit = unitList[-1][i];
        Log( string.format( "<%s:%s> %s_%s, 血量:%s, X:%s, Y:%s", prefix, GetLogicFrameCount(), unit.data.name, unit.index, unit.attr.hp, unit.pos.x, unit.pos.y ) );
    end
    -- 左方
    for i = 1, #unitList[1], 1 do
        local unit = unitList[1][i];
        Log( string.format( "<%s:%s> %s_%s, 血量:%s, X:%s, Y:%s", prefix, GetLogicFrameCount(), unit.data.name, unit.index, unit.attr.hp, unit.pos.x, unit.pos.y ) );
    end
end
-- 战斗开始，每个角色的信息
local function FightDebugger_WaveStart( unitList )
    FightDebugger_Wave( unitList, "开始" );
end
-- 战斗结果，每个角色的信息
local function FightDebugger_WaveEnd( unitList )
    FightDebugger_Wave( unitList, "结束" );
end

-- 随机数
local function FightDebugger_Random( num )
    Log( string.format( "<随机:%s> 随机结果:%s", GetLogicFrameCount(), num ) );
end

-- 注册事件
function FightDebugger.Init()
    Event.Fight:AddListener( EVENT_FIGHT_START, FightDebugger_Start );
    Event.Fight:AddListener( EVENT_FIGHT_END, FightDebugger_End );

    Event.Fight:AddListener( EVENT_FIGHT_UNITHPCHANGE, FightDebugger_HPChange );
    Event.Fight:AddListener( EVENT_FIGHT_WAVESTART, FightDebugger_WaveStart );
    Event.Fight:AddListener( EVENT_FIGHT_WAVEEND, FightDebugger_WaveEnd );
    Event.Fight:AddListener( EVENT_FIGHT_RANDOM, FightDebugger_Random );
end