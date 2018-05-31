using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public class RegexTool : EditorWindow {

    [MenuItem("Tools/正则表达式测试",false, 1000)]
    static void ShowWindow()
    {
        RegexTool window = GetWindow<RegexTool>();
    }

    private const int DefaultFontSize = 13;

    private string _inputStr;
    private string _regexStr;
    private string _outStr;

    void OnGUI()
    {
        GUI.skin.label.fontSize = DefaultFontSize;
        GUI.skin.textArea.fontSize = DefaultFontSize;
        GUI.skin.textField.fontSize = DefaultFontSize;

        EditorGUILayout.BeginVertical("Box");

        EditorGUILayout.BeginVertical("Box");
        GUILayout.Label("输入字符串：");
        _inputStr = EditorGUILayout.TextArea(_inputStr,GUILayout.Height(100));
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical("Box");
        GUILayout.Label("正则表达式：");
        _regexStr = EditorGUILayout.TextField(_regexStr, GUILayout.Height(DefaultFontSize+5));
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical("Box");
        GUILayout.Label("匹配结果：");
        _outStr = EditorGUILayout.TextArea(_outStr, GUILayout.Height(100));
        EditorGUILayout.EndVertical();

        if (GUILayout.Button("验证"))
        {
            if (!string.IsNullOrEmpty(_regexStr) && !string.IsNullOrEmpty(_inputStr))
            {
                Regex re = new Regex(_regexStr);
                MatchCollection matchCollection = re.Matches(_inputStr);
                _outStr = "";
                foreach (Match match in matchCollection)
                {
                    _outStr += match.Value+"\n";
                }
                if (!string.IsNullOrEmpty(_outStr))
                {
                    _outStr = _outStr.Remove(_outStr.Length-1);
                }
                GUI.FocusControl("");
            }
        }

        EditorGUILayout.EndVertical();
    }

}
