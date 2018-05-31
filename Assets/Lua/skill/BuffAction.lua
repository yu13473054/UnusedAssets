---------------------------------
-- Buff逻辑
-- OnActive 每次激活时的逻辑
-- Check    主动检查是否应该结束
-- OnQuit   退出时执行的逻辑
---------------------------------
-- 伤害
local BuffAction_DamageReal = {};
function BuffAction_DamageReal.OnActive( buff )
    local source = buff.source;
    local unit = buff.unit;
    -- 计算伤害公式
    local dmg = source.attr.atk * FightUtils.Random( buff.data.value[1], buff.data.value[2] ) / 100 + buff.data.value[3];
    -- 对象扣血，向下取整，最小1
    unit:HPChange( -1 * math.max( 1, math.floor( dmg ) ), unit );
end
function BuffAction_DamageReal.Check( buff )
end
function BuffAction_DamageReal.OnQuit( buff )
end

-- 护盾
local BuffAction_Shell = {};
function BuffAction_Shell.OnActive( buff )
    buff.unit.attr.shellTimes = buff.data.value[1];
    buff.unit.attr.shellHP = buff.data.value[2];
end
function BuffAction_Shell.Check( buff )
    -- 否则，全部==0结束Buff
    if buff.data.value[3] == 0 then
        if buff.unit.attr.shellTimes <= 0 and buff.unit.attr.shellHP <= 0 then
            return true;
        end

    -- 任意一个==0结束Buff
    else
        if buff.unit.attr.shellTimes <= 0 or buff.unit.attr.shellHP <= 0 then
            return true;
        end
    end
end
function BuffAction_Shell.OnQuit( buff )
    buff.unit.attr.shellTimes = 0;
    buff.unit.attr.shellHP = 0;
end


BuffAction = 
{
    [1] = BuffAction_DamageReal,    -- 真实伤害
    [2] = BuffAction_Shell,         -- 护盾
}