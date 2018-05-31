using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;
/// <summary>
/// 表格读取工具
/// </summary>
public class TableHandler
{
    /// <summary>
    /// 行数
    /// </summary>
    private int _recordsNum;

    /// <summary>
    /// 列数
    /// </summary>
    private int _fieldsNum;

    /// <summary>
    /// 数据区
    /// </summary>
    List<string> _dataBuf;

    /// <summary>
    /// 表格的列
    /// </summary>
    string[] _columns;

    private string _fileName = "";

    /// <summary>
    /// 构造
    /// </summary>
    public TableHandler()
    {
        _recordsNum = 0;
        _fieldsNum = 0;
        _dataBuf = new List<string>();
    }

    /// <summary>
    /// 打开TXT文件
    /// </summary>
    public bool OpenFromData( string fileName )
    {
        _fileName = fileName;

        if (AppConst.resourceMode == 2) //数据从外部读，其他的资源从AB获取
        {
            byte[] bytes = FileUtil.GetDataFromFile(System.Environment.CurrentDirectory + "/Data/" + fileName);
            if (bytes == null)
            {
                Debug.LogErrorFormat("<TableHandler> {0}中不存在文件{1}", System.Environment.CurrentDirectory + "/Data/", fileName);
                return false;
            }
            return OpenFromMemory(bytes);
        }
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
        _fileName = fileName;
        byte[] fileData = FileUtil.GetDataFromFile( _fileName );
        if ( fileData == null )
            return false;

        return OpenFromMemory( fileData );
    }

    /// <summary>
    /// 解析内存数据
    /// </summary>
    public bool OpenFromMemory( string content )
    {
        // 拆分得到每行的内容
        content = content.Replace( "\r\n", "\n" );
        string[] lineArray = content.Split( new char[] { '\n' }, StringSplitOptions.RemoveEmptyEntries );
        if( lineArray.Length < 1 )
            return false;

        // 分解第一行
        string[] strArray = lineArray[0].Split( new char[] { '\t' } );
        int recordsNum = 0;
        int fieldsNum = strArray.Length;
        _columns = new string[fieldsNum];
        Array.Copy( strArray, _columns, fieldsNum );

        // 遍历余下行数
        for( int i = 1; i < lineArray.Length; ++i )
        {
            if( lineArray[i].Length == 0 )
                break;

            strArray = lineArray[i].Split( new char[] { '\t' } );

            // 是不是有内容
            if( strArray.Length == 0 )
                break;

            if( strArray[0].Length == 0 )
                break;

            if( strArray[0][0] == '\0' )
                break;

            // 是不是注释行
            if( strArray[0][0] == '#' )
                continue;
            // 填充数据区
            for( int n = 0; n < fieldsNum; ++n )
            {
                _dataBuf.Add( strArray[n] );
            }

            ++recordsNum;
        }

        // 记录相关信息
        _recordsNum = recordsNum;
        _fieldsNum = fieldsNum;
        return true;
    }
    public bool OpenFromMemory( byte[] memory )
    {
        string content = StringUtil.ByteToString( memory );
        return OpenFromMemory( content );
    }

    /// <summary>
    /// 取数据
    /// </summary>
    /// <param name="recordLine">从0开始</param>
    /// <param name="columNum">从0开始</param>
    /// <returns></returns>
    public string GetValue( int recordLine, int columNum )
    {
#if UNITY_EDITOR
        try
        {
            int position = recordLine * _fieldsNum + columNum;

            if ( position < 0 || position > _dataBuf.Count )
            {
                string error = string.Format( "Invalid search request : recordLine:{0} columNum:{1}", recordLine, columNum );
                System.Diagnostics.Debug.Assert( false, error );
                throw new Exception( error );
            }

            return _dataBuf[position];
        }
        catch ( Exception ex )
        {
            System.Diagnostics.Debug.Assert( false, string.Format( "文件:{0} 读取出现异常:{1}", _fileName, ex.Message ) );
            return "";
        }
#else
        int position = recordLine * _fieldsNum + columNum;

            if (position < 0 || position > _dataBuf.Count)
            {
                string error = string.Format("Invalid search request : recordLine:{0} columNum:{1}", recordLine, columNum);
                System.Diagnostics.Debug.Assert(false, error);
                throw new Exception(error);
            }

            return _dataBuf[position];
#endif


    }
    /// <summary>
    /// 获取列
    /// </summary>
    /// <param name="columnNum"></param>
    /// <returns></returns>
    public string GetColumn( int columnNum )
    {
        return _columns[columnNum];
    }
    /// <summary>
    /// 获取记录数
    /// </summary>
    public int GetRecordsNum()
    {
        return _recordsNum;
    }

    /// <summary>
    /// 获取列数
    /// </summary>
    public int GetFieldsNum()
    {
        return _fieldsNum;
    }

}