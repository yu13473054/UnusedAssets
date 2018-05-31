using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

// 这个只能依赖Lua系统只能在Lua之后启用
public class NetworkManager : MonoBehaviour
{
    public static NetworkManager instance;

    private SocketClient _socket;
    static readonly object _lockObject = new object();
    static Queue<KeyValuePair<int, byte[]>> _events = new Queue<KeyValuePair<int, byte[]>>();

    private LuaFunction _onSocket;
    private LuaFunction _onHttp;

    void Awake()
    {
        instance = this;
    }

    public void Init()
    {
        _socket = new SocketClient();
        _socket.OnRegister();

        _onSocket = LuaManager.instance.GetFunction( "Network.Response" );
        _onHttp = LuaManager.instance.GetFunction( "Network.HttpResponse" );
    }

    ///------------------------------------------------------------------------------------
    public static void AddEvent( int _event, byte[] data )
    {
        lock( _lockObject )
        {
            _events.Enqueue( new KeyValuePair<int, byte[]>( _event, data ) );
        }
    }

    /// <summary>
    /// 交给Command，这里不想关心发给谁。
    /// </summary>
    void Update()
    {
        if( _events.Count > 0 )
        {
            while( _events.Count > 0 )
            {
                KeyValuePair<int, byte[]> _event = _events.Dequeue();

                // 在此把消息分发给Lua
                if( _event.Value == null )
                    _onSocket.Call<int>( _event.Key );
                else
                    _onSocket.Call<int, LuaByteBuffer>( _event.Key, new LuaByteBuffer( _event.Value ) );
            }
        }
    }

    /// <summary>
    /// 发送链接请求
    /// </summary>
    public void SendConnect( string host, int port )
    {
        _socket.SendConnect( host, port );
    }

    /// <summary>
    /// 发送SOCKET消息
    /// </summary>
    public void Send( LuaByteBuffer buffer )
    {
        _socket.WriteMessage( buffer.buffer );
    }


    /// <summary>
    /// HTTP GET
    /// </summary>
    public void HttpGet( string url )
    {
        HttpClient httpClient = new HttpClient();
        StartCoroutine( httpClient.Get( url, null, HttpResponse ) );
    }

    /// <summary>
    /// HTTP Response
    /// </summary>
    void HttpResponse( int error, string response )
    {
        _onHttp.Call<int, string>( error, response );
    }

    /// <summary>
    /// 析构函数
    /// </summary>
    void OnDestroy()
    {
        if( _socket != null )
            _socket.OnRemove();
        _events.Clear();
    }
}