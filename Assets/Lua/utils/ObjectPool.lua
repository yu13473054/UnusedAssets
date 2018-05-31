---------------------------------
-- Lua Class对象池
-- 自己管理好池的清空时机
---------------------------------
ObjectPool = Class( "ObjectPool" );

-- 构造函数，传需实例化的对象
function ObjectPool:Ctor( class )
    self.instanceTarget = class;
    -- 产出列表
    self.spawnList = {};
    -- 缓存列表
    self.cacheList = {};
end

-- 拿一个对象，传构造参数
function ObjectPool:Spawn(...)
    local obj;
    if #self.cacheList > 0 then
        -- 如果不是预加载，缓存里还存在，直接拿
        obj = self.cacheList[1];
        table.remove( self.cacheList, 1 );
        -- 调初始化方法
        obj:Ctor(...);
    else
        -- 缓存里不存在，新建
        obj = self.instanceTarget.New(...);
    end

    -- 压入产出列表
    table.insert( self.spawnList, obj );
    return obj;
end

-- 回收一个对象 
function ObjectPool:Despawn( obj )
    -- 从产出列表中删除
    local found = false;
    for i, v in ipairs( self.spawnList ) do
        if v == obj then
            table.remove( self.spawnList, i );
            table.insert( self.cacheList, obj );
            break;
        end
    end
end

-- 回收所有
function ObjectPool:DespawnAll()
    for i, obj in ipairs( self.spawnList ) do
        table.insert( self.cacheList, obj );
    end
    self.spawnList = {};
end

-- 销毁所有
function ObjectPool:Clear()
    self.spawnList = {};
    self.cacheList = {};
end

-- 所有产出列表中的调析构，并置空
function ObjectPool:Destory()
    local destoryList = {};    
    for i = 1, #self.spawnList do
        table.insert( destoryList, self.spawnList[i] );
    end

    for i = 1, #destoryList do
        local obj = destoryList[i];
        if obj.Destory ~= nil then
            obj:Destory();
        end
    end
    self:Clear();
end


---------------------------------
-- GameObject对象池
-- 自己管理好池的清空时机
---------------------------------
GameObjectPool = Class( "GameObjectPool" );

-- 回收GameObject的地方
local _cacheRoot = nil;

-- 构造函数，传需实例化的对象
function GameObjectPool:Ctor( instanceTarget, isInsertSpawn )
    if _cacheRoot == nil then
        _cacheRoot = GameObject.Find( "PoolCacheRoot" ).transform;
    end

    self.instanceTarget = instanceTarget;

    -- 产出列表
    self.spawnList = {};
    -- 缓存列表
    self.cacheList = {};
    
    if isInsertSpawn then
        table.insert( self.spawnList, instanceTarget );
    end
end

-- 拿一个对象
function GameObjectPool:Spawn( isPreSpawn )
    local obj;
    if not isPreSpawn and #self.cacheList > 0 then
        -- 如果不是预加载，缓存里还存在，直接拿
        obj = self.cacheList[1];
        table.remove( self.cacheList, 1 );
    else
        -- 缓存里不存在，新建
        obj = GameObject.Instantiate( self.instanceTarget );
        obj.name = self.instanceTarget.name .. "_" .. ( #self.cacheList + #self.spawnList + 1 );
    end

    if isPreSpawn then
        -- 如果是预加载直接
        obj.transform:SetParent( _cacheRoot );
        obj:SetActive( false );
        table.insert( self.cacheList, obj );
    else
        -- 初始化
        obj:SetActive( true );
        -- 压入产出列表
        table.insert( self.spawnList, obj );
    end
    return obj;
end

-- 回收一个对象 
function GameObjectPool:Despawn( obj )
    -- 从产出列表中删除
    for i, v in ipairs( self.spawnList ) do
        if v == obj then
            table.remove( self.spawnList, i );

            -- 重置
            obj.transform:SetParent( _cacheRoot );
            obj:SetActive( false );

            -- 压入缓存列表
            table.insert( self.cacheList, obj );
            return;
        end
    end
end

-- 回收所有
function GameObjectPool:DespawnAll()
    if IsNilOrNull( _cacheRoot ) then return end;

    for i, obj in ipairs( self.spawnList ) do
        table.insert( self.cacheList, obj );
        obj.transform:SetParent( _cacheRoot );
        obj:SetActive( false );
    end
    self.spawnList = {};
end

-- 销毁所有
function GameObjectPool:Clear()
    for i, obj in ipairs( self.spawnList ) do
        if not IsNilOrNull( obj ) then
            GameObject.DestroyImmediate( obj );
        end
    end
    for i, obj in ipairs( self.cacheList ) do
        if not IsNilOrNull( obj ) then
            GameObject.DestroyImmediate( obj );
        end
    end
    self.spawnList = {};
    self.cacheList = {};
end