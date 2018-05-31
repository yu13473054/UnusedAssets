-- 界面
DlgChapter = { };

local _ChapterInfo = {
    { bg = "Sg_Chapter_Bg", nameID = 110001, pos = { -428,117, -352,-141, -181,192, -143,-233, 54,14, 183,-181, 238,166, 423,-162 } },
    { bg = "Sg_Chapter_Bg", nameID = 110002, pos = { -428,117, -352,-141, -181,192, -143,-233, 54,14, 183,-181, 238,166, 423,-162 } },
    { bg = "Sg_Chapter_Bg", nameID = 110003, pos = { -428,117, -352,-141, -181,192, -143,-233, 54,14, 183,-181, 238,166, 423,-162 } },
}

local _dlg = nil;

local _chapteNameText;
local _tokenBarParent;
local _tokenBarPrefab;
local _chapterPagePrefab;
local _chapterBtnPrefab;
local _scrollView;
local _btnInfo = { };
local _preBtn;
local _nextBtn;
local _arrowTrans;

local _currChapterIndex;
local _currBtnIndex;

-- 打开界面
function DlgChapter.Open()
    _dlg = UIManager.instance:Open("DlgChapter");
end

-- 隐藏界面
function DlgChapter.Close()
    if _dlg == nil then
        return;
    end

    UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgChapter.OnEvent(uiEvent, controlID, value, gameObject)
    if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgChapter.Close();
        elseif controlID == 1 then
            -- 上一章
            _currChapterIndex = _currChapterIndex - 1;
            if _currChapterIndex < 1 then
                _currChapterIndex = 1;
            else
                DlgChapter.OnCPageIndexChange();
                _scrollView:SetAlignItemIndex(_currChapterIndex - 1, true);
            end
        elseif controlID == 2 then
            -- 下一章
            _currChapterIndex = _currChapterIndex + 1;
            if _currChapterIndex > #_ChapterInfo then
                _currChapterIndex = #_ChapterInfo;
            else
                DlgChapter.OnCPageIndexChange();
                _scrollView:SetAlignItemIndex(_currChapterIndex - 1, true);
            end
        elseif controlID == 101 or controlID == 102 or controlID == 103 then
            -- 默认点击TokenBar
            TokenBarDefaultClick(controlID);
        elseif controlID ~= 0 then
            local worldId = Mathf.Floor(controlID/1000);
            local stageId = controlID % 1000;
            DlgStageInfo.Open(worldId,stageId);
        end
    end
end

-- 载入时调用
function DlgChapter.OnAwake(gameObject)
    -- 控件赋值	
    local objs = gameObject:GetComponent(typeof(UISystem)).relatedGameObject;
    _chapteNameText = objs[0]:GetComponent(typeof(UIText));
    _tokenBarParent = objs[1].transform;
    _tokenBarPrefab = objs[2];
    _chapterBtnPrefab = objs[3];
    _chapterPagePrefab = objs[4];
    _scrollView = objs[5]:GetComponent(typeof(UIScrollView));
    _preBtn = objs[6];
    _nextBtn = objs[7];
    _arrowTrans = objs[8].transform;
end

-- 界面初始化时调用
function DlgChapter.OnStart(gameObject)
    -- 加载tokenBar：方法内部默认指定了点击按钮的controlId
    LoadTokenBarAndSetAttr(_tokenBarPrefab, _tokenBarParent, _dlg);

    DlgChapter.Init();
end

-- 界面显示时调用
function DlgChapter.OnEnable(gameObject)
    if not IsNilOrNull(_dlg) then
        DlgChapter.ShowView();
    end
end

-- 界面隐藏时调用
function DlgChapter.OnDisable(gameObject)

end

-- 界面删除时调用
function DlgChapter.OnDestroy(gameObject)
    _dlg = nil;
    _btnInfo = { };
end


----------------------------------------
-- 自定
----------------------------------------
-- 初始化控件
function DlgChapter.Init()

    -- 初始化ChapterPage和Btn
    for i = 1, #_ChapterInfo do
        local chapterPage = UIManager.instance:InstantiateGo(_chapterPagePrefab, _scrollView.content);
        local objs = chapterPage:GetComponent(typeof(UIItem)).relatedGameObject;
        local bgImg = objs[0]:GetComponent(typeof(UIImage));
        bgImg.sprite = UIManager.instance:GetSprite(_dlg.uiName, _ChapterInfo[i].bg);

        -- 初始化Btn
        for j = 1, #_ChapterInfo[i].pos, 2 do
            local singleBtnInfo = { };
            local chapterBtn = UIManager.instance:InstantiateGo(_chapterBtnPrefab, chapterPage.transform);
            singleBtnInfo.rootTrans = chapterBtn.transform;
            chapterBtn.transform.localPosition = Vector3.New(_ChapterInfo[i].pos[j], _ChapterInfo[i].pos[j + 1]);
            local objs = chapterBtn:GetComponent(typeof(UIItem)).relatedGameObject;
            singleBtnInfo.btnId = i * 1000 + Mathf.Ceil(j/2);
            singleBtnInfo.btnBgImg = objs[0]:GetComponent(typeof(UIImage));
            singleBtnInfo.btn = objs[0]:GetComponent(typeof(UIButton));
            singleBtnInfo.lockGO = objs[1];
            singleBtnInfo.starImg = { objs[2]:GetComponent(typeof(UIImage)), objs[3]:GetComponent(typeof(UIImage)), objs[4]:GetComponent(typeof(UIImage)) };
            singleBtnInfo.numText = objs[5]:GetComponent(typeof(UIText));
            table.insert(_btnInfo, singleBtnInfo);
        end
    end

    _scrollView.onAlignToFinish = function(itemIndex)
        _currChapterIndex = itemIndex + 1;
        DlgChapter.OnCPageIndexChange();
    end

    DlgChapter.ShowView();
end

--打开界面后，需要根据具体数据设置按钮信息，章节信息
function DlgChapter.ShowView()
    -- 获取当前通关的章节位置
    _currChapterIndex = 1;
    _currBtnIndex = 12;
    -- 设置对齐到某个位置
    _scrollView:SetAlignItemIndex(_currChapterIndex - 1, false);

    for i = 1, #_btnInfo do
        local data = { };
        if i < _currBtnIndex then
            -- 通过
            data.state = 1;
            data.starNum = Mathf.Random(1, 3);
        elseif i == _currBtnIndex then
            -- 最新关卡
            data.state = 0;
            data.starNum = 0;
        else
            -- 未通过
            data.state = -1;
            data.starNum = 0;
        end
        DlgChapter.SetBtnInfo(_btnInfo[i], data);
    end

end

function DlgChapter.OnCPageIndexChange()
    -- 设置章节名称
    _chapteNameText.text = Localization.Get(_ChapterInfo[_currChapterIndex].nameID);

    -- 设置切换按钮的显示和隐藏
    if _currChapterIndex == 1 then
        _preBtn:SetActive(false);
        _nextBtn:SetActive(true);
    elseif _currChapterIndex == #_ChapterInfo then
        _preBtn:SetActive(true);
        _nextBtn:SetActive(false);
    else
        _preBtn:SetActive(true);
        _nextBtn:SetActive(true);
    end
end

function DlgChapter.SetBtnInfo(singleBtnInfo, data)
    -- 设置按钮图
    if data.state == 1 then
        singleBtnInfo.btnBgImg.sprite = UIManager.instance:GetSprite(_dlg.uiName, "DlgChapter_PassBtn");
    else
        singleBtnInfo.btnBgImg.sprite = UIManager.instance:GetSprite(_dlg.uiName, "DlgChapter_NormalBtn");
    end
    -- 设置锁
    if data.state == -1 then -- 未通关
        singleBtnInfo.lockGO:SetActive(true);
    else
        singleBtnInfo.lockGO:SetActive(false);
         --设置按钮事件
        singleBtnInfo.btn.controlID = singleBtnInfo.btnId;
        singleBtnInfo.btn.uiMod = _dlg;
    end

    --设置星星
    for i = 1, #singleBtnInfo.starImg do
        if data.starNum == 0 then 
            singleBtnInfo.starImg[i].gameObject:SetActive(false);
        else
            singleBtnInfo.starImg[i].gameObject:SetActive(true);
            if i <= data.starNum then
                singleBtnInfo.starImg[i].isGray = false;
            else
                singleBtnInfo.starImg[i].isGray = true;
            end
        end
    end

    singleBtnInfo.numText.text = singleBtnInfo.btnId;

    -- 设置箭头
    if data.state == 0 then
        _arrowTrans:SetParent(singleBtnInfo.rootTrans);
        _arrowTrans.localPosition = Vector3.zero;
    end
end