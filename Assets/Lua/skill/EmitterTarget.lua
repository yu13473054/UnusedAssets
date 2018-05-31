---------------------------------
-- 技能的目标选择器
-- 目标可能是坐标或者单位
---------------------------------
local function Emitter_CurrTarget( emitter )
    return { emitter.ai.target };
end

local function Emitter_Self( emitter )
    return { emitter.ai.unit };
end

local function Emitter_Farest( emitter )
    return { FightUtils.GetNearestUnit( emitter.ai.unit, emitter.ai.unitList[ emitter.data.side * emitter.ai.side ] ) };
end

local function Emitter_Nearest( emitter )  
    return { FightUtils.GetFarestUnit( emitter.ai.unit, emitter.ai.unitList[ emitter.data.side * emitter.ai.side ] ) };
end

local function Emitter_Middle( emitter )
    local near, far = FightUtils.GetFarestAndNearest( emitter.ai.unit, emitter.ai.unitList[ emitter.data.side * emitter.ai.side ] );
    if near ~= nil and far ~= nil then
        return { Vector2.New( near.pos.x + ( far.pos.x - near.pos.x )  / 2, 0 ) };
    end
    return {};
end

local function Emitter_SideAll( emitter )
    local target = {};
    local unitList = emitter.ai.unitList[ emitter.data.side * emitter.ai.side ];
    for i = 1, #unitList, 1 do
        local unit = unitList[i];
        if unit ~= FIGHT_NULL and not FightUtils.IsUnitDead( unit ) then
            table.insert( target, unit );
        end
    end
    return target;
end

EmitterTarget =
{
    [1] = Emitter_CurrTarget, -- 选当前目标
    [2] = Emitter_Self,       -- 选自己，立即生效
    [3] = Emitter_Farest,     -- 最远的目标
    [4] = Emitter_Nearest,    -- 最近的目标
    [5] = Emitter_Middle,     -- 最近和最远的正中
    [6] = Emitter_SideAll,    -- 目标Side全体单位
}