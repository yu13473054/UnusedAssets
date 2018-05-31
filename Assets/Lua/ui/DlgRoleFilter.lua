-- 界面
DlgRoleFilter = {};
local _dlg = nil;

local _toggleList = {}

local _selectSortID;
local _filterValue = {};

-- 打开界面
function DlgRoleFilter.Open()
	_dlg = UIManager.instance:Open( "DlgRoleFilter" );
end

-- 隐藏界面
function DlgRoleFilter.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgRoleFilter.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgRoleFilter.Close();
        elseif controlID == 1 then 
            DlgRoleFilter.Close();
            DlgRole.Filter(_selectSortID,_filterValue);
        end
    elseif uiEvent == UIEVENT_UITOGGLE_ONVALUECHANGE then
        if controlID < 200 then -- 排序
            if value then
                _selectSortID = controlID;
            end
        elseif controlID < 500 then
            --记录筛选值
            if value then
                _filterValue[controlID] = controlID;
            else 
                 _filterValue[controlID] = nil;
            end
            if controlID%100 == 0 then  --点击的是all按钮
                if value then
                    DlgRoleFilter.SetOtherTogglesOff(controlID);
                else
                    --此时不能关闭allToggle
                    if not DlgRoleFilter.AllToggleCanOff(controlID) then 
                        _toggleList[math.floor(controlID/100) * 100].isOn = true;
                    end
                end
            else --点击其他按钮
                local allToggle = _toggleList[math.floor(controlID/100) * 100];
                if value then
                    if allToggle.isOn then
                        allToggle.isOn = false;
                    end
                else
                    if (not allToggle.isOn) and (not DlgRoleFilter.AllToggleCanOff(controlID)) then 
                        _toggleList[math.floor(controlID/100) * 100].isOn = true;
                    end
                end
            end
        end
	end
end

-- 载入时调用
function DlgRoleFilter.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;
    --设置排序按钮的controlID
    local trans = objs[0].transform;
    for i = 0 , trans.childCount-1 do
        local toggle = trans:GetChild(i):GetComponent(typeof(UIToggle));
--        local textID = toggle.transform:Find("Label"):GetComponent(typeof(UIText)).localizationID;
        toggle.controlID = 100+i+1;
        _toggleList[toggle.controlID] = toggle;
    end
    --星座的controlID
    trans = objs[1].transform;
    for i = 0 , trans.childCount-1 do
        local toggle = trans:GetChild(i):GetComponent(typeof(UIToggle));
        toggle.controlID = 200+i;
        _toggleList[toggle.controlID] = toggle;
    end
    --阵营的controlID
    trans = objs[2].transform;
    for i = 0 , trans.childCount-1 do
        local toggle = trans:GetChild(i):GetComponent(typeof(UIToggle));
        toggle.controlID = 300+i;
        _toggleList[toggle.controlID] = toggle;
    end
    --品质的controlID
    trans = objs[3].transform;
    for i = 0 , trans.childCount-1 do
        local toggle = trans:GetChild(i):GetComponent(typeof(UIToggle));
        if i == 0 then
            toggle.controlID = FILTER_GRADE_ALL;
        else
            toggle.controlID = FILTER_GRADE_SSR - i + 1;
        end
        _toggleList[toggle.controlID] = toggle;
    end
end

-- 界面初始化时调用
function DlgRoleFilter.OnStart( gameObject )
	
end

-- 界面显示时调用
function DlgRoleFilter.OnEnable( gameObject )
	
end

-- 界面隐藏时调用
function DlgRoleFilter.OnDisable( gameObject )
	
end

-- 界面删除时调用
function DlgRoleFilter.OnDestroy( gameObject )
	_dlg = nil;
end

----------------------------------------
-- 自定
----------------------------------------
function DlgRoleFilter.Show(selectSortID, filterValue)
    _toggleList[selectSortID].isOn = true;
    _toggleList[FILTER_CAMP_ALL].isOn = true;
    _toggleList[FILTER_CONSTLL_ALL].isOn = true;
    _toggleList[FILTER_GRADE_ALL].isOn = true;
    for i = 1, #filterValue do
        _toggleList[filterValue[i]].isOn = true;
    end
    
end

--判定AllToggle能否被关闭
function DlgRoleFilter.AllToggleCanOff(toggleValue)
    local kind = math.floor(toggleValue/100);
    local isOn = false;
    for key, toggle in pairs(_toggleList) do
        if key%100 ~= 0 then --排除allToggle
            if math.floor(key/100) == kind  then
                isOn = isOn or toggle.isOn;
                if isOn then break; end
            end
        end
    end
    return isOn;
end

--点击all按钮时，关闭其他所有按钮
function DlgRoleFilter.SetOtherTogglesOff(toggleValue)
    local kind = math.floor(toggleValue/100);
    for key, toggle in pairs(_toggleList) do
        if key%100 ~= 0 then --排除allToggle
            if math.floor(key/100) == kind and toggle.isOn then
                toggle.isOn = false;
            end
        end
    end
end

