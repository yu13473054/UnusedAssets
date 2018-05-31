---------------------------------
-- 效果，基本逻辑和数据
-- *池管理*
---------------------------------
Effect = Class( "Effect" );

-- 战斗相关的对象都用池管理
local _pool = ObjectPool.New( Effect );
function Effect.Create( effectID, bullet )
    return _pool:Spawn( effectID, bullet );
end
function Effect.Clear()
    _pool:Destory();
end

---------------------------------
-- 构造/重置方法
---------------------------------
function Effect:Ctor( effectID, bullet )
    -- 直接引用表
    self.data = Data.Effect()[effectID];

    self.ai = bullet.ai;
    
    ------------------
    -- 逻辑数据
    ------------------
    -- 生效次数，计数
    self.count = 0;

    -- 计时器
    self.delayTimer = 0;-- 延迟计时
    self.timer = 0;

    -- 目标
    if bullet.target.__cname ~= "Unit" then
        self.target = nil;
    else
        self.target = bullet.target;
    end
        
    -- 效果激活
    Event.Fight:DispatchEvent( EVENT_FIGHT_EFFECT_ADD, self );
end

function Effect:Destroy()
    -- 回收
    _pool:Despawn( self );
    Event.Fight:DispatchEvent( EVENT_FIGHT_EFFECT_REMOVE, self );
end

---------------------------------
-- 技能效果基础逻辑
---------------------------------
function Effect:Update( updateTime )
    -- 延时期间不执行逻辑
    if self.delayTimer < self.data.delay then
        self.delayTimer = self.delayTimer + updateTime;
        return;
    end

    -- 间隔为0或时间超过应有计数，生效一次
    if ( self.data.interval == 0 and self.count == 0 ) or ( self.data.interval ~= 0 and math.floor( self.timer / self.data.interval ) > self.count ) then
        -- 请求判定
        local targetList = EffectTarget[self.data.targetType]( self );

        -- 对每个目标产生效果
        for i = 1, #targetList, 1 do
            local target = targetList[i];
            -- 效果逻辑决定播什么样的特效，nil播第一个特效
            local fxIndex = EffectAction[ self.data.actionType ]( self, target );

            -- 判定目标播放特效
            if #self.data.fxList > 0 then
                fxIndex = fxIndex or 1;
                for i, target in ipairs( targetList ) do
                    local fx = FXManager.Spawn( self.data.fxList[fxIndex], "Fight" ).transform;
                    fx:SetParent( target.transform );
                    FightUtils.FXSetViewPos( fx, target.transform.position + target.char:GetMiddlePos() );
                end            
            end
        end

        self.count = self.count + 1;
    end

    -- 判定生命周期
    if self.timer >= self.data.life then
        self:Destroy();
        return;
    end

    self.timer = self.timer + updateTime;
end