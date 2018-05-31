---------------------------------
-- 效果实际的逻辑
---------------------------------
function EffectAction_Damage( effect, target )
    local unit = effect.ai.unit;
    -- 计算伤害公式
    local dmg = ( unit.attr.atk - target.attr.def ) * FightUtils.Random( effect.data.value[1], effect.data.value[2] ) / 100 + effect.data.value[3];
    -- 计算暴击
    local isCrit = false;
    if FightUtils.Random( 1, 100 ) <= unit.attr.crit then
        isCrit = true;
        dmg = dmg * unit.attr.critDmg / 100;
    end
    -- 对象扣血，向下取整，最小1
    target:HPChange( -1 * math.max( 1, math.floor( dmg ) ), unit, isCrit );

    -- 暴击播暴击特效
    return isCrit and 2 or 1;
end

function EffectAction_Heal( effect, target )
    local unit = effect.ai.unit;
    -- 计算治疗公式
    local heal = unit.attr.atk * FightUtils.Random( effect.data.value[1], effect.data.value[2] ) / 100 + effect.data.value[3];
    -- 对象加血，向下取整，最小1
    target:HPChange( math.max( 1, math.floor( heal ) ), unit, false );
end

function EffectAction_Buff( effect, target )
    -- 判定是否成功加上Buff
    if FightUtils.Random( 1, 100 ) <= effect.data.value[2] then
        target:BuffAdd( effect.data.value[1], effect.ai.unit );
    end
end

EffectAction = 
{
    [1] = EffectAction_Damage,      -- 伤害
    [2] = EffectAction_Heal,        -- 治疗
    [3] = EffectAction_Buff,        -- 加Buff
}