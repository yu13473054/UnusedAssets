--[[ 这里放一些公用定义，和一些公用逻辑方法 ]]
----------------------------------
-- UI定义
----------------------------------
-- UILayer
UILAYER_FULL                = 0;
UILAYER_POP                 = 1;
UILAYER_TOP                 = 2;

--UI事件
UIEVENT_UIBUTTON_CLICK = 10;                -- UIButton单击                   无参
UIEVENT_UIBUTTON_PRESS = 11;		        -- UIButton按下					0 按下，1 抬起

UIEVENT_UITOGGLE_CLICK = 22;                -- UIToggle单击                   无参
UIEVENT_UITOGGLE_PRESS = 23;		        -- UIToggle按下                   0 按下，1 抬起
UIEVENT_UITOGGLE_ONVALUECHANGE = 21;	    -- UIToggle内容发生变化时          bool值

UIEVENT_UISLIDER_DRAG = 31;                 -- UISlider拖动                   0 开始拖动，1 拖动中，2 结束拖动
UIEVENT_UISLIDER_PRESS = 34;                -- UISlider按下                   0 按下，1 抬起

UIEVENT_CAMERA_CLICK = 41;                  -- Camera单击，也是抬起			组件的名称作为标志值。无controlID
UIEVENT_CAMERA_PRESS = 42;                  -- Camera按下					组件的名称作为标志值。无controlID

UIEVENT_UISCROLLVIEW_DRAG = 51;		        -- UIScrollView拖动               0 开始拖动，1 拖动中，2 结束拖动
UIEVENT_UISCROLLVIEW_ONVALUECHANGE = 52;	-- UIScrollView内容发生变化时      Vector2对象
UIEVENT_WRAPCONTENT_ONITEMUPDATE = 53;	    -- WrapContent中Item更新        自定义对象：index，Transform
UIEVENT_WRAPCONTENT_ONINITDONE = 54;	    -- WrapContent中初始化完成       无

UIEVENT_UIINPUT_SUBMIT = 61;                --         

UIEVENT_UISCROLLBAR_ONVALUECHANGE = 71;	    -- UIScrollbar内容发生变化时       float值
UIEVENT_UISCROLLBAR_PRESS = 72;	            -- UIScrollbar按下                0 按下，1 抬起

----------------------------------
-- 事件定义
----------------------------------
EVENT_SOCKET_NORMAL         = 0;       -- 正常包
EVENT_SOCKET_ONCONNECT      = -1;      -- 连接成功
EVENT_SOCKET_DISCONNECT     = -101;    -- 正常断线
EVENT_SOCKET_EXCEPTION      = -102;    -- 异常掉线

-- Http协议号定义
EVENT_HTTP_EXCEPTION        = -100;    -- http 异常
EVENT_HTTP_LOGIN            = 10001;
EVENT_HTTP_SERVERLIST       = 10002;

-- 战斗
EVENT_FIGHT_UNITADD         = "EVENT_FIGHT_UNITADD";            -- 单位入场
EVENT_FIGHT_UNITDIE         = "EVENT_FIGHT_UNITDIE";            -- 单位死亡
EVENT_FIGHT_UNITMOVE        = "EVENT_FIGHT_UNITMOVE";           -- 单位移动
EVENT_FIGHT_UNITCHANGE      = "EVENT_FIGHT_UNITCHANGE";         -- 单位换人
EVENT_FIGHT_UNITENTER       = "EVENT_FIGHT_UNITENTER";          -- 单位入场
EVENT_FIGHT_UNITQUIT        = "EVENT_FIGHT_UNITQUIT";           -- 单位退场
EVENT_FIGHT_UNITHPCHANGE    = "EVENT_FIGHT_UNITHPCHANGE";       -- 单位HP变化
EVENT_FIGHT_FIGHTCAMERAMOVE = "EVENT_FIGHT_FIGHTCAMERAMOVE";    -- 战场摄像机移动
EVENT_FIGHT_EMITTER_ADD     = "EVENT_FIGHT_EMITTER_ADD";        -- 技能激活
EVENT_FIGHT_EMITTER_REMOVE  = "EVENT_FIGHT_EMITTER_REMOVE";     -- 技能结束
EVENT_FIGHT_BULLET_ADD      = "EVENT_FIGHT_BULLET_ADD";         -- 子弹出现
EVENT_FIGHT_BULLET_REMOVE   = "EVENT_FIGHT_BULLET_REMOVE";      -- 子弹结束
EVENT_FIGHT_EFFECT_ADD      = "EVENT_FIGHT_EFFECT_ADD";         -- 效果出现
EVENT_FIGHT_EFFECT_REMOVE   = "EVENT_FIGHT_EFFECT_REMOVE";      -- 效果结束
EVENT_FIGHT_BUFF_ADD        = "EVENT_FIGHT_BUFF_ADD";           -- Buff出现
EVENT_FIGHT_BUFF_REMOVE     = "EVENT_FIGHT_BUFF_REMOVE";        -- Buff结束
EVENT_FIGHT_UNITLIST_INIT   = "EVENT_FIGHT_UNITLIST_INIT";      -- 战场角色准备完毕
EVENT_FIGHT_START           = "EVENT_FIGHT_START";              -- 战斗开始
EVENT_FIGHT_END             = "EVENT_FIGHT_END";                -- 战斗结束
EVENT_FIGHT_WAVESTART       = "EVENT_FIGHT_WAVESTART";          -- 本波战斗结束
EVENT_FIGHT_WAVEEND         = "EVENT_FIGHT_WAVEEND";            -- 本波战斗结束
EVENT_FIGHT_READY           = "EVENT_FIGHT_READY";              -- 战斗准备完毕
EVENT_FIGHT_MAGICSYNC       = "EVENT_FIGHT_MAGICSYNC";          -- 能量值同步
EVENT_FIGHT_MAGICREDUCE     = "EVENT_FIGHT_MAGICREDUCE";        -- 能量值减少
EVENT_FIGHT_ONSKILL         = "EVENT_FIGHT_ONSKILL";            -- 释放了技能
-- 战斗Log专用
EVENT_FIGHT_RANDOM          = "EVENT_FIGHT_RANDOM";             -- 取随机数

--排序
SORT_GRADE = 101;
SORT_STAR = 102;
SORT_LEVEL = 103; 
SORT_IMPRESSION = 104;
SORT_BORNTIME = 105;
SORT_ATK = 106;
SORT_HP = 107;
SORT_DEF = 108;
SORT_CRIT = 109;
SORT_SPEED = 110;
--筛选
FILTER_CONSTLL_ALL = 200;
FILTER_CONSTLL_ARIES = 201;
FILTER_CONSTLL_TAURUS = 202;
FILTER_CONSTLL_GEMINI = 203;
FILTER_CONSTLL_CANCER = 204;
FILTER_CONSTLL_LEO = 205;
FILTER_CONSTLL_VIRGO = 206;
FILTER_CONSTLL_LIBRA = 207;
FILTER_CONSTLL_SCORPIO = 208;
FILTER_CONSTLL_SAGITTARIUS = 209;
FILTER_CONSTLL_CAPRICORNUS = 210;
FILTER_CONSTLL_AQUARIUS = 211;
FILTER_CONSTLL_PISCES = 212;
FILTER_CONSTLL_OTHER = 213;
FILTER_CAMP_ALL = 300;
FILTER_CAMP_SCHOOL = 301;
FILTER_CAMP_BELIEF = 302;
FILTER_CAMP_TECHNOLOGY = 303;
FILTER_CAMP_EXTRATALENT = 304;
FILTER_GRADE_ALL = 400;
FILTER_GRADE_N = 401;
FILTER_GRADE_R = 402;
FILTER_GRADE_SR = 403;
FILTER_GRADE_SSR = 404;

----------------------------------
-- 事件分发实例
----------------------------------
Event = {};
Event.Net = EventDispatcher.New();
Event.Fight = EventDispatcher.New();
Event.UI = EventDispatcher.New();

----------------------------------
-- 基础方法
----------------------------------
--星级对应等级上限
function LVLimitByStar(starNum)
    if starNum ==1 then
        return 40;
    elseif starNum ==2 then
        return 55;
    elseif starNum ==3 then
        return 70;
    elseif starNum ==4 then
        return 85;
    else
        return 100;
    end
end
-- Log，打印调试print就行
function Log( msg )
    Debugger.Log( msg );
end
function LogWarning( msg )
    Debugger.LogWarning( msg );
end
function LogErr( msg )
    Debugger.LogError( msg );
end
function error( msg )
    Debugger.LogError( msg );
end

-----------------------------------------------
-- Prefab
function LoadPrefab( name )
    local prefab = ResourceManager.instance:LoadPrefab( name );
    if prefab ~= nil then
        local go = GameObject.Instantiate( prefab );
        go.name = name;
        return go;
    end
end

--------------------------------
-- 角色相关加载
--------------------------------
-- 加载头像
function Load_Char_Head( uiName, res )
    local resName = "Char_Head_" .. res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, "char_head", "Assets/Res/Char_Sprite/Head/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, "char_head" );
end
-- 加载全身立绘
function Load_Char_Role( uiName, res )
    local resName = "Char_Role_" .. res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, resName, "Assets/Res/Char_Sprite/Role/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, resName );
end
-- 加载卡片立绘
function Load_Char_Card( uiName, res )
    local resName = "Char_Card_" .. res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, "Char_Card", "Assets/Res/Char_Sprite/Card/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, "char_card" );
end
-- 加载技能半身像
function Load_Char_Portrait( uiName, res, suffix )
    local resName = "Char_Portrait_" .. res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName .. "_" .. suffix, "char_portrait", "Assets/Res/Char_Sprite/Portrait/" .. resName .. "_" .. suffix .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName .. "_" .. suffix, "char_portrait" );
end

--------------------------------
--加载单张图片资源
--卡牌背景框底框
function LoadFrame_Card_Bottom(uiName, res)
    local resName = "Sg_Frame_Bottom" .. res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, "SG_Frame", "Assets/Res/SpritesGroup/SG_Frame/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, "SG_Frame" );
end
--卡牌背景框上层框
function LoadFrame_Card_Top(uiName, res)
    local resName = "Sg_Frame_Top" .. res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, "SG_Frame", "Assets/Res/SpritesGroup/SG_Frame/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, "SG_Frame" );
end
--星座图标
function LoadConstellation(uiName, res)
    local resName = res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, "icon_Constellation", "Assets/Res/Icon/Constellation/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, "icon_Constellation" );
end
--道具图标
function LoadItemIcon(uiName, res)
    local resName = res;

    -- 编辑器模式
    if AppConst.resourceMode == 0 then
        return UIManager.instance:GetSprite( uiName, resName, "icon_Item", "Assets/Res/Icon/Item/" .. resName .. ".png" );
    end    
    return UIManager.instance:GetSprite( uiName, resName, "icon_Item" );
end

--------------------------------
--加载TokenBar上的组件
function LoadTokenBar(prefab,parent)
    if not prefab then  
        LogErr("<Define> 加载TokenBar的Prefab为null！")
        return;
    end
    if not parent then  
        LogErr("<Define> 加载TokenBar的parent为null！")
        return;
    end
    local objs = UIManager.instance:InstantiateGo(prefab, parent):GetComponent(typeof(UIItem)).relatedGameObject;
    local tokenBar ={};
    tokenBar.diamondIconImg = objs[0]:GetComponent(typeof(UIImage));
    tokenBar.diamondNumText = objs[1]:GetComponent(typeof(UIText));
    tokenBar.diamondAddBtn = objs[2]:GetComponent(typeof(UIButton));
    tokenBar.diamondGo = objs[9];

    tokenBar.staminaIconImg = objs[3]:GetComponent(typeof(UIImage));
    tokenBar.staminaNumText = objs[4]:GetComponent(typeof(UIText));
    tokenBar.staminaAddBtn = objs[5]:GetComponent(typeof(UIButton));
    tokenBar.staminaGo = objs[10];

    tokenBar.coinIconImg = objs[6]:GetComponent(typeof(UIImage));
    tokenBar.coinNumText = objs[7]:GetComponent(typeof(UIText));
    tokenBar.coinAddBtn = objs[8]:GetComponent(typeof(UIButton));
    tokenBar.coinGo = objs[11];
    return tokenBar;
end
--加载TokenBar，并对其上组件通用设置
function LoadTokenBarAndSetAttr(prefab, parent, uiMod, diamondCtrlId, staminaCtrlId, coinCtrlId)
    local tokenBar = LoadTokenBar(prefab,parent);
    tokenBar.diamondAddBtn.controlID = diamondCtrlId or 101;
    tokenBar.diamondAddBtn.uiMod = uiMod;
    tokenBar.staminaAddBtn.controlID = staminaCtrlId or 102;
    tokenBar.staminaAddBtn.uiMod = uiMod;
    tokenBar.coinAddBtn.controlID = coinCtrlId or 103;
    tokenBar.coinAddBtn.uiMod = uiMod;
    return tokenBar;
end
--默认的TokenBar上的按钮点击功能
function TokenBarDefaultClick(ctrlId)
    if controlID == 101 then --钻石

    elseif controlID == 102 then --体力

    elseif controlID == 103 then --金币

    end
end
-----------------------------------------------

-- 判空，仅用于Unity.Object
function IsNilOrNull( obj )
    if obj == nil or obj:Equals( nil ) then
        return true;
    end
    return false;
end

function PlayTweenAnim(go)
    local anims = go:GetComponents(typeof(DOTweenAnimation));

	local longestAnim = anims[0];
	local dura = 0;
    --获取时间最长的animation
	for i = 0, anims.Length-1 do
	    local anim = anims[i];
	    anim:DOPlay();

	    if anim.duration > dura then
	        dura = anim.duration;
	        longestAnim = anim;
	    end
	end
    return longestAnim;
end

