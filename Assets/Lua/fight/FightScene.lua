-- 战斗场景控制
FightScene={};

--当前层背景的宽度，多少个背景，每个背景对象的位置
local _layers ;
local _speeds = {-1,-2,-3};
local _screenWidth;
local _alignLayerIndex = 2; -- 移动距离的参考层索引

function FightScene.Init(scenePrefab,size)
    _layers = {};
    local childCount = scenePrefab.transform.childCount;
    _screenWidth = Screen.width * size * 2 / Screen.height;
    for i = 0, childCount-1 do
        local bg = scenePrefab.transform:GetChild(i):GetChild(0);--默认第0个是背景层
        local spriteRenderer = bg:GetComponent(typeof(SpriteRenderer));
        if not IsNilOrNull(spriteRenderer) then
            -- 记录当层的信息
            local single = {width = 0, spriteTrans = {}, pos = {}};
            single.width = spriteRenderer.size.x;
            table.insert(_layers,single);

            local pos = bg.localPosition;

            -- 先将当层第一个bg记录下来
            local bgPos = Vector3.New(pos.x,pos.y,pos.z);
            table.insert(single.spriteTrans, bg);
            table.insert(single.pos, bgPos);

            -- 计算该层背景的个数
            local lastPos = bgPos;
            local bgCount = Mathf.Ceil(_screenWidth/single.width) + 1;
            -- 从第二个开始复制
            for j = 2, bgCount do
                local cloneBg = GameObject.Instantiate(bg);
                cloneBg:SetParent(bg.parent);
                local cloneBgPos = lastPos + Vector3.New(single.width * (j-1));
                table.insert(single.spriteTrans,cloneBg);
                table.insert(single.pos, cloneBgPos);

                -- 设置复制出来的bg的坐标
                cloneBg.localPosition = cloneBgPos;
            end
        end
    end
end

-- 将最后一层移动delta的坐标值：其他层移动相应的次数
function FightScene.Translate(delta)
    -- 计算移动的次数
    local moveCount = Mathf.Abs(delta/_speeds[_alignLayerIndex]);

    for i = 1, #_layers do
        local single = _layers[i];

        local head, bgCount = 1, #single.spriteTrans;
        -- 移动所有的bg
        local moveDelta = Vector3.New(moveCount*_speeds[i]);
        for j = 1, bgCount do
            single.pos[j]:Add(moveDelta);
        end

        -- 将超出屏幕边界的移到队列最后
        while (true) do
            if (moveDelta.x < 0) then 
                if(single.pos[head].x + single.width/2 <= - _screenWidth / 2) then
                    -- 从队头移动到队尾
                    local newPos = single.pos[bgCount] + Vector3.New(single.width);
                    table.remove(single.pos,head);
                    local trans = table.remove(single.spriteTrans, head);
                    table.insert(single.pos,newPos);
                    table.insert(single.spriteTrans,trans);
                else
                    break;
                end
            else
                if(single.pos[bgCount].x - single.width/2 >= _screenWidth / 2) then
                    -- 从队尾移动到队头
                    local newPos = single.pos[head] - Vector3.New(single.width);
                    table.remove(single.pos);
                    local trans = table.remove(single.spriteTrans);
                    table.insert(single.pos,1,newPos);
                    table.insert(single.spriteTrans,1,trans);
                else
                    break;
                end
            end
        end


        -- 设置坐标
        for j = 1, bgCount do
            local trans = single.spriteTrans[j];
            trans.localPosition = single.pos[j];
        end
    end
end

-- 设置速度参考层
function FightScene.SetAlignLayerId(id)
    if (id >= 1 or id <= #_speeds) then
        _alignLayerIndex = id;
    else
        LogErr("<FightScene> 指定层不存在：" .. id);
    end
end

-- 设置每层的速度：正负控制移动方向
function FightScene.SetSpeed (speeds)
    if type(speeds) ~= "table" then
        LogErr("<FightScene> 设置背景层速度时，需要传入Table类型");
        return;
    end 
    
    for i = 1, #_speeds do
        _speeds[i] = speeds[i] or _speeds[i];
    end
end

-- 设置指定层的速度
function FightScene.SetSingleLayerSpeed(id, speed)
    if (id >= 1 or id <= #_speeds) then
        _speeds[id] = speed;
    else
        LogErr("<FightScene> 指定层不存在：" .. id);
    end
end
