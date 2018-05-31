using UnityEngine;
using System;
using System.Collections.Generic;

public class AppConst
{
    // 初始化基础配置
    public static void Init()
    {
        // app配置
        ConfigHandler ini = new ConfigHandler();
        ini.OpenFromStreamingAssets( "app.txt" );
        platID = Int32.Parse( ini.ReadValue( "PlatID", "1" ).ToString() );
        updateHost = ini.ReadValue( "UpdateHost", "" ).ToString();
        loginHost = ini.ReadValue( "LoginHost", "" ).ToString();
        resourceMode = Int32.Parse( ini.ReadValue( "ResourceMode", "0" ).ToString() );
    }

    /*********************************************************************/
    // 配置变量
    /*********************************************************************/
    public static int platID = 0;
    public static string updateHost = "";
    public static string loginHost = "";
    // 0 : 读本地 
    // 1 : 读ab 
    // 2 : txt资源从外部项目根目录Data中获取，其他资源从AB中获取
    public static int resourceMode = 0; 

    public static int audioClipLimit = 6; // 同时播放的音效的个数


    /*********************************************************************/
    // 常用路径
    /*********************************************************************/
    // 用户配置地址
    public static string configPath = Application.persistentDataPath + "/Config/";

    // 日志文件地址
    public static string logPath = Application.persistentDataPath + "/Log/";

    // 包内表地址
#if UNITY_STANDALONE || UNITY_EDITOR
    public static string packageDataPath = Application.dataPath + "/Data/";
#else
    public static string packageDataPath = Application.streamingAssetsPath + "/Data/";
#endif

    // 包内Steaming地址
#if UNITY_STANDALONE || UNITY_EDITOR
    public static string packageABPath = Application.streamingAssetsPath + "/assetbundle/";
#elif UNITY_ANDROID
    public static string packageABPath = Application.dataPath + "!assets/assetbundle/";
#elif UNITY_IPHONE
    public static string packageABPath = Application.dataPath + "/Raw/assetbundle/";
#endif

    // 下载的资源文件地址
    public static string resourcesPath = Application.persistentDataPath + "/Resources/";
    
    // 平台名称
#if UNITY_STANDALONE_WIN
    public static string platformName = "win";
#elif UNITY_STANDALONE_OSX
    public static string platformName = "osx";
#elif UNITY_ANDROID
    public static string platformName = "android";
#elif UNITY_IPHONE
    public static string platformName = "ios";
#endif
}