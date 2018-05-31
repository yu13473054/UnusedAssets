using System.Collections;
using System.Collections.Generic;
using Spine.Unity;
using UnityEditor;
using UnityEngine;

public class RoleGenerateManager : MonoBehaviour
{
    public static RoleGenerateManager instance;

//    public string skeletonDataAssetName = "SkelBone";

    void Awake()
    {
        instance = this;
//        DontDestroyOnLoad(gameObject);

//        LoadSkeleton(skeletonDataAssetName);
    }

    private void LoadSkeleton(string skelResName)
    {
        //实例化animation对象
//        SkeletonAnimation skelAnim = LoadRootSkeletonData(skelResName);
//        
//        //生成骨架GameObject
//        SkeletonUtility skeletonUtility = skelAnim.GetComponent<SkeletonUtility>();
//        if (!skeletonUtility) skeletonUtility = skelAnim.gameObject.AddComponent<SkeletonUtility>();
//        skeletonUtility.SpawnHierarchy(SkeletonUtilityBone.Mode.Follow, true, true, true);
//
//        //添加角色生成器
//        RoleGenerator roleGene = skelAnim.GetComponent<RoleGenerator>();
//        if (!roleGene) skelAnim.gameObject.AddComponent<RoleGenerator>();
    }

    public SkeletonDataAsset LoadRootSkeletonData(string skelResName)
    {
        string path = "Assets/Res/Char_Equipment/RootSpine/"+ skelResName + "/" + skelResName + "_SkeletonData.asset";
        SkeletonDataAsset asset = LoadAsset<SkeletonDataAsset>(skelResName, "char_equipment_root_" + skelResName, path);
        return asset;
    }

    public SkeletonDataAsset LoadPartSkeletonData(string skelResName)
    {
        string path = "Assets/Res/Char_Equipment/PartSpine/"+ skelResName + "/" + skelResName + "_SkeletonData.asset";
        SkeletonDataAsset asset = LoadAsset<SkeletonDataAsset>(skelResName, "char_equipment_part_" + skelResName, path);
        return asset;
    }

    public AtlasAsset LoadPartAtlas(string atlasResName)
    {
        string path = "Assets/Res/Char_Equipment/Atlas/"+ atlasResName + "/" + atlasResName + "_Atlas.asset";
        AtlasAsset asset = LoadAsset<AtlasAsset>(atlasResName, "char_equipment_atlas_" + atlasResName, path);
        return asset;
    }

    public Sprite LoadTexture(string texName)
    {
        string path = "Assets/Res/Char_Equipment/Sprite/" + texName + ".png";
        Sprite asset = LoadAsset<Sprite>(texName, "char_equipment_sp_" + texName, path);
        return asset;
    }

    public T LoadAsset<T>(string assetName, string abName, string editorPath) where T : UnityEngine.Object
    {
        if(ResourceManager.instance)
            return ResourceManager.instance.LoadAsset<T>(assetName, abName, editorPath);
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<T>(editorPath);
#endif
        return null;
    }

    #region 资源的管理
//    //key:abNam ---- value:uiSystemName的list
//    Dictionary<string, List<string>> _extraABUserDic = new Dictionary<string, List<string>>();
//
//    public Sprite GetSprite(string uiName, string spriteName)
//    {
//        string abName = "";
//        //获取ab的名称，保存这个ab包被哪些UI系统所用
//        if (AppConst.resourceMode != 0 && !ResourceManager.instance.IsDependBySprite(uiName, spriteName, out abName))
//            ABRef(uiName, abName);
//        return ResourceManager.instance.LoadSprite(spriteName);
//    }
//    public Sprite GetSprite(UISystem uiSystem, string spriteName)
//    {
//        return GetSprite(uiSystem.name, spriteName);
//    }
//    // 直接从AB中拿图片
//    public Sprite GetSprite(string uiName, string spriteName, string abName, string editorPath = "")
//    {
//        //获取ab的名称，保存这个ab包被哪些UI系统所用
//        abName = abName.ToLower();
//        if (AppConst.resourceMode != 0 && !ResourceManager.instance.IsDependBySprite(uiName, abName))
//        {
//            ABRef(uiName, abName);
//        }
//        return ResourceManager.instance.LoadSprite(spriteName, abName, editorPath);
//    }
//    private void ABRef(string uiName, string abName)
//    {
//        List<string> userList;
//        if (!_extraABUserDic.TryGetValue(abName, out userList))
//        {
//            userList = new List<string>();
//            _extraABUserDic[abName] = userList;
//        }
//        if (!userList.Contains(uiName))
//        {
//            userList.Add(uiName);
//            ResourceManager.instance.AddRefCount(abName);
//        }
//    }
//
//    /// <summary>
//    /// 在UI界面被Destroy的时候，需要同时卸载依赖的ab包及其动态加载进来的ab包
//    /// </summary>
//    /// <param name="uiSystemName"></param>
//    private void OnUIDestroy(string uiSystemName)
//    {
//        //卸载UI prefab
//        ResourceManager.instance.UnloadAssetBundle(uiSystemName);
//        //卸载额外加载进来的ab资源
//        foreach (var pair in _extraABUserDic)
//        {
//            List<string> userList = pair.Value;
//            userList.Remove(uiSystemName);//删除ab包的使用者信息
//            //卸载该ab包或者减少引用计数
//            ResourceManager.instance.UnloadAssetBundle(pair.Key);
//        }
//
//    }
    #endregion
}
