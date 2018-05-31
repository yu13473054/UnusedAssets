using System.Collections;
using System.Threading;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
using System.Net;
using System.ComponentModel;
using System;
using UnityEngine;
public class NotifyConst
{
    public const int DOWNLOAD           = 1;        //下载
    public const int DOWNLOAD_PROGRESS  = 2;        //下载进度
    public const int UPLOAD             = 3;        //上传
    public const int UPLOAD_PROGRESS    = 4;        //上传进度
}

// 线程事件
public class ThreadEvent
{
    public int Key;
    public List<object> evParams = new List<object>();
}

// 线程通知的数据结构
public class NotifyData
{
    public int evID;
    public object[] evParam;
    public NotifyData( int id, object[] param )
    {
        this.evID = id;
        this.evParam = param;
    }
}

/// <summary>
/// 当前线程管理器，同时只能做一个任务
/// </summary>
public class ThreadManager : MonoBehaviour
{
    public static ThreadManager instance;

    // 线程
    private Thread _thread;

    // 通知函数
    private Action<NotifyData> _func;

    // 记录响应时间
    private Stopwatch _stopWatch = new Stopwatch();

    // 当前正在下载的文件
    private string _currDownFile = string.Empty;

    // 当前正在上传的文件
    private string _currUploadFile = string.Empty;

    // 事件队列
    static readonly object _lockObj = new object();
    static Queue<ThreadEvent> _events = new Queue<ThreadEvent>();

    // 代理
    delegate void ThreadSyncEvent( NotifyData data );

    public void Awake()
    {
        instance = this;
        _thread = new Thread( OnUpdate );
    }

    // Use this for initialization
    public void Start()
    {
        _thread.Start();
    }

    // 添加到事件队列
    public void AddEvent( ThreadEvent ev, Action<NotifyData> func )
    {
        lock( _lockObj )
        {
            _func = func;
            _events.Enqueue( ev );
        }
    }

    // 通知事件
    private void OnSyncEvent( NotifyData data )
    {
        if( _func != null )
            _func( data );  // 回调逻辑层
    }

    void OnUpdate()
    {
        while( true )
        {
            lock( _lockObj )
            {
                if( _events.Count > 0 )
                {
                    ThreadEvent e = _events.Dequeue();
                    try
                    {
                        switch( e.Key )
                        {
                            case NotifyConst.DOWNLOAD:
                                {  //下载文件
                                    OnDownloadFile( e.evParams );
                                }
                                break;
                            case NotifyConst.UPLOAD:
                                { // 上传文件
                                    OnUploadFile( e.evParams );
                                }
                                break;
                        }
                    }
                    catch( System.Exception ex )
                    {
                        UnityEngine.Debug.LogError( ex.Message );
                    }
                }
            }
            Thread.Sleep( 1 );
        }
    }

    // 下载文件
    void OnDownloadFile( List<object> evParams )
    {
        string url = evParams[0].ToString();
        string downloadPath = evParams[1].ToString();
        _currDownFile = Path.GetFileName( downloadPath );

        using( WebClient client = new WebClient() )
        {
            _stopWatch.Start();
            client.DownloadProgressChanged += new DownloadProgressChangedEventHandler( DownloadProgress );
            client.DownloadFileCompleted += new AsyncCompletedEventHandler( DownloadCompleted );
            client.DownloadFileAsync( new System.Uri( url + _currDownFile ), downloadPath );
        }
    }

    // 更新下载进度
    private void DownloadProgress( object sender, DownloadProgressChangedEventArgs e )
    {
        string speed = string.Format( "{0} kb/s", ( e.BytesReceived / 1024d / _stopWatch.Elapsed.TotalSeconds ).ToString( "0.00" ) );
        object[] evParam = { _currDownFile, speed, e.BytesReceived };
        NotifyData data = new NotifyData( NotifyConst.DOWNLOAD_PROGRESS, evParam );
        OnSyncEvent( data );
    }

    // 下载完成
    private void DownloadCompleted( object sender, AsyncCompletedEventArgs e )
    {
        _stopWatch.Reset();
        // 通知逻辑层
        object[] evParam = { _currDownFile };
        NotifyData data = new NotifyData( NotifyConst.DOWNLOAD, evParam );
        OnSyncEvent( data );
    }

    // 上传文件
    void OnUploadFile( List<object> evParams )
    {
        string url = evParams[0].ToString();
        string uploadPath = evParams[1].ToString();
        _currUploadFile = Path.GetFileName( uploadPath );

        using( WebClient client = new WebClient() )
        {
            _stopWatch.Start();
            client.UploadProgressChanged += new UploadProgressChangedEventHandler( UploadProgress );
            client.UploadFileCompleted += new UploadFileCompletedEventHandler( UploadCompleted );
            byte[] file = File.ReadAllBytes( uploadPath );
            client.UploadDataAsync( new System.Uri( url + _currUploadFile ), file );
        }
    }

    // 上传进度
    private void UploadProgress( object sender, UploadProgressChangedEventArgs e )
    {
        string value = string.Format( "{0} kb/s", ( e.BytesSent / 1024d / _stopWatch.Elapsed.TotalSeconds ).ToString( "0.00" ) );
        object[] evParam = { value, e.BytesSent };
        NotifyData data = new NotifyData( NotifyConst.UPLOAD_PROGRESS, evParam );
        OnSyncEvent( data );
    }

    // 上传完成
    private void UploadCompleted( object sender, AsyncCompletedEventArgs e )
    {
        _stopWatch.Reset();
        // 通知逻辑层
        object[] evParam = { _currUploadFile };
        NotifyData data = new NotifyData( NotifyConst.UPLOAD, evParam );
        OnSyncEvent( data );
    }

    // 应用程序退出
    void OnDestroy()
    {
        _events.Clear();
        _thread.Abort();
    }
}
