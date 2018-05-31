---------------------------------
-- 从Unit中把AI部分分离出来
-- 战斗AI，放数据和基础逻辑。
-- 具体逻辑在AIState，这里只实例化并保存逻辑所需的值。以及判定释放何种技能。
-- 状态机为单实力，AI中保存引用。
---------------------------------
AI = Class( "AI" );

---------------------------------
-- 构造方法
---------------------------------
-- 构造函数
function AI:Ctor( aiID, unit, side )
    -- 根据aiID决定使用哪个状态机
    self.state = AIState;

    -- 基础属性
    self.unit = unit;
    self.currState = nil;
    self.unitList = Fight.GetUnitList();
    self.side = side;
    self.target = nil;

    -- 技能
    self.currSkill = nil;
    -- 记下技能信息，技能可能不在了
    self.preAtkTime = 0;
    self.onAtkTime = 0;
    self.aftAtkTime = 0;

    -- 计算属性
    -- 当前状态的持续时间
    self.stateTimer = 0;

    -- 跑路开始时的位置
    self.runStartViewPos = nil;
    self.runEndViewPos = nil;
end

---------------------------------
-- AI逻辑
---------------------------------
-- 一次逻辑帧
function AI:Update( updateTime )
    -- 不执行状态变更才执行当前状态逻辑
    if self.currState ~= nil then
        self.currState.Update( self, updateTime );
    end
end

-- 自动判定应该放什么技能
function AI:SkillAuto()
    self.currSkill = self.unit.skills[1][1];
    self:AttackPrepare();
end

-- 手动指定技能
function AI:Skill( skillType, index )
    self.unit:ManualFinish();
    self.currSkill = self.unit.skills[skillType][index];
    self:AttackPrepare();
end

-- 技能准备
function AI:AttackPrepare()
    -- 如果是普通攻击提前算好攻击时间，除了攻击间隔
    if self.currSkill.data.skillType == 1 then
        self.preAtkTime = math.floor( self.currSkill.data.preAtkTime * self.unit.attr.atkSpd / 100 );
        self.onAtkTime = math.floor( self.currSkill.data.onAtkTime * self.unit.attr.atkSpd / 100 );
        self.aftAtkTime = self.currSkill.data.aftAtkTime;
    else
        self.preAtkTime = self.currSkill.data.preAtkTime;
        self.onAtkTime = self.currSkill.data.onAtkTime;
        self.aftAtkTime = self.currSkill.data.aftAtkTime;
    end

    -- 释放技能
    Event.Fight:DispatchEvent( EVENT_FIGHT_ONSKILL, self.unit );
end

-- 根据选好的技能攻击
function AI:Attack()
    -- 生成发射器
    for i = 1, #self.currSkill.data.emitterList, 1 do
        local emitterID = self.currSkill.data.emitterList[i];
        if emitterID > 0 then
            Emitter.Create( self.currSkill.data.emitterList[i], self );
        end
    end
end