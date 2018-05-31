---------------------------------
-- 效果判定
---------------------------------
local function EffectTarget_Direct( effect )
    if effect.target == nil then
        return {};
    end

    return { effect.target };
end

local _rectA = Rect.Zero();
local _rectB = Rect.Zero();
local function EffectTarget_AOE( effect )
    local target = {};

    local unitList = effect.ai.unitList[ effect.data.side * effect.ai.side ];

    local center;
    if effect.target.__cname == "Unit" then
        center = effect.target.pos;
    else
        center = effect.target;
    end
    -- 判定范围
    _rectA:SetCenter( center );
    _rectA:SetSize( Vector2.New( effect.data.cldX, effect.data.cldY ) );

    -- 逐个相交判定    
    for i = 1, #unitList, 1 do
        local unit = unitList[i];
        -- 不能是死亡状态
        if unit ~= FIGHT_NULL and not FightUtils.IsUnitDead( unit ) then
            _rectB:SetCenter( unit.pos );
            _rectB:SetSize( Vector2.New( unit.data.cldX, unit.data.cldY ) );

            -- 相交判定
            if _rectA:Intersects( _rectB ) then
                table.insert( target, unit );
            end
        end
    end

    return target;
end

local function EffectTarget_SideAll( effect )
    local target = {};

    local unitList = effect.ai.unitList[ effect.data.side * effect.ai.side ];
    -- 逐个相交判定    
    for i = 1, #unitList, 1 do
        local unit = unitList[i];
        -- 不能是死亡状态
        if unit ~= FIGHT_NULL and not FightUtils.IsUnitDead( unit ) then
            table.insert( target, unit );
        end
    end

    return target;
end


EffectTarget = 
{
    [1] = EffectTarget_Direct,      -- 指向,直接对子弹目标产生判定
    [2] = EffectTarget_AOE,         -- 进行AOE判定
    [3] = EffectTarget_SideAll,     -- 目标Side全体单位
}