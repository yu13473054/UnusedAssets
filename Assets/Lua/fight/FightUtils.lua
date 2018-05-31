--------------------------------------------
-- 战斗用工具方法
--------------------------------------------
FightUtils = {};

-- 找列表中离自己最近的单位
function FightUtils.GetNearestUnit( selfUnit, unitList )
    local nearUnit = nil;
    local nearDis = 1048576;    -- 最大值，怎么着都不会超过这个吧。
    for i = 1, #unitList, 1 do
        local unit = unitList[i];
        -- 不能是死亡状态
        if unit ~= FIGHT_NULL and not FightUtils.IsUnitDead( unit ) then
            local dis = math.abs( unit.pos.x - selfUnit.pos.x );
            if dis < nearDis then
                nearUnit = unit;
                nearDis = dis;
            end
        end
    end
    return nearUnit, nearDis;
end

-- 找列表中离自己最远的单位
function FightUtils.GetFarestUnit( selfUnit, unitList )
    local farUnit = nil;
    local farDis = 0;
    for i = 1, #unitList, 1 do
        local unit = unitList[i];
        -- 不能是死亡状态
        if unit ~= FIGHT_NULL and not FightUtils.IsUnitDead( unit ) then
            local dis = math.abs( unit.pos.x - selfUnit.pos.x );
            if dis > farDis then
                farUnit = unit;
                farDis = dis;
            end
        end
    end
    return farUnit, farDis;
end

-- 距离自己最近和最远的人，如果只剩一人，则返回相同目标
function FightUtils.GetFarestAndNearest( selfUnit, unitList )
    local farUnit = nil;
    local farDis = 0;
    local nearUnit = nil;
    local nearDis = 1048576;
    for i = 1, #unitList, 1 do
        local unit = unitList[i];
        -- 不能是死亡状态
        if unit ~= FIGHT_NULL and not FightUtils.IsUnitDead( unit ) then
            local dis = math.abs( unit.pos.x - selfUnit.pos.x );
            if dis > farDis then
                farUnit = unit;
                farDis = dis;
            end
            if dis < nearDis then
                nearUnit = unit;
                nearDis = dis;
            end
        end
    end
    return nearUnit, farUnit;
end

-- 逻辑坐标转视觉坐标
function FightUtils.Pos2ViewPos( pos )
    local center = Fight.GetStageCenter();
    return Vector3.New( pos.x / VIEW_LOGIC_RATIO + center.x, pos.y / VIEW_LOGIC_RATIO, pos.y / VIEW_LOGIC_RATIO );
end

-- 单位是否死亡
function FightUtils.IsUnitDead( unit )
    if unit.ai.state == AIState.dead or unit.attr.hp == 0 then
        return true;
    end
    return false;
end

-- 取战斗随机值，用c#实现
local _random;
-- 每设一次，创一个random实例
function FightUtils.RandomSeed( seed )
    _random = XRandom.New( seed );
end
function FightUtils.Random( from, to )
    if from == to then
        return from;
    end
    local offset = to - from;
    local factor = offset >= 0 and 1 or -1;
    local num = _random:nextInt( offset * factor + 1 );
    num = from + num * factor
    Event.Fight:DispatchEvent( EVENT_FIGHT_RANDOM, num );
    return num;
end

-- 设置特效ViewPos
function FightUtils.FXSetViewPos( fxTrans, viewPos )
    if fxTrans == nil then
        return;
    end

    -- 给特效z一个小偏移，让它能在角色前
    viewPos.z = viewPos.y - 0.1;
    fxTrans.position = viewPos;
end

-- 设置特效TimeScale
function FightUtils.FXTimeStop( trans, noTimeStop )
    -- 找所有ParitcleSystem
    local particles = trans:GetComponentsInChildren( typeof( ParticleSystem ) );
    for i = 0, particles.Length - 1, 1 do
        Log( particles[i].main );
        particles[i].main.useUnscaledTime = noTimeStop;
    end
    -- 找所有的Animator
    local animators = trans:GetComponentsInChildren( typeof( Animator ) );
    for i = 0, animators.Length - 1, 1 do
        if noTimeStop then
            animators[i].updateMode = AnimatorUpdateMode.UnscaledTime;
        else
            animators[i].updateMode = AnimatorUpdateMode.Normal;
        end
    end
end