---------------------------------
-- 效果，基本逻辑和数据
-- *池管理*
---------------------------------
Buff = Class( "Buff" );

-- 战斗相关的对象都用池管理
local _pool = ObjectPool.New( Buff );
function Buff.Create( buffID, unit, source )
    return _pool:Spawn( buffID, unit, source );
end
function Buff.Clear()
    _pool:Destory();
end

---------------------------------
-- 构造/重置方法
---------------------------------
function Buff:Ctor( buffID, unit, source )
    -- 直接引用表
    self.data = Data.Buff()[buffID];

    ------------------
    -- 逻辑数据
    ------------------
    -- Buff产生者
    self.source = source;

    -- 作用对象
    self.unit = unit;

    -- 生效次数，计数
    self.count = 0;

    -- 计时器
    self.timer = 0;

    -- 驱散
    self.despel = false;

    -- 表现挂在角色身上
    self.fx = nil;
    if self.data.fxID > 0 then
        self.fx = FXManager.Spawn( self.data.fxID, "Fight" );
        self.fx.transform:SetParent( unit.transform );
        FightUtils.FXSetViewPos( self.fx.transform, self.unit.transform.position + unit.char:GetMiddlePos() );
        FightUtils.FXTimeStop( self.fx.transform, source.noTimeStop );
    end
        
    -- 效果激活
    Event.Fight:DispatchEvent( EVENT_FIGHT_BUFF_ADD, self );
end

function Buff:Destroy()
    -- 调用结束方法
    BuffAction[ self.data.actionType ].OnQuit( self );

    -- 清除角色身上的Buff
    self.unit:BuffRemove( self.data.id );

    -- 特效
    -- 回收
    if self.fx ~= nil then
        FXManager.Despawn( self.data.fxID, "Fight", self.fx );
    end
    -- 结束特效
    if self.data.quitFXID > 0 then
        local quitFX = FXManager.Spawn( self.data.quitFXID, "Fight" ).transform;
        quitFX:SetParent( self.unit.transform );
        FightUtils.FXSetViewPos( quitFX, self.unit.transform.position + self.unit.char:GetMiddlePos() );
        FightUtils.FXTimeStop( quitFX, source.noTimeStop );
    end
    
    -- 回收
    _pool:Despawn( self );
    Event.Fight:DispatchEvent( EVENT_FIGHT_BUFF_REMOVE, self );
end

---------------------------------
-- Buff效果基础逻辑
---------------------------------
function Buff:Update( updateTime )
    local buffAction = BuffAction[self.data.actionType];

    -- 是否被驱散
    if self.despel then
        self:Destroy();
        return;
    end

    -- 间隔为0或时间超过应有计数，生效一次
    if ( self.data.interval == 0 and self.count == 0 ) or ( self.data.interval ~= 0 and math.floor( self.timer / self.data.interval ) > self.count ) then
        buffAction.OnActive( self );
        self.count = self.count + 1;
    end

    -- 主动检查Buff是否应该结束
    if buffAction.Check( self ) then
        self:Destroy();
        return;
    end

    -- 判定生命周期
    if self.timer >= self.data.life then
        self:Destroy();
        return;
    end

    self.timer = self.timer + updateTime;
end

-- 驱散
function Buff:Dispel()
    -- 检查是否可被驱散
    if self.data.canDispel == 1 then
        return;
    end

    self.despel = true;
end