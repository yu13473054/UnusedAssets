using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
/// <summary>
/// 表格读取工具
/// </summary>
public class ConfigHandler
{
	/// <summary>
	/// 节点值
	/// </summary>
	private Dictionary<string, string> _dict;
	private string _fileName;

    /// <summary>
    /// 构造
    /// </summary>
    public ConfigHandler()
    {
		_fileName = "";
		_dict = new Dictionary<string, string>();
    }

    /// <summary>
    /// 打开TXT文件
    /// </summary>
    public bool OpenFromData( string fileName )
    {
        _fileName = "";
        // 先尝试从更新的ab中读取。
        TextAsset asset = null;
        if( ResourceManager.instance != null )
            asset = ResourceManager.instance.LoadAsset<TextAsset>( "data", fileName );
        if ( asset == null )
        {
            // 没有就从安装包里读取
            byte[] fileData = FileUtil.GetDataFromWWW( AppConst.packageDataPath + fileName );
            if ( fileData == null )
                return false;
            return OpenFromMemory( fileData );
        }
            
        return OpenFromMemory( asset.ToString() );
    }

    /// <summary>
    /// 打开完整路径
    /// </summary>
    public bool Open( string fileName )
    {
        _dict.Clear();
		_fileName = fileName;
        byte[] fileData = FileUtil.GetDataFromFile( fileName );
        if (fileData == null)
            return false;
        return OpenFromMemory(fileData);
    }

    /// <summary>
    /// 打开TXT文件从StreamingAssets
    /// </summary>
    public bool OpenFromStreamingAssets( string fileName )
    {
        _dict.Clear();
        _fileName = Application.streamingAssetsPath + "/" + fileName;
        byte[] fileData = FileUtil.GetDataFromWWW( _fileName );
        if ( fileData == null )
            return false;
        return OpenFromMemory( fileData );
    }

    /// <summary>
    /// 解析内存数据
    /// </summary>
    public bool OpenFromMemory( byte[] memory )
    {
        string content = StringUtil.ByteToString( memory );
        return OpenFromMemory( content );
    }
    public bool OpenFromMemory( string content )
    {
		string st = null;
		int equalSignPos;
		string key, value;

		// 拆分得到每行的内容
        content = content.Replace( "\r\n", "\n" );
		string[] lineArray = content.Split(new char[] { '\n' }, StringSplitOptions.RemoveEmptyEntries);
		if (lineArray.Length < 1)
			return false;

		for ( int tmpi=0; tmpi < lineArray.Length; tmpi++ )
		{
			st = lineArray[tmpi].Trim();
			if (st == "")
				continue;
			if ( st[0] == '#' )
			{
				
			}
			else
			{                    
				//开始解析         
				equalSignPos = st.IndexOf('=');
				if (equalSignPos != 0)
				{
					key = st.Substring(0, equalSignPos);
					value = st.Substring(equalSignPos + 1, st.Length - equalSignPos - 1);
					if (_dict.ContainsKey(key))
						_dict[key] = value;
					else
						_dict.Add(key, value);
				}
				else
				{
					if (_dict.ContainsKey(st))
						_dict[st] = "";
					else
						_dict.Add(st, "");
				}              
			}                                
		}

        return true;
    }

	public void Clear()
	{
		_dict.Clear();
	}        

	// 写入一个值
	public void WriteValue(string key, object value)
	{
		if (_dict.ContainsKey(key))
			_dict[key] = value.ToString();
		else
			_dict.Add(key, value.ToString());

		string IniText="";
		foreach ( var item in _dict )
		{
			IniText = IniText + item.Key + "=" + item.Value + "\r\n";
		}
		FileUtil.WriteFile( _fileName, IniText );
	}

	// 读取一个值
	public object ReadValue(string key, string defaultv)
	{
		if (_dict.ContainsKey(key))
			return _dict[key];
		else
			return defaultv;
	}

    // 从另一个配置获得数据并保存
    public void Copy( ConfigHandler config )
    {
        string IniText = "";
        foreach( var item in config._dict )
        {
            IniText = IniText + item.Key + "=" + item.Value + "\r\n";
        }
        FileUtil.WriteFile( _fileName, IniText );
    }
}

