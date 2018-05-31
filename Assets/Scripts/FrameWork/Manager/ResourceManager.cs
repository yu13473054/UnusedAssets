using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;

// 添加引用计数的结构
public class AssetBundleInfo
{
    public AssetBundle assetBundle;
    public int referencedCount;
    public string[] dependencies;

    public AssetBundleInfo( AssetBundle assetBundle )
    {
        this.assetBundle = assetBundle;
        referencedCount = 1;
    }
}

// 数据管理器 
public class ResourceManager : MonoBehaviour
{
    public static ResourceManager instance;

    Dictionary<string, string[]> _resmap_sprite;    // 图片映射表
    Dictionary<string, string[]> _resmap_prefab;    // Prefab映射表
    Dictionary<string, string[]> _resmap_object;    // 其他资源映射表

    // Manifest文件缓存
    AssetBundleManifest _assetBundleManifest = null;
    // 已经加载的AssetBundle
    Dictionary<string, AssetBundleInfo> _loadedAssetBundles = new Dictionary<string, AssetBundleInfo>();

    #region 初始化/析构
    void Awake()
    {
        instance = this;
    }

    public void Init()
    {
        StartCoroutine( OnInit() );
    }
    public IEnumerator OnInit()
    {
        // 读取所有assetbundle名和依赖
        if( AppConst.resourceMode != 0 )
            yield return OnLoadAsset<AssetBundleManifest>(
                "assetbundle", "AssetBundleManifest", delegate( string name, AssetBundleManifest manifest ) { _assetBundleManifest = manifest; } );

        // sprite资源映射表
        _resmap_sprite = new Dictionary<string, string[]>();
        TableHandler spriteTable = new TableHandler();
        spriteTable.OpenFromData( "resmap_sprite.txt" );
        for( int row = 0; row < spriteTable.GetRecordsNum(); row++ )
        {
            string[] s = new string[2];
            s[0] = spriteTable.GetValue( row, 1 );
            s[1] = spriteTable.GetValue( row, 2 );
            _resmap_sprite.Add( spriteTable.GetValue( row, 0 ), s );
        }
        yield return 0;

        // prefab资源映射表
        _resmap_prefab = new Dictionary<string, string[]>();
        TableHandler prefabTable = new TableHandler();
        prefabTable.OpenFromData( "resmap_prefab.txt" );
        for( int row = 0; row < prefabTable.GetRecordsNum(); row++ )
        {
            string[] s = new string[2];
            s[0] = prefabTable.GetValue( row, 1 );
            s[1] = prefabTable.GetValue( row, 2 );
            _resmap_prefab.Add( prefabTable.GetValue( row, 0 ), s );
        }
        yield return 0;

        // object资源映射表
        _resmap_object = new Dictionary<string, string[]>();
        TableHandler objectTable = new TableHandler();
        objectTable.OpenFromData( "resmap_object.txt" );
        for( int row = 0; row < objectTable.GetRecordsNum(); row++ )
        {
            string[] s = new string[2];
            s[0] = objectTable.GetValue( row, 1 );
            s[1] = objectTable.GetValue( row, 2 );
            _resmap_object.Add( objectTable.GetValue( row, 0 ), s );
        }
        yield return 0;
    }

    void OnDestroy()
    {
        // 卸载所有加载了的AB
        foreach( var elm in _loadedAssetBundles )
        {
            elm.Value.assetBundle.Unload( true );
        }
    }
    #endregion


    #region 额外加载ab包，需要各自的系统单独管理添加和卸载的逻辑

    ///判断sprite所属ab包是不是uiPrefab的直接依赖包，依赖包由ResourceManager管理
    public bool IsDependBySprite(string uiName, string spriteName, out string spriteABName)
    {
        spriteABName = _resmap_sprite[spriteName][1].ToLower();
        return IsDependBySprite(uiName, spriteABName);
    }

    public bool IsDependBySprite(string uiName, string spriteABName)
    {
        string uiABName = _resmap_prefab[uiName][1].ToLower();
        if (_loadedAssetBundles.ContainsKey(uiABName))
        {
            string[] dependencies = _loadedAssetBundles[uiABName].dependencies;
            for (int i = 0; i < dependencies.Length; i++)
            {
                //sprite的ab包被UI的ab包直接依赖
                if (dependencies[i].Equals(spriteABName))
                {
                    return true;
                }
            }
        }
        return false;
    }

    #endregion

    //手动增加引用计数
    public void AddRefCount(string abName)
    {
        //第一次加载时，不需要增加引用计数
        if (_loadedAssetBundles.ContainsKey(abName))
        {
            AssetBundleInfo bundleInfo = _loadedAssetBundles[abName];
            bundleInfo.referencedCount++;
            for (int i = 0; i < bundleInfo.dependencies.Length; i++)
            {
                AddRefCount(bundleInfo.dependencies[i]);
            }
        }

    }

    public string[] GetDependencies(string abName)
    {
        if (_assetBundleManifest != null )
        {
            return _assetBundleManifest.GetAllDependencies(abName);
        }
        return null;
    }

    #region AB缓存操作

    // 尝试从缓存拿
    public AssetBundleInfo GetLoadedAssetBundle( string assetBundleName )
    {
        assetBundleName = assetBundleName.ToLower();

        // 已经缓存的
        AssetBundleInfo bundle = null;
        _loadedAssetBundles.TryGetValue( assetBundleName, out bundle );
        return bundle;
    }

    // 释放AssetBundle
    public void UnloadAssetBundle( string assetBundleName, bool force = false )
    {
        if( _assetBundleManifest == null && !force )
            return;

        assetBundleName = assetBundleName.ToLower();

        AssetBundleInfo bundle = null;
        if( !_loadedAssetBundles.TryGetValue( assetBundleName, out bundle ) )
            return;

        // 如果强行卸载将忽略依赖，并清除所有引用，慎用！
        if( force )
        {
            bundle.assetBundle.Unload( true );
            _loadedAssetBundles.Remove( assetBundleName );
            return;
        }

        if( --bundle.referencedCount <= 0 )
        {
            bundle.assetBundle.Unload( false );
            _loadedAssetBundles.Remove( assetBundleName );

            // 再卸载依赖
            string[] dependencies = bundle.dependencies;
            if(dependencies != null && dependencies.Length > 0 )
            {
                for( int i = 0; i < dependencies.Length; i++ )
                {
                    UnloadAssetBundle( dependencies[i] );
                }
            }
        }
    }
    #endregion

    #region 同步加载
    // 泛型读取
    public T LoadAsset<T>( string assetBundleName, string assetName ) where T : UnityEngine.Object
    {
        // 加载AssetBundle
        AssetBundle ab = LoadAssetBundle( assetBundleName );
        if( ab == null )
        {
            return default( T );
        }

        // 读取assetbundle里的这个文件
        T asset = ab.LoadAsset<T>( assetName );
        if( asset == null )
        {
            Debugger.LogError( "<ResourceManager> 找不到Asset :" + assetName );
            return default( T );
        }

        return asset;
    }

    // 载入AssetBundle
    public AssetBundle LoadAssetBundle( string assetBundleName )
    {
        // 非AB包模式，放弃读取
        if( AppConst.resourceMode == 0 )
            return null;

        // 强制小写
        assetBundleName = assetBundleName.ToLower();

        // 如果缓存里有先拿缓存
        AssetBundleInfo bundle;
        _loadedAssetBundles.TryGetValue(assetBundleName, out bundle);
        if ( bundle != null )
            return bundle.assetBundle;

        // 先加载依赖
        string[] dependencies=null;
        if( _assetBundleManifest != null )
        {
            dependencies = _assetBundleManifest.GetAllDependencies( assetBundleName );
            if( dependencies.Length > 0 )
            {
                for( int i = 0; i < dependencies.Length; i++ )
                {
                    string dependABName = dependencies[i];
                    //第一次添加的依赖不需要增加引用计数，默认就是1
                    if(_loadedAssetBundles.ContainsKey(dependABName))
                    {
                        _loadedAssetBundles[dependABName].referencedCount++;
                    }
                    else
                    {
                        LoadAssetBundle(dependABName);
                    }
                }
            }
        }

        // 优先查询下载资源，本地没有就找包里资源
        string file = AppConst.resourcesPath + assetBundleName;
        if( File.Exists( file ) == false )
        {
            file = AppConst.packageABPath + assetBundleName;
        }

        // 开始读取
        AssetBundle assetBundle = AssetBundle.LoadFromFile( file );
        if( assetBundle == null )
        {
            // 没读到
            Debugger.LogError( "<ResourceManager> 找不到Assetbundle :" + assetBundleName );
            return null;
        }

        // 添加到已加载列表
        Debugger.Log( "<ResourceManager> AssetBundle已读取: " + file );
        AssetBundleInfo bundleInfo = new AssetBundleInfo( assetBundle );
        bundleInfo.dependencies = dependencies;
        _loadedAssetBundles.Add( assetBundleName.ToLower(), bundleInfo );
        return assetBundle;
    }
    #endregion

    #region 同步加载源接口

    // 读取Sprite资源
    public Sprite LoadSprite( string reskeyname )
    {
        if( _resmap_sprite == null || _resmap_sprite.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个图片: " + reskeyname );
            return null;
        }

        // 0：从本地读，1：从AB读
        if (AppConst.resourceMode == 0)
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite>( _resmap_sprite[reskeyname][0] );
#else
            return null;
#endif
        else
            return LoadAsset<Sprite>( _resmap_sprite[reskeyname][1], reskeyname);
    }

    // 读取Prefab资源
    public GameObject LoadPrefab( string reskeyname )
    {
        if( _resmap_prefab == null || _resmap_prefab.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个预制: " + reskeyname );
            return null;
        }

        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>( _resmap_prefab[reskeyname][0] );
#else
            return null;
#endif
        else
            return LoadAsset<GameObject>( _resmap_prefab[reskeyname][1], reskeyname);
    }

    // 读取Object
    public UnityEngine.Object LoadObject( string reskeyname, Type type )
    {
        if( _resmap_object == null || _resmap_object.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个资源: " + reskeyname );
            return null;
        }

        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath(_resmap_object[reskeyname][0], type );
#else
            return null;
#endif
        else
            return LoadAsset<UnityEngine.Object>( _resmap_object[reskeyname][1], reskeyname);
    }

    // 读取Object，泛型
    public T LoadObject<T>( string reskeyname ) where T : UnityEngine.Object
    {
        if( _resmap_object == null || _resmap_object.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个资源: " + reskeyname );
            return default( T );
        }

        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<T>(_resmap_object[reskeyname][0] );
#else
            return null;
#endif
        else
            return LoadAsset<T>( _resmap_object[reskeyname][1], reskeyname);
    }

    /*************************************************************/
    // 再封装，方便Lua调用
    /*************************************************************/
    // 读取Material资源
    public Material LoadMaterial( string reskeyname )
    {
        return LoadObject<Material>( reskeyname );
    }

    // 直接从AB中读prefab
    public GameObject LoadPrefab( string prefabName, string abName, string editorPath = "" )
    {
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>( editorPath );
#else
            return null;
#endif
        else
            return LoadAsset<GameObject>( abName, prefabName );
    }

    // 直接从AB中读Object
    public UnityEngine.Object LoadObject( string objName, string abName, string editorPath = "" )
    {
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>( editorPath );
#else
            return null;
#endif
        else
            return LoadAsset<UnityEngine.Object>( abName, objName );
    }

    public T LoadAsset<T>(string assetName, string abName, string editorPath) where T : UnityEngine.Object
    {
        if (AppConst.resourceMode == 0)
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<T>(editorPath);
#else
            return null;
#endif
        else
            return LoadAsset<T>(abName, assetName);
    }

    // 直接从AB中读Sprite
    public Sprite LoadSprite( string spriteName, string abName, string editorPath = "" )
    {
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite>( editorPath );
#else
            return null;
#endif
        else
            return LoadAsset<Sprite>( abName, spriteName );
    }

    // 读取AudioClip资源
    public AudioClip LoadAudioClip( string clipName, string abName, string editorPath = "" )
    {
        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            return UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>( editorPath );
#else
            return null;
#endif
        else
            return LoadAsset<AudioClip>( abName, clipName );
    }
    #endregion

    #region 异步加载
    // 异步载入
    void LoadAssetAsyn<T>( string assetBundleName, string assetNames, Action<string, T> action ) where T : UnityEngine.Object
    {
        StartCoroutine( OnLoadAsset<T>( assetBundleName, assetNames, action ) );
    }

    // 异步载入协程
    IEnumerator OnLoadAsset<T>( string assetBundleName, string assetName, Action<string, T> action ) where T : UnityEngine.Object
    {
        // 先读AB
        AssetBundleInfo bundleInfo = GetLoadedAssetBundle( assetBundleName );
        if( bundleInfo == null )
        {
            yield return OnLoadAssetBundle( assetBundleName );
            bundleInfo = GetLoadedAssetBundle( assetBundleName );
            if( bundleInfo == null )
            {
                Debugger.LogError( "<ResourceManager> 找不到Assetbundle :" + assetBundleName );
                yield break;
            }
        }

        // 为啥没泛型类？？
        AssetBundleRequest request = bundleInfo.assetBundle.LoadAssetAsync<T>( assetName );
        yield return request;

        // 如果没找到
        if( request.asset == null )
        {
            Debugger.LogError( "<ResourceManager> 找不到Asset :" + assetName );
            yield break;
        }

        // 执行回调
        if( action != null )
            action( assetName, (T)request.asset );
    }

    // 异步读AB
    IEnumerator OnLoadAssetBundle( string assetBundleName )
    {
        // 强制小写
        assetBundleName = assetBundleName.ToLower();

        // 优先查询本地资源，本地没有就找包里资源
        string file = AppConst.resourcesPath + assetBundleName;
        if( File.Exists( file ) == false )
        {
            file = AppConst.packageABPath + assetBundleName;
        }

        // 异步读取依赖
        string[] dependencies = null;
        if( _assetBundleManifest != null )
        {
            dependencies = _assetBundleManifest.GetAllDependencies( assetBundleName );
            if( dependencies.Length > 0 )
            {
                for( int i = 0; i < dependencies.Length; i++ )
                {
                    string dependABName = dependencies[i];
                    //第一次添加的依赖不需要增加引用计数，默认就是1
                    if (_loadedAssetBundles.ContainsKey(dependABName))
                    {
                        _loadedAssetBundles[dependABName].referencedCount++;
                    }
                    else
                    {
                        yield return OnLoadAssetBundle( dependABName );
                    }
                }
            }
        }
        AssetBundleCreateRequest request = AssetBundle.LoadFromFileAsync(file);
        yield return request;

        // 没读到
        if( request.assetBundle == null )
        {
            Debugger.LogError( "<ResourceManager> 没有此AssetBundle path:[" + file + "]" );
            yield break;
        }

        // 添加到已加载列表
        AssetBundleInfo bundleInfo = new AssetBundleInfo( request.assetBundle );
        bundleInfo.dependencies = dependencies;
        _loadedAssetBundles.Add( assetBundleName.ToLower(), bundleInfo );
    }
    #endregion

    #region 异步加载资源接口
    // 异步读取Sprite
    public void LoadSpriteAsyn( string reskeyname, Action<string, Sprite> action )
    {
        if( _resmap_sprite == null || _resmap_sprite.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个图片: " + reskeyname );
            return;
        }


        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            action( reskeyname, UnityEditor.AssetDatabase.LoadAssetAtPath<Sprite>( _resmap_prefab[reskeyname][0] ) );
#else
            return;
#endif
        else
            LoadAssetAsyn<Sprite>( _resmap_prefab[reskeyname][1], _resmap_prefab[reskeyname][0], action );
    }

    // 异步读取Sprite
    public void LoadPrefabAsyn( string reskeyname, Action<string, GameObject> action )
    {
        if( _resmap_sprite == null || _resmap_prefab.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个预制: " + reskeyname );
            return;
        }


        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            action( reskeyname, UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>( _resmap_prefab[reskeyname][0] ) );
#else
            return;
#endif
        else
            LoadAssetAsyn<GameObject>( _resmap_prefab[reskeyname][1], _resmap_prefab[reskeyname][0], action );
    }

    // 异步读取Object
    public void LoadObjectAsyn( string reskeyname, Action<string, UnityEngine.Object> action )
    {
        if( _resmap_sprite == null || _resmap_object.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个资源: " + reskeyname );
            return;
        }


        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            action( reskeyname, UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Object>( _resmap_prefab[reskeyname][0] ) );
#else
            return;
#endif
        else
            LoadAssetAsyn<UnityEngine.Object>( _resmap_prefab[reskeyname][1], _resmap_prefab[reskeyname][0], action );
    }

    /*************************************************************************/
    // 实例化列表
    /*************************************************************************/
    public class InstantiateQueueData
    {
        public string name;
        public Transform parent;
        public InstantiateQueueData( string name, Transform parent )
        {
            this.name = name;
            this.parent = parent;
        }
    }

    Queue<InstantiateQueueData> _LoadQueue = new Queue<InstantiateQueueData>();

    // 同一帧插入，第一次输入回调有效
    public void InstantiateQueueAdd( string reskeyname, Transform parent, Action<Dictionary<string, GameObject>> onFinish )
    {
        if( _LoadQueue.Count == 0 )
            StartCoroutine( InstantiateQueue( onFinish ) );

        // 加入队列
        _LoadQueue.Enqueue( new InstantiateQueueData( reskeyname, parent ) );
    }

    // 异步实例化队列
    IEnumerator InstantiateQueue( Action<Dictionary<string, GameObject>> onFinish )
    {
        yield return 0;

        // 记录下加载的go
        GameObject loadedGo = null;
        Dictionary<string, GameObject> goList = new Dictionary<string, GameObject>();
        Action<string, GameObject> onLoaded = ( name, go ) =>
        {
            loadedGo = go;
            goList.Add( name, go );
        };

        // 异步读取资源，并实例化
        while( _LoadQueue.Count != 0 )
        {
            InstantiateQueueData queueData = _LoadQueue.Dequeue();
            yield return OnLoadPrefab( queueData.name, onLoaded );

            GameObject go = GameObject.Instantiate( loadedGo, queueData.parent );
            go.transform.localPosition = Vector3.zero;
            go.transform.localScale = Vector3.zero;
            go.transform.localRotation = Quaternion.identity;
            go.name = queueData.name;

            yield return 0;
        }

        // 执行回调返回列表
        if( onFinish != null )
            onFinish( goList );
    }

    // 异步查表读Asset
    IEnumerator OnLoadPrefab( string reskeyname, Action<string, GameObject> action )
    {
        if( _resmap_sprite == null || _resmap_prefab.ContainsKey( reskeyname ) == false )
        {
            Debugger.LogError( "<ResourceManager> 映射表中没有这个预制: " + reskeyname );
            yield break;
        }


        // 0：从本地读，1：从AB读
        if( AppConst.resourceMode == 0 )
#if UNITY_EDITOR
            action( reskeyname, UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>( _resmap_prefab[reskeyname][0] ) );
#else
            {}
#endif
        else
            yield return OnLoadAsset<GameObject>( _resmap_prefab[reskeyname][1], _resmap_prefab[reskeyname][0], action );
    }

    #endregion
}
