using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

/// <summary>
/// 日志系统
/// </summary>
public static class Debugger
{
    static private FileStream _fileStreamGame = null;
    static Dictionary<string, DateTime> _markTimes = new Dictionary<string, DateTime>();
    
    // 创建日志系统
    public static void Create( string path )
    {
        if ( !Directory.Exists( path ) )
        {
            Directory.CreateDirectory( path );
        }

        DateTime now = DateTime.Now;
        string time = string.Format("{0:D4}_{1:D2}_{2:D2}-{3:D2}_{4:D2}_{5:D2}",
                                    now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
        if ( _fileStreamGame == null )
             _fileStreamGame = new FileStream(path + "/" + time + ".game.log", FileMode.Create);
    }

    // 关闭日志系统
    public static void Close()
    {
        if ( _fileStreamGame != null )
        {
            _fileStreamGame.Close();
            _fileStreamGame = null;
        }
    }

    // 写入游戏日志
    public static void WriteGame(string msg)
    {
        if ( _fileStreamGame == null )
            return;
        DateTime now = DateTime.Now;
        string time = string.Format("[{0:D2}:{1:D2}:{2:D2}]", now.Hour, now.Minute, now.Second);
        byte[] memory = StringUtil.StringToByte(time + msg + "\r\n");
        _fileStreamGame.Write(memory, 0, memory.Length);
        _fileStreamGame.Flush();
    }

    // 记录用时开始
    public static void MarkStart(string tag)
    {
        _markTimes.Add(tag, DateTime.Now);
    }

    // 记录用时结束
    public static void MarkEnd(string tag)
    {
        DateTime start = _markTimes[tag];
        WriteGame(tag + " usetime:" + (DateTime.Now - start).TotalMilliseconds);
        _markTimes.Remove(tag);
    }

    // Log
    public static void Log( object log )
    {
        Debug.Log( log );
        WriteGame( log.ToString() );
    }
    public static void Log( string log, params object[] param )
    {
        string str = String.Format( log, param );
        Debug.Log( str );
        WriteGame( str );
    }

    // LogWarning
    public static void LogWarning( object log )
    {
        Debug.LogWarning( log );
        WriteGame( "WARNING: " + log.ToString() );
    }
    public static void LogWarning( string log, params object[] param )
    {
        string str = String.Format( log, param );
        Debug.LogWarning( str );
        WriteGame( str );
    }

    // LogError
    public static void LogError( object log )
    {
        Debug.LogError( log );
        WriteGame( "ERROR: " + log.ToString() );
    }
    public static void LogError( string log, params object[] param )
    {
        string str = String.Format( log, param );
        Debug.LogError( str );
        WriteGame( str );
    }
};
