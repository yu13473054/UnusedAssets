using System;
using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEditor.SceneManagement;
using System.IO;
using System.Text.RegularExpressions;
using Spine.Unity;
using Debug = UnityEngine.Debug;
using Object = UnityEngine.Object;

public delegate void VoidDelegateIntInt(int i, int j);
public delegate void VoidDelegateIntIntInt(int i, int j, int k);

class ResData
{
    public string name;
    public Object obj;
    public Type type;

    public ResData(string name, Type type)
    {
        this.name = name;
        this.type = type;
    }
}

public class AppearanceEditor : EditorWindow
{
    [MenuItem("Tools/预览换装 _F4", false)]
    public static void ShowWindow()
    {
        AppearanceEditor window = GetWindow(typeof(AppearanceEditor)) as AppearanceEditor;

        int width = 400;
        int height = 850;
        int screen_widht = 1920;
        int screen_height = 1080;
        int x = (screen_widht - width) / 2;
        int y = (screen_height - height) / 2;
        window.position = new Rect(x, y, width, height);

        window.InitData();
    }

    Dictionary<string, ResData[]> partDic = new Dictionary<string, ResData[]>();
    Regex regex = new Regex("\\d+");

    public void InitData()
    {
        partDic["头部"] = new[] { new ResData("头发", typeof(AtlasAsset)), new ResData("发饰", typeof(Sprite)) };
        partDic["表情"] = new[] { new ResData("表情", typeof(AtlasAsset)) };
        partDic["上衣"] = new[] { new ResData("上衣", typeof(AtlasAsset)), new ResData("武器", typeof(Sprite)) };
        partDic["背饰"] = new[] { new ResData("背饰", typeof(AtlasAsset)) };
        partDic["下衣"] = new[] { new ResData("下衣", typeof(AtlasAsset)), new ResData("丝袜", typeof(Sprite)), new ResData("鞋子", typeof(Sprite)) };
        partDic["尾巴"] = new[] { new ResData("尾巴", typeof(AtlasAsset)) };
    }

    void OnEnable()
    {
        InitData();
    }

    void OnGUI()
    {
        GUI.skin.font = null;

        if (!EditorApplication.isPlaying)
        {
            GUIStyle style = new GUIStyle(GUI.skin.label);
            style.fontSize = 30;
            style.alignment = TextAnchor.MiddleCenter;
            EditorGUILayout.LabelField("请先运行游戏再设置数据", style, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(true));
            return;
        }

        EditorGUILayout.BeginVertical();
        foreach (KeyValuePair<string, ResData[]> pair in partDic)
        {
            EditorGUILayout.BeginVertical("Box");
            EditorGUILayout.PrefixLabel(pair.Key);
            EditorGUILayout.BeginVertical("Box");
            float oldWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = GUI.skin.label.CalcSize(new GUIContent("穿戴")).x + 20;

            foreach (ResData str in pair.Value)
            {
                EditorGUILayout.BeginHorizontal();
                EditorGUILayout.PrefixLabel(str.name);
                str.obj = EditorGUILayout.ObjectField(str.obj, str.type, false);
                EditorGUILayout.EndHorizontal();
            }
            EditorGUIUtility.labelWidth = oldWidth;
            EditorGUILayout.EndVertical();
            EditorGUILayout.EndVertical();
            EditorGUILayout.Space();
        }

        if (GUILayout.Button("预览"))
        {
            Preview();
        }
        EditorGUILayout.EndVertical();

    }

    void Preview()
    {
        Debug.Log(Application.isPlaying + "    " + EditorApplication.isPlaying);
        if (!EditorApplication.isPlaying)
        {
            Debug.LogError("请先运行游戏!");
            return;
        }

        GameObject rootGo = GameObject.Find("root");
        if (!rootGo)
        {
            Debug.LogError("缺少骨架！！把骨架信息拖到Hierarchy中");
            return;
        }

        //添加管理器
        RoleGenerateManager manager = rootGo.GetComponent<RoleGenerateManager>();
        if (!manager)
        {
            rootGo.AddComponent<RoleGenerateManager>();
        }

        //添加生成组件
        RoleGenerator generator = rootGo.GetComponent<RoleGenerator>();
        if (generator)
        {
            DestroyImmediate(generator);
        }
        generator = rootGo.AddComponent<RoleGenerator>();

        //----------解析各个部件的ID
        int headID = ParserID(partDic["头部"][0]);//头部ID
        int hairDecorationID = ParserID(partDic["头部"][1]); //发饰
        int faceID = ParserID(partDic["表情"][0]); //表情
        int clothID = ParserID(partDic["上衣"][0]); //上衣
        int weaponID = ParserID(partDic["上衣"][1]); //武器
        int bagID = ParserID(partDic["背饰"][0]); //背饰
        int pantsID = ParserID(partDic["下衣"][0]); //下衣
        int stockingsID = ParserID(partDic["下衣"][1]); //丝袜
        int shoesID = ParserID(partDic["下衣"][2]); //鞋子
        int tailID = ParserID(partDic["尾巴"][0]); //尾巴

        generator.InitPartResID(headID, hairDecorationID, faceID, 0, clothID, weaponID, bagID, pantsID, stockingsID, shoesID, tailID);

        generator.SetAnimation("IDLE");
    }

    int ParserID(ResData resData)
    {
        int ID = 0;
        if (resData.obj == null) return ID;
        string resName = resData.obj.name;
        ID = Convert.ToInt32(regex.Match(resName).Value);
        return ID;
    }

    public static void CalcLableWith(string label)
    {
        var textDimensions = GUI.skin.label.CalcSize(new GUIContent(label));
        EditorGUIUtility.labelWidth = textDimensions.x;
    }

    public static string TextField(string label, string text)
    {
        CalcLableWith(label);
        return EditorGUILayout.TextField(label, text);
    }

}
