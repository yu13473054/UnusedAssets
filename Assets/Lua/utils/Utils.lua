--[[ 这里面放 不太可能会被修改的&&和逻辑无关的 工具方法 ]]

-- 克隆一个表，*注意*会递归拷贝子表
function Clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

-- 类
function Class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.Ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.New(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:Ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {Ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.New(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:Ctor(...)
            return instance
        end
    end

    return cls
end

-------------------------------------------
-- 延迟执行
-------------------------------------------
local InvokeInfo = Class( "InvokeInfo" );
function InvokeInfo:Ctor( func, delay, name, ... )
    self.func = func;
    self.param = { ... };
    self.name = name;
    self.timer = Timer.New( function() self:Func(); end, delay, 1, false );
    self.timer:Start();
end
function InvokeInfo:Func()
    self.func( unpack( self.param ) );
    InvokeStop( self.name );
end
function InvokeInfo:Stop()
    self.timer:Stop();
end

local _invokeList = {};
-- 如果名字为空不管理
function Invoke( func, delay, name, ... )
    -- 如果名字为空不管理
    if name == nil then
        InvokeInfo.New( func, delay, name, ... );
        return;
    end

    -- 名字不为空，管理好
    if _invokeList[name] ~= nil then
        return;
    end
    _invokeList[name] = InvokeInfo.New( func, delay, name, ... );
end
-- 停止计时
function InvokeStop( name )
    if name == nil then
        return;
    end

    -- 停止并置空
    if _invokeList[name] ~= nil then
        _invokeList[name]:Stop();
    end
    _invokeList[name] = nil;
end