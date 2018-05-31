--道具
Item = {};

function Item.Load(prefab,parent)
    local goTmp = UIManager.instance:InstantiateGo(prefab, parent).gameObject;
    local objs = goTmp:GetComponent(typeof(UIItem)).relatedGameObject;
    local item ={};
    item.go = goTmp;
    item.frameImg = objs[0]:GetComponent(typeof(UIImage));
    item.iconImg = objs[1]:GetComponent(typeof(UIImage));

    return item;
end

function Item.Render(dlg, item, itemId)
    local itemInfo = Data.Item()[itemId];
    if itemInfo == nil then
        LogErr(string.format("<Item> ItemID = %s 的数据为空", itemId));
        return;
    end
    item.go:SetActive(true);

    item.frameImg.sprite = UIManager.instance:GetSprite(dlg.uiName, "Cm_Ft_ItemIconFrame");
    item.iconImg.sprite = LoadItemIcon(dlg.uiName, itemInfo.iconRes);
end

function Item.Reset(item)

end

function Item.Hide(item)
    item.go:SetActive(false);
     Item.Reset();
end

--头像

--半身像
