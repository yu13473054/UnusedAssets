using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine.UI;



public class UIManager : MonoBehaviour
{
    public static UIManager instance;

    public const int UI_MAXCOUNT = 16;

    Transform _UIRoot;
    Camera _UICamera;
    //层
    private Dictionary<int, Transform> _layers;
    // 名字查找
    Dictionary<string, UISystem> _UIListByName;
    // 顺序查找
    List<UISystem> _UIList;
    // childUI栈
    Stack<string> _fullUIStack;


    void Awake()
    {
        instance = this;
        //        DontDestroyOnLoad(gameObject);

        //初始化
        _layers = new Dictionary<int, Transform>();
        _UIList = new List<UISystem>();
        _UIListByName = new Dictionary<string, UISystem>();
        _fullUIStack = new Stack<string>();

        GameObject uiRoot = GameObject.Find("UIRoot");
        if (uiRoot == null)
        {
            Debug.LogError("<UIManager> Can't Find UIRoot!");
            return;
        }
        _UIRoot = uiRoot.transform;

        Transform uicamera = _UIRoot.Find("UICamera");
        if (uicamera == null)
        {
            Debug.LogError("<UIManager> Can't Find UICamera!");
            return;
        }
        _UICamera = uicamera.GetComponent<Camera>();

        string[] layerName = Enum.GetNames( typeof( UILayer ) );
        for( int i = 0; i < layerName.Length; i++ )
        {
            string goName = "Layer_" + i + "_" + layerName[i];
            Transform layer = _UIRoot.Find( goName );
            if( layer == null )
            {
                Debug.LogError( "<UIManager> Can't Find Layer:" + goName );
                return;
            }
            _layers[(int)Enum.Parse( typeof( UILayer ), layerName[i] )] = layer;
        }
        
    }

    /// <summary>
    /// 界面显示
    /// </summary>
    /// <param name="uiName">待显示的界面的名称：需要保证传入的uiName的一致性</param> 
    /// <returns></returns>
    public UISystem Open(string uiName)
    {
        UISystem uiSystem = null;
        if (_UIListByName.TryGetValue(uiName, out uiSystem))
        {
            CloseLastOnOpen(uiSystem);
            OpenEnd(uiSystem);
            return uiSystem;
        }

        //加载新的UI
        uiSystem = LoadUISystem(uiName);
        DestroyOldUI();// 超过最大数量，析构最老的那个

        CloseLastOnOpen(uiSystem);
        OpenEnd(uiSystem);

        //管理UI
        _UIList.Add(uiSystem);
        _UIListByName.Add(uiName, uiSystem);

        return uiSystem;
    }

    /// 打开新的UI时，关闭之前的UI：目前只是针对主界面
    private void CloseLastOnOpen(UISystem uiSystem)
    {
        if (uiSystem.layer == UILayer.FULL)
        {
            UISystem lastUISystem = FindCurrFullUI();
            if (lastUISystem == uiSystem) return;//防止反复重复打开同一个主界面
            if (lastUISystem == null) return;
            if (lastUISystem.uiState != UIState.DESTROYONCLOSE)
            {
                //把上一个主界面压栈
                _fullUIStack.Push(lastUISystem.name);
            }
            CloseEnd(lastUISystem);
        }
    }

    //负责显示UI
    void OpenEnd(UISystem uiSystem)
    {
        ResetToFront(uiSystem);
        uiSystem.gameObject.SetActive(true);
    }

    /// <summary>
    /// 删除最旧的一个不显示的UI
    /// </summary>
    private void DestroyOldUI()
    {
        if (_UIList.Count >= UI_MAXCOUNT)
        {
            for (int i = 0; i < _UIList.Count; i++)
            {
                // 子界面堆栈中的界面不删除
                UISystem uiSystem = _UIList[i];
                if (uiSystem.uiState == UIState.NORMAL && !uiSystem.gameObject.activeSelf && !_fullUIStack.Contains(uiSystem.name))
                {
                    UnloadUI(uiSystem);
                    break;
                }
            }
        }
    }

    /// <summary>
    /// 从UI的管理列表中删除对应的UI
    /// </summary>
    private void UnloadUI(UISystem uiSystem)
    {
        if (uiSystem == null) return;
        Destroy(uiSystem.gameObject);
        _UIList.Remove(uiSystem);
        _UIListByName.Remove(uiSystem.uiName);
        //判断是否需要卸载对应的ab包
        OnUIDestroy(uiSystem.uiName);
    }

    // 移至队列最后
    void ResetToFront(UISystem uiSystem)
    {
        //不在管理队列中，属于新添加的UI
        if (!_UIList.Contains(uiSystem)) return;
        //已经是最后一个了
        if (_UIList[_UIList.Count - 1] == uiSystem)  return;
        //移至队尾
        _UIList.Remove(uiSystem);
        _UIList.Add(uiSystem);
        // 设到最前
        uiSystem.transform.SetAsLastSibling();
    }

    void Update()
    {
#if UNITY_EDITOR || UNITY_ANDROID
        if (Input.GetKeyUp(KeyCode.Escape))
        {
            UISystem uiSystem = null;
            for (int i = _UIList.Count - 1; i >= 0; i--)
            {
                //list中最后的一个可见的全屏界面就是当前显示的全屏界面
                UISystem tmp = _UIList[i];
                if ((tmp.layer == UILayer.FULL || tmp.layer == UILayer.POP) && tmp.gameObject.activeSelf)
                {
                    uiSystem = tmp;
                    break;
                }
            }
            if (uiSystem != null)
            {
               Close(uiSystem);
            }
            else
            {
                ExitGame();
            }
        }
#endif
    }

    /// <summary>
    /// 重新设置全屏界面堆栈，此方式中，栈底必须是不能再关闭的全屏界面
    /// </summary>
    /// <param name="uiNames"></param>
    public void SetFullStack(params string[] uiNames)
    {
        _fullUIStack.Clear();
        Add2FullStack(uiNames);
    }

    public void Add2FullStack(params string[] uiNames)
    {
        for (int i = 0; i < uiNames.Length; i++)
        {
            _fullUIStack.Push(uiNames[i]);
        }
    }

    // 界面关闭时调用
    public void Close(string uiName)
    {
        UISystem uiSystem = null;
        if (_UIListByName.TryGetValue(uiName, out uiSystem))
        {
            Close(uiSystem);
        }
    }
    public void Close(UISystem uiSystem)
    {
        if (uiSystem == null) return;
        OpenLastOnClose(uiSystem);
        CloseEnd(uiSystem);
    }

    //关闭当前界面，打开上一个界面：当前只是针对主界面
    private void OpenLastOnClose(UISystem uiSystem)
    {
        if (uiSystem.layer == UILayer.FULL)
        {
            //自动打开上一个全屏界面
            string uiName = null;
            while (string.IsNullOrEmpty(uiName) && _fullUIStack.Count > 0)
            {
                uiName = _fullUIStack.Pop();
            }
            if (string.IsNullOrEmpty(uiName))
            {
                //已经没有上一级全屏界面了，需要关闭游戏了
                ExitGame();
                return;
            }
            UISystem openUI = null;
            if (!_UIListByName.TryGetValue(uiName, out openUI))
            {
                openUI = LoadUISystem(uiName);
            }
            if (openUI.layer != UILayer.FULL)
            {
                Debug.LogError("<UIManager> 不是全屏界面：" + uiName);
            }
            DestroyOldUI(); // 超过最大数量，析构最老的那个

            if (!_UIListByName.ContainsKey(uiName))
            {
                //管理UI
                _UIList.Add(uiSystem);
                _UIListByName.Add(uiName, uiSystem);
            }
            OpenEnd(openUI);
        }
    }

    void CloseEnd(UISystem uiSystem)
    {
        uiSystem.gameObject.SetActive(false);

        if (uiSystem.uiState == UIState.DESTROYONCLOSE)
        {
            UnloadUI(uiSystem);
        }
    }

    void ExitGame()
    {
        Debug.Log("所有界面都被关闭了！");
    }

    UISystem LoadUISystem(string uiName)
    {
        GameObject obj = ResourceManager.instance.LoadPrefab(uiName);
        if (obj == null)
        {
            Debug.LogError("<UIManager> Can't Find UI:" + uiName);
            return null;
        }
        GameObject go = Instantiate(obj);
        UISystem uiSystem = go.GetComponent<UISystem>();
        if (uiSystem == null)
        {
            Destroy(go);
            Debug.LogError("<UIManager> " + uiName + "is not a UI!");
            return null;
        }
        if (!uiName.Equals(uiSystem.uiName))
        {
            Destroy(go);
            Debug.LogErrorFormat("<UIManager> UI名称不一致，需要打开的是{0}，实际得到的是：{1}", uiSystem.uiName, uiName);
            return null;
        }
        go.name = uiName;
        go.transform.SetParent(_layers[(int)uiSystem.layer],false);
        go.transform.localScale = Vector3.one;
        go.transform.localPosition=Vector3.zero;
        return uiSystem;
    }

    /// 实例化一个GameObject
    public Transform InstantiateGo(GameObject go, Transform parent = null)
    {
        if (go == null) return null;
        GameObject inst = Instantiate(go);
        inst.SetActive(true);
        if (parent != null)
        {
            inst.transform.SetParent(parent, false);
            inst.transform.localScale = Vector3.one;
            inst.transform.localPosition = Vector3.zero;
        }
        return inst.transform;
    }


    //获取此时的显示full界面
    UISystem FindCurrFullUI()
    {
        for (int i = _UIList.Count-1; i >=0; i--)
        {
            //list中最后的一个可见的全屏界面就是当前显示的全屏界面
            UISystem uiSystem = _UIList[i];
            if (uiSystem.layer == UILayer.FULL && uiSystem.gameObject.activeSelf)
            {
                return uiSystem;
            }
        }
        return null;
    }

    // 关闭所有界面
    public void CloseAll(params UILayer[] layers)
    {
        for (int i = _UIList.Count - 1; i >= 0; i--)
        {
            UISystem uiSystem = _UIList[i];
            if (uiSystem.gameObject.activeSelf)
            {
                if (layers == null || layers.Length==0)//关闭所有界面
                {
                    CloseEnd(uiSystem);
                }
                else
                {
                    for (int j = 0; j < layers.Length; j++)
                    {
                        if (uiSystem.layer == layers[j])
                        {
                            CloseEnd(uiSystem);
                            break;
                        }
                    }
                }
            }
        }
    }

    // 关闭所有带词缀的界面
    public void CloseAll(string prefix)
    {
        for (int i = _UIList.Count - 1; i >= 0; i--)
        {
            if (_UIList[i].gameObject.activeSelf && _UIList[i].gameObject.name.Contains(prefix))
            {
                Close(_UIList[i]);
            }
        }
    }

    /// <summary>
    /// 将场景中的世界坐标转换成UI坐标
    /// </summary>
    /// <param name="worldPos"></param> 世界坐标
    /// <param name="worldCam"></param> 当前世界坐标对应的相机
    /// <returns></returns>
    public Vector3 World2ScreenPos(Vector3 worldPos, Camera worldCam)
    {
        Vector3 screenPos = worldCam.WorldToScreenPoint(worldPos);
        Vector3 uiPos = _UICamera.ScreenToWorldPoint(screenPos);
        return uiPos;
    }


    // 除Layer0界面打开的个数
    public int OpenCount()
    {
        int count = 0;
        for (int i = _UIList.Count - 1; i >= 0; i--)
        {
            if (_UIList[i].gameObject.activeSelf && _UIList[i].layer == UILayer.POP)
            {
                count++;
            }
        }

        return count;
    }

    // UI 根节点
    public Transform GetUIRoot()
    {
        return _UIRoot;
    }

    // UI摄影机
    public Camera GetUICamera()
    {
        return _UICamera;
    }

    // 获得画布
    public Canvas GetCanvas()
    {
        return _UIRoot.GetComponent<Canvas>();
    }

    // 获得对应层
    public Transform GetLayer(int layerValue)
    {
        return GetLayer((UILayer) layerValue);
    }

    public Transform GetLayer(UILayer layer)
    {
        int key = (int)layer;
        if( !_layers.ContainsKey( key ) )
        {
            return null;
        }
        return _layers[key];
    }

    // 清空UI
    public void UnloadAllUI()
    {
        foreach (var pair in _UIListByName)
        {
            UISystem uiSystem = pair.Value;
            if (uiSystem != null)
            {
                Destroy(uiSystem.gameObject);
                OnUIDestroy(uiSystem.uiName);
            }
        }

        _UIList.Clear();
        _UIListByName.Clear();
        _fullUIStack.Clear();
        _extraABUserDic.Clear();
    }

    void OnDestroy()
    {
        UnloadAllUI();
        instance = null;
        Debug.Log("<UIManager> OnDestroy!");
    }

    #region UI资源的管理
    //key:abNam ---- value:uiSystemName的list
    Dictionary<string , List<string>> _extraABUserDic= new Dictionary<string, List<string>>();

    public Sprite GetSprite( string uiName, string spriteName )
    {
        string abName = "";
        //获取ab的名称，保存这个ab包被哪些UI系统所用
        if( AppConst.resourceMode != 0 && !ResourceManager.instance.IsDependBySprite( uiName, spriteName, out abName ) )
            ABRef( uiName, abName );
        return ResourceManager.instance.LoadSprite( spriteName );
    }
    public Sprite GetSprite( UISystem uiSystem, string spriteName )
    {
        return GetSprite( uiSystem.name, spriteName );
    }
    // 直接从AB中拿图片
    public Sprite GetSprite( string uiName, string spriteName, string abName, string editorPath = "" )
    {
        //获取ab的名称，保存这个ab包被哪些UI系统所用
        abName = abName.ToLower();
        if( AppConst.resourceMode != 0 && !ResourceManager.instance.IsDependBySprite(uiName, abName))
        {
            ABRef( uiName, abName );
        }
        return ResourceManager.instance.LoadSprite( spriteName, abName, editorPath );
    }
    private void ABRef( string uiName, string abName )
    {
        List<string> userList;
        if( !_extraABUserDic.TryGetValue( abName, out userList ) )
        {
            userList = new List<string>();
            _extraABUserDic[abName] = userList;
        }
        if( !userList.Contains( uiName ) )
        {
            userList.Add( uiName );
            ResourceManager.instance.AddRefCount( abName );
        }
    }

    /// <summary>
    /// 在UI界面被Destroy的时候，需要同时卸载依赖的ab包及其动态加载进来的ab包
    /// </summary>
    /// <param name="uiSystemName"></param>
    private void OnUIDestroy(string uiSystemName)
    {
        //卸载UI prefab
        ResourceManager.instance.UnloadAssetBundle(uiSystemName);
        //卸载额外加载进来的ab资源
        foreach (var pair in _extraABUserDic)
        {
            List<string> userList = pair.Value;
            userList.Remove(uiSystemName);//删除ab包的使用者信息
            //卸载该ab包或者减少引用计数
            ResourceManager.instance.UnloadAssetBundle(pair.Key);
        }
    }
    #endregion
}
