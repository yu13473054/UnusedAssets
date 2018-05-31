------------------------------------------------------------------
-- 战场调度
-- 会改变Unit属性
-- 战斗系统保持低耦合，原则上不允许出现直接调用战斗意外逻辑系统的接口，比如UI!
------------------------------------------------------------------
Fight = {};

------------------------------------------------
-- 战斗全局常量
------------------------------------------------
-- 战斗类型
FIGHTTYPE_PVE = 0;
FIGHTTYPE_PVP = 1;

-- 逻辑帧毫秒数
FIGHT_LOGICTIME = 25;
-- 单位像素
VIEW_LOGIC_RATIO = 10000;
-- 视觉Y轴偏移量
VIEW_OFFSET_Y = -1.5;
-- 定义下空对象
FIGHT_NULL = 0;

-- 途径
FIGHTPATH_DEFAULT       = 0;    -- 默认
FIGHTPATH_POISON        = 1;    -- 毒

------------------------------------------------
-- 战场调度数据
------------------------------------------------
-- 战场是左右翻转，非镜像。所以Row计算时将不会乘side
-- row排， col列
-- 逻辑排列
--    逻辑排（1开始）：
--    4 -----------
--    2 -----------
--    1 -----------
--    3 -----------
--    逻辑列：
--    1, 2, 3, 4
local _Data;
local _Fight_Row;
local _Fight_Col;

-- 16个索引位置
-- 0  4  8  12
-- 1  5  9  13
-- 2  6  10 14
-- 3  7  11 15
local _Fight_PosIndexed;

------------------------------------------------
-- 战场控件
------------------------------------------------
-- 战斗舞台
local _objStage = nil;
-- 战斗相关对象Root
local _objObjectRoot = nil;
-- 战斗摄影机
local _objCamera;
-- 场景黑背景
local _objBlackTween;

------------------------------------------------
-- 战斗逻辑属性
------------------------------------------------
-- 关于阵营side，-1: 左方， 1：右方。可以直接-side取敌方。
-- 单位列表
local _unitList = {};
-- 备战单位列表
local _unitBackList = {};
-- 技能列表
local _emitterList = {};
-- 子弹列表
local _bulletList = {};
-- 效果列表
local _effectList = {};
-- Buff列表
local _buffList = {};
-- 死亡单位
local _deadUnitList = {};
-- 逻辑计时器
local _timer;
-- 能量
local _magic = {};
-- 战场中心的显示坐标
local _stageCenter = Vector3.zero;
-- 当前波数
local _currWave = 0;
-- 敌人数据
local _enemyData = {};
-- 战斗类型
local _fightType = 0;
-- 逻辑帧计数
local _logicFrameCount = 0;
-- 战斗结束标志
local _fighEnd = false;
-- 时间停止
local _timeStop = false;
local _timeStopTimer = 0;
-- 战斗网络协议数据
local _netProto;

-- 战场初始化，只调用一次
local _inited = false;
local function Fight_Init()
    if _inited then
        return;
    end
    _inited = true;

    -- 启用战斗日志
    FightDebugger.Init();

    -- 读取常量
    _Data = Data.FightConst();
    -- 列的最终结果需要乘side;
    _Fight_Row = { _Data.fightStart_Row, _Data.fightStart_Row + _Data.fightSpace_Row, _Data.fightStart_Row - _Data.fightSpace_Row, _Data.fightStart_Row + _Data.fightSpace_Row * 2 };
    _Fight_Col = { _Data.fightStart_Col, _Data.fightStart_Col + _Data.fightSpace_Col, _Data.fightStart_Col + _Data.fightSpace_Col * 2, _Data.fightStart_Col + _Data.fightSpace_Col * 3 };
    _Fight_PosIndexed =
    {
        { x = _Fight_Col[1], y = _Fight_Row[4] },
        { x = _Fight_Col[1], y = _Fight_Row[2] },
        { x = _Fight_Col[1], y = _Fight_Row[1] },
        { x = _Fight_Col[1], y = _Fight_Row[3] },
    
        { x = _Fight_Col[2], y = _Fight_Row[4] },
        { x = _Fight_Col[2], y = _Fight_Row[2] },
        { x = _Fight_Col[2], y = _Fight_Row[1] },
        { x = _Fight_Col[2], y = _Fight_Row[3] },
    
        { x = _Fight_Col[3], y = _Fight_Row[4] },
        { x = _Fight_Col[3], y = _Fight_Row[2] },
        { x = _Fight_Col[3], y = _Fight_Row[1] },
        { x = _Fight_Col[3], y = _Fight_Row[3] },
    
        { x = _Fight_Col[4], y = _Fight_Row[4] },
        { x = _Fight_Col[4], y = _Fight_Row[2] },
        { x = _Fight_Col[4], y = _Fight_Row[1] },
        { x = _Fight_Col[4], y = _Fight_Row[3] },
    };

    -- 预读数据表
    Data.FightConst();
    Data.Unit();
    Data.Character();
    Data.Skill();
    Data.Emitter();
    Data.Bullet();
    Data.Effect();
    Data.Buff();
end

------------------------------------------------
-- 战斗调度准备
------------------------------------------------
-- 准备作战单位，初始化属性，如果unitinfo不为空，以info中的属性为准，否则读表
-- 准备时设定好初始站位
local function Fight_Pepare( side, list, unitIDList, unitInfoList, posList )
    -- 生成单位
    for i, id in ipairs( unitIDList ) do
        local unit = nil;
        -- 区分下是前场单位，还是后备单位
        if list == _unitList then
            unit = Unit.Create( id, unitInfoList[i], side, i - 1, _objObjectRoot, i );
            -- 发送添加事件
            Event.Fight:DispatchEvent( EVENT_FIGHT_UNITADD, unit );
        else
            unit = Unit.Create( id, unitInfoList[i], side, i + 3, _objObjectRoot, i );
            unit:Quit( true );
        end
        table.insert( list[side], unit );
    end

    -- 单位调整站位
    if list == _unitList then
        local unitList = list[side];

        -- 如果没有位置信息
        if posList == nil then
            -- 按射程排序
            table.sort( unitList, function( x, y ) return x.attr.rng < y.attr.rng; end );
            -- 四排单位表
            local rowList = { {}, {}, {}, {} };
            -- 调整站位
            for col = 1, #unitList, 1 do
                local unit = unitList[col];
                unit.char:Show( true );
                
                -- 遍历前面所有单位，如果射程小于阈值，则不能在同一排
                for row = 1, #rowList, 1 do
                    local jumpRow = false;
                    for i = 1, #rowList[row], 1 do
                        -- 如果射程小于阈值，则不能在同一排
                        if unit.attr.rng - rowList[row][i].attr.rng < _Data.range_Threshold then
                            jumpRow = true;
                            break;
                        end
                    end
                    -- 这排不行，直接下排
                    if not jumpRow then
                        -- 一定不能跟前方相邻单位在同一排
                        if unitList[col-1] == nil or unitList[col-1].row ~= row then
                            -- 找到设置属性，跳出
                            unit.row = row;
                            table.insert( rowList[row], unit );
                            -- 根据排，设置站位
                            unit:SetPos( _Fight_Col[col] * side, _Fight_Row[row] );
                            break;
                        end
                    end
                end
            
                -- 设置显示坐标
                unit:SetViewPos( _stageCenter + Vector3.New( unit.pos.x + _Data.fight_RunDistance * side, unit.pos.y, 0 ) / VIEW_LOGIC_RATIO );
            end

        -- 有位置信息
        else
            for i = 1, #unitList, 1 do
                local unit = unitList[i];
                unit.char:Show( true );
            
                -- 设置逻辑坐标
                unit:SetPos( posList[i].x * side, posList[i].y );
                -- 设置显示坐标
                unit:SetViewPos( _stageCenter + Vector3.New( unit.pos.x + _Data.fight_RunDistance * side, unit.pos.y, 0 ) / VIEW_LOGIC_RATIO );
            end            
        end
    else
        -- 备战单位直接隐藏。
        for i, unit in ipairs( list[side] ) do
            unit.char:Show( false );
        end
    end
end

-- 下一波敌人
local function Fight_Next()
    _logicFrameCount = 0;
    _currWave = _currWave + 1;

    -- 清空死亡敌人
    for i = 1, #_deadUnitList, 1 do
        _deadUnitList[i]:Destory();
    end
    _deadUnitList = {};

    -- 不是第一波，重置玩家逻辑位置
    if _currWave > 1 then
        -- 先清理死亡角色        
        local i = 1;
        while i <= #_unitList[-1] do
            local unit = _unitList[-1][i];
            if FightUtils.IsUnitDead( unit ) then
                table.insert( _deadUnitList, _unitList[-1][i] );
                table.remove( _unitList[-1], i );
            else            
                i = i + 1;
            end
        end


        -- 先按射程排序
        table.sort( _unitList[-1], function( x, y ) return x.attr.rng < y.attr.rng; end );
        -- 第一人站最前排
        local firstUnit = _unitList[-1][1];
        firstUnit:SetPos( -_Fight_Col[1], _unitList[-1][1].pos.y );
        -- 其他人根据相对射程，偏移
        for i = 2, #_unitList[-1], 1 do
            local unit = _unitList[-1][i];
            unit:SetPosX( firstUnit.pos.x - ( unit.attr.rng - firstUnit.attr.rng ) );
        end
    end    

    -- 根据我方第一人的位置，算屏幕中心坐标
    _stageCenter.x = _unitList[-1][1].viewPos.x + ( _Data.fight_RunDistance + _Data.fightStart_Col ) / VIEW_LOGIC_RATIO;

    -- 摄像机设到战场中心
    FightCamera.Move( _objCamera.transform.position, Vector3.New( _stageCenter.x, 0, -100 ), _Data.fight_RunTime + _Data.fightStart_Col / 20 );

    -- 敌人全部转移到死亡列表中
    for i = 1, #_unitList[1], 1 do
        table.insert( _deadUnitList, _unitList[1][i] );
    end
    _unitList[1] = {};

    -- 读取敌人信息
    local idList = {};
    local levelList = {};
    local posList = {};
    for i = 1, #_enemyData.wave[_currWave], 1 do
        local data = _enemyData.wave[_currWave][i];
        idList[i] = data.id;
        levelList[i] = data.level;
        -- 位置转换下
        posList[i] = _Fight_PosIndexed[ data.posIndex + 1 ];
    end
    Fight_Pepare( 1, _unitList, idList, levelList, posList );    

    -- 角色准备完毕，敌我双方都进入跑路状态
    for i, unit in ipairs( _unitList[-1] ) do
        unit:Ready();    
    end
    for i, unit in ipairs( _unitList[1] ) do
        unit:Ready();    
    end

    -- 一波战斗开始
    Event.Fight:DispatchEvent( EVENT_FIGHT_WAVESTART, _unitList );
end

------------------------------------------------
-- 战斗调度
------------------------------------------------
-- 开始战斗
-- 根据类型不同info内容不同
function Fight.Start( fightType, info )
    -- 初始化
    Fight_Init();

    -- 战斗开始
    Event.Fight:DispatchEvent( EVENT_FIGHT_START );

    ---------------------------
    -- 重置数值
    -- 随机种子
    FightUtils.RandomSeed( 12345678 );

    -- 初始化
    _fighEnd = false;
    _fightType = fightType;-- 技能列表
    _emitterList = {};
    _bulletList = {};
    _effectList = {};
    _buffList = {};

    -- 角色列表                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
    _unitList[-1] = {};
    _unitList[1] = {};
    _unitBackList[-1] = {};
    _unitBackList[1] = {};
    
    -- 逻辑帧
    _logicFrameCount = 0;

    -- 能量
    _magic[-1] = 0;
    _magic[1] = 0;
    ---------------------------

    -- 战斗舞台
    _objStage = LoadPrefab( "FightStage" );
    _objCamera = _objStage.transform:GetChild( 0 ):GetComponent( typeof( Camera ) );
    _objObjectRoot = _objStage.transform:GetChild( 1 );
    _objBlackTween = _objStage.transform:GetChild( 0 ):GetChild( 0 ):GetComponent( typeof( DOTweenAnimation ) );

    -- 战斗场景，战斗场景的移动由战斗摄影机驱动
    local fightScene = LoadPrefab( "FightScene_1" ).transform;
    fightScene:SetParent( _objCamera.transform );    
    FightScene.Init( fightScene, _objCamera.orthographicSize );
    -- 战斗摄像机
    FightCamera.Init( _objCamera );

    -- 逻辑计时器
    if _timer == nil then
        _timer = TimerUpdate.New( Fight.Timer, -1 );
    else
        _timer:Reset( Fight.Timer, -1 );
    end
    _timer:Start();

    -- 生成协议
    _netProto = Req_BattleMsg();
    _netProto.btType = fightType;
    _netProto.levelId = info;

    -- 根据战斗类型，准备战场
    if fightType == FIGHTTYPE_PVE then
        -- 初始化我方角色
        Fight_Pepare( -1, _unitList, { 1, 2, 3, 4 }, { 1, 1, 1, 1 } );
        -- 初始化我方备战角色
        Fight_Pepare( -1, _unitBackList, { 5, 6, 7 }, { 1, 1, 1 } );

        -- 发送我方角色列表事件
        Event.Fight:DispatchEvent( EVENT_FIGHT_UNITLIST_INIT, _unitList[-1], _unitBackList[-1] );

        -- 读取敌人信息
        _currWave = 0;

        -- 拿信息
        _enemyData = Data.StageByID()[info];

        -- 摄像机
        _objCamera.transform.position = _unitList[-1][1].viewPos;

        -- 开始第一波敌人
        Fight_Next();
    end

    -- 战斗开始
    Event.Fight:DispatchEvent( EVENT_FIGHT_READY );
end

-- 退出战斗
function Fight.Exit()
    _timer:Stop();

    -- 清空场中
    for i = 1, #_unitList[1], 1 do
        _unitList[1][i]:Destory();
    end
    for i = 1, #_unitList[-1], 1 do
        _unitList[-1][i]:Destory();
    end

    -- 清空备战
    for i = 1, #_unitBackList[1], 1 do
        _unitBackList[1][i]:Destory();
    end
    for i = 1, #_unitBackList[-1], 1 do
        _unitBackList[-1][i]:Destory();
    end

    -- 回收清理
    BulletFX.Clear();
    Emitter.Clear();
    Bullet.Clear();
    Effect.Clear();
    Buff.Clear();
    Unit.Clear();
    FXManager.Clear( "Fight" );
    GameObject.Destroy( _objStage );
end

--------------------------------------------
-- 逻辑队列管理
--------------------------------------------
-- 添加技能
local function Fight_EmitterAdd( emitter )
    table.insert( _emitterList, emitter );
end
Event.Fight:AddListener( EVENT_FIGHT_EMITTER_ADD, Fight_EmitterAdd );
-- 删除技能，不立即删除，下帧再删
local function Fight_EmitterRemove( emitter )
    for i = 1, #_emitterList, 1 do
        if _emitterList[i] == emitter then
            _emitterList[i] = FIGHT_NULL;
            break;
        end
    end
end
Event.Fight:AddListener( EVENT_FIGHT_EMITTER_REMOVE, Fight_EmitterRemove );

-- 添加子弹
local function Fight_BulletAdd( bullet )
    table.insert( _bulletList, bullet );
end
Event.Fight:AddListener( EVENT_FIGHT_BULLET_ADD, Fight_BulletAdd );
-- 删除技能，不立即删除，下帧再删
local function Fight_BulletRemove( bullet )
    for i = 1, #_bulletList, 1 do
        if _bulletList[i] == bullet then
            _bulletList[i] = FIGHT_NULL;
            break;
        end
    end
end
Event.Fight:AddListener( EVENT_FIGHT_BULLET_REMOVE, Fight_BulletRemove );

-- 添加效果
local function Fight_EffectAdd( effect )
    table.insert( _effectList, effect );
end
Event.Fight:AddListener( EVENT_FIGHT_EFFECT_ADD, Fight_EffectAdd );
-- 删除技能，不立即删除，下帧再删
local function Fight_EffectRemove( effect )
    for i = 1, #_effectList, 1 do
        if _effectList[i] == effect then
            _effectList[i] = FIGHT_NULL;
            break;
        end
    end
end
Event.Fight:AddListener( EVENT_FIGHT_EFFECT_REMOVE, Fight_EffectRemove );

-- 添加Buff
local function Fight_BuffAdd( buff )
    table.insert( _buffList, buff );
end
Event.Fight:AddListener( EVENT_FIGHT_BUFF_ADD, Fight_BuffAdd );
-- 删除技能，不立即删除，下帧再删
local function Fight_BuffRemove( buff )
    for i = 1, #_buffList, 1 do
        if _buffList[i] == buff then
            _buffList[i] = FIGHT_NULL;
            break;
        end
    end
end
Event.Fight:AddListener( EVENT_FIGHT_BUFF_REMOVE, Fight_BuffRemove );

-- 角色退场
-- 不立即删除，下帧再删
local function Fight_UnitQuit( unit )
    local unitList = _unitList[unit.ai.side];
    for i = 1, #unitList, 1 do
        if unitList[i] == unit then
            unitList[i] = FIGHT_NULL;
            break;
        end
    end
end
Event.Fight:AddListener( EVENT_FIGHT_UNITQUIT, Fight_UnitQuit );

--------------------------------------------
-- 战场逻辑
--------------------------------------------
local function Fight_MagicChange( side, changeValue )
    -- 能量减少事件
    if changeValue < 0 then    
        Event.Fight:DispatchEvent( EVENT_FIGHT_MAGICREDUCE, _magic[side], changeValue );
    end

    _magic[side] = math.clamp( _magic[side] + changeValue, 0, Data.FightConst().magic_Max );
end

-- 受伤涨能量
local function Fight_MagicChangeDmg( unit, change )
    if change < 0 then
        Fight_MagicChange( unit.ai.side, math.floor( -change / unit.baseAttr.hp * Data.FightConst().magic_DmgFactor ) );
    end
end
Event.Fight:AddListener( EVENT_FIGHT_UNITHPCHANGE, Fight_MagicChangeDmg );

-- 使用了主动技能减能量
local function Fight_OnSkill( unit )
    local skillData = unit.ai.currSkill.data;
    -- 主动技要减能量
    if skillData.skillType == 2 then
        Fight_MagicChange( unit.ai.side, -skillData.cost );
    end
end
Event.Fight:AddListener( EVENT_FIGHT_ONSKILL, Fight_OnSkill );

-- 结束战斗
local function Fight_End( win, lose )    
    if _fighEnd == false then
        Time.timeScale = 0.2;
        Invoke( function() Time.timeScale = 1; end, 3 );
        Invoke( function() Event.Fight:DispatchEvent( EVENT_FIGHT_END ); end, 5 );
        _fighEnd = true;

        -- 发网络包
        -- PVE，非失败才发
        if _fightType == FIGHTTYPE_PVE and not lose[-1] then
            Network.Send( _netProto );
        end
    end
end

-- 时间暂停状态
local function Fight_TimeStop( stop )
    _timeStop = stop;
    Time.timeScale = stop and 0 or 1;

    -- 背景变黑
    if stop then
        _objBlackTween:DOPlayForward();
    else
        _objBlackTween:DOPlayBackwards();
    end

    -- 所有角色变黑
    local listIndex = { -1, 1 };
    for i = 1, #listIndex, 1 do
        local side = listIndex[i];
        for j = 1, #_unitList[side], 1 do
            local unit = _unitList[side][j];
            if stop then
                if not FightUtils.IsUnitDead( unit ) and not unit.noTimeStop then
                    unit:PlayHalfBlack();
                end
            else
                if not FightUtils.IsUnitDead( unit ) then
                    unit:PlayHalfBlackRecover();
                end
            end
        end
    end
end

--------------------------------------------
-- 交互事件
--------------------------------------------
-- 释放技能
local function Fight_SkillActive( unit )
    -- 战斗结束
    if _fighEnd then
        return;
    end

    -- 先判能量够不够
    if unit.skills[2][1].data.cost > _magic[ unit.ai.side ] then
        return;
    end

    -- 操作成功，插入网络包
    if unit:ManualSkill() then
        local btInfo = BattleInfoVO();
        btInfo.section = _currWave;
        btInfo.frame = _logicFrameCount;
        btInfo.type = 1;
        btInfo.param = tostring( unit.index );
        table.insert( _netProto.btInfos, btInfo );
    end
end
Event.Fight:AddListener( EVENT_FIGHT_SKILLACTIVE, Fight_SkillActive );

-- 释放技能
local _changeUnit;
local _changeTarget;
local function Fight_ChangeUnit( target, unit )
    -- 战斗结束
    if _fighEnd then
        return;
    end

    -- 检查满不满足换人条件
    -- 不是后备单位不能换
    if not unit.isBack then
        return;
    end
    -- 跑路状态不能换人
    if target.ai.currState == AIState.run then
        return;
    end

    -- 换人
    _changeUnit = unit;
    _changeTarget = target;
    
    -- 操作成功，插入网络包
    local btInfo = BattleInfoVO();
    btInfo.section = _currWave;
    btInfo.frame = _logicFrameCount;
    btInfo.type = 2;
    btInfo.param = unit.index .. ";" .. target.index;
    table.insert( _netProto.btInfos, btInfo );
end
Event.Fight:AddListener( EVENT_FIGHT_UNITCHANGE, Fight_ChangeUnit );

--------------------------------------------
-- 工具函数
--------------------------------------------
function Fight.GetCamera()
    return _objCamera;
end
function Fight.GetLogicFrameCount()
    return _logicFrameCount;
end
function Fight.GetStageCenter()
    return _stageCenter;
end
function Fight.GetObjectRoot()
    return _objObjectRoot;
end

-- 无人处于跑路，胜利，则正在战斗中
function Fight.IsFighting( side )
    local fighting = true;
    for i = 1, #_unitList[side], 1 do
        local unit = _unitList[side][i];
        if unit ~= FIGHT_NULL then
            if unit.ai.currState == AIState.run then
                fighting = false;
                break;
            elseif unit.ai.currState == AIState.win then
                fighting = false;
                break;
            end
        end
    end
    return fighting;
end

function Fight.GetUnitList()
    return _unitList;
end

--------------------------------------------
-- 战场逻辑驱动
--------------------------------------------
function Fight_Update( updateTime )
    ----------------------------------
    -- 战斗帧，能量回复
    ----------------------------------
    -- 所有人在战斗中才认为战斗在进行。
    -- 条件：无人处于跑路，胜利
    if Fight.IsFighting( -1 ) and Fight.IsFighting( 1 ) then
        Fight_MagicChange( -1, Data.FightConst().magic_Speed * updateTime );
        Fight_MagicChange( 1, Data.FightConst().magic_Speed * updateTime );
        
        -- 增加帧数
        _logicFrameCount = _logicFrameCount + 1;
    end

    ----------------------------------
    -- 换人
    ----------------------------------
    if _timeStopTimer > 0 then
        _timeStopTimer = _timeStopTimer - updateTime;
        if _timeStopTimer <= 0 then
            Fight_TimeStop( false );
        end
    end

    if _changeUnit ~= nil then
        _changeUnit:ManualEnter( _changeTarget );
        _changeTarget:ManualQuit();

        table.insert( _unitList[ _changeUnit.ai.side ], _changeUnit );
        
        _timeStopTimer = _changeUnit.data.lockTime;
        Fight_TimeStop( true );

        _changeUnit = nil;
    end

    ----------------------------------
    -- 逻辑对象更新
    ----------------------------------
    -- 发射器更新
    local i = 1;
    while i <= #_emitterList do
        -- 如果已被删除
        if _emitterList[i] == FIGHT_NULL then
            table.remove( _emitterList, i );
        else
            if not _timeStop or ( _timeStop and _emitterList[i].ai.unit.noTimeStop ) then
                _emitterList[i]:Update( updateTime );
            end

            i = i + 1;
        end
    end
    -- 子弹更新
    i = 1;
    while i <= #_bulletList do
        -- 如果已被删除
        if _bulletList[i] == FIGHT_NULL then
            table.remove( _bulletList, i );
        else
            if not _timeStop or ( _timeStop and _bulletList[i].ai.unit.noTimeStop ) then
                _bulletList[i]:Update( updateTime );
            end

            i = i + 1;
        end
    end  
    -- 效果更新
    i = 1;
    while i <= #_effectList do
        -- 如果已被删除
        if _effectList[i] == FIGHT_NULL then
            table.remove( _effectList, i );
        else
            if not _timeStop or ( _timeStop and _effectList[i].ai.unit.noTimeStop ) then
                _effectList[i]:Update( updateTime );
            end

            i = i + 1;
        end
    end
    -- Buff更新
    i = 1;
    while i <= #_buffList do
        -- 如果已被删除
        if _buffList[i] == FIGHT_NULL then
            table.remove( _buffList, i );
        else
            if not _timeStop then
                _buffList[i]:Update( updateTime );
            end
            i = i + 1;
        end
    end  

    -- 单位更新，同时获得胜负结果
    local win = { [-1] = true, [1] = true };
    local lose = { [-1] = true, [1] = true };
    local listIndex = { -1, 1 };
    for j = 1, #listIndex, 1 do
        i = 1;
        local side = listIndex[j];
        while i <= #_unitList[side] do
            local unit = _unitList[side][i];
            -- 如果已被删除
            if unit == FIGHT_NULL then
                table.remove( _unitList[side], i );
            else
                if not _timeStop or ( _timeStop and unit.noTimeStop ) then
                    unit:Update( updateTime, _timeStop );
                end

                if unit.ai.currState ~= AIState.dead then
                    -- 有一人非死亡，就没失败
                    lose[side] = false;

                    -- 有一人非死亡非胜利，就没胜利
                    if unit.ai.currState ~= AIState.win then
                        win[side] = false;
                    end
                end
                i = i + 1;
            end
        end
    end

    ----------------------------------
    -- 处理胜败，优先判失败
    ----------------------------------
    -- PVE的情况    
    if _fightType == FIGHTTYPE_PVE then
        -- 任一方死完，没有下波敌人结束战斗
        if lose[-1] or ( lose[1] and _enemyData.wave[ _currWave + 1 ] == nil ) then
            Fight_End( win, lose );

        -- 否则，左方角色全部进入胜利状态后进入下场战斗
        elseif win[-1] then            
            Event.Fight:DispatchEvent( EVENT_FIGHT_WAVEEND, _unitList );
            Fight_Next( win, lose );
        end
    else
        -- 任一方死完，结束战斗
        if lose[-1] or lose[1] then
            Fight_End( win, lose );
        end
    end

    ----------------------------------
    -- 显示更新
    ----------------------------------
    FightCamera.Update( updateTime );

    ----------------------------------
    -- 发一些逻辑事件
    ----------------------------------
    Event.Fight:DispatchEvent( EVENT_FIGHT_MAGICSYNC, _magic );
end

local _fightTimer = 0;
function Fight.Timer()
    _fightTimer = _fightTimer + Time.unscaledDeltaTime * 1000;
    while _fightTimer > FIGHT_LOGICTIME do
        _fightTimer = _fightTimer - FIGHT_LOGICTIME;
        Fight_Update( FIGHT_LOGICTIME );
    end
end