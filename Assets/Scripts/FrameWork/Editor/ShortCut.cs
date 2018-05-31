using UnityEngine;
using UnityEngine.SceneManagement;
using System.IO;
using UnityEditor;

public class ShortCut
{
    [MenuItem("Tools/暂停 _F1")]
    static void Pause()
    {
        EditorApplication.ExecuteMenuItem("Edit/Pause");
    }    

    [MenuItem("Tools/重启 _F5")]
    static void Reboot()
    {
        SceneManager.LoadScene("Game");
    }

    [MenuItem("Tools/手动释放内存 _F6")]
    static void UnloadUnusedAssets()
    {
        Resources.UnloadUnusedAssets();
    }

    [MenuItem("Tools/GC _F7")]
    static void GC()
    {
        System.GC.Collect();
    }

    [MenuItem("Tools/打开缓存目录 _F12")]
    static void OpenPersistentDataPath()
    {
        string path = Application.persistentDataPath;
#if UNITY_EDITOR_WIN
        string winPath = path.Replace("/", "\\"); // windows explorer doesn't like forward slashes
        System.Diagnostics.Process.Start("explorer.exe", ("/root,") + winPath);
#endif
#if UNITY_EDITOR_OSX
        string macPath = path.Replace("\\", "/"); // mac finder doesn't like backward slashes

        if ( !macPath.StartsWith("\"") )
		{
			macPath = "\"" + macPath;
		}
 
		if ( !macPath.EndsWith("\"") )
		{
			macPath = macPath + "\"";
		}
 
		string arguments = ("") + macPath;
        System.Diagnostics.Process.Start("open", arguments);
#endif
    }
}
