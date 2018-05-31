---------------------------------
-- 子弹特效表现
-- 存储弹道表所需数据
-- 子弹创建后，自我驱动逻辑，自己控制生命周期
-- *池管理*
---------------------------------
BulletFX = Class( "BulletFX" );

-- 战斗相关的对象都用池管理
local _pool = ObjectPool.New( BulletFX );
function BulletFX.Create( bulletID, fromViewPos, targetViewPos, life, root )
    return _pool:Spawn( bulletID, fromViewPos, targetViewPos, life, root );
end
function BulletFX.Clear()
    _pool:Destory();
end

function BulletFX:Ctor( bulletID, fromViewPos, targetViewPos, life, root )
    self.data = Data.Bullet()[ bulletID ];

    -- 父节点
    self.root = root;

    -- 数据
    self.fromViewPos = fromViewPos;
    self.targetViewPos = targetViewPos;
    self.life = life;

    -- 运算过程中用的临时变量
    self.value = {};

    -- 计时器
    self.timer = 0;
    if self.timerHandler ~= nil then
         self.timerHandler:Reset( function() self:Update(); end, 1, -1 );
    else
        self.timerHandler = FrameTimer.New( function() self:Update(); end, 1, -1 );
    end

    -- 生成特效
    self.transform = nil;
    self.gameObject = nil;
    if self.data.fxID > 0 then
        self.gameObject = FXManager.Spawn( self.data.fxID, "Fight" );
        -- 先隐藏重置，防止拖尾穿帮
        self.gameObject:SetActive( false );
        self.transform = self.gameObject.transform;
        self.transform:SetParent( root );
        FightUtils.FXSetViewPos( self.transform, fromViewPos );
        self.gameObject:SetActive( true );
    end

    self.timerHandler:Start();
end

-- 销毁，回收特效和自己的对象
function BulletFX:Destory()
    self.timerHandler:Stop();
    
    if self.data.fxID > 0 then
        FXManager.Despawn( self.data.fxID, "Fight", self.gameObject );
    end
    _pool:Despawn( self );
end

---------------------------------
-- 逻辑
---------------------------------
-- 根据逻辑更新弹道
function BulletFX:Update()
    if self.data.actionType >= 0 then
        BulletFXAction[self.data.actionType]( self, Time.deltaTime * 1000 );
    end
end

-- 命中
function BulletFX:Hit()
    -- 如果命中特效不为空，产生命中特效
    if self.data.hitFXID > 0 then
        local hit = FXManager.Spawn( self.data.hitFXID, "Fight" ).transform;
        hit:SetParent( self.root );
        hit.position = self.targetViewPos;
    end

    -- 销毁
    self:Destory();
end