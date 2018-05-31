---------------------------------
-- 角色类
-- *用途较广，数据较少，无频繁生成销毁，故没用池管理*
---------------------------------
-- 角色动作
local CharAction =
{
    IDLE    = "IDLE",
    MOVE    = "MOVE",
    ATTACK0 = "ATTACK0",
    ATTACK1 = "ATTACK1",
    DIE     = "DIE",
    SKILL   = "SKILL",
    HITED   = "HITED",
    ENTER   = "ENTER",
    QUIT    = "QUIT",
    WIN     = "WIN",
    STUN    = "STUN",
}

-- 额外动作
local CharAction_Animator = 
{
    RED                 = Animator.StringToHash( "RED" ),
    ENTER               = Animator.StringToHash( "ENTER" ),
    QUIT                = Animator.StringToHash( "QUIT" ),
    HALFBLACK           = Animator.StringToHash( "HALFBLACK" ),
    HALFBLACKRECOVER    = Animator.StringToHash( "HALFBLACKRECOVER" ),
}

-- 角色相关
Character = Class( "Character" );

---------------------------------
-- 构造方法
---------------------------------
-- 创建一个角色 
function Character:Ctor( charID, root )
    self.data = Data.Character()[charID];

    -- Unity属性
    self.abName = "";

    -- 创建角色
    self.gameObject = CharacterManager.Spawn( self.data.res, root );
    self.spineAnime = self.gameObject:GetComponent( typeof( SkeletonAnimation ) );

    -- 取下动画Animator
    self.animator = self.gameObject:GetComponent( typeof( Animator ) );
        
    -- 持续时间查找元表
    local durationMeta = {};
    durationMeta.__index = function( t, k )
        local duration = self.spineAnime.SkeletonDataAsset:GetSkeletonData( true ):FindAnimation( k ).Duration;
        t[k] = duration;
        return duration;
    end
    
    -- 缓存动画时间
    self.animeDuration = {};
    setmetatable( self.animeDuration, durationMeta );
end

-- 回收
function Character:Destory()
    CharacterManager.Despawn( self.data.res, self.gameObject );
end

-- 手动Update
function Character:Update( updateTime )
    self.spineAnime:Update( updateTime / 1000 );
end

-- 时间豁免
function Character:NoTimeStop( noTimeStop )
    if noTimeStop then
        self.animator.updateMode = AnimatorUpdateMode.UnscaledTime;
    else
        self.animator.updateMode = AnimatorUpdateMode.Normal;
    end
end

---------------------------------
-- 工具方法
---------------------------------
function Character:GetMiddlePos()
    return Vector3.New( 0, self.data.height / 200, 0 );
end

---------------------------------
-- Spine动作
---------------------------------
-- 待机
function Character:Idle()
    if self.spineAnime.AnimationName == CharAction.IDLE then
        return;
    end

    self.spineAnime.loop  = true;
    self.spineAnime.timeScale = 1;
    self.spineAnime.AnimationName = CharAction.IDLE;
end

-- 移动
function Character:Move( timeScale )
    if self.spineAnime.AnimationName == CharAction.MOVE then
        return;
    end

    self.spineAnime.loop  = true;
    self.spineAnime.timeScale = timeScale;
    self.spineAnime.AnimationName = CharAction.MOVE;
end

-- 攻击动作1
function Character:Attack0( duration )
    timeScale = timeScale or 1;

    self.spineAnime.loop  = false;
    self.spineAnime.AnimationName = CharAction.ATTACK0;

    -- 在指定时间内执行完
    if duration ~= nil then
        self.spineAnime.timeScale = self.animeDuration[ CharAction.ATTACK0 ] / duration;
    else
        self.spineAnime.timeScale = 1;
    end
end

-- 攻击动作2
function Character:Attack1( duration )
    timeScale = timeScale or 1;

    self.spineAnime.loop  = false;
    self.spineAnime.AnimationName = CharAction.ATTACK1;
    
    -- 在指定时间内执行完
    if duration ~= nil then
        self.spineAnime.timeScale = self.animeDuration[ CharAction.ATTACK1 ] / duration;
    else
        self.spineAnime.timeScale = 1;
    end
end

-- 施法动作
function Character:Skill( duration )
    timeScale = timeScale or 1;

    self.spineAnime.loop  = false;
    self.spineAnime.AnimationName = CharAction.SKILL;
    
    -- 在指定时间内执行完
    if duration ~= nil then
        self.spineAnime.timeScale = self.animeDuration[ CharAction.SKILL ] / duration;
    else
        self.spineAnime.timeScale = 1;
    end
end

-- 死亡动作
function Character:Die()
    self.spineAnime.loop  = false;
    self.spineAnime.timeScale = 1;
    self.spineAnime.AnimationName = CharAction.DIE;
end

-- 被击动作
function Character:Hited()
    self.spineAnime.loop  = false;
    self.spineAnime.timeScale = 1;
    self.spineAnime.AnimationName = CharAction.Hited;
end

-- 胜利动作
function Character:Win()
    if self.spineAnime.AnimationName == CharAction.IDLE then
        return;
    end

    self.spineAnime.loop  = true;
    self.spineAnime.timeScale = 1;
    self.spineAnime.AnimationName = CharAction.IDLE;
end

-- 晕眩动作
function Character:Stun()
    if self.spineAnime.AnimationName == CharAction.Stun then
        return;
    end

    self.spineAnime.loop  = true;
    self.spineAnime.timeScale = 1;
    self.spineAnime.AnimationName = CharAction.Stun;
end

---------------------------------
-- 额外动作
---------------------------------
-- 更改朝向
function Character:Turn( isRight )
    self.spineAnime.skeleton.FlipX = not isRight;
end

-- 显示/隐藏
function Character:Show( isShow )
    self.gameObject:SetActive( isShow );
end

-- 动作暂定
function Character:Pause( isPause )
    self.spineAnime.timeScale = isPause and 0 or 1;
end

-- 入场动作
function Character:Enter()
    self:Idle();
    self.animator:SetTrigger( CharAction_Animator.ENTER );
end

-- 出场动作
function Character:Quit()
    self:Idle();
    self.animator:SetTrigger( CharAction_Animator.QUIT );

    -- 延时0.5秒隐藏
    Invoke( function() self:Show( false ); end, 0.5 );
end

-- 变红
function Character:Red()
    self.animator:SetTrigger( CharAction_Animator.RED );
end

-- 变黑
function Character:HalfBlack()
    self.animator:SetTrigger( CharAction_Animator.HALFBLACK );
end

-- 变黑恢复
function Character:HalfBlackRecover()
    self.animator:SetTrigger( CharAction_Animator.HALFBLACKRECOVER );
end