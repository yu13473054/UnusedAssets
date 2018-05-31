------------------------------------------------------------------
-- 战斗摄像机控制控制
------------------------------------------------------------------
FightCamera = {};

local _camera;
local _trans;

local _distance;
local _fromViewPos;
local _targetViewPos;

local _duration
local _timer = 0;

function FightCamera.Init( camera )
    _camera = camera;
    _trans = _camera.transform;
end

--function FightCamera.Update( updateTime )
--    lcoal speed = 0.0005
--    FightScene.Translate( updateTime * _speed * ( _targetViewPos.x - _viewPos.x ) );

--    _viewPos = Vector3.Lerp( _viewPos, _targetViewPos, updateTime * speed );
--    _trans.position = _viewPos;
--end

function FightCamera.Update( updateTime )
    if _timer > _duration then
        return;
    end

    -- 驱动地图移动
    FightScene.Translate( _distance * updateTime / _duration );

    -- 移动摄像机
    _trans.position = Vector3.Lerp( _fromViewPos, _targetViewPos, _timer / _duration );

    -- 累计计时器
    _timer = _timer + updateTime;
    
    -- 分发事件
    Event.Fight:DispatchEvent( EVENT_FIGHT_FIGHTCAMERAMOVE, _trans.position );
end

function FightCamera.Move( fromViewPos, targetViewPos, duration )
    -- 记录
    _fromViewPos = fromViewPos;
    _targetViewPos = targetViewPos;
    _distance = _targetViewPos.x - _fromViewPos.x;

    -- 初始化
    _duration = duration;
    _timer = 0;
    _trans.position = fromViewPos;
end