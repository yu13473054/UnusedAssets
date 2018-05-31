using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;

// 资源更新逻辑，执行顺序从上到下
public class UpdateManager : MonoBehaviour
{
    public static UpdateManager instance;

    public Action<string, float> updateCallBack;

    class DownloadFile
    {
        public DownloadFile( string name, int size, string md5 )
        {
            this.name = name;
            this.size = size;
            this.md5 = md5;
        }
        public string name = "";
        public int size = 0;
        public string md5 = string.Empty;
    }

    // 下载文件总大小
    int _downloadTotalSize = 0;
    //需要下载的文件的个数
    private int _downLoadFileNum;

    // 已下载的文件
    List<string> _downloadedFiles = new List<string>();

    // 更新是否完成
    bool _isFinish = false;
    public bool isFinish{ get{ return _isFinish; } }

    void Awake()
    {
        instance = this;
    }

    // 开始更新
    public void BeginUpdate()
    {
        _isFinish = false;

        // 第一步比较，包内资源和本地资源的版本号
        // 包内版本
        ConfigHandler packageVerConfig = new ConfigHandler();
        packageVerConfig.OpenFromStreamingAssets( "version.txt" );
        int packageVer = int.Parse( packageVerConfig.ReadValue( "Resource_Version", "0" ).ToString() );
        Debugger.Log( "<Update> 包内资源版本：" + packageVer );

        // 下载版本
        // 如果不存在，直接写一个包内文件
        ConfigHandler localVerConfig = new ConfigHandler();
        localVerConfig.Open( AppConst.configPath + "version.txt" );
        int localVer = int.Parse( localVerConfig.ReadValue( "Resource_Version", "0" ).ToString() );
        Debugger.Log( "<Update> 本地资源版本：" + localVer );

        // 如果本地版本不存在，保存一份
        if( !File.Exists( AppConst.configPath + "version.txt" ) )
            localVerConfig.Copy( packageVerConfig );

        // 如果包内版本更高，删除所有本地资源文件
        if( Directory.Exists( AppConst.resourcesPath ) )
        {
            if( packageVer > localVer )
            {
                Directory.Delete( AppConst.resourcesPath, true );
                Directory.CreateDirectory( AppConst.resourcesPath );
            }
        }
        else
        {
            Directory.CreateDirectory( AppConst.resourcesPath );
#if UNITY_IOS
            UnityEngine.iOS.Device.SetNoBackupFlag( AppConst.resourcesPath );
#endif
        }

        // 本地最终版本
        localVer = Math.Max( packageVer, localVer );

        // 检查远端版本
        StartCoroutine( CheckResVer( localVer ) );
    }

    // 检查远端版本
    IEnumerator CheckResVer( int localVer )
    {
        // 拿远端版本
        WWW www = new WWW( AppConst.updateHost + AppConst.platformName + "/version.txt" );
        yield return www;
        if( www.error != null )
        {
            Debugger.LogError( "<Update> 无法获取远端资源版本：" + www.error );
            yield break;
        }
        ConfigHandler remoteVerConfig = new ConfigHandler();
        remoteVerConfig.OpenFromMemory( www.bytes );

        // 是否要强更？
        float forceVer = float.Parse( remoteVerConfig.ReadValue( "Force_Version", "0" ).ToString() );
        Debugger.Log( "<Update> 强更程序版本：" + forceVer );
        float appVer = float.Parse( Application.version );
        if( forceVer > appVer )
        {
            Debugger.Log( "<Update> 去商店下载最新版本！" );
            // 弹出跳转商店的页面
            yield break;
        }

        // 继续热更资源：
        // 远端资源版本
        int remoteVer = int.Parse( remoteVerConfig.ReadValue( "Resource_Version", "0" ).ToString() );
        Debugger.Log( "<Update> 远端资源版本：" + remoteVer );

        // 远端版本<本地(或包内)，警告。虽然不太可能出现
        if( remoteVer < localVer )
        {
            Debugger.LogWarning( "<Update> *注意*远端版本小于本地版本！" );
            // 考虑提示玩家自助修复
            _isFinish = true;
            yield break;
        }

        // 远端版本更新，开始更新
        if( remoteVer > localVer )
        {
            yield return UpdateResource( remoteVer );
        }
        else
        {
            Debugger.Log( "<Update> 无需更新！" );
            _isFinish = true;
        }
    }

    void UnpackFileList( TextAsset fileListData, Dictionary<string, DownloadFile> fileListMap )
    {
        string[] fileList = fileListData.ToString().Split( '\n' );
        // 解析文件列表
        foreach( var file in fileList )
        {
            string[] values = file.Split( '|' );
            string fileName = values[0];
            string fileMd5 = values[1];
            int fileSize = Convert.ToInt32( values[2] );
            fileListMap.Add( fileName, new DownloadFile( fileName, fileSize, fileMd5 ) );
        }
    }

    // 开始更新
    IEnumerator UpdateResource( int remoteVer )
    {
        // 更新过程中，每秒都需要进行网络检查
        StartCoroutine( OnCheckNetwork() );

        // 下载地址
        string downloadURL = AppConst.updateHost + AppConst.platformName + "/" + remoteVer + "/";

        /*********************************************/
        // 本地资源文件表
        /*********************************************/
        Dictionary<string, DownloadFile> localFileList = new Dictionary<string, DownloadFile>();
        // 读取本地文件列表
        TextAsset filelistData = ResourceManager.instance.LoadAsset<TextAsset>( "filelist", "filelist" );
        if( filelistData == null )
        {
            Debugger.LogError( "<Update> 无法读取本地文件列表！" );
            yield break;
        }
        UnpackFileList( filelistData, localFileList );
        ResourceManager.instance.UnloadAssetBundle( "filelist", true );

        /*********************************************/
        // 远端资源文件表
        /*********************************************/
        Dictionary<string, DownloadFile> remoteFileList = new Dictionary<string, DownloadFile>();
        // 获取服务器文件列表
        WWW fileListWWW = new WWW( downloadURL + "filelist" );
        yield return fileListWWW;
        if( fileListWWW.error != null )
        {
            Debugger.LogError( "<Update> 无法获取远端文件列表：" + fileListWWW.error );
            yield break;
        }
        AssetBundle remoteFilelistAB = AssetBundle.LoadFromMemory( fileListWWW.bytes );
        UnpackFileList( remoteFilelistAB.LoadAsset<TextAsset>( "filelist" ), remoteFileList );
        remoteFilelistAB.Unload( true );

        /*********************************************/
        // 开始比较差异，生成下载列表
        /*********************************************/
        List<DownloadFile> downloadList = new List<DownloadFile>();
        foreach( var remoteFile in remoteFileList )
        {
            bool isNeedDownload = false;
            DownloadFile localFile;
            if( !localFileList.TryGetValue( remoteFile.Key, out localFile ) )
            {
                // 不存在文件，下载！
                isNeedDownload = true;
                Debugger.Log( "<Download> [" + remoteFile.Key + "] 不存在，Download！" );
            }
            else
            {
                if( localFile.size != remoteFile.Value.size )
                {
                    // 大小不一致，下载
                    isNeedDownload = true;
                    Debugger.Log( "<Download> [" + remoteFile.Key + "] 大小不一致，Download！" );
                }
                else
                {
                    if( !localFile.md5.Equals( remoteFile.Value.md5 ) )
                    {
                        // MD5不一致，下载
                        isNeedDownload = true;
                        Debugger.Log( "<Download> [" + remoteFile.Key + "] MD5不一致，Download！" );
                    }
                }
            }

            // 如果需要更新
            if( isNeedDownload )
            {
                downloadList.Add( remoteFile.Value );
                _downloadTotalSize += remoteFile.Value.size;
            }
        }

        Debugger.Log( "<Download> 下载文件总大小：" + _downloadTotalSize );
        // 如果是wifi下载不提示
        if( Application.platform == RuntimePlatform.WindowsEditor || Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork )
        { }
        else
        {
            // 询问玩家是否下载
        }

        /*********************************************/
        // 开始下载
        /*********************************************/
        // 下载文件夹
        string downloadPath = AppConst.resourcesPath + "Download/";
        if( downloadList.Count > 0 )
        {
            if( !Directory.Exists( downloadPath ) )
                Directory.CreateDirectory( downloadPath );
            //通知显示界面
            _downLoadFileNum = downloadList.Count;
            UpdateProgress(1);
        }

        // 下载文件
        for( int i = 0; i < downloadList.Count; i++ )
        {
            DownloadFile downloadFile = downloadList[i];

            bool downloadFinish = false;
            while( !downloadFinish )
            {
                // 启动下载文件
                Download( downloadURL, downloadPath + downloadFile.name );
                // 等待下载完成
                while( !_downloadedFiles.Contains( downloadFile.name ) )
                {
                    yield return new WaitForEndOfFrame();
                }

                // 没下下来
                string finishedFile = downloadPath + downloadFile.name;
                if( !File.Exists( finishedFile ) )
                {
                    Debugger.Log( "<Download> 下载失败：" + downloadFile.name );
                    _downloadedFiles.Remove( downloadFile.name );
                    continue;
                }

                // MD5检查
                if( !downloadFile.md5.Equals( Utils.md5file( finishedFile ) ) )
                {
                    // 下载文件损坏，重新下载               
                    Debugger.Log( "<Download> 下载文件损坏：" + downloadFile.name );
                    _downloadedFiles.Remove( downloadFile.name );
                    continue;
                }

                // 下载成功
                Debugger.Log( "<Download> 下载成功：" + downloadFile.name );
                downloadFinish = true;

                //通知显示界面
                UpdateProgress(1);
            }
        }

        // 更新完毕之后将临时补丁文件夹内容拷贝到正式本地目录
        if( downloadList.Count > 0 )
        {
            // 拷贝所有文件
            FileUtil.CopyDir( downloadPath, AppConst.resourcesPath );
            Directory.Delete( downloadPath, true );

            // 写入文件列表
            using( StreamWriter sw = new StreamWriter( AppConst.resourcesPath + "filelist" ) )
            {
                sw.Write( fileListWWW.bytes );
                sw.Close();
            }

            // 更新程序资源版本文件
            ConfigHandler localVerConfig = new ConfigHandler();
            localVerConfig.Open( AppConst.configPath + "version.txt" );
            localVerConfig.WriteValue( "Resource_Version", remoteVer );
            Debugger.Log( "<Update> 更新资源至：" + remoteVer );
        }

        // 更新完成
        _isFinish = true;
    }

    /// <summary>
    /// 显示UI的更新进度
    /// </summary>
    /// <param name="type">1：更新，2：解压</param>

    void UpdateProgress(int type)
    {
        if (updateCallBack!=null)
        {
            if(type ==1)
            {
                float perc = _downloadedFiles.Count*1f/_downLoadFileNum;
                updateCallBack("更新进度："+Mathf.CeilToInt(perc * 100)+"%", perc);
            }
        }
    }

    /// <summary>
    /// 下载文件
    /// </summary>
    void Download( string url, string file )
    {
        object[] param = new object[2]{ url, file };
        ThreadEvent ev = new ThreadEvent();
        ev.Key = NotifyConst.DOWNLOAD;
        ev.evParams.AddRange( param );
        ThreadManager.instance.AddEvent( ev, OnThreadDownLoadProc );
    }

    /// <summary>
    /// 下载过程，线程调用
    /// </summary>
    /// <param name="data"></param>
    void OnThreadDownLoadProc( NotifyData data )
    {
        switch( data.evID )
        {
            case NotifyConst.DOWNLOAD_PROGRESS:
                // 下载过程
                //string file = data.evParam[0].ToString();
                //m_szNeedremoteFileDict[file].bytesReceived = Convert.ToInt64( data.evParam[2] );
                //m_downloadspeed = data.evParam[1].ToString();
                //m_downloadProgress = String.Format( "{0:F}", GetDownloadSize() / 1024.0 / 1024.0 ) + "MB" + " / " + String.Format( "{0:F}", m_downloadsize_total / 1024.0 / 1024.0 ) + "MB";
                break;
            case NotifyConst.DOWNLOAD:
                // 下载完成之后添加到已下载列表
                _downloadedFiles.Add( data.evParam[0].ToString() );
                break;
        }
    }

    // 网络检查
    IEnumerator OnCheckNetwork()
    {
        while( true )
        {
            // 启动检测网络
            yield return new WaitForSeconds( 2 );
            if( Application.internetReachability == NetworkReachability.NotReachable )
            {
                Debugger.LogError( "<Download> 下载中网络中断！" );
            }
        }
    }
}
