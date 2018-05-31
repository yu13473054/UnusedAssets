using UnityEngine;
using System;
using System.Collections;

// 处理游戏启动到进入游戏的流程，注意*部分初始化/加载顺序不可变。
public class Boot : MonoBehaviour
{
    private AssetsUpdate _assetsUpdate;

    // 游戏启动
    void Start()
    {
        Application.runInBackground = true;
        StartCoroutine( Bootstrap() );
    }

    // 引导整个启动流程
    IEnumerator Bootstrap()
    {
        // 初始化流程
        yield return Step_Init();

        // 更新流程，仅限ab资源模式
        if( AppConst.resourceMode != 0 )
            yield return Step_Update();

        // 加载流程
        yield return Step_Load();
    }

    // 初始化流程
    IEnumerator Step_Init()
    {
        // 创建日志
        Debugger.Create( AppConst.logPath );
        Debugger.Log( "---------------- 游戏开始! ---------------" );
        Debugger.Log( "<Boot> 初始化开始!" );
        yield return null;

        // 初始化基础配置，在初始化资源管理器之前
        AppConst.Init();

        // 资源管理器，第一步加载
        Utils.Add<ResourceManager>( gameObject );
        yield return null;

        // UI管理器
        Utils.Add<UIManager>( gameObject );
        yield return null;

        // 加载更新界面
        GameObject go = ResourceManager.instance.LoadPrefab( "AssetsUpdate", "assetsupdate", "Assets/Res/AssetsUpdate/AssetsUpdate.prefab" );
        _assetsUpdate = Instantiate( go ).GetComponent<AssetsUpdate>();
        _assetsUpdate.transform.SetParent( UIManager.instance.GetLayer( 0 ), false );
        _assetsUpdate.transform.localScale = Vector3.one;
        _assetsUpdate.transform.localPosition = Vector3.zero;

        // 文字表初始化
        Localization.Init();
        yield return null;

        // 添加Lua管理器
        Utils.Add<LuaManager>( gameObject );
        yield return null;

        // 添加网络管理器
        Utils.Add<NetworkManager>( gameObject );
        yield return null;

        // 添加音频管理器
        AudioManager.Init();
        yield return null;

        // 添加更新
        Utils.Add<UpdateManager>( gameObject );
        yield return null;

        // 下载线程管理器
        Utils.Add<ThreadManager>( gameObject );
        yield return 0;

        Debugger.Log( "<Boot> 初始化结束!" );
    }

    // 更新流程
    IEnumerator Step_Update()
    {
        Debugger.Log( "<Boot> 资源更新开始!" );

        // 开始更新
        UpdateManager.instance.updateCallBack = UpdateUI;
        UpdateManager.instance.BeginUpdate();
        // 更新完成前挂起
        while( !UpdateManager.instance.isFinish )
        {
            yield return 0;
        }
        Debugger.Log( "<Boot> 资源更新结束!" );
    }

    // 加载流程
    IEnumerator Step_Load()
    {
        Debugger.Log( "<Boot> 资源加载开始!" );

        // 最先初始化 异步初始化ResourceManager
        yield return ResourceManager.instance.OnInit();

        // 文字表重读
        Localization.Init();
        yield return null;

        // 音效数据
        yield return AudioManager.instance.OnInit();

        // 隐藏资源更新的进度条和文字
        _assetsUpdate.UpdateDone();

        // Lua初始化
        LuaManager.instance.Init();
        yield return null;

        // 网络初始化（必须在Lua后）
        NetworkManager.instance.Init();
        yield return null;

        Debugger.Log( "<Boot> 资源加载结束!" );

        // Lua启动
        LuaManager.instance.Call("LuaStart");
    }

    void UpdateUI(string hintText, float perc)
    {
        _assetsUpdate.UpdateProgress(hintText,perc);
    }

    // 游戏结束
    void OnDestroy() 
    {
        Debugger.Log( "---------------- 游戏结束! ---------------" );
    }
}
