-- 界面
DlgChat = {};
local _dlg = nil;
local _inPutText;   
local _msgContentPrefab;
local _msgPrefab;
local _msgItem;
local _msgScroll;

local _maxChat = 5;

local _itemList = {};
local _msgList = {};

-- 打开界面
function DlgChat.Open()
	_dlg = UIManager.instance:Open( "DlgChat" );
end

-- 隐藏界面
function DlgChat.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgChat.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgChat.Close();
        elseif controlID == 1 then -- 发送消息
            DlgChat.QuitSend();
        elseif controlID == 2 then -- 表情

        elseif controlID == 3 then -- 语音

        end
	end
end

-- 载入时调用
function DlgChat.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _msgItem =  objs[2]:GetComponent( typeof( UIItem ) ).relatedGameObject;
   
    _inPutText = objs[0]:GetComponent( typeof( UIInputField ) );
    _msgScroll = objs[3]:GetComponent( typeof( UIScrollView ) );
  
    _msgContentPrefab = objs[1];   
    _msgPrefab = objs[2];

end

-- 界面初始化时调用
function DlgChat.OnStart( gameObject )

end

-- 界面显示时调用
function DlgChat.OnEnable( gameObject )
	
end

-- 界面隐藏时调用
function DlgChat.OnDisable( gameObject )
	
end

-- 界面删除时调用
function DlgChat.OnDestroy( gameObject )
	_dlg = nil;
end


----------------------------------------
-- 自定
----------------------------------------

-- 发送按钮对应方法 
function DlgChat.QuitSend()    
    
    -- 没有输入无操作
    if _inPutText.text == "" then 
        return;
    else 
        DlgWait.Open();

        -- 消息操作
        DlgChat.UpdateItem( _msgPrefab );    
        _inPutText.text = "";

        DlgWait.Close();
    end
end

-- Msg信息加载
function DlgChat.UpdateItem( item )

    -- 存储属性
    local playerName;       --  玩家姓名
    local playerText;       --  玩家发送的消息内容
    local playerIcon;       --  玩家头像   
    local oneMsgList = {};  -- 单信息存储表
    
    -- 判断是做增加操作还是替换操作
    if #_itemList < _maxChat then              
        -- 克隆
        local temp = GameObject.Instantiate( item );
        temp.transform:SetParent(_msgContentPrefab.transform,false);
        temp:SetActive(true);
        -- 获取属性值
        playerName = CachePlayer.playerName;
        playerText = _inPutText.text;  
        -- 获取控件
        local objs = temp:GetComponent( typeof( UIItem ) ).relatedGameObject;
        objs[7]:SetActive(false);
        objs[0]:GetComponent( typeof( UIText ) ).text = playerName;
        objs[1]:GetComponent( typeof( UIText ) ).text = playerText; 

        -- 信息内容
        oneMsgList = {playerName = CachePlayer.playerName, playerIcon = nil, playerText = _inPutText.text};
        DlgChat.UpdateList( temp , oneMsgList, true );
    else
        -- 替换操作（将第一个控件挪到最后）
        table.insert(_itemList,_itemList[1]);
        table.remove(_itemList,1);
        _itemList[_maxChat].transform:SetAsLastSibling();

        -- 获取属性值
        playerName = CachePlayer.playerName;
        playerText = _inPutText.text; 
        -- 获取控件
        local objs = _itemList[_maxChat]:GetComponent( typeof( UIItem ) ).relatedGameObject;
        objs[6]:SetActive(true);
        objs[7]:SetActive(false);
        objs[0]:GetComponent( typeof( UIText ) ).text = playerName;
        objs[1]:GetComponent( typeof( UIText ) ).text = playerText;
        -- 信息内容 
        oneMsgList = {playerName = CachePlayer.playerName, playerIcon = nil, playerText = _inPutText.text};

        DlgChat.UpdateList( _itemList[_maxChat], oneMsgList, false );
    end
    -- 强制刷新
    LayoutRebuilder.ForceRebuildLayoutImmediate(_msgContentPrefab.transform);
    -- 滑动位置至尾
    _msgScroll.verticalNormalizedPosition = 0;
end 

-- Msg显示信息文本表
function DlgChat.UpdateList( item, oneMsgList, boolItem)
  
    -- 存入信息消息（临时）     
    table.insert( _msgList,{
                  msgName = oneMsgList.playerName,
                  msgIcon = oneMsgList.playerIcon, 
                  msgText = oneMsgList.playerText });
  
    if boolItem == true then
        -- 存入加载控件
        table.insert( _itemList,item );
    end
end