-- 界面
DlgSkillShow = {};
local _dlg = nil;

local _animTrans;
local _anims;

local _longestAnim;

-- 打开界面
function DlgSkillShow.Open()
	_dlg = UIManager.instance:Open( "DlgSkillShow" );
end

-- 隐藏界面
function DlgSkillShow.Close()
	if _dlg == nil then
		return;
	end
	
	UIManager.instance:Close(_dlg);
end

----------------------------------------
-- 事件
----------------------------------------
-- 所属按钮点击时调用
function DlgSkillShow.OnEvent( uiEvent, controlID, value, gameObject )
	if uiEvent == UIEVENT_UIBUTTON_CLICK then
        if controlID == -1 then
            DlgSkillShow.Close();
        end
	end
end

-- 载入时调用
function DlgSkillShow.OnAwake( gameObject )
	-- 控件赋值	
	local objs = gameObject:GetComponent( typeof( UISystem ) ).relatedGameObject;	
    _animTrans = objs[0].transform;
    _roleImg = objs[0]:GetComponent( typeof( UIImage ) );
end

-- 界面初始化时调用
function DlgSkillShow.OnStart( gameObject )
    _anims = _animTrans:GetComponents(typeof(DOTweenAnimation));
	_longestAnim = PlayTweenAnim(_animTrans);

    _longestAnim.onComplete = function (anim)
        anim:DORewind();

        --关闭展示
        DlgSkillShow.Close();
    end

end

-- 界面显示时调用
function DlgSkillShow.OnEnable( gameObject )
	if not IsNilOrNull(_dlg) then
        for i = 0, _anims.Length-1 do
	        local anim = _anims[i];
	        anim:DOPlay();
	    end
    end
end

-- 界面隐藏时调用
function DlgSkillShow.OnDisable( gameObject )
	
end

-- 界面删除时调用
function DlgSkillShow.OnDestroy( gameObject )
	_dlg = nil;
    _longestAnim.onComplete = nil;
end


----------------------------------------
-- 自定
----------------------------------------
function DlgSkillShow.Show( unit )
    DlgSkillShow.Open();

    _roleImg.sprite = Load_Char_Role( _dlg.name, Data.Character()[unit.data.charID].res );
    _roleImg:SetNativeSize();
end