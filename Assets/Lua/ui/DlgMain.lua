-- 界面
DlgMain = {};
local _dlg = nil;
local _tokenBarParent;
local _tokenBarPrefab;
local _userNameText;
local _lvText;
local _expImg;
local _arrowIconTrans;
local _btnGroupTrans;
local _roleTrans;

local _expandAnim;
local _arrowAnim;
local _isExpand = true;
local _canClick = true;

local _sceneGo;
local _sceneCamera;

-- 打开界面
function DlgMain.Open()
	_dlg = UIManager.instance:Open( "DlgMain" );
end

-- 隐藏界面
function DlgMain.Close()
	if _dlg == nil then
		return;
	end
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgMain.OnEvent( uiEvent, controlID, value, gameObject )
    if not _canClick then return end;
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgMain.Close();
        elseif controlID == 1 then --邮件
        
        elseif controlID == 2 then --聊天
            DlgChat.Open();       
        elseif controlID == 3 then --图鉴

        elseif controlID == 4 then --活动

        elseif controlID == 5 then --任务

        elseif controlID == 6 then --好友

        elseif controlID == 7 then --角色
            DlgRole.Open();
        elseif controlID == 8 then --箭头
            DlgMain.Expand();
        elseif controlID ~= 0 then  --默认点击TokenBar
            TokenBarDefaultClick(controlID);
        end
    elseif uiEvent == UIEVENT_CAMERA_CLICK then
        if value == "Build_1" then --开始游戏
            DlgChapter.Open();
        end
	end
end

-- 载入时调用
function DlgMain.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;
    _userNameText = objs[0]:GetComponent(typeof(UIText));
    _lvText = objs[1]:GetComponent(typeof(UIText));
    _expImg = objs[2]:GetComponent(typeof(UIImage));
    _tokenBarParent = objs[3].transform;
    _arrowIconTrans = objs[4].transform;
    _tokenBarPrefab = objs[5];
    _btnGroupTrans = objs[6].transform;
    _roleTrans = objs[7].transform;
end

-- 界面初始化时调用
function DlgMain.OnStart( gameObject )
    --第一次打开界面时无法获取到_dlg
    _sceneGo.transform.parent:GetChild(0):GetComponent(typeof(Camera2D)).uiMod = _dlg;

    --加载tokenBar：方法内部默认指定了点击按钮的controlId
    LoadTokenBarAndSetAttr(_tokenBarPrefab, _tokenBarParent, _dlg);

    --设置收缩和展开动画
    LayoutRebuilder.ForceRebuildLayoutImmediate(_btnGroupTrans);
    local btnGroupW = _btnGroupTrans.sizeDelta.x;
    _expandAnim = _btnGroupTrans:GetComponent(typeof(DOTweenAnimation));
    _expandAnim.endValueV3 = Vector3.New(btnGroupW, -37, 0);
    _expandAnim:CreateTween();
    _expandAnim.onStepComplete = function(anim) _canClick = true; end;

    _arrowAnim = _arrowIconTrans:GetComponent(typeof(DOTweenAnimation));

	--创建立绘骨骼动画
	local spineAnim = SpineUtils.Create("Role_008");
    spineAnim.transform:SetParent(_roleTrans, false);
end

-- 界面显示时调用
function DlgMain.OnEnable( gameObject )
	_isExpand = true;
    --加载背景
    if IsNilOrNull(_sceneGo) then --第一次打开界面
        local lobbyScene = LoadPrefab("LobbyScene").transform;
        _sceneGo = lobbyScene:GetChild(1).gameObject;   
        _sceneCamera = lobbyScene:GetChild(0):GetComponent(typeof(Camera2D));

        --玩家信息加载
        _userNameText.text = CachePlayer.playerName;

    else
        _sceneGo:SetActive(true);
        _sceneCamera:Reset();
    end
end

-- 界面隐藏时调用
function DlgMain.OnDisable( gameObject )
    if IsNilOrNull(_sceneGo) then return end;
	_sceneGo:SetActive(false);
end

-- 界面删除时调用
function DlgMain.OnDestroy( gameObject )
	_dlg = nil;
end


----------------------------------------
-- 自定
----------------------------------------
--控制下方按钮的展开和收缩
function DlgMain.Expand()
    _canClick = false;
    if _isExpand then
        _expandAnim:DOPlayForward();
        _arrowAnim:DOPlayForward();
    else
        _expandAnim:DOPlayBackwards();
        _arrowAnim:DOPlayBackwards();
    end
    _isExpand = not _isExpand;
 end