---------------------------------
-- 子弹，基本逻辑和数据
-- 通过SkillTarget选目标
-- *池管理*
---------------------------------
Bullet = Class( "Bullet" );

-- 战斗相关的对象都用池管理
local _pool = ObjectPool.New( Bullet );
function Bullet.Create( bulletID, emitter, ai, target )
    return _pool:Spawn( bulletID, emitter, ai, target );
end
function Bullet.Clear()
    _pool:Destory();
end

---------------------------------
-- 构造/析构方法
---------------------------------
-- 构造函数，目标可以是坐标或是单位
function Bullet:Ctor( bulletID, emitter, ai, target )
    -- 直接引用表
    self.data = Data.Bullet()[bulletID];

    self.ai = ai;

    ------------------
    -- 逻辑属性
    ------------------
    self.timer = 0;    
    self.hitTime = 0

    local targetPos;
    if target.__cname == "Unit" then
        targetPos = target.pos;
    else
        targetPos = target;
    end
    -- 如果速度>0，算命中时间
    if self.data.speed > 0 then
        self.hitTime = math.floor( math.abs( targetPos.x - self.ai.unit.pos.x ) / self.data.speed );
    end

    -- 目标
    self.target = target;

    -- 子弹特效
    if self.data.fxID > 0 or self.data.hitFXID > 0 then        
        local targetViewPos;
        if target.__cname == "Unit" then
            targetViewPos = target.transform.position + target.char:GetMiddlePos();
        else
            targetViewPos = FightUtils.Pos2ViewPos( targetPos );
        end
        -- 起始位置为发射器位置
        BulletFX.Create( bulletID, emitter.viewPos, targetViewPos, self.hitTime, ai.unit.transform.parent );
    end
    
    -- 激活
    Event.Fight:DispatchEvent( EVENT_FIGHT_BULLET_ADD, self );
end

-- 销毁方法
function Bullet:Destroy()
    -- 回收
    _pool:Despawn( self );
    Event.Fight:DispatchEvent( EVENT_FIGHT_BULLET_REMOVE, self );
end

---------------------------------
-- 子弹基础逻辑
---------------------------------
-- 更新
function Bullet:Update( updateTime )
    -- 计时结束生效
    if self.timer >= self.hitTime then
        -- 产生效果
        for i, id in ipairs( self.data.effectList ) do
            Effect.Create( id, self );
        end

        -- 结束自己
        self:Destroy();
        return;
    end

    -- 累计距离
    self.timer = self.timer + updateTime;
end
