using UnityEngine;
using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using System.Text.RegularExpressions;
using System.Reflection;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class Utils : MonoBehaviour
{
    public static long GetTime()
    {
        TimeSpan ts = new TimeSpan(DateTime.UtcNow.Ticks - new DateTime(1970, 1, 1, 0, 0, 0).Ticks);
        return (long)ts.TotalMilliseconds;
    }

    /// <summary>
    /// 添加组件
    /// </summary>
    public static T Add<T>(GameObject go) where T : Component
    {
        if (go != null)
        {
            T[] ts = go.GetComponents<T>();
            for (int i = 0; i < ts.Length; i++)
            {
                if (ts[i] != null) Destroy(ts[i]);
            }
            return go.gameObject.AddComponent<T>();
        }
        return null;
    }

    /// <summary>
    /// 添加组件
    /// </summary>
    public static T Add<T>(Transform go) where T : Component
    {
        return Add<T>(go.gameObject);
    }

    /// <summary>
    /// 移除组件
    /// </summary>
    public static T Del<T>(GameObject go) where T : Component
    {
        if (go != null)
        {
            T[] ts = go.GetComponents<T>();
            for (int i = 0; i < ts.Length; i++)
            {
                if (ts[i] != null)
                    Destroy(ts[i]);
            }
        }
        return null;
    }

    /// <summary>
    /// 手机震动
    /// </summary>
    public static void Vibrate()
    {
#if UNITY_STANDALONE
#elif UNITY_STANDALONE_OSX
#else
		Handheld.Vibrate();
#endif
    }

    /// <summary>
    /// Base64编码
    /// </summary>
    public static string Encode(string message)
    {
        byte[] bytes = Encoding.GetEncoding("utf-8").GetBytes(message);
        return Convert.ToBase64String(bytes);
    }

    /// <summary>
    /// Base64解码
    /// </summary>
    public static string Decode(string message)
    {
        byte[] bytes = Convert.FromBase64String(message);
        return Encoding.GetEncoding("utf-8").GetString(bytes);
    }

    /// <summary>
    /// 判断数字
    /// </summary>
    public static bool IsNumeric(string str)
    {
        if (str == null || str.Length == 0) return false;
        for (int i = 0; i < str.Length; i++)
        {
            if (!Char.IsNumber(str[i])) { return false; }
        }
        return true;
    }

    /// <summary>
    /// 是否为数字
    /// </summary>
    public static bool IsNumber( string strNumber )
    {
        Regex regex = new Regex( "[^0-9]" );
        return !regex.IsMatch( strNumber );
    }

    /// <summary>
    /// HashToMD5Hex
    /// </summary>
    public static string HashToMD5Hex(string sourceStr)
    {
        byte[] Bytes = Encoding.UTF8.GetBytes(sourceStr);
        using (MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider())
        {
            byte[] result = md5.ComputeHash(Bytes);
            StringBuilder builder = new StringBuilder();
            for (int i = 0; i < result.Length; i++)
                builder.Append(result[i].ToString("x2"));
            return builder.ToString();
        }
    }

    /// <summary>
    /// 计算字符串的MD5值
    /// </summary>
    public static string md5(string source)
    {
        MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
        byte[] data = System.Text.Encoding.UTF8.GetBytes(source);
        byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
        md5.Clear();

        string destString = "";
        for (int i = 0; i < md5Data.Length; i++)
        {
            destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
        }
        destString = destString.PadLeft(32, '0');
        return destString;
    }

    /// <summary>
    /// 计算文件的MD5值
    /// </summary>
    public static string md5file(string file)
    {
        try
        {
            FileStream fs = new FileStream(file, FileMode.Open);
            System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] retVal = md5.ComputeHash(fs);
            fs.Close();

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < retVal.Length; i++)
            {
                sb.Append(retVal[i].ToString("x2"));
            }
            return sb.ToString();
        }
        catch (Exception ex)
        {
            throw new Exception("md5file() fail, error:" + ex.Message);
        }
    }
    
    /// <summary>
    /// 把字符串串换成一个字符的数组
    /// </summary>
    /// <param name="value"></param>
    /// <returns></returns>
    public static string[] String2Array(string value)
    {
        string[] array = new string[value.Length];
        for (int i = 0; i < value.Length; i++)
        {
            array[i] = value[i].ToString();
        }
        return array;
    }

    /// <summary>
    /// 清除所有子节点
    /// </summary>
    public static void ClearChild(Transform go)
    {
        if (go == null) return;
        for (int i = go.childCount - 1; i >= 0; i--)
        {
            Destroy(go.GetChild(i).gameObject);
        }
    }

    /// <summary>
    /// 取得行文本
    /// </summary>
    public static string GetFileText(string path)
    {
        return File.ReadAllText(path);
    }

    /// <summary>
    /// 主要给脚本使用
    /// </summary>
    public static bool Exists(string path)
    {
        return Directory.Exists(path);
    }

    /// <summary>
    /// 主要给脚本使用
    /// </summary>
    public static void CreateDirectory(string path)
    {
        Directory.CreateDirectory(path);
    }

    /// <summary>
    /// 网络可用
    /// </summary>
    public static bool NetAvailable
    {
        get
        {
            return Application.internetReachability != NetworkReachability.NotReachable;
        }
    }

    /// <summary>
    /// 是否是无线
    /// </summary>
    public static bool IsWifi
    {
        get
        {
            return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork;
        }
    }

    public static void Log(string str)
    {
        Debug.Log(str);
    }

    public static void LogWarning(string str)
    {
        Debug.LogWarning(str);
    }

    public static void LogError(string str)
    {
        Debug.LogError(str);
    }


    public static Component AddComponent(GameObject go, string assembly, string classname)
    {
        Assembly asmb = Assembly.Load(assembly);
        Type t = asmb.GetType(assembly + "." + classname);
        return go.AddComponent(t);
    }

    // 获取一个byte的每一位
    public static byte get_sflag(byte sflag, byte offset)
    {
        if ((sflag & (1 << offset)) != 0)
            return 1;
        return 0;
    }

    // 获取一个int的每一位
    public static int get_int_sflag(int sflag, int offset)
    {
        if ((sflag & (1 << offset)) != 0)
            return 1;
        return 0;
    }

    // 设置Int的某一位
    public static int set_int_sflag(int sflag, int offset)
    {
        return sflag | (1 << offset);
    }

    // 按位与
    public static byte byteAndOp(byte value, byte i)
    {
        return (byte)(value & i);
    }

    // 按位与
    public static int IntAndOp(int value, int i)
    {
        return (int)(value & i);
    }

    // 获取当前运行平台
    public static int platform
    {
        get { return (int)Application.platform; }
    }

    // 是否移动平台
    public static bool isMobilePlatform
    {
        get { return Application.isMobilePlatform; }
    }

    // 操作系统名称
    public static string operatingSystem
    {
        get { return SystemInfo.operatingSystem; }
    }

    // 设备唯一标示
    public static string deviceUniqueIdentifier
    {
        get { 
            //if ( Application.platform == RuntimePlatform.IPhonePlayer )
            //{

            //}
            //else
            //{
                return SystemInfo.deviceUniqueIdentifier;
            //}
        }
    }

    // 设备型号
    public static string deviceModel
    {
        get { return SystemInfo.deviceModel; }
    }

    public static int systemLanguage
    {
        get { return (int)(Application.systemLanguage); }
    }

    /// <summary>
    /// 获取点击 点中的UI 对象
    /// </summary>
    /// <returns></returns>
    public static bool IsPointerOverUIObject(string objectName)
    {
        Vector2 touchPos = Input.mousePosition;
        if (isMobilePlatform)
        {
            if (Input.touchCount > 0)
                touchPos = Input.touches[0].position;
        }

        PointerEventData eventDataCurrentPosition = new PointerEventData(EventSystem.current);
        eventDataCurrentPosition.position = new Vector2(touchPos.x, touchPos.y);

        List<RaycastResult> results = new List<RaycastResult>();
        EventSystem.current.RaycastAll(eventDataCurrentPosition, results);

        foreach (var v in results)
        {
            if (v.gameObject.name == objectName)
            {
                return true;
            }
        }
        return false;
    }

    /*
     * 获取当前文本空间的 单个英文字符的宽度
     */
    public static int GetCharacterWidth(UnityEngine.UI.Text text)
    {
        CharacterInfo info;
        text.font.RequestCharactersInTexture(".", text.fontSize, FontStyle.Normal);
        text.font.GetCharacterInfo('.', out info, text.fontSize);

        return info.advance;
    }

    /// <summary>
    /// 判断字符是否是emoji表情
    /// </summary>
    /// <param name="codePoint"></param>
    /// <returns></returns>
    public static bool IsEmojiCharacter(char codePoint)
    {
        return !((codePoint == 0x0) || (codePoint == 0x9) || (codePoint == 0xA)
                || (codePoint == 0xD)
                || ((codePoint >= 0x20) && (codePoint <= 0xD7FF))
                || ((codePoint >= 0xE000) && (codePoint <= 0xFFFD)));
    }

    /// <summary>
    /// 获取时间格式串
    /// </summary>
    /// <param name="second"></param>
    /// <returns></returns>
    public static string GetTimeFormat(int second)
    {
        int day = second / 86400;
        int hour = (second / 3600) % 24;
        int min = (second / 60) % 60;
        int sec = (second % 60);

        StringBuilder builder = new StringBuilder();

        if (day > 0)
        {
            builder.Append(string.Format("{0}d", day));
            if (hour > 0)
            {
                builder.Append(string.Format(" {0}h", hour));
            }
            if (min > 0)
            {
                builder.Append(string.Format(" {0}m", min));
            }
            return builder.ToString();
        }
        if (hour > 0)
        {
            builder.Append(string.Format("{0}h", hour));
            if (min > 0)
            {
                builder.Append(string.Format(" {0}m", min));
            }
            if (sec > 0)
            {
                builder.Append(string.Format(" {0}s", sec));
            }
            return builder.ToString();
        }
        if (min > 0)
        {
            builder.Append(string.Format("{0}m", min));
            if (sec > 0)
            {
                builder.Append(string.Format(" {0}s", sec));
            }
            return builder.ToString();
        }
        builder.Append(string.Format("{0}s", sec));
        return builder.ToString();
    }

    public static int GetMillisecond()
    {
        return DateTime.Now.Millisecond;
    }

    public static string StringFormat( string text, params object[] args )
    {
        return string.Format( text, args );
    }

    public static Vector2 ScreenPointToLocalPointInRectangle(RectTransform rect, Vector2 screenPoint, Camera cam )
    {
        Vector2 point;
        RectTransformUtility.ScreenPointToLocalPointInRectangle( rect, screenPoint, cam, out point );

        return point;
    }
    
    public static string[] GetFiles( string path )
    {
        return Directory.GetFiles( path );
    }

    public static int GetFilesNum( string path )
    {
        return Directory.GetFiles( path ).Length;
    }

    public static string FileTimeString( string filename )
    {
        return File.GetLastWriteTime( filename ).ToString("yyyy-MM-dd HH:mm:ss");
    }

    public static double FileTimeInt( string filename )
    {
        return (File.GetLastWriteTime( filename )- DateTime.MinValue).TotalSeconds;
    }

    public static int FileSize( string filename )
    {
        FileInfo f = new FileInfo( filename );
        return (int)f.Length;
    }

    public static void ChangeLayer( Transform trans, int layer )
    {
        trans.gameObject.layer = layer;
        foreach( Transform child in trans )
        {
            ChangeLayer( child, layer );
        }
    }

    /// <summary>
    /// 获取UI显示大小
    /// </summary>
    public static float GetPreferredSize(RectTransform rect,int axis)
    {
        return LayoutUtility.GetPreferredSize(rect, axis);
    }

    static List<string> s_MaskWord = null;
    public static void MaskWordInit()
    {
        if( s_MaskWord == null )
        {
            s_MaskWord = new List<string>();

            TableHandler objectTable = new TableHandler();
            objectTable.OpenFromData( "MaskWord.txt" );
            for ( int row = 0; row < objectTable.GetRecordsNum(); row++ )
            {
                string word = objectTable.GetValue( row, 0 );
                if( word != "" )
                    s_MaskWord.Add( word );
            }
        }
    }

    // 处理屏蔽字
    public static string MaskWordProcess( string str )
    {
        if( str == null )
            return "";

        if( str == "" )
            return str;

        if( s_MaskWord == null )
            MaskWordInit();

        // 替换为*
        foreach( string word in s_MaskWord )
        {
            if ( str.Contains( word ) )    
            {
                int lg = word.Length;
                string sg = "";
                for( int i = 0; i < lg; i++ )
                {
                    sg+="*";
                }
                str = str.Replace( word, sg );
            }
        }

        return str;
    }

    // 检查屏蔽字
    public static bool MaskWordCheck( string str )
    {
        if( str == null )
            return false;

        if( str == "" )
            return true;

        if( s_MaskWord == null )
            MaskWordInit();
        
        // 是否有屏蔽字
        foreach( string word in s_MaskWord )
        {
            if ( str.Contains( word ) )    
            {
                return false;
            }
        }

        return true;
    }

    public static int MemSize()
    {
        return UnityEngine.SystemInfo.systemMemorySize;
    }
}
