-- 界面
DlgBattle = {};
local _dlg = nil;
local _levelTitleText;
local _magicNumText;
local _dotPrefab;
local _bossHPGo;
local _bossIconImg;
local _bossHpImg;
local _hpPrefabGo;
local _hurtNumPrefab;
local _skillBtnInfo = {};
local _changeBtnInfo = {};
local _energySlider;
local _cutlinePrefab;
local _dotEffectPrefab;


local _hps = {};      --所有单位的血条的相关信息

local _hpGoPool ;
local _hurtNumGoPool ;
local _dotGoPool ;
local _dotEffectGoPool ;

--数据
local _unitList = {};   --unit作为key，对应skillBtn的index作为值
local _unitBackList = {}; ----unit作为key，对应changeBtn的index作为值

local _choosenUnit; --点击换人按钮对应的单位

local _UNIT_TYPE_HERO =1;
local _UNIT_TYPE_ENEMY =2;
local _UNIT_TYPE_BOSS =3;

local _newDotX;
local _dotWidth;

local _magicLimitNum;
local _currMagicNum = 0;
local _currEnergyNum = 0;
local _useEnergyNum = 0; --扣除能量时临时显示使用
local _useNumQueue = {};


-- 打开界面
function DlgBattle.Open()
	_dlg = UIManager.instance:Open( "DlgBattle" );
end

-- 隐藏界面
function DlgBattle.Close()
	if _dlg == nil then
		return;
	end
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgBattle.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgBattle.Close();
        elseif controlID == 1 then -- 暂停
            DlgPause.Open()
        elseif controlID >= 11 and controlID <= 13 then -- 换人按钮
            local btnIndex = controlID-10;

            if _choosenUnit then
                --恢复已选中的按钮至正常状态
--                _changeBtnInfo[_unitBackList[_choosenUnit]]
                _choosenUnit = nil;
            end

            --如果点击是另外一个换人按钮,或者首次选中换人按钮选中它
            if _choosenUnit == nil or btnIndex ~= _unitBackList[_choosenUnit] then 
                -- 设置换人按钮的状态
--              _changeBtnInfo[btnIndex]
                _choosenUnit = DlgBattle.GetUnitByBtn(btnIndex, _unitBackList);
            end

        elseif controlID >= 21 and controlID <= 24 then -- 技能按钮
            local btnIndex = controlID-20;
            local unit = DlgBattle.GetUnitByBtn(btnIndex, _unitList);
            
            -- 跑动过场禁止点
            if unit.ai.currState == AIState.run then return; end
            if _choosenUnit then -- 换人操作
                -- 已死
                if FightUtils.IsUnitDead( _choosenUnit ) then return; end

                --重新设置技能按钮index和unit的对应关系
                _unitList[_choosenUnit] = btnIndex;
                --移除被换掉的技能index
                _unitList[unit] = nil; 

                --重新设置按钮
                DlgBattle.InitSkillBtn(_skillBtnInfo[btnIndex], _choosenUnit);

                --重新设置换人按钮index和unit的对应关系
                local changeBtnIndex = _unitBackList[_choosenUnit];
                _unitBackList[unit] = changeBtnIndex;
                _unitBackList[_choosenUnit] = nil;

                --重新设置按钮
                DlgBattle.InitChangeBtn(_changeBtnInfo[changeBtnIndex], unit);

                --通知战场换人操作
                Event.Fight:DispatchEvent( EVENT_FIGHT_UNITCHANGE, unit, _choosenUnit);

                _choosenUnit = nil;
            else -- 释放技能
                --通知战场释放技能
                Event.Fight:DispatchEvent( EVENT_FIGHT_SKILLACTIVE, unit );
            end
        end
	end
end

-- 载入时调用
function DlgBattle.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _hpPrefabGo = objs[0];
    _hurtNumPrefab = objs[1];
    _magicNumText = objs[2]:GetComponent(typeof(UIText));
    _levelTitleText = objs[4]:GetComponent(typeof(UIText));
    _bossIconImg = objs[5]:GetComponent(typeof(UIImage));
    _bossHpImg = objs[6]:GetComponent(typeof(UIImage));
    
    -- 遍历得到技能按钮信息
    local startId = 7;
    for i = 0, 3 do 
        local info = {};
        info.btnBgImg = objs[startId + i * 4 + 0]:GetComponent(typeof(UIImage));
        info.skillNumText = objs[startId + i * 4 + 1]:GetComponent(typeof(UIText));
        info.hpImg = objs[startId + i * 4 + 2]:GetComponent(typeof(UIImage));
        info.nameText = objs[startId + i * 4 + 3]:GetComponent(typeof(UIText));
        table.insert(_skillBtnInfo,info);
    end 

     -- 遍历得到切换按钮信息
    local startId = 23;
    for i = 0, 2 do 
        local info = {};
        info.iconImg = objs[startId + i]:GetComponent(typeof(UIImage));
        table.insert(_changeBtnInfo,info);
    end 

    _bossHPGo = objs[26];

    _energySlider = objs[27]:GetComponent(typeof(UISlider));
    _dotPrefab = objs[3];
    _cutlinePrefab = objs[28];
    _dotEffectPrefab = objs[29];

    _hpGoPool = GameObjectPool.New(_hpPrefabGo);
    _hurtNumGoPool = GameObjectPool.New(_hurtNumPrefab);
    _dotGoPool = GameObjectPool.New(_dotPrefab);
    _dotEffectGoPool = GameObjectPool.New(_dotEffectPrefab);
end

-- 界面初始化时调用
function DlgBattle.OnStart( gameObject )
    _magicLimitNum = 10;

    --能量格数据
    _newDotX = 0;
    _dotWidth = _dotPrefab.transform.parent.sizeDelta.x/_magicLimitNum;

    _magicNumText.text = tostring(_currMagicNum);

    --添加能量值分割线
    local dotWidth = _cutlinePrefab.transform.parent.sizeDelta.x/_magicLimitNum;
    local lineX = dotWidth;
    for i = 1, _magicLimitNum-1 do
        local tmpTrans = UIManager.instance:InstantiateGo(_cutlinePrefab, _cutlinePrefab.transform.parent);
        local pos = tmpTrans.localPosition;
        pos.x = lineX;
        tmpTrans.localPosition = pos;

        lineX= lineX + dotWidth;
    end
end

-- 界面显示时调用
function DlgBattle.OnEnable( gameObject )
	DlgBattle.RegisterEvent();

    _magicLimitNum = 0;
    _currMagicNum = 0;
    _currEnergyNum = 0;
    _useEnergyNum = 0;
    _useNumQueue = {};

    _bossHPGo:SetActive(false);
end

-- 界面隐藏时调用
function DlgBattle.OnDisable( gameObject )
	DlgBattle.UnRegisterEvent();

    --清空血条信息
    _hps = {};
    _unitList = {};
    _unitBackList = {};

    -- 缓存产生的prefab
    _hpGoPool:DespawnAll();
    _hurtNumGoPool:DespawnAll();
    _dotGoPool:DespawnAll();
    _dotEffectGoPool:DespawnAll();
end

-- 界面删除时调用
function DlgBattle.OnDestroy( gameObject )
	_dlg = nil;
    _skillBtnInfo = {};
    _changeBtnInfo = {};
    _hpGoPool:Clear();
    _hurtNumGoPool:Clear();
    _dotGoPool:Clear();
    _dotEffectGoPool:Clear();
end

----------------------------------------
-- 自定
----------------------------------------
--战斗结束
function DlgBattle.FightEnd()
    UIManager.instance:UnloadAllUI();
    Fight.Exit();
    DlgMain.Open();
end

function DlgBattle.MagicReduce(magic, use)
    if use<0 then
        --记录释放技能时的能量值
        table.insert(_useNumQueue, - use);
        _useEnergyNum = _useEnergyNum - use;
        DlgBattle.ReduceMagic(Mathf.Abs(use/10000));
    end
end

--改变总的技能点数
function DlgBattle.ChangeMagicNum( magic ) 
    --改变进度条
    _currEnergyNum = magic[-1];
    _energySlider.value = (magic[-1] + _useEnergyNum)/(_magicLimitNum*10000);
    local newMagicNum = Mathf.Floor(_currEnergyNum/ 10000);
    if newMagicNum > _currMagicNum then --添加新的能量格
        for i = 1, newMagicNum-_currMagicNum do
            local go = _dotGoPool:Spawn();
            go.transform:SetParent(_dotPrefab.transform.parent,false);
            go.transform.localScale = Vector3.one;
            local size = go.transform.sizeDelta;
            size.x = _dotWidth;
            go.transform.sizeDelta = size;
        end
        _currMagicNum =  newMagicNum;
        _magicNumText.text = tostring(_currMagicNum);
    end

end

--释放技能时，减少技能点的逻辑入口
function DlgBattle.ReduceMagic(reduce)
    for i = 1, reduce do
        local go = _dotEffectGoPool:Spawn();
        go.transform:SetParent(_dotEffectPrefab.transform.parent,false);
        go.transform.localScale = Vector3.one;
        local size = go.transform.sizeDelta;
        size.x = _dotWidth;
        go.transform.sizeDelta = size;
        DlgBattle.AddDotEffect(go, i == 1);
    end
end

--添加技能点减少效果
function DlgBattle.AddDotEffect(go, isFirst)
    local longestAnim = PlayTweenAnim(go);
    longestAnim.onComplete = function (anim)
        anim:DORewind();
        _dotEffectGoPool:Despawn(anim.gameObject);
        --一次会添加多个技能点效果，只有第一个在销毁时，同步减少数据
        if isFirst then
            _useEnergyNum =  _useEnergyNum - _useNumQueue[1];
            table.remove(_useNumQueue,1);
        end
        --移除技能点
        _dotGoPool:Despawn(_dotPrefab.transform.parent:GetChild(1).gameObject);
        _currMagicNum = _currMagicNum-1;
    end
end

local function DlgBattle_AddHurtEffect(unit, change, isCrit)
    local go = _hurtNumGoPool:Spawn();
    go.transform:SetParent(_hurtNumPrefab.transform.parent,false);
--    go.name = unit.transform.name .. "_HurtNum_" .. change;

    --设置go的位置
    DlgBattle.SetUIPos(go, unit.transform.position + Vector3.New(0, unit.char.data.height/100 ,0));
    go.transform.localScale = Vector3.one;

    --设置动画
    local trans = go.transform:GetChild(0);
	local longestAnim = PlayTweenAnim(trans);
    longestAnim.onComplete = function (anim)
        anim:DORewind();
        _hurtNumGoPool:Despawn(anim.transform.parent.gameObject);
    end

    --获取Prefab中对应的数字对象
    local childIndex =0;
    if unit.ai.side == -1 then  -- 友方单位
        childIndex = not isCrit and 0 or 1;
    elseif unit.ai.side == 1 then -- 敌方单位
        childIndex = not isCrit and 2 or 3;
    elseif unit.ai.side == 2 then -- boss
        childIndex = not isCrit and 4 or 5;
    end
    childIndex = change > 0 and (childIndex+6) or childIndex ;

    local textGo;
    -- 设置初始属性
	for i = 0, trans.childCount-1 do
        local  tmpGo = trans:GetChild(i).gameObject;
        if childIndex == i then 
            textGo = tmpGo;
	        tmpGo:SetActive(true);
        else
	        tmpGo:SetActive(false);
        end
    end
    local hurtText = textGo:GetComponent(typeof(UIText));
    hurtText.text = tostring(change);
end

--血量变化
function DlgBattle.ChangeHP(unit, change, source, isCrit) 
    --扣血
    local obj = _hps[unit];
    if obj ~= nil then
        if obj.kind == _UNIT_TYPE_HERO then
            local perc = unit.attr.hp / unit.baseAttr.hp;
            obj.hpImg.fillAmount = perc;
            --换人的瞬间，场上的单位可能还在，但是按钮上的血条可能已经变成另外一个单位的了
            if _unitList[unit] == nil then return; end
            --改变技能按钮上的血条
            if _unitList[unit] ~= nil then
                _skillBtnInfo[_unitList[unit]].hpImg.fillAmount = perc;
            end
        elseif obj.kind == _UNIT_TYPE_ENEMY then
            obj.hpImg.fillAmount = unit.attr.hp / unit.baseAttr.hp;
        elseif obj.kind == _UNIT_TYPE_BOSS then
            obj.hpImg.fillAmount = unit.attr.hp / unit.baseAttr.hp;
        end
    end

    --产生伤害数字
    DlgBattle_AddHurtEffect(unit, change, isCrit);
end

-- 初始化hero和enemy
local function DlgBattle_UnitNew(unit,spriteName)
    -- 初始化一个对象
    local go = _hpGoPool:Spawn();
    go.transform:SetParent(_hpPrefabGo.transform.parent,false);
--    go.name = unit.transform.name .. "_HP";

    --设置go的位置
    DlgBattle.SetUIPos(go, unit.transform.position + Vector3.New(0, unit.char.data.height/100 ,0));
    go.transform.localScale = Vector3.one;
    -- 设置初始属性
    local relatedObj = go:GetComponent(typeof(UIItem)).relatedGameObject;
    local img = relatedObj[0]:GetComponent(typeof(UIImage));
    img.sprite = UIManager.instance:GetSprite(_dlg.uiName, spriteName);
    img.fillAmount = unit.attr.hp / unit.baseAttr.hp;

    return go, img;
end

--初始化新的血条
function DlgBattle.AddUnit(unit)
    local obj = {};
    obj.unit = unit;
    if unit.ai.side == -1 then  -- 友方单位
        local go, img = DlgBattle_UnitNew(unit,"DlgBattle_Blood_01");
        --保存对象
        obj.kind = _UNIT_TYPE_HERO;
        obj.hpGo = go;
        obj.hpImg = img;
    elseif unit.ai.side == 1 then -- 敌方单位
        local go, img = DlgBattle_UnitNew(unit,"DlgBattle_Blood_02");
        --保存对象
        obj.kind = _UNIT_TYPE_ENEMY;
        obj.hpGo = go; 
        obj.hpImg = img;
    elseif unit.ai.side == 2 then -- boss
        -- 显示boss血条
        _bossHPGo:SetActive(true);
        _bossHpImg.fillAmount = 1;
        --boss头像
--        _bossIconImg

        obj.kind = _UNIT_TYPE_BOSS;
        obj.hpGo = _bossHPGo;
        obj.hpImg = _bossHpImg;
    else
        return;
    end
    _hps[unit] = obj;
end

--移除血条
function DlgBattle.RemoveUnit(unit)
    local obj = _hps[unit];
    if obj ~= nil then
        if obj.kind == _UNIT_TYPE_HERO then
            _hpGoPool:Despawn(obj.hpGo);
            --设置对应的技能按钮的状态
--            _skillBtnInfo[_unitList[unit]]
        elseif obj.kind == _UNIT_TYPE_ENEMY then
            _hpGoPool:Despawn(obj.hpGo);
        elseif obj.kind == _UNIT_TYPE_BOSS then
             obj.hpGo:SetActive(false);
        end
        _hps[unit] = nil;
    end
end

function DlgBattle.SetUIPos(go, worldPos)
    go.transform.position = UIManager.instance:World2ScreenPos(worldPos, Fight.GetCamera());
    local localPos = go.transform.localPosition;
    localPos.z=0;
    go.transform.localPosition=localPos;
end

-- 设置Hp的位置
function DlgBattle.SetHpPos(unit)
    local obj = _hps[unit];
    if obj ~= nil then
        if obj.kind == _UNIT_TYPE_HERO or obj.kind == _UNIT_TYPE_ENEMY then
            DlgBattle.SetUIPos(obj.hpGo, unit.transform.position + Vector3.New(0, unit.char.data.height/100 ,0));
        elseif obj.kind == _UNIT_TYPE_BOSS then

        end
--    else
--        LogErr("<DlgBattle> 尝试修改坐标的单位不存在，单位name = " .. unit.transform.name);
    end
end

-- 相机移动，需要设置所有单位的血条跟随移动
function DlgBattle.FightCamMove()
    for unit, obj in pairs(_hps) do
        if obj.kind == _UNIT_TYPE_HERO or obj.kind == _UNIT_TYPE_ENEMY then
            DlgBattle.SetUIPos(obj.hpGo, unit.transform.position + Vector3.New(0, unit.char.data.height/100 ,0));
        elseif obj.kind == _UNIT_TYPE_BOSS then

        end
    end
    
end

-- 初始化技能按钮上的信息
function DlgBattle.InitSkillBtn(skillBtnInfo, unit)
    skillBtnInfo.btnBgImg.gameObject:SetActive(true);
    skillBtnInfo.btnBgImg.sprite = Load_Char_Portrait(_dlg.uiName, unit.char.data.res,"a");
    skillBtnInfo.skillNumText.text = unit.skills[2][1].data.cost / 10000;
    skillBtnInfo.hpImg.fillAmount = unit.attr.hp / unit.baseAttr.hp;
    skillBtnInfo.nameText.text = Localization.Get(unit.data.nameID);
end

-- 初始化技能按钮上的信息
function DlgBattle.InitChangeBtn(changeBtnInfo, unit)
    changeBtnInfo.iconImg.gameObject:SetActive(true);
    changeBtnInfo.iconImg.sprite = Load_Char_Head(_dlg.uiName, unit.char.data.res);
end

-- 初始化换人按钮上的信息
function DlgBattle.InitBtn(unitList, unitBackList)
    --初始化技能按钮
    for i,unit in pairs(unitList) do
        _unitList[unit] = i;
        DlgBattle.InitSkillBtn(_skillBtnInfo[i], unit);
    end

    --初始化换人按钮
    for i,unit in pairs(unitBackList) do
        _unitBackList[unit] = i;    
        DlgBattle.InitChangeBtn(_changeBtnInfo[i], unit);
    end
end

-- 通过按钮的index获取对应的unit
function DlgBattle.GetUnitByBtn(index, list)
    for unit,id in pairs(list) do
        if id == index then 
            return unit;
        end
    end
    return nil;
end

--注册事件
function DlgBattle.RegisterEvent()
    Event.Fight:AddListener(EVENT_FIGHT_UNITADD, DlgBattle.AddUnit);
    Event.Fight:AddListener(EVENT_FIGHT_UNITENTER, DlgBattle.AddUnit);
    Event.Fight:AddListener(EVENT_FIGHT_UNITENTER, DlgSkillShow.Show);
    Event.Fight:AddListener(EVENT_FIGHT_UNITDIE, DlgBattle.RemoveUnit);
    Event.Fight:AddListener(EVENT_FIGHT_UNITQUIT, DlgBattle.RemoveUnit);
    Event.Fight:AddListener(EVENT_FIGHT_UNITMOVE, DlgBattle.SetHpPos);
    Event.Fight:AddListener(EVENT_FIGHT_FIGHTCAMERAMOVE, DlgBattle.FightCamMove);
    Event.Fight:AddListener(EVENT_FIGHT_UNITHPCHANGE, DlgBattle.ChangeHP);
    Event.Fight:AddListener(EVENT_FIGHT_UNITLIST_INIT, DlgBattle.InitBtn);
    Event.Fight:AddListener(EVENT_FIGHT_END, DlgBattle.FightEnd);
    Event.Fight:AddListener(EVENT_FIGHT_MAGICSYNC, DlgBattle.ChangeMagicNum);
    Event.Fight:AddListener(EVENT_FIGHT_MAGICREDUCE, DlgBattle.MagicReduce);
end
--反注册事件
function DlgBattle.UnRegisterEvent()
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITADD, DlgBattle.AddUnit);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITENTER, DlgBattle.AddUnit);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITENTER, DlgSkillShow.Show);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITDIE, DlgBattle.RemoveUnit);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITQUIT, DlgBattle.RemoveUnit);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITMOVE, DlgBattle.SetHpPos);
    Event.Fight:RemoveListener(EVENT_FIGHT_FIGHTCAMERAMOVE, DlgBattle.FightCamMove);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITHPCHANGE, DlgBattle.ChangeHP);
    Event.Fight:RemoveListener(EVENT_FIGHT_UNITLIST_INIT, DlgBattle.InitBtn);
    Event.Fight:RemoveListener(EVENT_FIGHT_END, DlgBattle.FightEnd);
    Event.Fight:RemoveListener(EVENT_FIGHT_MAGICSYNC, DlgBattle.ChangeMagicNum);
    Event.Fight:RemoveListener(EVENT_FIGHT_MAGICREDUCE, DlgBattle.MagicReduce);
end

