using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;

// ���ֻ������Luaϵͳֻ����Lua֮������
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
    /// ����Command�����ﲻ����ķ���˭��
    /// </summary>
    void Update()
    {
        if( _events.Count > 0 )
        {
            while( _events.Count > 0 )
            {
                KeyValuePair<int, byte[]> _event = _events.Dequeue();

                // �ڴ˰���Ϣ�ַ���Lua
                if( _event.Value == null )
                    _onSocket.Call<int>( _event.Key );
                else
                    _onSocket.Call<int, LuaByteBuffer>( _event.Key, new LuaByteBuffer( _event.Value ) );
            }
        }
    }

    /// <summary>
    /// ������������
    /// </summary>
    public void SendConnect( string host, int port )
    {
        _socket.SendConnect( host, port );
    }

    /// <summary>
    /// ����SOCKET��Ϣ
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
    /// ��������
    /// </summary>
    void OnDestroy()
    {
        if( _socket != null )
            _socket.OnRemove();
        _events.Clear();
    }
}