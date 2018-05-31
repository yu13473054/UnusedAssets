using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

/// <summary>
/// 文件工具
/// </summary>
public static class FileUtil
{
    /// <summary>
    /// 读文件获取二进制内容
    /// </summary>
    public static byte[] GetDataFromFile( string filepath )
    {
        if ( !File.Exists(filepath) )
            return null;
        using ( FileStream fileStream = new FileStream( filepath, FileMode.Open ) )
        {
            // 创建缓存
            int fileLength = (int)fileStream.Length;
            byte[] fileData = new byte[fileLength];

            // 读取内容
            fileStream.Read(fileData, 0, fileLength);
            fileStream.Close();
            return fileData;
        }
    }

    /// <summary>
    /// WWW方式读文件获取二进制内容
    /// </summary>
    public static byte[] GetDataFromWWW( string filepath )
    {
        if ( Application.platform == RuntimePlatform.Android )
        {
            WWW www = new WWW( filepath );
            while ( !www.isDone )
            {
            }
            if ( www.error != null )
            {
                Debugger.Log( "GetDataFromWWW www.error: " + www.error );
                return null;
            }
            return www.bytes;
        }
        else
        {
            FileInfo file = new FileInfo( filepath );
            if ( !file.Exists )
                return null;
            FileStream fs = file.OpenRead();
            byte[] fileData = new byte[fs.Length];
            fs.Read( fileData, 0, (int)fs.Length );
            fs.Close();
            return fileData;
        }
    }

    /// <summary>
    /// 写文件内容
    /// </summary>
    public static void WriteFile( string fileName, string text )
    {
        string fullPath = fileName;

        string dir = Path.GetDirectoryName( fullPath );
        if ( !Directory.Exists( dir ) )
            Directory.CreateDirectory( dir );

        using ( FileStream fileStream = new FileStream(fullPath, FileMode.Create, FileAccess.Write) )
        {
            StreamWriter sw = new StreamWriter(fileStream, Encoding.Default);
            sw.Write(text);
            sw.Close();
        }
    }

    /// <summary>
    /// 是否存在指定路径的文件
    /// </summary>
    public static bool IsFileExist(string filePath)
    {
        if (filePath.Length == 0)
            return false;

        return File.Exists(filePath);
    }

    /// <summary>
    /// 拷贝文件夹
    /// </summary>
    public static void CopyDir( string fromDir, string toDir )
    {
        if ( !Directory.Exists( fromDir ) )
            return;

        if ( !Directory.Exists( toDir ) )
        {
            Directory.CreateDirectory( toDir );
        }

        string[] files = Directory.GetFiles( fromDir );
        foreach ( string formFileName in files )
        {
            string fileName = Path.GetFileName( formFileName );
            string toFileName = Path.Combine( toDir, fileName );
            File.Copy( formFileName, toFileName, true );
        }
        string[] fromDirs = Directory.GetDirectories( fromDir );
        foreach ( string fromDirName in fromDirs )
        {
            string dirName = Path.GetFileName( fromDirName );
            string toDirName = Path.Combine( toDir, dirName );
            CopyDir( fromDirName, toDirName );
        }
    }
};
