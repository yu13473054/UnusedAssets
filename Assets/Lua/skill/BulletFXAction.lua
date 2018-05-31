---------------------------------
-- 子弹特效表现，弹道逻辑
---------------------------------
local function BulletFX_HitOnly( bulletFX, updateTime )
    bulletFX:Hit();
end

local function BulletFX_Straight( bulletFX, updateTime )
    -- 移动距离超过距离，算作命中
    if bulletFX.timer >= bulletFX.life then
        bulletFX:Hit();
        return;
    end
    
    -- 位置差值
    if bulletFX.transform ~= nil then        
        FightUtils.FXSetViewPos( bulletFX.transform, Vector3.Lerp( bulletFX.fromViewPos, bulletFX.targetViewPos, bulletFX.timer / bulletFX.life ) );
    end

    -- 计时
    bulletFX.timer = bulletFX.timer + updateTime;
end

BulletFXAction = 
{
    [0] = BulletFX_HitOnly,             -- 瞬间产生命中效果
    [1] = BulletFX_HitOnly,             -- 瞬间产生命中效果
    [2] = BulletFX_Straight,            -- 直线子弹，带弹道修正
}