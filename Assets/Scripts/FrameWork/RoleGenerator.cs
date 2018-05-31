using System.Collections;
using System.Collections.Generic;
using Spine;
using Spine.Unity;
using Spine.Unity.Modules.AttachmentTools;
using UnityEngine;

public class PartData
{
    public string partResName;
    public string slotName = "";//部位spine中需要替换资源的slot名称
    public string atlasName = ""; //替换的资源图集
    public string regionName = ""; //使用图集中的哪部分资源
}

public class RoleGenerator : MonoBehaviour
{
    //测试数据
    private readonly string[] boneNames = { "right-wing", "left-wing" };
    private Dictionary<string, int> roleBoneData = new Dictionary<string, int>();
    private Dictionary<int, PartData> partDataDic = new Dictionary<int, PartData>();

    //头部
    private int _headID;//头部spine使用的贴图资源id，通过资源id，可以确定头部spine的资源
    private int _hairDecorationID;//发饰
    private int _faceID;//spine使用的贴图资源id，通过资源id，可以确定对应spine的资源
    private int _earID;//spine使用的贴图资源id，通过资源id，可以确定对应spine的资源
    //上装      
    private int _clothID;//spine使用的贴图资源id，通过资源id，可以确定对应spine的资源
    private int _weaponID; //武器的贴图资源
    private int _bagID;//spine使用的贴图资源id，通过资源id，可以确定对应spine的资源
    //下装      
    private int _pantsID;//spine使用的贴图资源id，通过资源id，可以确定对应spine的资源
    private int _stockingsID;//下装丝袜使用的贴图资源id
    private int _shoesID;//下装鞋子使用的贴图资源id
    private int _tailID;//spine使用的贴图资源id，通过资源id，可以确定对应spine的资源

    private SkeletonAnimation _rootSkelAnim;
    private List<SkeletonAnimation> _skelList;

//    private string currAnimName;
//    private bool isInit;

    void Awake()
    {
        _skelList = new List<SkeletonAnimation>();

        for (int i = 0; i < boneNames.Length; i++)
        {
            roleBoneData[boneNames[i]] = i + 1;
        }

        PartData data = new PartData()
        {
            partResName = "RegionWing",
            atlasName = "dragon-pma",
            regionName = "left-wing03",
            slotName = "right-wing"
        };
        partDataDic[1] = data;

        data = new PartData()
        {
            partResName = "MeshWing",
            atlasName = "dragon-pma",
            regionName = "left-wing03",
            slotName = "left-wing"
        };
        partDataDic[2] = data;
    }

    public void InitPartResID(int headID, int hairDecorationID, int faceID, int earID, int clothID, int weaponID, int bagID, int pantsID, int stockingsID, int shoesID, int tailID)
    {
        _headID = headID;
        _hairDecorationID = hairDecorationID;
        _faceID = faceID;
        _earID = earID;
        _clothID = clothID;
        _weaponID = weaponID;
        _bagID = bagID;
        _pantsID = pantsID;
        _stockingsID = stockingsID;
        _shoesID = shoesID;
        _tailID = tailID;
    }

    // Use this for initialization
    void Start()
    {
//        InitPartResID(1001,1002,0,0,0,0,0,0,0,0,0);

        Generate();
    }

    public void Generate()
    {
//        _rootSkelAnim = GetComponent<SkeletonAnimation>();
//        _skelList.Add(_rootSkelAnim);

        //------头部
        Transform headTans = transform.Find("head");
        //头部Spine ID
        string spineRes = string.Format("Head_{0:D3}", (_headID-1000));
        SkeletonAnimation anim = InitSkelAnim(spineRes, headTans);
        _skelList.Add(anim);
        //设置头部spine中slot的内容
        string atlasName = "Head_Atlas_"+_headID;
        SetAttachment(anim, atlasName, "houfa", "houfa");
        SetAttachment(anim, atlasName, "toufa", "toufa");
        SetAttachment(anim, atlasName, "tou", "head");
        SetAttachment(anim, atlasName, "youmawei", "youmawei");
        SetAttachment(anim, atlasName, "zuomawei", "zuomawei");
        //发饰
        SetAttachment(anim,"","HairDecoration_"+_hairDecorationID, "toushi");

        //------上装
        //        Transform upperWearTans = transform.Find("upperWear");
        //        //上装Spine ID
        //        spineRes = string.Format("Cloth_{0:D3}", (_headID - 2000));
        //        anim = InitSkelAnim(spineRes, upperWearTans);
        //        _skelList.Add(anim);
        //        //设置slot的内容
        //        atlasName = "Cloth_Atlas_" + _clothID;
        //        SetAttachment(anim, atlasName, "cloth", "cloth");
        //        SetAttachment(anim, atlasName, "leftArm", "leftArm");
        //        SetAttachment(anim, atlasName, "rightArm", "rightArm");
        //        //设置武器
        //        SetAttachment(anim, "", "Weapon_Sp_"+_weaponID, "weapon");

    }

    private SkeletonAnimation InitSkelAnim(string resName, Transform parent)
    {
        SkeletonDataAsset asset = RoleGenerateManager.instance.LoadPartSkeletonData(resName);
        SkeletonAnimation anim = SkeletonAnimation.NewSkeletonAnimationGameObject(asset);
        anim.gameObject.name = resName;
        anim.transform.SetParent(parent, false);
        return anim;
    }

//    private void SetAtttachment(SkeletonAnimation skeletonrenderer, string resName, string slotStrm)

    public void SetAttachment(SkeletonAnimation skeletonrenderer, string atlasName, string regionStr, string slotStr, string attachName = "")
    {
        //        float scale = skeletonrenderer.skeletonDataAsset.scale;

        Slot slot = skeletonrenderer.skeleton.FindSlot(slotStr);
        if (slot == null) return;//没有slot，可能表示没有该细节

        if (atlasName.Equals(""))//直接加载texture
        {
            Sprite tex = RoleGenerateManager.instance.LoadTexture(regionStr);
            if (tex == null)
            {
                Debug.LogErrorFormat("<RoleGenerator> 找不到贴图{0}", regionStr);
                return;
            }
            Attachment originalAttachment = slot.Attachment;
            if (originalAttachment != null)
            {
                slot.Attachment = originalAttachment.GetRemappedClone(tex,skeletonrenderer.SkeletonDataAsset.atlasAssets[0].materials[0]);
            }
            else
            {
                slot.Attachment = tex.ToRegionAttachment(skeletonrenderer.SkeletonDataAsset.atlasAssets[0].materials[0]);
            }
        }
        else
        {
            AtlasRegion atlasRegion = null;
            Atlas atlas = RoleGenerateManager.instance.LoadPartAtlas(atlasName).GetAtlas();
            atlasRegion = atlas.FindRegion(regionStr);
            if (atlasRegion == null)
            {
                Debug.LogErrorFormat("<RoleGenerator> 图集：{0}中没有切片{1}",atlasName, regionStr);
                return;
            }

            Attachment originalAttachment = slot.Attachment;
            if (originalAttachment != null)
            {
                slot.Attachment = originalAttachment.GetRemappedClone(atlasRegion);
            }
            else
            {
                slot.Attachment = atlasRegion.ToRegionAttachment(atlasRegion.name);
            }
        }

//        if (slot!=null)
//        {

            //        customSkin = customSkin ?? new Skin("custom skin"); // This requires that all customizations are done with skin placeholders defined in Spine.
            //        int slotIndex = skeletonrenderer.skeleton.FindSlotIndex(slotStr); // You can access GetAttachment and SetAttachment via string, but caching the slotIndex is faster.
            //        Skin templateSkin = skeletonrenderer.skeleton.Data.DefaultSkin;
            //        Attachment templateAttachment = templateSkin.GetAttachment(slotIndex, attachName);
            //        Attachment newAttachment = templateAttachment.GetRemappedClone(sprite, sourceMaterial);
            //        customSkin.SetAttachment(slotIndex, attachName, newAttachment);
            
//        }
    }

    private bool IsBoneMatch(string boneName)
    {
        for (int i = 0; i < this.boneNames.Length; i++)
        {
            if (boneName.Equals(boneNames[i]))
            {
                return true;
            }
        }
        return false;
    }

    #region 播放动画
    public void SetAnimation(string animName, bool loop = true, int trackIndex = 0)
    {
        StopAllCoroutines();
        StartCoroutine(SetAnimCo(animName,loop, trackIndex));
    }

    private IEnumerator SetAnimCo(string animName, bool loop, int trackIndex)
    {
        yield return null;
        for (int i = 0; i < _skelList.Count; i++)
        {
            _skelList[i].state.SetAnimation(trackIndex, animName, loop);
        }
    }

    public void AddAnimation(string animName, bool loop = true, int trackIndex = 0, float mixTime = 0.2f)
    {
        StartCoroutine(AddAnimCo(animName, loop, trackIndex, mixTime));
    }

    private IEnumerator AddAnimCo(string animName, bool loop, int trackIndex, float mixTime)
    {
        yield return null;
        for (int i = 0; i < _skelList.Count; i++)
        {
            _skelList[i].state.AddAnimation(trackIndex, animName, loop, mixTime);
        }
    }

    #endregion

    void OnDestroy()
    {
        for (int i = 0; i < _skelList.Count; i++)
        {
            DestroyImmediate(_skelList[i].gameObject);
        }
    }
}
