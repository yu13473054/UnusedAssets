-- 界面
DlgStageInfo = {};
local _dlg = nil;

local _itemElePrefab;
local _itemParentTrans;
local _headElePrefab;
local _nameText;
local _needLvText;
local _staUseText;

local _itemGroup = {};

local _worldId;
local _stageId;

-- 打开界面
function DlgStageInfo.Open(worldId, stageId)
    _worldId = worldId;
    _stageId = stageId;

	_dlg = UIManager.instance:Open( "DlgStageInfo" );
end

-- 隐藏界面
function DlgStageInfo.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgStageInfo.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgStageInfo.Close();
        elseif controlID == 1 then
            UIManager.instance:UnloadAllUI();
            DlgBattle.Open();
            Fight.Start( FIGHTTYPE_PVE, 1);
        end
	end
end

-- 载入时调用
function DlgStageInfo.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _itemElePrefab = objs[0];
    _itemParentTrans = objs[4].transform;
    _nameText = objs[1]:GetComponent(typeof(UIText));
    _needLvText = objs[2]:GetComponent(typeof(UIText));
    _staUseText = objs[3]:GetComponent(typeof(UIText));
    _headElePrefab = objs[5];
end

-- 界面初始化时调用
function DlgStageInfo.OnStart( gameObject )
    --首次显示在Start中进行初始化
	DlgStageInfo.ShowView();
end

-- 界面显示时调用
function DlgStageInfo.OnEnable( gameObject )
	if not IsNilOrNull(_dlg) then
        DlgStageInfo.ShowView();
    end
end

-- 界面隐藏时调用
function DlgStageInfo.OnDisable( gameObject )
end

-- 界面删除时调用
function DlgStageInfo.OnDestroy( gameObject )
	_dlg = nil;
    _itemGroup = {};
end


----------------------------------------
-- 自定
----------------------------------------
function DlgStageInfo.ShowView()
    local stageInfo = Data.Stage()[_worldId][_stageId];
    if stageInfo == nil then
        LogErr(string.format("<DlgStageInfo> 关卡数据为空，worldID = %s, stageID = %s", _worldId, _stageId));
        return;
    end
    _nameText.text = Localization.Get(stageInfo.nameID);
    _needLvText.text = string.format(Localization.Get(100014), stageInfo.needLv);
    _staUseText.text = string.format(Localization.Get(100015), stageInfo.staUse);

    --临时：
    local drops = {1,1,1};

    --显示item
    local itemNum = #_itemGroup;
    for i = 1, #drops do
        local itemTmp;
        if i > itemNum then
            itemTmp = Item.Load(_itemElePrefab, _itemParentTrans);
            table.insert(_itemGroup, itemTmp);
        else
            itemTmp = _itemGroup[i];
        end
        Item.Render(_dlg,itemTmp,drops[i]);
    end

    --隐藏多余的item
    for i = #drops + 1, itemNum do
        Item.Hide(_itemGroup[i]);
    end


end