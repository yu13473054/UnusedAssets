-- 界面
DlgRole = {};
local _dlg = nil;
local _cardContent;
local _cardScroll;
local _scrollBar;
local _selectFrameTrans;
local _setRoleImg;
local _roleNameText;
local _contelText;
local _cvText;
local _starGroupTrans;
local _cardNumText;
local _preBtnGo;
local _nextBtnGo;
local _detailBtnGo;
local _moveAnim;
local _movePanelTrans;
local _lvText;
local _expSlider;
local _expText;
local _atkCharText;
local _defCharText;
local _helpCharText;
local _hpText;
local _atkText;
local _defText;
local _gapText;
local _critText;
local _scopeText;
local _critDmgText;

local _itemList = {};
local _initCardList;
local _showCardList;
local _selectCardId;
local _isShowDetail;
local _canClick = true;

local _selectSortId;
local _sortSequence = {SORT_GRADE,SORT_STAR,SORT_LEVEL,SORT_IMPRESSION,SORT_BORNTIME,SORT_ATK,SORT_HP,SORT_DEF,SORT_CRIT,SORT_SPEED};
local _resultSortSeq = {};
local _resultFilter = {};

-- 打开界面
function DlgRole.Open()
	_dlg = UIManager.instance:Open( "DlgRole" );
end

-- 隐藏界面
function DlgRole.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgRole.OnEvent( uiEvent, controlID, value, gameObject )
    if not _canClick then return end;

	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            if _isShowDetail then --详情界面返回
                _preBtnGo:SetActive(false);
                _nextBtnGo:SetActive(false);
                DlgRole.MovePanel();
            else --正常返回
                DlgRole.Close();
            end
        elseif controlID == 1 then --详情
            _detailBtnGo:SetActive(false);
            DlgRole.MovePanel();
        elseif controlID == 3 then --查看上一个角色
            DlgRole.SelectCard(_selectCardId-1);
        elseif controlID == 4 then --查看下一个角色
            DlgRole.SelectCard(_selectCardId+1);
        elseif controlID == 5 then --查看立绘
            DlgRoleShow.Show(Data.Unit()[_showCardList[_selectCardId].id] );
        elseif controlID == 6 then --排序
            DlgRoleFilter.Open();
            DlgRoleFilter.Show(_selectSortId, _resultFilter);
        elseif controlID > 1000 then --卡牌
            local index = controlID-1000;
            DlgRole.SelectCard(index);
        end
    elseif uiEvent == UIEVENT_UISCROLLVIEW_ONVALUECHANGE then
        if controlID == 41 then -- 滚动框
             _scrollBar.value = value.y;
        end
    elseif uiEvent == UIEVENT_UISCROLLBAR_ONVALUECHANGE then
        if controlID == 61 then --滚动条
            _cardScroll.verticalNormalizedPosition = value;
        end
    elseif uiEvent == UIEVENT_WRAPCONTENT_ONITEMUPDATE then
        if controlID == 41 then
            DlgRole.OnUpdateItem(value[0], value[1]);
        end
    elseif uiEvent == UIEVENT_WRAPCONTENT_ONINITDONE then
        if controlID == 41 then
            DlgRole.OnInitDone();
        end
	end
end

-- 载入时调用
function DlgRole.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _cardContent = objs[0]:GetComponent(typeof(WrapContent));
    _cardScroll = objs[1]:GetComponent(typeof(UIScrollView));
    _scrollBar = objs[2]:GetComponent(typeof(UIScrollbar));
    _selectFrameTrans = objs[3].transform;
    _setRoleImg = objs[4]:GetComponent(typeof(UIImage));
    _roleNameText = objs[5]:GetComponent(typeof(UIText));
    _cvText = objs[6]:GetComponent(typeof(UIText));
    _contelText = objs[7]:GetComponent(typeof(UIText));
    _starGroupTrans = objs[8].transform;
    _cardNumText = objs[9]:GetComponent(typeof(UIText));
    _preBtnGo = objs[10];
    _nextBtnGo = objs[11];
    _detailBtnGo = objs[12];
    _movePanelTrans = objs[13].transform;
    _moveAnim = _movePanelTrans:GetComponent(typeof(DOTweenAnimation));
    _lvText = objs[14]:GetComponent(typeof(UIText));
    _expSlider = objs[15]:GetComponent(typeof(UISlider));
    _expText = objs[16]:GetComponent(typeof(UIText));
    _atkCharText = objs[17]:GetComponent(typeof(UIText));
    _defCharText = objs[18]:GetComponent(typeof(UIText));
    _helpCharText = objs[19]:GetComponent(typeof(UIText));
    _hpText = objs[20]:GetComponent(typeof(UIText));
    _atkText = objs[21]:GetComponent(typeof(UIText));
    _defText = objs[22]:GetComponent(typeof(UIText));
    _gapText = objs[23]:GetComponent(typeof(UIText));
    _scopeText = objs[24]:GetComponent(typeof(UIText));
    _critText = objs[25]:GetComponent(typeof(UIText));
    _critDmgText = objs[26]:GetComponent(typeof(UIText));
end                 

-- 界面初始化时调用
function DlgRole.OnStart( gameObject )
    _resultFilter = {FILTER_CONSTLL_ALL,FILTER_CAMP_ALL,FILTER_GRADE_ALL};
	DlgRole.ShowView();
end

-- 界面显示时调用
function DlgRole.OnEnable( gameObject )
    _moveAnim.onStepComplete = DlgRole.OnEndMove;
    _itemList = {};

	if not IsNilOrNull(_dlg) then
        DlgRole.ShowView();
    end
end

-- 界面隐藏时调用
function DlgRole.OnDisable( gameObject )
	_moveAnim.onStepComplete = nil;
end

-- 界面删除时调用
function DlgRole.OnDestroy( gameObject )
	_dlg = nil;
end

----------------------------------------
-- 自定
----------------------------------------
function DlgRole.OnInitDone()
     _scrollBar.handleRect.gameObject:SetActive(_cardScroll:IsCanDrag());
end

function DlgRole.OnUpdateItem(index, item)
    DlgRole.CheckItemUse(item);
    --数据
    index = index+1;
    local unitData = Data.Unit()[_showCardList[index].id];
    _itemList[index] = item;
    -- 获取控件
    local objs = item:GetComponent( typeof( UIItem ) ).relatedGameObject;

    --框
    local frameBg = objs[0]:GetComponent(typeof(UIImage));
    frameBg.sprite = LoadFrame_Card_Bottom(_dlg.uiName, unitData.grade);
    local frameTop = objs[2]:GetComponent(typeof(UIImage));
    frameTop.sprite = LoadFrame_Card_Top(_dlg.uiName, unitData.grade);

    local btn = objs[2]:GetComponent(typeof(UIButton));
    btn.uiMod = _dlg;
    btn.controlID = 1000+index;

    -- 卡牌icon
    local cardIcon = objs[1]:GetComponent(typeof(UIImage));
    cardIcon.sprite = Load_Char_Card(_dlg.uiName, Data.Character()[unitData.charID].res);

    -- 星座图标
    local constellationIcon = objs[3]:GetComponent(typeof(UIImage));
    constellationIcon.sprite = LoadConstellation(_dlg.uiName, Data.Constellation()[unitData.constellID].icon);

    -- 设置星星
    local star = _showCardList[index].star;
    for i = 1, star do
        objs[3+i]:GetComponent(typeof(UIImage)).isGray = false;
    end
    for i = star + 1, 5 do
        objs[3+i]:GetComponent(typeof(UIImage)).isGray = true;
    end

    -- 设置等级
    objs[9]:GetComponent(typeof(UIText)).text = "Lv." .. _showCardList[index].level;

    --第一次默认选中第一个
    if _selectCardId == -1 then
        DlgRole.SelectCard(1);
    end

    --选中item被用来渲染其他的卡牌了：隐藏选中框
    if _itemList[_selectCardId] ~= nil then
        if index == _selectCardId then
            _selectFrameTrans.gameObject:SetActive(true);
            _selectFrameTrans:SetParent(_itemList[_selectCardId] ,false);
            _selectFrameTrans.localScale = Vector3.one;
            _selectFrameTrans.localPosition=Vector3.zero;
        end
    else
        _selectFrameTrans.gameObject:SetActive(false);
    end
end;

--记录当前item中都渲染的是那些数据
function DlgRole.CheckItemUse(item)
    for index, value in pairs(_itemList) do
        if item == value then
            _itemList[index] = nil;
        end
    end
end

function DlgRole.ShowView()
    --卡牌数据:临时
    
    if _initCardList == nil then
        _initCardList = CachePlayer.cards;
--        _initCardList = {};
--        local ta = {1,2,3,4,5,6,7,8,9,10,11,12,13, 14,1,2,3,4,5,6,7,8,9,10,11,12,13,14};
--        for i = 1, #ta do
--            table.insert(_initCardList, {
--                id = ta[i];
--                star = Mathf.Random(1,5);
--                level = Mathf.Random(1,30);
--                exp = 30;
--                bornTime = 30;
--                });
--        end
    end
    
    --重置
    _canClick = true;
    _isShowDetail = false;
    _movePanelTrans.localPosition = Vector3.New(-348.3,0,0);
    _moveAnim.endValueV3 = Vector3.New(340, 0, 0);
    _moveAnim:CreateTween();
    _detailBtnGo:SetActive(true);
    _preBtnGo:SetActive(false);
    _nextBtnGo:SetActive(false);

    --设置循环列表
    _selectSortId = tonumber(Data.userini:ReadValue("RoleSortID", tostring(SORT_GRADE)));
    DlgRole.Filter(_selectSortId, _resultFilter);
    
    _cardNumText.text = #_showCardList;
end

function DlgRole.SelectCard(index)
    if _selectCardId == index then return; end
    local showCardNum = #_showCardList;
    if showCardNum == 0 then return; end
    if index > showCardNum then
        index = 1;
    elseif index <= 0 then
        index = showCardNum;
    end
    _selectCardId = index;

    if _itemList[index] == nil then
        _selectFrameTrans.gameObject:SetActive(false);
    else
        _selectFrameTrans.gameObject:SetActive(true);
        _selectFrameTrans:SetParent(_itemList[index],false);
        _selectFrameTrans.localScale = Vector3.one;
        _selectFrameTrans.localPosition=Vector3.zero;
    end

    DlgRole.SetRoleInfo();
end

--色色展示面板
function DlgRole.SetRoleInfo()
    local currCardData = _showCardList[_selectCardId]
    local unitData = Data.Unit()[currCardData.id];
     _setRoleImg.sprite = Load_Char_Role(_dlg.uiName, Data.Character()[unitData.charID].res);
     _setRoleImg:SetNativeSize();
     _roleNameText.text = Localization.Get(unitData.nameID);
     _cvText.text = Localization.Get(unitData.cVID);
     _contelText.text = Localization.Get(Data.Constellation()[unitData.constellID].nameID)
     -- 设置星星
    local star = currCardData.star;
    for i = 1, star do
        _starGroupTrans:GetChild(i-1):GetComponent(typeof(UIImage)).isGray = false;
    end
    for i = star + 1, 5 do
        _starGroupTrans:GetChild(i-1):GetComponent(typeof(UIImage)).isGray = true;
    end
    -- 设置详细数据
    _lvText.text = currCardData.level .. "/" .. LVLimitByStar(currCardData.star);
    _expText.text = currCardData.exp .. "/180";
    _expSlider.value = currCardData.exp*1.0 / 180;
    --潜力
--    _atkCharText.text
--    _defCharText.text
--    _helpCharText.text
    _hpText.text = unitData.hp + unitData.lvlHp * currCardData.level;
    _atkText.text = unitData.atk + unitData.lvlAtk * currCardData.level;
    _defText.text = unitData.def + unitData.lvlDef * currCardData.level;
    _gapText.text = unitData.atkSpd + unitData.lvlAtkSpd * currCardData.level;
    _scopeText.text = unitData.rng + unitData.lvlRng * currCardData.level;
    _critText.text = unitData.crit + unitData.lvlCrit * currCardData.level;
    _critDmgText.text = (100 + unitData.critDmgPlus) .. "%";
end

function DlgRole.MovePanel()
    _canClick = false;
    _isShowDetail = not _isShowDetail;
    if _isShowDetail then
        _moveAnim:DOPlayForward();
    else
        _moveAnim:DOPlayBackwards();
    end
end

function DlgRole.OnEndMove(anim)
    _canClick = true;
    if _isShowDetail then
        _preBtnGo:SetActive(true);
        _nextBtnGo:SetActive(true);
    else
        _detailBtnGo:SetActive(true);
    end
end

function DlgRole.Filter(selectSortId,_filterValue)
    _selectSortId = selectSortId;
    Data.userini:WriteValue("RoleSortID", selectSortId);
    --重新制定排序优先级
    _resultSortSeq = {};
    table.insert(_resultSortSeq, selectSortId);
    for key,value in ipairs(_sortSequence) do
        if value ~= selectSortId then
            table.insert(_resultSortSeq, value);
        end
    end
    --剔除卡牌
    _resultFilter = {};
    for key, var in pairs(_filterValue) do
        table.insert(_resultFilter, var);
    end
    --剔除
    DlgRole.FilterCard();

    --排序
    table.sort(_showCardList, DlgRole.Sort);

    --重新显示内容
    _selectFrameTrans:SetParent(transform ,false);
     _selectCardId = -1;
     _scrollBar.value = 1;
    _cardContent:SetDataNum(#_showCardList, true);
end

function DlgRole.IsMatch(card, filterKindList)
    local unitData = Data.Unit()[card.id];
    local result = true;
    for kind, filterList in pairs(filterKindList) do
        local isKindMatch = false;
        if kind == math.floor(FILTER_CONSTLL_ALL/100) then --星座
            for key, filter in pairs(filterList) do
                if filter == FILTER_CONSTLL_ALL then
                    isKindMatch = isKindMatch or true;
                elseif filter == FILTER_CONSTLL_OTHER then
                    isKindMatch = isKindMatch or (unitData.constellID >=filter-FILTER_CONSTLL_ALL);
                else
                    isKindMatch = isKindMatch or (unitData.constellID == filter-FILTER_CONSTLL_ALL);
                end
                --满足该类别中一个条件后，就不和该类别其他中其他的条件进行比较了
                if isKindMatch then break; end 
            end
        elseif kind == math.floor(FILTER_CAMP_ALL/100) then --阵营
            for key, filter in pairs(filterList) do
                if filter == FILTER_CAMP_ALL then
                    isKindMatch = isKindMatch or true;
                else
                    isKindMatch = isKindMatch or true;
--                    isKindMatch = isKindMatch or (unitData.constellID == filter-FILTER_CONSTLL_ALL);
                end
                --满足该类别中一个条件后，就不和该类别其他中其他的条件进行比较了
                if isKindMatch then break; end 
            end
        elseif kind == math.floor(FILTER_GRADE_ALL /100) then --品质
            for key, filter in pairs(filterList) do
                if filter == FILTER_GRADE_ALL then
                    isKindMatch = isKindMatch or true;
                else
                    isKindMatch = isKindMatch or (unitData.grade == filter-FILTER_GRADE_ALL);
                end
                --满足该类别中一个条件后，就不和该类别其他中其他的条件进行比较了
                if isKindMatch then break; end 
            end
        end
        --每一类的筛选条件都是并的关系
       result = result and isKindMatch;
       if not result then break; end
    end
    return result;
end

function DlgRole.FilterCard()
    --将筛选条件分类
    local filterKindList = {}
    for i = 1, #_resultFilter do
        local filter = _resultFilter[i];
        local kind = math.floor(filter/100);
        if filterKindList[kind] == nil then filterKindList[kind] = {}; end
        filterKindList[kind][filter] = filter;
    end
    
    local newShowCardList = {};
    for i = 1, #_initCardList do
        local card = _initCardList[i];
        if DlgRole.IsMatch(card, filterKindList) then
            table.insert(newShowCardList, card);
        end
    end
    _showCardList = newShowCardList;
end

function DlgRole.Sort(first, second)
    local firstUnitData = Data.Unit()[first.id];
    local secondUnitData = Data.Unit()[second.id];
    for i = 1, #_resultSortSeq do 
        if _resultSortSeq[i] == SORT_GRADE and firstUnitData.grade ~= secondUnitData.grade then -- 品质
            return firstUnitData.grade > secondUnitData.grade;
        elseif _resultSortSeq[i] == SORT_STAR and first.star ~= second.star then -- 星级
            return first.star > second.star;
        elseif _resultSortSeq[i] == SORT_LEVEL and first.level ~= second.level then -- 等级
            return first.level > second.level;
        elseif _resultSortSeq[i] == SORT_BORNTIME and first.bornTime ~= second.bornTime then -- 时序
            return first.bornTime < second.bornTime;
        elseif _resultSortSeq[i] == SORT_IMPRESSION and first.bornTime ~= second.bornTime then -- 好感
            return first.bornTime < second.bornTime;
        elseif _resultSortSeq[i] == SORT_ATK then -- 攻击
            local firstValue = firstUnitData.atk + firstUnitData.lvlAtk * first.level;
            local secondValue = secondUnitData.atk + secondUnitData.lvlAtk * second.level;
            if firstValue ~= secondValue then 
                return firstValue > secondValue;
            end
        elseif _resultSortSeq[i] == SORT_HP then -- 生命
            local firstValue = firstUnitData.atk + firstUnitData.lvlAtk * first.level;
            local secondValue = secondUnitData.atk + secondUnitData.lvlAtk * second.level;
            if firstValue ~= secondValue then 
                return firstValue > secondValue;
            end
        elseif _resultSortSeq[i] == SORT_DEF then -- 防御
            local firstValue = firstUnitData.def + firstUnitData.lvlDef * first.level;
            local secondValue = secondUnitData.def + secondUnitData.lvlDef * second.level;
            if firstValue ~= secondValue then 
                return firstValue > secondValue;
            end
        elseif _resultSortSeq[i] == SORT_CRIT then -- 会心
            local firstValue = firstUnitData.crit + firstUnitData.lvlCrit * first.level;
            local secondValue = secondUnitData.crit + secondUnitData.lvlCrit * second.level;
            if firstValue ~= secondValue then 
                return firstValue > secondValue;
            end
        elseif _resultSortSeq[i] == SORT_SPEED then -- 间隔
            local firstValue = firstUnitData.atkSpd + firstUnitData.lvlAtkSpd * first.level;
            local secondValue = secondUnitData.atkSpd + secondUnitData.lvlAtkSpd * second.level;
            if firstValue ~= secondValue then 
                return firstValue > secondValue;
            end
        end
    end
    return false;
end