---------------------------------
-- 战斗单位
-- 保存角色属性和属性的属性操作逻辑
-- 行为逻辑在AI
-- 每波战斗中不会被消除
-- *池管理*
---------------------------------
Unit = Class( "Unit" );

-- 战斗相关的对象都用池管理
local _pool = ObjectPool.New( Unit );
function Unit.Create( unitID, info, side, index, root )
    return _pool:Spawn( unitID, info, side, index, root );
end
function Unit.Clear()
    _pool:Destory();
end

------------------------------------------------
-- 构造/析构方法
------------------------------------------------
-- 创建或重新初始化一个单位
-- 如果info是个数字，就读表。否则直接使用info的数据
-- 表现的一些属性为和逻辑属性区分，全部加了view前缀
function Unit:Ctor( unitID, info, side, index, root )
    self.data = Data.Unit()[unitID];

    ------------------
    -- 表现属性
    ------------------
    -- 创建角色，并包一层
    if IsNilOrNull(self.transform) then
        self.transform = GameObject.New().transform;
        self.transform:SetParent( root );
        self.transform.position = Vector3.zero;
    end
    self.transform.name = "Unit_" .. unitID;

    -- 显示位置，都不带偏移值，最后射到position时再加上
    self.viewPos = Vector3.zero;

    -- 索引，这个角色在战斗中的唯一标识。还会用作Z轴偏差
    self.index = ( side == -1 ) and index or index + 100;
    
    ------------------
    -- 战斗基础属性
    ------------------
    -- 战斗基础属性，初始属性，参与Buff等的计算
    self.baseAttr = {};
    if type( info ) == "number" then
        -- 角色每次都新建
        self.char = Character.New( self.data.charID, self.transform );

        local level = info;
        self.baseAttr.rng = self.data.rng + self.data.lvlRng * ( level - 1 );
        self.baseAttr.hp = self.data.hp + self.data.lvlHp * ( level - 1 );
        self.baseAttr.atk = self.data.atk + self.data.lvlAtk * ( level - 1 );
        self.baseAttr.def = self.data.def + self.data.lvlDef * ( level - 1 );
        self.baseAttr.crit = self.data.crit + self.data.lvlCrit * ( level - 1 );
        self.baseAttr.critDmg = Data.FightConst().critical_Damage + self.data.critDmgPlus;
        self.baseAttr.spd = self.data.spd + self.data.lvlSpd * ( level - 1 );
        self.baseAttr.atkSpd = self.data.atkSpd + self.data.lvlAtkSpd * ( level - 1 );
    else
        -- 角色每次都新建
        self.char = Character.New( info.charID, self.transform );

        self.baseAttr.rng = info.rng;
        self.baseAttr.hp = info.hp;
        self.baseAttr.atk = info.atk;
        self.baseAttr.def = info.def;
        self.baseAttr.crit = info.crit;
        self.baseAttr.critDmg = info.critDmg;
        self.baseAttr.spd = info.spd;
        self.baseAttr.atkSpd = info.atkSpd;
    end

    -- 加成属性
    self.addAttr = {};
    self.addAttr.rng = 0;
    self.addAttr.atk = 0;
    self.addAttr.def = 0;
    self.addAttr.crit = 0;
    self.addAttr.critDmg = 0;
    self.addAttr.spd = 0;
    self.addAttr.atkSpd = 0;
    
    -- 战斗中属性最终计算的属性，会被Buff等修改
    self.attr = {};
    self.attr.rng = self.baseAttr.rng;
    self.attr.hp = self.baseAttr.hp;
    self.attr.atk = self.baseAttr.atk;
    self.attr.def = self.baseAttr.def;
    self.attr.crit = self.baseAttr.crit;
    self.attr.critDmg = self.baseAttr.critDmg;
    self.attr.spd = self.baseAttr.spd;
    self.attr.atkSpd = self.baseAttr.atkSpd;
    self.attr.shellTimes = 0;
    self.attr.shellHP = 0;

    ------------------
    -- 逻辑基础属性
    ------------------
    -- 位置
    self.pos = Vector2.zero;
    self.row = 1;
    
    -- 方向，1右面，-1左边
    self.faceDir = 0;

    -- AI重置数据就能直接用，不用池。
    if self.ai == nil then
        self.ai = AI.New( 1, self, side );
    else
        self.ai:Ctor( 1, self, side );
    end
    
    -- 被控时间
    self.oocTime = 0;

    -- Buff列表，ID为索引
    self.buffList = {};

    -- 生成技能
    -- 1：普攻，2：大招，3：换人，4：被动
    -- 玩家直接拿每种的第一个技能
    self.skills = { {}, {}, {}, {} };
    for i = 1, #self.data.skill, 1 do
        for j = 1, #self.data.skill[i] do
            table.insert( self.skills[i],
            {
                index = j,
                data = Data.Skill()[ self.data.skill[i][j] ],
            } );
        end
    end

    -- 是否是后备
    self.isBack = false;
    
    -- 玩家操作
    self.manualOP = 0;

    -- 入场等待时间
    self.enterPepareTime = 0;

    -- 时间暂停豁免对象
    self.noTimeStop = false;
end

-- 销毁
function Unit:Destory()
    -- 删除角色
    self.char:Destory();
    -- 回收
    _pool:Despawn( self );
end

------------------------------------------------
-- 逻辑
------------------------------------------------
-- 准备完毕
function Unit:Ready()
    -- 清空身上所有Buff
    self:BuffClear();

    -- #强制切换AI状态
    AIState.run.Enter( self.ai );
end

-- 逻辑更新
function Unit:Update( updateTime, timeStop )
    if self.ai ~= nil then
        self.ai:Update( updateTime );
    end

    -- 如果忽略时间停止，手动Update角色动画
    if timeStop and self.noTimeStop then
        self.char:Update( updateTime );
    end
end

-- 设置位置，传的是逻辑坐标
function Unit:SetPos( x, y )
    self.pos.x = x;
    self.pos.y = y;
end
function Unit:SetPosX( x )
    self.pos.x = x;
end
function Unit:SetPosY( y )
    self.pos.y = y;
end

-- 伤害/治疗
function Unit:HPChange( change, source, isCrit )
    -- 已经退场不受伤和治疗
    if self.isBack then
        return;
    end

    -- 已经死亡不受伤
    if FightUtils.IsUnitDead( self ) then
        return;
    end

    -- 伤害效果
    if change < 0 then
        -- ***** 计算护盾 *******
        if self.attr.shellHP > 0 or self.attr.shellTimes > 0 then
            self.attr.shellHP = self.attr.shellHP + change;
            self.attr.shellTimes = self.attr.shellTimes - 1;
            return;
        end

        -- 播受击效果
        self:PlayRed();
    end

    self.attr.hp = self.attr.hp + change;

    -- hp不足，死亡
    if self.attr.hp <= 0 then
        self.attr.hp = 0;

        -- 清空Buff
        self:BuffClear();
        
        -- 死亡时，删除Unit的事件通知
        Event.Fight:DispatchEvent( EVENT_FIGHT_UNITDIE, self );

    -- hp不能超过上限
    elseif self.attr.hp >= self.baseAttr.hp then
        self.attr.hp = self.baseAttr.hp;
    end
    
    -- 事件通知
    Event.Fight:DispatchEvent( EVENT_FIGHT_UNITHPCHANGE, self, change, source, isCrit );
end

-- 入场
function Unit:Enter()
    self:PlayEnter();
    
    -- 设前场属性
    self.isBack = false;
    
    -- 入场事件
    Event.Fight:DispatchEvent( EVENT_FIGHT_UNITENTER, self );
end

-- 退场
function Unit:Quit( isInit )
    -- 播退场动画
    self.isBack = true;

    -- 仅初始化
    if isInit then
        return;
    end

    -- 清除身上所有Buff
    self:BuffClear();

    -- 退场
    self:PlayQuit();
    self:ManualFinish();
    Event.Fight:DispatchEvent( EVENT_FIGHT_UNITQUIT, self );
end

-- 种Buff
function Unit:BuffAdd( buffID, source )
    -- 不能重复获得相同Buff
    if self.buffList[buffID] ~= nil then
        return;
    end

    self.buffList[buffID] = Buff.Create( buffID, self, source );
end

-- Buff清除
function Unit:BuffRemove( buffID )
    self.buffList[buffID] = nil;
end

-- 清除所有Buff
function Unit:BuffClear()
    for i, buff in pairs( self.buffList ) do
        buff:Destroy();
    end    
end

-- 设置时间暂停豁免
function Unit:NoTimeStop( noTimeStop )
    self.noTimeStop = noTimeStop;
    --self.char:NoTimeStop( noTimeStop );
end

------------------------------------------------
-- 手动操作
------------------------------------------------
-- 手动技能
function Unit:ManualSkill()
    -- 正在进行其他操作
    if self.manualOP ~= 0 then
        return false;
    end

    -- 检测是否满足技能释放条件
    if self.ai.currState == AIState.run or self.ai.currState == AIState.ooc or self.ai.currState == AIState.win or FightUtils.IsUnitDead( self ) then
        return false;
    end

    self.manualOP = 1;
    return true;
end

-- 退场
function Unit:ManualQuit()
    -- 正在进行其他操作
    if self.manualOP ~= 0 then
        return;
    end

    self.manualOP = 2;
    
    -- 不被暂停
    self:NoTimeStop( true );
end

-- 入场，特殊手动操作，不在AI中切换
function Unit:ManualEnter( target )
    -- 如果目标死亡
    if FightUtils.IsUnitDead( target ) then
        self.enterPepareTime = 0;

        -- 在最后出场
        self:SetPos( Data.FightConst().fightEdge_Col * self.ai.side, target.pos.y );
        self:SetViewPos( FightUtils.Pos2ViewPos( self.pos ) );     

    else
        self.enterPepareTime = Data.FightConst().switch_PrepareTime;
        
        -- 在指定位置入场
        self:SetPos( target.pos.x, target.pos.y );
        self:SetViewPos( target.viewPos );
    end
    
    -- 手动取一次最近目标
    self.ai.target = FightUtils.GetNearestUnit( self, self.ai.unitList[-self.ai.side] );
    -- 转向目标
    if self.ai.target ~= nil then
        self:FaceTo( self.ai.target );
    end
    
    -- #强制切换AI状态
    -- 进入入场状态
    AIState.enter.Enter( self.ai );

    -- 不被暂停
    self:NoTimeStop( true );
end

-- 完成手动操作
function Unit:ManualFinish()
    self.manualOP = 0;
end
------------------------------------

------------------------------------------------
-- 表现
------------------------------------------------
-- 刷新表现位置，参数为空时完成逻辑坐标到显示坐标的转换
function Unit:SetViewPos( viewPos )
    -- z轴用index做个偏差值，保证角色y轴相同时模型不会穿插。
    viewPos.z = viewPos.y + self.index % 100 / 100;
    self.viewPos = viewPos;
    self.transform.position = viewPos + Vector3.New( 0, VIEW_OFFSET_Y, 0 );
end

-- 显示坐标移动驱动，确定起点，终点的情况下的差值
function Unit:ViewPosLerp( viewPosStart, viewPosEnd, ratio )
    self:SetViewPos( Vector3.Lerp( viewPosStart, viewPosEnd, ratio ) );
end

------------------------------------------------
-- 表现 & 逻辑
------------------------------------------------
-- 面向目标单位，同时改变逻辑方向
function Unit:FaceTo( unit )
    if unit.pos.x - self.pos.x > 0 then
        -- 目标在右边
        if self.faceDir ~= 1 then
            self:Turn( true );
        end
    else
        -- 目标在左边
        if self.faceDir ~= -1 then
            self:Turn( false );
        end
    end
end

-- 转向
function Unit:Turn( isRight )
    self.faceDir = isRight and 1 or -1;
    self.char:Turn( isRight );
end

-- 移动时间，*注意*移动方向基于朝向
function Unit:Move( moveTime )
    -- 设置逻辑坐标
    self:SetPosX( self.pos.x + moveTime * self.attr.spd * self.faceDir );
    self:SetViewPos( Vector3.New( self.viewPos.x + moveTime * self.attr.spd * self.faceDir / VIEW_LOGIC_RATIO, self.viewPos.y, 0 ) );

    -- 分发事件
    Event.Fight:DispatchEvent( EVENT_FIGHT_UNITMOVE, self, self.viewPos, self.pos );
end

------------------------------------------------
-- AI用，动作处理。会根据自身状态，判断具体应该播放什么动画。
------------------------------------------------
-- 待机
function Unit:PlayIdle()
    self.char:Idle();
end

-- 移动
function Unit:PlayMove()
    -- 根据移动加速决定播放速度
    self.char:Move( 1 + self.addAttr.spd / self.baseAttr.spd );
end

-- 攻击准备，根据技能决定动画
function Unit:PlayPreAttack()
    local action = self.ai.currSkill.data.action;
    if action == 1 then
        -- 攻击类型1：普通攻击
        -- 随机播放普通攻击0，普通攻击1
        if math.random( 0, 1 ) == 0 then
            self.char:Attack0( ( self.ai.preAtkTime + self.ai.onAtkTime ) / 1000 );
        else
            self.char:Attack1( ( self.ai.preAtkTime + self.ai.onAtkTime ) / 1000 );
        end
    elseif action == 2 or action == 3 then
        -- 攻击类型2，3：技能攻击
        self.char:Skill( ( self.ai.preAtkTime + self.ai.onAtkTime ) / 1000 );
    elseif action == 4 then
        -- 攻击类型4：持续施法
        self.char:Skill( self.ai.preAtkTime / 1000 );
    end
end

-- 攻击中，根据技能决定动画
function Unit:PlayOnAttack( skill )
    local action = self.ai.currSkill.data.action;
    if action == 4 then
        -- 持续施法
    end
end

-- 死亡
function Unit:PlayDie()
    self.char:Die();
end

-- 被击
function Unit:PlayHited()
    self.char:Hited();
end

-- 入场
function Unit:PlayEnter()
    self.char:Show( true );
    self.char:Enter();    
end

-- 出场
function Unit:PlayQuit()
    -- 如果死亡，直接消失
    if FightUtils.IsUnitDead( self ) then
        self.char:Show( false );
    else
        self.char:Quit();
    end
end

-- 胜利
function Unit:PlayWin()
    self.char:Win();
end

-- 被控
function Unit:PlayOOC()
    -- 暂播晕眩动作
    self.char:Stun();
end

-- 变红
function Unit:PlayRed()
    self.char:Red();
end

-- 变黑
function Unit:PlayHalfBlack()
    self.char:HalfBlack();
end

-- 变黑还原
function Unit:PlayHalfBlackRecover()
    self.char:HalfBlackRecover();
end