using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class HttpClient
{
    // 进度
    private float _progress = 0;

    // 委托回调
    public delegate void ResponseDelegate( int error, string response );

    //POST请求
    public IEnumerator Post( string url, Dictionary<string, string> post, ResponseDelegate responseDelegate )
    {
        //表单
        WWWForm form = new WWWForm();

        //从集合中取出所有参数，设置表单参数
        foreach( KeyValuePair<string, string> post_arg in post )
        {
            form.AddField( post_arg.Key, post_arg.Value );
        }

        //表单传值，就是post
        WWW www = new WWW( url, form );
        yield return www;

        // 进度
        _progress = www.progress;

        if( www.error != null )
        {//POST请求失败
            if( responseDelegate != null )
                responseDelegate.Invoke( 1, www.error );
        }
        else
        {//POST请求成功
            if( responseDelegate != null )
                responseDelegate.Invoke( 0, www.text );
        }
    }

    //GET请求
    public IEnumerator Get( string url, Dictionary<string, string> get, ResponseDelegate responseDelegate )
    {
        string Parameters;
        bool first;
        if( get != null && get.Count > 0 )
        {
            first = true;
            Parameters = "?";
            //从集合中取出所有参数，拼url串
            foreach( KeyValuePair<string, string> post_arg in get )
            {
                if( first )
                    first = false;
                else
                    Parameters += "&";

                Parameters += post_arg.Key + "=" + post_arg.Value;
            }
        }
        else
        {
            Parameters = "";
        }

        //直接URL传值就是get 
        WWW www = new WWW( url + Parameters );
        yield return www;

        // 进度
        _progress = www.progress;

        if( www.error != null )
        {//GET请求失败
            if( responseDelegate != null )
                responseDelegate.Invoke( 1, www.error );

        }
        else
        {//GET请求成功
            if( responseDelegate != null )
                responseDelegate.Invoke( 0, www.text );
        }
    }

    // 获取进度
    public float getProgress()
    {
        return _progress;
    }
}

