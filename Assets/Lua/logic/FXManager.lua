--------------------------------------------
-- 特效管理器
-- 请自己用poolName，管理好自己生成的特效
--------------------------------------------
FXManager = {};

local _poolList = {};
-- 获得一个特效
function FXManager.Spawn( id, poolGroup )
    -- 没有这个名字的池，创建一个
    local data = Data.FX()[id];
    if _poolList[poolGroup] == nil then
        _poolList[poolGroup] = {};
    end
    if _poolList[poolGroup][data.resName] == nil then
        local prefab = ResourceManager.instance:LoadPrefab( data.resName, data.abName, data.editorPath );
        _poolList[poolGroup][data.resName] = GameObjectPool.New( prefab );
    end
    local obj = _poolList[poolGroup][data.resName]:Spawn();

    -- 如果有生命周期，则生命周期结束后自动回收
    if data.life > 0 then
        Invoke( FXManager.Despawn, data.life, nil, id, poolGroup, obj );
    end

    return obj;
end

-- 回收一个特效
function FXManager.Despawn( id, poolGroup, obj )
    if _poolList[poolGroup] == nil then
        return;
    end
    local data = Data.FX()[id];
    _poolList[poolGroup][data.resName]:Despawn( obj );
end

-- 清空指定特效池
function FXManager.Clear( poolGroup )
    if _poolList[poolGroup] == nil then
        return;
    end    
    for i, pool in pairs( _poolList[poolGroup] ) do
        pool:Clear();
    end
end

-- 清空所有特效
function FXManager.ClearAll()
    for i, poolGroup in pairs( _poolList ) do
        for i, pool in pairs( poolGroup ) do
            pool:Clear();
        end
    end    
end