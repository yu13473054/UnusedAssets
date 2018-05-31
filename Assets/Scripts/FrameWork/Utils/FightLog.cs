using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

/// <summary>
/// 战斗日志
/// </summary>
public static class FightLog
{
    static private FileStream _fileStreamGame = null;
    
    // 创建日志系统
    public static void Create()
    {
        if ( !Directory.Exists( AppConst.logPath ) )
        {
            Directory.CreateDirectory( AppConst.logPath );
        }

        DateTime now = DateTime.Now;
        string time = string.Format("{0:D4}_{1:D2}_{2:D2}-{3:D2}_{4:D2}_{5:D2}",
                                    now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second);
        if ( _fileStreamGame == null )
             _fileStreamGame = new FileStream(AppConst.logPath + "/" + time + ".fight.log", FileMode.Create);
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

    // Log
    public static void Log( string log )
    {
        if( _fileStreamGame == null )
            return;

        Debug.Log( log );

        byte[] memory = StringUtil.StringToByte( log + "\r\n" );
        _fileStreamGame.Write( memory, 0, memory.Length );
        _fileStreamGame.Flush();
    }
};
