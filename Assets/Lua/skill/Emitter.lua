---------------------------------
-- 发射器，基本逻辑和数据
-- 通过EmitterTarget选目标
-- 最后激活发射子弹
-- *池管理*
---------------------------------
Emitter = Class( "Emitter" );

-- 战斗相关的对象都用池管理
local _pool = ObjectPool.New( Emitter );
function Emitter.Create( emitterID, ai )
    return _pool:Spawn( emitterID, ai );
end
function Emitter.Clear()
    _pool:Destory();
end

---------------------------------
-- 构造/析构方法
---------------------------------
-- 构造函数
function Emitter:Ctor( emitterID, ai )
    -- 直接引用表
    self.data = Data.Emitter()[emitterID];

    ------------------
    -- 逻辑属性
    ------------------
    -- 产生技能的AI
    self.ai = ai;

    -- 计时器
    self.timer = 0;
    self.life = ai.onAtkTime;

    -- 生效次数，计数器
    self.count = 0;
    
    -- 添加发射器
    Event.Fight:DispatchEvent( EVENT_FIGHT_EMITTER_ADD, self );

    -- 视觉位置
    self.viewPos = ai.unit.transform.position + ai.unit.char:GetMiddlePos() + Vector3.New( self.data.offsetX, self.data.offsetY, 0 );
    -- 特效
    self.gameObject = nil;
    if self.data.fxID > 0 then
        self.gameObject = FXManager.Spawn( self.data.fxID, "Fight" );
        self.gameObject.transform:SetParent( ai.unit.transform.parent );
        FightUtils.FXSetViewPos( self.gameObject.transform, self.viewPos );
    end
end

-- 销毁方法
function Emitter:Destroy()
    -- 回收
    _pool:Despawn( self );    
    
    if self.data.fxID > 0 then
        FXManager.Despawn( self.data.fxID, "Fight", self.gameObject );
    end

    Event.Fight:DispatchEvent( EVENT_FIGHT_EMITTER_REMOVE, self );
end

---------------------------------
-- 发射器基础逻辑
---------------------------------
-- 更新
function Emitter:Update( updateTime )
    -- 如果间隔等于0，直接生效
    if ( self.data.interval == 0 and self.count == 0 ) or ( self.data.interval ~= 0 and math.floor( self.timer / self.data.interval ) > self.count ) then    
        -- 找目标
        local target = EmitterTarget[ self.data.targetType ]( self );

        -- 产生指定数量的子弹，不能超过目标数
        for i = 1, math.min( self.data.bulletNum, #target ), 1 do
            Bullet.Create( self.data.bulletID, self, self.ai, target[i] );
        end

        -- 累加生效次数
        self.count = self.count + 1;
    end

    -- 生命结束
    if self.timer >= self.life then
        self:Destroy();
        return;
    end
    
    -- 计时器
    self.timer = self.timer + updateTime;
end
