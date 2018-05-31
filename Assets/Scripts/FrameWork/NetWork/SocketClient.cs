using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Collections;
using System.Collections.Generic;

public class Protocal
{
    ///BUILD TABLE
    public const int CONNECT = -1;          //连接服务器
    public const int DISCONNECT = -101;     //正常断线
    public const int EXCEPTION  = -102;     //异常掉线
}

public enum DisType
{
    EXCEPTION,
    DISCONNECT,
}

public class SocketClient
{
    private const int MAX_READ = 8192;
    public static bool loggedIn = false;

    private TcpClient _client = null;
    private NetworkStream _outStream = null;
    private MemoryStream _memStream;
    private BinaryReader _reader;

    private byte[] byteBuffer = new byte[MAX_READ];

    // Use this for initialization
    public SocketClient()
    {
    }

    /// <summary>
    /// 注册代理
    /// </summary>
    public void OnRegister()
    {
        _memStream = new MemoryStream();
        _reader = new BinaryReader( _memStream );
    }

    /// <summary>
    /// 移除代理
    /// </summary>
    public void OnRemove()
    {
        this.Close();
        _reader.Close();
        _memStream.Close();
    }

    /// <summary>
    /// 连接服务器
    /// </summary>
    void ConnectServer( string host, int port )
    {
        _client = null;
        try
        {
            IPAddress[] address = Dns.GetHostAddresses( host );
            if( address.Length == 0 )
            {
                Debugger.LogError( "host invalid" );
                return;
            }
            if( address[0].AddressFamily == AddressFamily.InterNetworkV6 )
            {
                _client = new TcpClient( AddressFamily.InterNetworkV6 );
            }
            else
            {
                _client = new TcpClient( AddressFamily.InterNetwork );
            }
            _client.SendTimeout = 1000;
            _client.ReceiveTimeout = 1000;
            _client.NoDelay = true;
            _client.BeginConnect( host, port, new AsyncCallback( OnConnect ), null );
        }
        catch( Exception e )
        {
            Close(); Debugger.LogError( e.Message );
        }
    }

    /// <summary>
    /// 连接上服务器
    /// </summary>
    void OnConnect( IAsyncResult asr )
    {
        _outStream = _client.GetStream();
        _client.GetStream().BeginRead( byteBuffer, 0, MAX_READ, new AsyncCallback( OnRead ), null );
        NetworkManager.AddEvent( Protocal.CONNECT, null );
    }

    /// <summary>
    /// 写数据
    /// </summary>
    public void WriteMessage( byte[] message )
    {
        MemoryStream ms = null;
        using( ms = new MemoryStream() )
        {
            ms.Position = 0;
            BinaryWriter writer = new BinaryWriter( ms );
            ushort msglen = (ushort)message.Length;
            writer.Write( msglen );
            writer.Write( message );
            writer.Flush();
            if( _client != null && _client.Connected )
            {
                //NetworkStream stream = _client.GetStream();
                byte[] payload = ms.ToArray();
                _outStream.BeginWrite( payload, 0, payload.Length, new AsyncCallback( OnWrite ), null );
            }
            else
            {
                Debugger.LogError( "_client.connected----->>false" );
            }
        }
    }

    /// <summary>
    /// 读取消息
    /// </summary>
    void OnRead( IAsyncResult asr )
    {
        int bytesRead = 0;
        try
        {
            lock( _client.GetStream() )
            {
                //读取字节流到缓冲区
                bytesRead = _client.GetStream().EndRead( asr );
            }
            if( bytesRead < 1 )
            {
                //包尺寸有问题，断线处理
                OnDisconnected( DisType.DISCONNECT, "bytesRead < 1" );
                return;
            }

            //分析数据包内容，抛给逻辑层
            OnReceive( byteBuffer, bytesRead );

            lock( _client.GetStream() )
            {
                //分析完，再次监听服务器发过来的新消息
                Array.Clear( byteBuffer, 0, byteBuffer.Length );   //清空数组
                _client.GetStream().BeginRead( byteBuffer, 0, MAX_READ, new AsyncCallback( OnRead ), null );
            }
        }
        catch( Exception ex )
        {
            //PrintBytes();
            OnDisconnected( DisType.EXCEPTION, ex.Message );
        }
    }

    /// <summary>
    /// 丢失链接
    /// </summary>
    void OnDisconnected( DisType dis, string msg )
    {
        Close();   //关掉客户端链接
        int protocal = dis == DisType.EXCEPTION ? Protocal.EXCEPTION : Protocal.DISCONNECT;
        NetworkManager.AddEvent( protocal, null );
    }

    /// <summary>
    /// 打印字节
    /// </summary>
    /// <param name="bytes"></param>
    void PrintBytes()
    {
        string returnStr = string.Empty;
        for( int i = 0; i < byteBuffer.Length; i++ )
        {
            returnStr += byteBuffer[i].ToString( "X2" );
        }
        Debugger.LogError( returnStr );
    }

    /// <summary>
    /// 向链接写入数据流
    /// </summary>
    void OnWrite( IAsyncResult r )
    {
        try
        {
            _outStream.EndWrite( r );
        }
        catch( Exception ex )
        {
            Debugger.LogError( "OnWrite--->>>" + ex.Message );
        }
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    void OnReceive( byte[] bytes, int length )
    {
        _memStream.Seek( 0, SeekOrigin.End );
        _memStream.Write( bytes, 0, length );
        //Reset to beginning
        _memStream.Seek( 0, SeekOrigin.Begin );
        while( RemainingBytes() > 2 )
        {
            ushort messageLen = _reader.ReadUInt16();
            if( RemainingBytes() >= messageLen )
            {
                MemoryStream ms = new MemoryStream();
                BinaryWriter writer = new BinaryWriter( ms );
                writer.Write( _reader.ReadBytes( messageLen ) );
                ms.Seek( 0, SeekOrigin.Begin );
                OnReceivedMessage( ms );
            }
            else
            {
                //Back up the position two bytes
                _memStream.Position = _memStream.Position - 2;
                break;
            }
        }
        //Create a new stream with any leftover bytes
        byte[] leftover = _reader.ReadBytes( (int)RemainingBytes() );
        _memStream.SetLength( 0 );     //Clear
        _memStream.Write( leftover, 0, leftover.Length );
    }

    /// <summary>
    /// 剩余的字节
    /// </summary>
    private long RemainingBytes()
    {
        return _memStream.Length - _memStream.Position;
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    /// <param name="ms"></param>
    void OnReceivedMessage( MemoryStream ms )
    {
        BinaryReader r = new BinaryReader( ms );
        byte[] message = r.ReadBytes( (int)( ms.Length - ms.Position ) );
        NetworkManager.AddEvent( 0, message );
    }

    /// <summary>
    /// 关闭链接
    /// </summary>
    public void Close()
    {
        if( _client != null )
        {
            if( _client.Connected ) _client.Close();
            _client = null;
        }
        loggedIn = false;
    }

    /// <summary>
    /// 发送连接请求
    /// </summary>
    public void SendConnect( string host, int port  )
    {
        ConnectServer( host, port );
    }
}
