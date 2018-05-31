---------------------------------
-- 基础状态机，如果需要继承复用，直接调接口
-- 会改变AI状态
-- 控制Unit表现，注释带@
---------------------------------
-- move：移动，preAttack：攻击准备，onAttack：攻击中，aftAttack：afterAttack攻击间隔，ooc:OutOfControl被控，dead：死亡，enter：入场，quit：退场，win：胜利，run：跑路纯动画
AIState = { move = {}, preAttack = {}, onAttack = {}, aftAttack = {}, ooc = {}, dead = {}, enter = {}, quit = {}, win = {}, run = {} };
---------------------------------
-- 移动
function AIState.move.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.move;

    -- @播移动动画
    ai.unit:PlayMove();
end
function AIState.move.Quit( ai )

end
function AIState.move.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 死亡
    if ai.unit.attr.hp <= 0 then
        AIState.dead.Enter( ai );
        return;
        
    -- 手动释放技能
    elseif ai.unit.manualOP == 1 then  
        ai:Skill( 2, 1 );
        AIState.preAttack.Enter( ai );
        return;
        
    -- 退场
    elseif ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );
        return;
    end
    ------------------------------------------------

    -- 寻敌，找距离最近的单位
    local nearUnit, nearDis = FightUtils.GetNearestUnit( ai.unit, ai.unitList[-ai.side] );
    
    -- 如果目标不存在进入胜利状态
    if nearUnit == nil then
        AIState.win.Enter( ai );
        return;
    end

    -- 设定目标
    ai.target = nearUnit;

    -- 转向目标
    ai.unit:FaceTo( nearUnit );

    -- 判断射程
    if nearDis > ai.unit.attr.rng then
        -- @如果目标不在射程内，向目标移动一个逻辑时间的距离
        ai.unit:Move( updateTime );
    else        
        -- 否则产生技能并进入攻击状态
        ai:SkillAuto();
        AIState.preAttack.Enter( ai );
    end
end

---------------------------------
-- 攻击准备，进入这个状态前应已经生成技能
function AIState.preAttack.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.preAttack;

    -- 清空计时
    ai.stateTimer = 0;

    -- @播攻击准备动画
    ai.unit:PlayPreAttack(); 
end
function AIState.preAttack.Quit( ai )
    
end
function AIState.preAttack.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 死亡
    if ai.unit.attr.hp <= 0 then
        AIState.dead.Enter( ai );
        return;

    -- 手动释放技能
    elseif ai.unit.manualOP == 1 then  
        ai:Skill( 2, 1 );
        AIState.preAttack.Enter( ai );
        return;
        
    -- 退场
    elseif ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );

    -- 计时结束进入攻击中
    elseif ai.stateTimer >= ai.preAtkTime then
        AIState.onAttack.Enter( ai );
        return;
    end
    ------------------------------------------------


    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end

---------------------------------
-- 攻击中
function AIState.onAttack.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.onAttack;

    -- 攻击
    ai:Attack();

    -- 清空计时
    ai.stateTimer = 0;

    -- @播攻击中动画
    ai.unit:PlayOnAttack(); 
end
function AIState.onAttack.Quit( ai )

end
function AIState.onAttack.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 死亡
    if ai.unit.attr.hp <= 0 then
        AIState.dead.Enter( ai );
        return;

    -- 手动释放技能
    elseif ai.unit.manualOP == 1 then  
        ai:Skill( 2, 1 );
        AIState.preAttack.Enter( ai );
        return;        
        
    -- 退场
    elseif ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );

    elseif ai.stateTimer >= ai.onAtkTime then
        -- 计时结束进入攻击间隔
        AIState.aftAttack.Enter( ai );
        return;
    end
    ------------------------------------------------

    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end

---------------------------------
-- 攻击后
function AIState.aftAttack.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.aftAttack;

    -- 清空计时
    ai.stateTimer = 0;

    -- 普通攻击，算上攻速，重新计算时间
    if ai.currSkill.data.skillType == 1 then
        ai.aftAtkTime = math.floor( ai.aftAtkTime * ai.unit.attr.atkSpd / 100 );
    end

    -- @播待机动画
    ai.unit:PlayIdle();
end
function AIState.aftAttack.Quit( ai )

end
function AIState.aftAttack.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 死亡
    if ai.unit.attr.hp <= 0 then
        AIState.dead.Enter( ai );
        return;

    -- 手动释放技能
    elseif ai.unit.manualOP == 1 then
        ai:Skill( 2, 1 );
        AIState.preAttack.Enter( ai );
        return;
        
    -- 退场
    elseif ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );
        return;

    -- 计时结束进入寻敌移动
    elseif ai.stateTimer >= ai.aftAtkTime then
        AIState.move.Enter( ai );
        return;
    end
    ------------------------------------------------

    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end

---------------------------------
-- 被控制
function AIState.ooc.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.ooc;

    -- 清空计时
    ai.stateTimer = 0;

    -- @播被控动画
    ai.unit:PlayOOC();
end
function AIState.ooc.Quit( ai )

end
function AIState.ooc.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 死亡
    if ai.unit.attr.hp <= 0 then
        AIState.dead.Enter( ai );
        return; 
        
    -- 退场
    elseif ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );

    -- 计时结束进入寻敌移动
    elseif ai.stateTimer >= ai.unit.oocTime then
        AIState.move.Enter( ai );
        return;
        
    -- 退场
    elseif ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );
        return;
    end
    ------------------------------------------------

    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end

---------------------------------
-- 死亡
function AIState.dead.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.dead;
    
    -- @播死亡动画
    ai.unit:PlayDie();
end
function AIState.dead.Quit( ai )

end
function AIState.dead.Update( ai, updateTime )
    -- 退场
    if ai.unit.manualOP == 2 then
        AIState.quit.Enter( ai );
    end
end

---------------------------------
-- 入场状态
function AIState.enter.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.enter;

    -- 清空计时
    ai.stateTimer = 0;
end
function AIState.enter.Quit( ai )
    
end
function AIState.enter.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 完成入场准备，播放入场动画，转为前场
    if ai.stateTimer >= ai.unit.enterPepareTime and ai.unit.isBack then
        -- 入场
        ai.unit:Enter();
    elseif ai.stateTimer >= ai.unit.enterPepareTime + Data.FightConst().switch_Time then
        -- 释放入场技
        ai:Skill( 3, 1 );
        AIState.preAttack.Enter( ai );
    end
    ------------------------------------------------

    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end

---------------------------------
-- @退场状态
function AIState.quit.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.quit;

    -- 如果生命为0，立即退场
    if ai.unit.attr.hp <= 0 then
        ai.unit:Quit();
        return;
    end
    
    -- @播招人动画

    -- 清空计时
    ai.stateTimer = 0;
end
function AIState.quit.Quit( ai )
    
end
function AIState.quit.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 完成入场准备，播放入场动画，转为前场
    if ai.stateTimer >= Data.FightConst().switch_PrepareTime and not ai.unit.isBack then
        -- 退场
        ai.unit:Quit();
    end
    ------------------------------------------------
    
    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end

---------------------------------
-- @胜利状态
function AIState.win.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.win;

    -- @播胜利动画
    ai.unit:PlayWin();
end
function AIState.win.Quit( ai )

end
function AIState.win.Update( ai, updateTime )

end

---------------------------------
-- @跑路状态
function AIState.run.Enter( ai )
    -- 当前状态退出
    if ai.currState ~= nil then
        ai.currState.Quit();
    end
    ai.currState = AIState.run;

    -- 根据side调整方向
    ai.unit:Turn( ai.side == -1 and true or false );

    -- @播移动动画，得算下移动速度，调整动画播放速度
    ai.unit:PlayMove( 1 );
    
    -- 清空计时
    ai.stateTimer = 0;

    -- 记下开始位置
    ai.runStartViewPos = ai.unit.viewPos;
    -- 结束位置是根据逻辑坐标和战场中心的显示坐标算出的
    ai.runEndViewPos = Clone( ai.unit.viewPos );
    ai.runEndViewPos.x = Fight.GetStageCenter().x + ai.unit.pos.x / VIEW_LOGIC_RATIO;
end
function AIState.run.Quit( ai )

end
function AIState.run.Update( ai, updateTime )
    ------------------------------------------------
    -- 判定状态转换条件，注意判定顺序
    -- 跑路结束，直接进入寻敌
    if ai.stateTimer >= Data.FightConst().fight_RunTime then
        AIState.move.Enter( ai );
        return;
    end
    ------------------------------------------------

    -- 差值时间
    ai.unit:ViewPosLerp( ai.runStartViewPos, ai.runEndViewPos, ai.stateTimer / Data.FightConst().fight_RunTime );

    -- 计时
    ai.stateTimer = ai.stateTimer + updateTime;
end