-- 角色相关
CharacterManager = {};

-- 对象池
local _charCache = {};

-- 产生一个角色
function CharacterManager.Spawn( res, root )
    local charPool = _charCache[res];
    local obj;
    if charPool == nil then
        -- 读一个资源
        obj = SpineUtils.CreateCharacter( "Char_" .. res );
        charPool = GameObjectPool.New( obj, true );
        _charCache[res] = charPool;
    else
        obj = charPool:Spawn( false );
    end
    obj.transform:SetParent( root );
    obj.transform.localScale = Vector3.one;
    obj.transform.localPosition = Vector3.zero;
    return obj;
end

-- 回收角色
function CharacterManager.Despawn( res, gameObject )
    local charPool = _charCache[res];
    if charPool ~= nil then
        charPool:Despawn( gameObject );
    end
end

-- 清理资源
function CharacterManager.Clear()
    for i, pool in pairs( _charCache ) do
        pool:Clear();
    end    
end