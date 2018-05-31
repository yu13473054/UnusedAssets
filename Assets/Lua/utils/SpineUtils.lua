-- Spine工具类负责读取处理Spine动画
SpineUtils = {};

-- 创建一个Spine动画GameObject
function SpineUtils.CreateCharacter( name )
    -- 加载数据
    local dataAsset = SpineUtils.LoadData( name, "Char" );

    -- 创建GO，挂载动画
    local spineObj = LoadPrefab( "Char" );
    local spine = spineObj:GetComponent( typeof( SkeletonAnimation ) );
    spine.skeletonDataAsset = dataAsset;
    spine:Initialize( true );
    
    spine.initialSkinName = dataAsset:GetSkeletonData( true ).Skins.Items[0].Name;
    spine.AnimationName = dataAsset:GetSkeletonData( true ).Animations.Items[0].Name;
    return spineObj;
end

function SpineUtils.Create( name )
    -- 加载数据
    local dataAsset = SpineUtils.LoadData( name, "Spine" );

    -- 创建GO，挂载动画
    local spineObj = GameObject(name);
    spineObj.transform.localScale = Vector3.New(100,100,100);
    spineObj.layer = 5;
    local spine = spineObj:AddComponent( typeof( SkeletonAnimation ) );
    spine.skeletonDataAsset = dataAsset;
    spine.loop = true;
    spine:Initialize( true );
    
    spine.initialSkinName = dataAsset:GetSkeletonData( true ).Skins.Items[0].Name;
    spine.AnimationName = dataAsset:GetSkeletonData( true ).Animations.Items[0].Name;
    return spineObj;
end

function SpineUtils.LoadData( name, typeName )
    -- 读配置文件
    local dataAsset;
    if AppConst.resourceMode == 0 then
        dataAsset = ResourceManager.instance:LoadObject( name .. "_SkeletonData", string.lower( typeName ) .. "_" .. name,
            "Assets/Res/" .. typeName .. "/" .. name .. "/" .. name .. "_SkeletonData.asset" );
    else
        dataAsset = ResourceManager.instance:LoadObject( name .. "_SkeletonData", string.lower( typeName ) .. "_" .. name );
    end

    if dataAsset == nil then
        LogErr( "<Character> 无法读取Spine资源：" .. name );
        return nil;
    end
    return dataAsset
end