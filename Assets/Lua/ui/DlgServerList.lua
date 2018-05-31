-- 界面
DlgServerList = { };
local _dlg = nil;
local _serverItem;
local _itemParent;
local _itemList = { };
--local _selectServerId;

-- 打开界面
function DlgServerList.Open()
    _dlg = UIManager.instance:Open("DlgServerList");
end

-- 隐藏界面
function DlgServerList.Close()
    if _dlg == nil then
        return;
    end
    UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgServerList.OnEvent(uiEvent, controlID, value, gameObject)
    if uiEvent ==UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgServerList.Close();
        elseif controlID >= 2000 then
            -- 点击服务器按钮
            local selectServerId = controlID - 2000;
            DlgServerList.Close();
            Event.UI:DispatchEvent("SERVERLIST", selectServerId);
        end
    end
end

-- 载入时调用
function DlgServerList.OnAwake(gameObject)
    -- 控件赋值	
    local objs = gameObject:GetComponent(typeof(UISystem)).relatedGameObject;
    _serverItem = objs[0];
    _itemParent = objs[1].transform;
end

-- 界面初始化时调用
function DlgServerList.OnStart(gameObject)

end

-- 界面显示时调用
function DlgServerList.OnEnable(gameObject)
    DlgServerList.InitItem();
end

-- 界面隐藏时调用
function DlgServerList.OnDisable(gameObject)
    DlgServerList.CollectItem();
end

-- 界面删除时调用
function DlgServerList.OnDestroy(gameObject)
    _dlg = nil;
end

----------------------------------------
-- 自定
----------------------------------------
function DlgServerList.InitItem()
    for i, var in pairs(DlgLogin.ServerIDSorted) do
        -- 获取item的实例
        local item = nil;
        if (i > #_itemList) then
            local inst = UIManager.instance:InstantiateGo(_serverItem, _itemParent);
            local uiItem = inst:GetComponent(typeof(UIItem));
            item = {
                transform = inst,
                serverBtn = uiItem.relatedGameObject[0]:GetComponent(typeof(UIButton)),
                serverName = uiItem.relatedGameObject[1]:GetComponent(typeof(UIText))
            };
            table.insert(_itemList, item);
        else
            item = _itemList[i];
        end

        -- 初始化item
        if DlgLogin.ServerList[var].serverState == 0 then
            -- 状态0为维护状态
            item.transform.gameObject:SetActive(false);
        else
            item.transform.gameObject:SetActive(true);
            item.serverBtn.uiMod = _dlg;
            item.serverBtn.controlID = var + 2000;
            item.serverName.text = DlgLogin.ServerList[var].serverName;
        end

    end

     --隐藏多余的item
    for i = #DlgLogin.ServerIDSorted + 1, #_itemList do
        _itemList[i].transform.gameObject:SetActive(false);
    end

end

function DlgServerList.CollectItem()
    for i, var in pairs(_itemList) do
        var.transform.gameObject:SetActive(false);
    end
end


