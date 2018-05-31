using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text; 

public class Builder
{
#if UNITY_STANDALONE_WIN
    static BuildTarget _buildTarget = BuildTarget.StandaloneWindows;
#elif UNITY_IPHONE
    static BuildTarget _buildTarget = BuildTarget.iOS;
#elif UNITY_ANDROID
    static BuildTarget _buildTarget = BuildTarget.Android;
#elif UNITY_EDITOR_OSX
    static BuildTarget _buildTarget = BuildTarget.StandaloneOSX;
#endif

    const string ABPATH = "Assets/StreamingAssets/assetbundle";

    static void Build( bool resverUpdate )
    {
        // 删除构建的文件
        RemoveBuildFile();
        // 创建文件夹
        Directory.CreateDirectory( ABPATH );

        /*********************************************************/
        // 打包前准备
        /*********************************************************/
        // 自动设置AB名
        EditorUtility.DisplayProgressBar( "打包前准备", "正在自动设置AB名", 0 );
        AssetBundleNameAuto.AssetBundleSetNames();

        /*********************************************************/
        // 打包
        /*********************************************************/
        // Lua打包
        BuildLua();

        // 配置打包
        BuildData();

        // 其他打包
        EditorUtility.DisplayProgressBar( "打包", "AB打包中", 0.3f );
        BuildPipeline.BuildAssetBundles( ABPATH, BuildAssetBundleOptions.ChunkBasedCompression, _buildTarget );
        AssetDatabase.Refresh();

        /*********************************************************/
        // 版本号处理
        /*********************************************************/
        if( resverUpdate )
        {
            EditorUtility.DisplayProgressBar( "统计", "版本文件处理中", 0.8f );
            // 修改app配置的版本号，每次打包+1
            ConfigHandler resverIni = new ConfigHandler();
            resverIni.OpenFromStreamingAssets( "version.txt" );
            int new_resource_version = int.Parse( resverIni.ReadValue( "Resource_Version", "0" ).ToString() ) + 1;
            resverIni.WriteValue( "Resource_Version", new_resource_version );
        }

        /*********************************************************/
        // 统计
        /*********************************************************/
        // 创建文件列表，并打包成ab
        EditorUtility.DisplayProgressBar( "统计", "版本文件处理中", 0.9f );
        Directory.CreateDirectory( "Assets/Temp" );
        string[] files = Directory.GetFiles( ABPATH );
        using( StreamWriter sw = new StreamWriter( "Assets/Temp/filelist.txt", false ) )
        {
            string fileList = "";
            for( int i = 0; i < files.Length; i++ )
            {
                string file = files[i];
                string ext = Path.GetExtension( file );
                string fileName = Path.GetFileName( file );
                if( ext.Equals( ".meta" ) || ext.Equals( ".manifest" ) )
                    continue;

                // md5 值
                string md5 = Utils.md5file( file );
                // 文件大小
                FileInfo fileInfo = new FileInfo( file );
                long size = fileInfo.Length;
                fileList += fileName + "|" + md5 + "|" + size + "\n";
            }
            fileList = fileList.TrimEnd( '\n' );
            sw.Write( fileList );
            sw.Close();
        }
        AssetDatabase.Refresh();
        // 把filelist打ab压缩
        AssetBundleBuild filelistAB = new AssetBundleBuild();
        filelistAB.assetBundleName = "filelist";
        filelistAB.assetNames = new string[] { "Assets/Temp/filelist.txt" };
        BuildPipeline.BuildAssetBundles( "Assets/Temp", new AssetBundleBuild[] { filelistAB }, BuildAssetBundleOptions.None, _buildTarget );
        File.Copy( "Assets/Temp/filelist", ABPATH + "/filelist", true );
        UnityEditor.FileUtil.DeleteFileOrDirectory( "Assets/Temp" );
        AssetDatabase.Refresh();

        /*********************************************************/
        // 上传
        /*********************************************************/
        if( resverUpdate )
        {
            EditorUtility.DisplayProgressBar( "上传", "准备上传", 1f );
            Upload();
            EditorUtility.ClearProgressBar();
        }
    }

    [MenuItem( "Builder/资源出包(打包+上传)", false, 1 )]
    static void BuildPackage()
    {
        Build( true );
        RemoveManifest();
    }

    [MenuItem( "Builder/删除manifest文件", false, 2 )]
    static void RemoveManifest()
    {
        DirectoryInfo dir = new DirectoryInfo( ABPATH );
        FileInfo[] files = dir.GetFiles();
        foreach( FileInfo file in files )
        {
            string path = file.FullName.Replace( "\\", "/" );
            string filename = Path.GetFileName( path );
            if( Path.GetExtension( filename ).Equals( ".manifest" ) )
                UnityEditor.FileUtil.DeleteFileOrDirectory( path );
        }
        AssetDatabase.Refresh();
    }


    [MenuItem( "Builder/资源打包(不上传)", false, 101 )]
    static void BuildAll()
    {
        Build( false );
    }

    [MenuItem( "Builder/Lua打包(不上传)", false, 102 )]
    static void BuildLua()
    {
        EditorUtility.DisplayProgressBar( "打包前准备", "正在处理Lua文件", 0.1f );
        LuaPrepare( true );

        // 拿所有文件
        EditorUtility.DisplayProgressBar( "打包", "Lua打包中", 0.2f );
        List<AssetBundleBuild> abList = new List<AssetBundleBuild>();
        DirectoryInfo raw = new DirectoryInfo( "Assets/Lua" );
        DirectoryInfo[] directory = raw.GetDirectories();
		foreach( DirectoryInfo dir in directory )
		{
            AssetBundleBuild build = new AssetBundleBuild();
            build.assetBundleName = "lua_" + dir.Name.ToLower();

            List<string> fileList = new List<string>();
            FileInfo[] files = dir.GetFiles( "*", SearchOption.AllDirectories );
            foreach( FileInfo file in files ) 
            {
			    // 文件跳过
                if( file.Extension == ".meta" || file.Extension == ".lua" )
                    continue;

                int pos = file.FullName.IndexOf( "Assets" );
                string path = file.FullName.Substring( pos );
                fileList.Add( path );
            }
            build.assetNames = fileList.ToArray();

            abList.Add( build );
		}

        BuildPipeline.BuildAssetBundles( ABPATH, abList.ToArray(), BuildAssetBundleOptions.ChunkBasedCompression, _buildTarget );
        EditorUtility.DisplayProgressBar( "收尾", "Lua还原中", 0.3f );
        LuaPrepare( false );

        EditorUtility.ClearProgressBar();
    }

    [MenuItem( "Builder/配置打包(不上传)", false, 103 )]
    static void BuildData()
    {
        EditorUtility.DisplayProgressBar( "打包前准备", "正在处理Data文件", 0.5f );

        Directory.CreateDirectory( "Assets/Temp" );

        // 拿所有文件
        FileInfo[] files = new DirectoryInfo( "Assets/Data" ).GetFiles( "*", SearchOption.AllDirectories );
        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = "data";

        List<string> fileList = new List<string>();
        foreach( FileInfo file in files )
        {
            // 文件跳过
            if( file.Extension == ".meta" )
                continue;

            string newPath = file.FullName.Replace( "\\Data\\", "\\Temp\\" );
            File.WriteAllText( newPath, StringUtil.ByteToString( File.ReadAllBytes( file.FullName ) ), new UTF8Encoding( false ) );

            int pos = newPath.IndexOf( "Assets" );
            string path = newPath.Substring( pos );
            fileList.Add( path );
        }

        build.assetNames = fileList.ToArray();

        AssetDatabase.Refresh();
        BuildPipeline.BuildAssetBundles( ABPATH, new AssetBundleBuild[]{ build }, BuildAssetBundleOptions.ChunkBasedCompression, _buildTarget );

        UnityEditor.FileUtil.DeleteFileOrDirectory( "Assets/Temp" );
        EditorUtility.ClearProgressBar();
    }

    // 复制Lua，改后缀以打包
    static void LuaPrepare( bool isProcess )
    {
        DirectoryInfo dir = new DirectoryInfo( "Assets/Lua" );
        FileInfo[] files = dir.GetFiles( "*.lua", SearchOption.AllDirectories );
        if( isProcess )
        {
            // 生成新的文件
            foreach( FileInfo file in files )
            {
                string path = file.FullName.Replace( "\\", "/" );
                UnityEditor.FileUtil.CopyFileOrDirectory( path, path + ".bytes" );
            }
            AssetDatabase.Refresh();
        }
        else
        {
            // 删除生成文件
            files = dir.GetFiles( "*.bytes", SearchOption.AllDirectories );
            foreach( FileInfo file in files )
            {
                string path = file.FullName.Replace( "\\", "/" );
                UnityEditor.FileUtil.DeleteFileOrDirectory( path );
            }
            AssetDatabase.Refresh();
        }
    }

    [MenuItem( "Builder/上传当前版本", false, 104 )]
    static void Upload()
    {
        // 上传ab
        ConfigHandler resverIni = new ConfigHandler();
        resverIni.OpenFromStreamingAssets( "version.txt" );
        int resver = int.Parse( resverIni.ReadValue( "Resource_Version", "0" ).ToString() );
        UploadDirectory( ABPATH, _ftpServerIP + "/Resources/" + AppConst.platformName + "/", resver.ToString() );

        // 上传版本文件
        UploadFile( "Assets/StreamingAssets/version.txt", _ftpServerIP + "/Resources/" + AppConst.platformName + "/version.txt" );
    }

    [MenuItem( "Builder/删除打包的AB文件", false, 301 )]
    static void RemoveBuildFile()
    {
        UnityEditor.FileUtil.DeleteFileOrDirectory( ABPATH );
        AssetDatabase.Refresh();
    }

    /************************************************************************/
    // FTP
    /************************************************************************/
    static string _ftpServerIP = "ftp://192.168.3.102/";//服务器ip  
    static string _ftpUserID = "test";//用户名  
    static string _ftpPassword = "123";//密码

    #region 上传文件
    // 上传文件  
    public static void UploadFile( string localFile, string ftpPath )
    {
        if( !File.Exists( localFile ) )
        {
            UnityEngine.Debug.LogError( "文件：“" + localFile + "” 不存在！" );
            return;
        }
        FileInfo fileInf = new FileInfo( localFile );
        FtpWebRequest reqFTP;

        reqFTP = (FtpWebRequest)FtpWebRequest.Create( ftpPath );// 根据uri创建FtpWebRequest对象   
        reqFTP.Credentials = new NetworkCredential( _ftpUserID, _ftpPassword );// ftp用户名和密码  
        reqFTP.KeepAlive = false;// 默认为true，连接不会被关闭 // 在一个命令之后被执行  
        reqFTP.Method = WebRequestMethods.Ftp.UploadFile;// 指定执行什么命令  
        reqFTP.UseBinary = true;// 指定数据传输类型  
        reqFTP.ContentLength = fileInf.Length;// 上传文件时通知服务器文件的大小  
        int buffLength = 2048;// 缓冲大小设置为2kb  
        byte[] buff = new byte[buffLength];
        int contentLen;

        // 打开一个文件流 (System.IO.FileStream) 去读上传的文件  
        FileStream fs = fileInf.OpenRead();
        try
        {
            Stream strm = reqFTP.GetRequestStream();// 把上传的文件写入流  
            contentLen = fs.Read( buff, 0, buffLength );// 每次读文件流的2kb  

            while( contentLen != 0 )// 流内容没有结束  
            {
                // 把内容从file stream 写入 upload stream  
                strm.Write( buff, 0, contentLen );
                contentLen = fs.Read( buff, 0, buffLength );
            }
            // 关闭两个流  
            strm.Close();
            fs.Close();
            UnityEngine.Debug.Log( "文件【" + ftpPath + "】上传成功！" );
        }
        catch( Exception ex )
        {
            UnityEngine.Debug.LogError( "上传文件【" + ftpPath + "】时，发生错误：" + ex.Message );
        }
    }
    #endregion

    #region 上传文件夹
    // 上传整个目录  
    public static void UploadDirectory( string localDir, string ftpPath, string dirName )
    {
        localDir += "/";
        //检测本地目录是否存在  
        if( !Directory.Exists( localDir ) )
        {
            UnityEngine.Debug.LogError( "本地目录：“" + localDir + "” 不存在！" );
            return;
        }

        string uri = ftpPath + dirName;
        //检测FTP的目录路径是否存在  
        if( !CheckDirectoryExist( ftpPath, dirName ) )
        {
            MakeDir( ftpPath, dirName );//不存在，则创建此文件夹  
        }
        List<List<string>> infos = GetDirDetails( localDir ); //获取当前目录下的所有文件和文件夹  

        //先上传文件
        for( int i = 0; i < infos[0].Count; i++ )
        {
            string ext = Path.GetExtension( infos[0][i] );
            string fileName = Path.GetFileName( infos[0][i] );
            if( ext.Equals( ".meta" ) || ext.Equals( ".manifest" ) || fileName == "app.txt" || fileName == "version.txt" )
                continue;

            UploadFile( localDir + fileName, uri + "/" + fileName );
            EditorUtility.DisplayProgressBar( "上传", "上传中...", (float)i / (float)infos[0].Count );
        }
        //再处理文件夹  
        for( int i = 0; i < infos[1].Count; i++ )
        {
            UploadDirectory( localDir, uri + "/", infos[1][i] ); 
        }

        UnityEngine.Debug.Log( "资源版本：【" + dirName + "】上传完毕！" );
        EditorUtility.ClearProgressBar();
    }

    // 判断ftp服务器上该目录是否存在  
    private static bool CheckDirectoryExist( string ftpPath, string dirName )
    {
        bool flag = true;
        try
        {
            string uri = ftpPath + dirName + "/";
            //实例化FTP连接  
            FtpWebRequest ftp = (FtpWebRequest)FtpWebRequest.Create( uri );
            ftp.Credentials = new NetworkCredential( _ftpUserID, _ftpPassword );
            ftp.Method = WebRequestMethods.Ftp.ListDirectory;
            FtpWebResponse response = (FtpWebResponse)ftp.GetResponse();
            response.Close();
        }
        catch( Exception )
        {
            flag = false;
        }
        return flag;
    }

    // 创建文件夹
    public static void MakeDir( string ftpPath, string dirName )
    {
        FtpWebRequest reqFTP;
        try
        {
            string uri = ftpPath + dirName;
            reqFTP = (FtpWebRequest)FtpWebRequest.Create( uri );
            reqFTP.Method = WebRequestMethods.Ftp.MakeDirectory;
            reqFTP.UseBinary = true;
            reqFTP.Credentials = new NetworkCredential( _ftpUserID, _ftpPassword );
            FtpWebResponse response = (FtpWebResponse)reqFTP.GetResponse();
            Stream ftpStream = response.GetResponseStream();
            ftpStream.Close();
            response.Close();
            UnityEngine.Debug.Log( "文件夹【" + dirName + "】创建成功！" );
        }
        catch( Exception ex )
        {
            UnityEngine.Debug.LogError( "新建文件夹【" + dirName + "】时，发生错误：" + ex.Message );
        }

    }

    // 获取目录下的详细信息  
    static List<List<string>> GetDirDetails( string localDir )
    {
        List<List<string>> infos = new List<List<string>>();
        try
        {
            infos.Add( Directory.GetFiles( localDir ).ToList() ); //获取当前目录的文件  

            infos.Add( Directory.GetDirectories( localDir ).ToList() ); //获取当前目录的目录  

            for( int i = 0; i < infos[0].Count; i++ )
            {
                int index = infos[0][i].LastIndexOf( @"\" );
                infos[0][i] = infos[0][i].Substring( index + 1 );
            }
            for( int i = 0; i < infos[1].Count; i++ )
            {
                int index = infos[1][i].LastIndexOf( @"\" );
                infos[1][i] = infos[1][i].Substring( index + 1 );
            }
        }
        catch( Exception ex )
        {
            ex.ToString();
        }
        return infos;
    }
    #endregion
}
