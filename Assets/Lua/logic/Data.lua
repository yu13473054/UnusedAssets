-- 数据
Data = {};

-- 配置文件
Data.userini = nil;

-- 皮肤表
local _character = nil;
-- 单位表
local _unit = nil;
-- 技能表
local _skill = nil;
-- 发射器表
local _emitter = nil;
-- 子弹表
local _bullet = nil;
-- 效果表
local _effect = nil;
-- Buff表
local _buff = nil;
-- 战斗常量
local _fightConst = nil;
-- 关卡
local _stage = nil;
local _stageByID = nil;
-- 特效表
local _fx = nil;
-- 道具表
local _item = nil;
-- 小传表
local _biography = nil;
-- 剧情表
local _story = nil;
-- 星座表
local _constellation = nil;

-- 配置数据初始化
function Data.OnInit()
    -- 读取配置文件

    -- 读取ini配置文件
	Data.userini = ConfigHandler.New();
	Data.userini:Open( AppConst.configPath .. "user.txt" );

    -- 设下配置的默认值
	if Data.userini:ReadValue( "UserName", "" ) == "" then
		Data.userini:WriteValue( "UserName", "" );
	end
	if Data.userini:ReadValue( "ServerID", "" ) == "" then
		Data.userini:WriteValue( "ServerID", 0 );
	end

    -- 如果需要预加载，在这里读进去
    -- Data.Unit();
end

-- 单位表
function Data.Unit()
    if _unit ~= nil then
        return _unit;
    end
    _unit = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Unit.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
            local unit = 
            {
                name = tableHandler:GetValue( records, 1 ),
                hp = tonumber( tableHandler:GetValue( records, 2 ) ),
                lvlHp = tonumber( tableHandler:GetValue( records, 3 ) ),
                atk = tonumber( tableHandler:GetValue( records, 4 ) ),
                lvlAtk = tonumber( tableHandler:GetValue( records, 5 ) ),
                def = tonumber( tableHandler:GetValue( records, 6 ) ),
                lvlDef = tonumber( tableHandler:GetValue( records, 7 ) ),
                rng = tonumber( tableHandler:GetValue( records, 8 ) ),
                lvlRng = tonumber( tableHandler:GetValue( records, 9 ) ),
                spd = tonumber( tableHandler:GetValue( records, 10 ) ),
                lvlSpd = tonumber( tableHandler:GetValue( records, 11 ) ),
                crit = tonumber( tableHandler:GetValue( records, 12 ) ),
                lvlCrit = tonumber( tableHandler:GetValue( records, 13 ) ),
                critDmgPlus = tonumber( tableHandler:GetValue( records, 14 ) ),
                atkSpd = tonumber( tableHandler:GetValue( records, 15 ) ),
                lvlAtkSpd = tonumber( tableHandler:GetValue( records, 16 ) ),
                cldX = tonumber( tableHandler:GetValue( records, 17 ) ),
                cldY = tonumber( tableHandler:GetValue( records, 18 ) ),
                skill =
                { 
                    tableHandler:GetValue( records, 19 ),
                    tableHandler:GetValue( records, 20 ),
                    tableHandler:GetValue( records, 21 ),
                    tableHandler:GetValue( records, 22 ),
                },
                lockTime = tonumber( tableHandler:GetValue( records, 23 ) ),
                swCD = tonumber( tableHandler:GetValue( records, 24 ) ),
                grade = tonumber( tableHandler:GetValue( records, 25 ) ),
                initStar = tonumber( tableHandler:GetValue( records, 26 ) ),
                constellID = tonumber( tableHandler:GetValue( records, 27 ) ),
                charID = tonumber( tableHandler:GetValue( records, 28 ) ),
                nameID = tonumber( tableHandler:GetValue( records, 29 ) ),
                cVID = tonumber( tableHandler:GetValue( records, 30 ) ),
            };            
			table.insert( _unit, id, unit );

            -- 解析技能
            -- 1：普攻，2：大招，3：换人，4：被动          
            for i = 1, #unit.skill, 1 do
                if unit.skill[i] ~= "" then
                    local skills = string.split( unit.skill[i], ';' );
                    unit.skill[i] = {};
                    for j = 1, #skills, 1 do
                        table.insert( unit.skill[i], tonumber( skills[j] ) );
                    end
                else
                    unit.skill[i] = {};
                end
            end
		end
	end
    return _unit;
end

-- 皮肤表
function Data.Character()
    if _character ~= nil then
        return _character;
    end
    _character = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Character.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _character, id,
            {
                res = tableHandler:GetValue( records, 2 ),
                height = tonumber( tableHandler:GetValue( records, 3 ) ),
            } );
		end
	end
    return _character;
end

-- 技能表
function Data.Skill()
    if _skill ~= nil then
        return _skill;
    end
    _skill = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Skill.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
            local skill = 
            {
                id = id,
                emitterList = tableHandler:GetValue( records, 2 ),
                cost = tonumber( tableHandler:GetValue( records, 3 ) ),
                cd = tonumber( tableHandler:GetValue( records, 4 ) ),
                -- 这里加了1，-- 1：普攻，2：大招，3：换人，4：被动
                skillType = tonumber( tableHandler:GetValue( records, 5 ) ),
                preAtkTime = tonumber( tableHandler:GetValue( records, 6 ) ),
                onAtkTime = tonumber( tableHandler:GetValue( records, 7 ) ),
                aftAtkTime = tonumber( tableHandler:GetValue( records, 8 ) ),
                action = tonumber( tableHandler:GetValue( records, 9 ) ),
            }
			table.insert( _skill, id, skill );

            -- 解析发射器
            local emitters = string.split( skill.emitterList, ';' );
            skill.emitterList = {};
            for i = 1, #emitters, 1 do
                table.insert( skill.emitterList, tonumber( emitters[i] ) );
            end            
		end
	end
    return _skill;
end

-- 发射器表
function Data.Emitter()
    if _emitter ~= nil then
        return _emitter;
    end
    _emitter = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Emitter.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _emitter, id,
            {
                id = id,
                targetType = tonumber( tableHandler:GetValue( records, 2 ) ),
                side = tonumber( tableHandler:GetValue( records, 3 ) ),
                corX = tonumber( tableHandler:GetValue( records, 4 ) ),
                corY = tonumber( tableHandler:GetValue( records, 5 ) ),
                bulletID = tonumber( tableHandler:GetValue( records, 6 ) ),
                bulletNum = tonumber( tableHandler:GetValue( records, 7 ) ),
                interval = tonumber( tableHandler:GetValue( records, 8 ) ),
                fxID = tonumber( tableHandler:GetValue( records, 9 ) ),
                offsetX = tonumber( tableHandler:GetValue( records, 10 ) ),
                offsetY = tonumber( tableHandler:GetValue( records, 11 ) ),
            } );
		end
	end
    return _emitter;
end

-- 子弹表
function Data.Bullet()
    if _bullet ~= nil then
        return _bullet;
    end
    _bullet = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Bullet.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
            local bullet = 
            {
                id = id,
                speed = tonumber( tableHandler:GetValue( records, 2 ) ),
                effectList = tableHandler:GetValue( records, 3 ),
                actionType = tonumber(tableHandler:GetValue( records, 4 ) ),
                fxID = tonumber(tableHandler:GetValue( records, 5 ) ),
                hitFXID = tonumber(tableHandler:GetValue( records, 6 ) ),
            };
			table.insert( _bullet, id, bullet );

            -- 解析下effectList
            local effects = string.split( bullet.effectList, ';' );
            bullet.effectList = {};
            for i = 1, #effects, 1 do
                table.insert( bullet.effectList, tonumber( effects[i] ) );
            end
		end
	end
    return _bullet;
end

-- 效果表
function Data.Effect()
    if _effect ~= nil then
        return _effect;
    end
    _effect = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Effect.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
            local effect = 
            {
                id = id,
                actionType = tonumber( tableHandler:GetValue( records, 2 ) ),
                targetType = tonumber( tableHandler:GetValue( records, 3 ) ),
                side = tonumber( tableHandler:GetValue( records, 4 ) ),
                cldX = tonumber( tableHandler:GetValue( records, 5 ) ),
                cldY = tonumber( tableHandler:GetValue( records, 6 ) ),
                maxCount = tonumber( tableHandler:GetValue( records, 7 ) ),
                delay = tonumber( tableHandler:GetValue( records, 8 ) ),
                life = tonumber( tableHandler:GetValue( records, 9 ) ),
                interval = tonumber( tableHandler:GetValue( records, 10 ) ),
                value =
                {
                    tonumber( tableHandler:GetValue( records, 11 ) ),
                    tonumber( tableHandler:GetValue( records, 12 ) ),
                    tonumber( tableHandler:GetValue( records, 13 ) ),
                    tonumber( tableHandler:GetValue( records, 14 ) ),
                },
                fxList = tableHandler:GetValue( records, 15 ),
            };
			table.insert( _effect, id, effect );

            -- 解析下fxList
            local fx = string.split( effect.fxList, ';' );
            effect.fxList = {};
            for i = 1, #fx, 1 do
                table.insert( effect.fxList, tonumber( fx[i] ) );
            end
		end
	end
    return _effect;
end

-- Buff表
function Data.Buff()
    if _buff ~= nil then
        return _buff;
    end
    _buff = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Buff.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _buff, id,
            {
                id = id,
                actionType = tonumber( tableHandler:GetValue( records, 2 ) ),
                life = tonumber( tableHandler:GetValue( records, 3 ) ),
                interval = tonumber( tableHandler:GetValue( records, 4 ) ),
                value =
                {
                    tonumber( tableHandler:GetValue( records, 5 ) ),
                    tonumber( tableHandler:GetValue( records, 6 ) ),
                    tonumber( tableHandler:GetValue( records, 7 ) ),
                    tonumber( tableHandler:GetValue( records, 8 ) ),
                },
                type = tonumber( tableHandler:GetValue( records, 9 ) ),
                canDispel = tonumber( tableHandler:GetValue( records, 10 ) ),
                isAura = tonumber( tableHandler:GetValue( records, 11 ) ),
                fxID = tonumber( tableHandler:GetValue( records, 12 ) ),
                quitFXID = tonumber( tableHandler:GetValue( records, 13 ) ),
                path = tonumber( tableHandler:GetValue( records, 14 ) ),
            } );
		end
	end
    return _buff;
end

-- 战斗常量表
function Data.FightConst()
    if _fightConst ~= nil then
        return _fightConst;
    end
    _fightConst = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "FightConst.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for i = 0, tableRecordsNum, 1 do
            if tableHandler:GetValue( i, 3 ) == "0" then
                _fightConst[ tableHandler:GetValue( i, 2 ) ] = tonumber( tableHandler:GetValue( i, 4 ) );
            else
                _fightConst[ tableHandler:GetValue( i, 2 ) ] = tableHandler:GetValue( i, 4 );
            end
        end
	end
    return _fightConst;
end

-- 关卡表
function Data.Stage()
    if _stage ~= nil then
        return _stage;
    end
    _stage = {};
    _stageByID = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Stage.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
            local world = tonumber( tableHandler:GetValue( records, 1 ) );
            local stage = tonumber( tableHandler:GetValue( records, 2 ) );
            if _stage[world] == nil then
                _stage[world] = {};
            end

            -- 插表
            local stageTable = 
            {
                id = id,
                world = world,
                stage = stage,
                staUse = tonumber( tableHandler:GetValue( records, 3 ) );
                needLv = tonumber( tableHandler:GetValue( records, 4 ) );
                drop = tonumber( tableHandler:GetValue( records, 5 ) );
                bossId = tonumber( tableHandler:GetValue( records, 6 ) );
                wave = {},
                map = tableHandler:GetValue( records, 10 ),
                nameID = tonumber( tableHandler:GetValue( records, 11 ) );
            };
			table.insert( _stage[world], stage, stageTable );
            -- 同时保存一份ID索引的
            table.insert( _stageByID, id, stageTable );
            
            -- 解析每播怪的数据
            local wave = 
            { 
                tableHandler:GetValue( records, 7 ),
                tableHandler:GetValue( records, 8 ),
                tableHandler:GetValue( records, 9 ),
            };
            for i = 1, #wave, 1 do
                if wave[i] ~= "" then
                    local monsters = string.split( wave[i], ';' );
                    stageTable.wave[i] = {};
                    for j = 1, #monsters, 1 do
                        local info = string.split( monsters[j], '-' );
                        table.insert( stageTable.wave[i], { id = tonumber( info[1] ), level = tonumber( info[2] ), posIndex = tonumber( info[3] ) } );
                    end
                else
                    break;
                end
            end
		end
	end
    return _stage;
end
-- 基于ID索引的关卡表
function Data.StageByID()
    Data.Stage();
    return _stageByID;
end

-- 道具表
function Data.Item()
    if _item ~= nil then
        return _item;
    end
    _item = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Item.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _item, id,
            {
                nameID = tonumber( tableHandler:GetValue( records, 2 ) ),
                descId = tonumber( tableHandler:GetValue( records, 3 ) ),
                iconRes = tableHandler:GetValue( records, 4 ),
            } );
		end
	end
    return _item;
end

-- 小传表
function Data.Biography()
    if _biography ~= nil then
        return _biography;
    end
    _biography = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Biography.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _biography, id,
            {
                name = tonumber( tableHandler:GetValue( records, 1 ) ),
                desc = tonumber( tableHandler:GetValue( records, 2 ) ),
            } );
		end
	end
    return _biography;
end

-- 剧情表
function Data.Story()
    if _story ~= nil then
        return _story;
    end
    _story = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Story.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _story, id,
            {
                name = tonumber( tableHandler:GetValue( records, 1 ) ),
                desc = tonumber( tableHandler:GetValue( records, 2 ) ),
            } );
		end
	end
    return _story;
end

-- 特效表
function Data.FX()
    if _fx ~= nil then
        return _fx;
    end
    _fx = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "fx.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _fx, id,
            {
                resName = tableHandler:GetValue( records, 2 ),
                editorPath = tableHandler:GetValue( records, 3 ),
                abName = tableHandler:GetValue( records, 4 ),
                life = tonumber( tableHandler:GetValue( records, 5 ) );
            } );
		end
	end
    return _fx;
end

-- 星座表
function Data.Constellation()
    if _constellation ~= nil then
        return _constellation;
    end
    _constellation = {};

	local tableHandler = TableHandler.New();
	if tableHandler:OpenFromData( "Constellation.txt" ) == true then
		local tableRecordsNum = tableHandler:GetRecordsNum() - 1;
		for records = 0, tableRecordsNum, 1 do
            local id = tonumber( tableHandler:GetValue( records, 0 ) );
			table.insert( _constellation, id,
            {
                nameID = tonumber( tableHandler:GetValue( records, 2 ) );
                icon = tableHandler:GetValue( records, 3 ),
            } );
		end
	end
    return _constellation;
end