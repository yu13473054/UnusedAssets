using UnityEngine;
using System.Collections;

#if UNITY_ANDROID
using System;
public static class DeviceHelper 
{
    public static string getCountry()
    {
        if ( Application.isEditor )
            return "cn";
        string Country = string.Empty;
        AndroidJavaClass jc = new AndroidJavaClass( "com.guohegame.unityplugins.LocaleHelper" );
        if ( jc != null ) 
        {
            Country = jc.CallStatic<string>( "getCurrentCountry" );
        }
        return Country.ToLower();
    }

    public static string getLanguage()
    {
        if ( Application.isEditor )
            return "zh";
        string Language = string.Empty;
        AndroidJavaClass jc = new AndroidJavaClass( "com.guohegame.unityplugins.LocaleHelper" );
        if ( jc != null )
        {
            Language = jc.CallStatic<string>( "getCurrentLanguage" );
        }
        return Language.ToLower();
    }
    
    // 获得设备相关信息
	// ios1/android2 | Mac地址 | 设备ID | 分辨率 | 设备名 | 系统名 | 网络类型 | 运营商
	// 2|CC:3A:61:D0:B7:DE|357748052440339|1080*1920|GT-I9508|android 4.4.2|Wi-Fi|中国联通
    public static string GetDeviceDesc()
    {
        if ( Application.isEditor )
            return "2|CC:3A:61:D0:B7:DE|357748052440339|1080*1920|GT-I9508|android 4.4.2|Wi-Fi|中国联通";
		string rtn;
        using ( AndroidJavaClass jc = new AndroidJavaClass( "com.ghgame.ghpluslib.GhFunc" ) )
        {
			rtn = jc.CallStatic<string>("getDeviceDesc");
        }
		return rtn;
    }
}

#elif UNITY_IOS
using System.Runtime.InteropServices;
public static class DeviceHelper
{
    [DllImport("__Internal")]
    private static extern string _getCountry();
    public static string getCountry()
    {
        if ( Application.isEditor )
            return "cn";
        // iOS 地区为zh-hant_cn 取最后一个地区编码
        string[] s = _getCountry().ToLower().Split('_');
        if ( s.Length < 2 )
            return "us";

        string Country = s[1];
        return Country;
    }

    [DllImport("__Internal")]
    private static extern string _getLanguage();
    public static string getLanguage()
    {
        if ( Application.isEditor )
            return "zh";
        // string Language = _getLanguage().ToLower();
        // iOS下获取的语言为 zh-hant-cn 取第一个语言编码，繁体简体用tw cn区分就好了
        string[] s = _getLanguage().ToLower().Split( '-' );
        string Language = s[0];
        return Language;
    }

    
    // 获得设备相关信息
	// ios1/android2 | Mac地址 | 设备ID | 分辨率 | 设备名 | 系统名 | 网络类型 | 运营商
	// 2|CC:3A:61:D0:B7:DE|357748052440339|1080*1920|GT-I9508|android 4.4.2|Wi-Fi|中国联通
	[DllImport("__Internal")]
	private static extern string getDeviceDesc();	// 设备信息
    public static string GetDeviceDesc()
    {
        if ( Application.isEditor )
            return "1|CC:3A:61:D0:B7:DE|357748052440339|1080*1920|GT-I9508|android 4.4.2|Wi-Fi|中国联通";
		return getDeviceDesc();
    }
}
#else
public static class DeviceHelper
{
    public static string GetCountry()
    {
        return "cn";
    }

    public static string GetLanguage()
    {
        return "en";
    }
    // 获得设备相关信息
    // ios1/android2 | Mac地址 | 设备ID | 分辨率 | 设备名 | 系统名 | 网络类型 | 运营商
    // 2|CC:3A:61:D0:B7:DE|357748052440339|1080*1920|GT-I9508|android 4.4.2|Wi-Fi|中国联通
    public static string GetDeviceDesc()
    {
        // 测试用
        return "3|cc:cc:cc:cc:cc:cc|8888888|1080*1920|PC|WIN7|Wi-Fi|小灵通";
    }
}

#endif
