using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.Xml;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;
using Object = UnityEngine.Object;


public class CustomFontMaker : Editor
{
    [MenuItem("Assets/Create/BMFont",false,610)]
    static void CreateFont()
    {
        Object obj = Selection.activeObject;
        string fntPath = AssetDatabase.GetAssetPath(obj);
        if (!fntPath.EndsWith(".fnt"))
        {
            // 不是字体文件 
            Debug.LogError("请选择.fnt文件");
            return;
        }

        //创建对应的material
        string fontMaterialPath = fntPath.Replace(".fnt", ".mat");
        Material material = AssetDatabase.LoadAssetAtPath<Material>(fontMaterialPath);
        if (!material)
        {
            material = new Material(Shader.Find("GUI/Text Shader"));
            AssetDatabase.CreateAsset(material, fontMaterialPath);
            AssetDatabase.Refresh();
        }
        //创建font
        string customFontPath = fntPath.Replace(".fnt", ".fontsettings");
        Font customFont = AssetDatabase.LoadAssetAtPath<Font>(customFontPath);
        if (!customFont)
        {
            customFont = new Font();
            AssetDatabase.CreateAsset(customFont, customFontPath);
            AssetDatabase.Refresh();
        }
        customFont.material = material;

        StreamReader reader = new StreamReader(new FileStream(fntPath, FileMode.Open));
        List<CharacterInfo> charList = new List<CharacterInfo>();

        Regex reg = new Regex(@"char id=(?<id>\d+)\s+x=(?<x>\d+)\s+y=(?<y>\d+)\s+width=(?<width>\d+)\s+height=(?<height>\d+)\s+xoffset=(?<xoffset>(-|\d)+)\s+yoffset=(?<yoffset>(-|\d)+)\s+xadvance=(?<xadvance>\d+)\s+");
        string line = reader.ReadLine();
        int scaleW = 512;
        int scaleH = 512;

        while (line != null)
        {
            if (line.IndexOf("char id=") != -1)
            {
                Match match = reg.Match(line);
                if (match != Match.Empty)
                {

                    var id = System.Convert.ToInt32(match.Groups["id"].Value);
                    var x = System.Convert.ToInt32(match.Groups["x"].Value);
                    var y = System.Convert.ToInt32(match.Groups["y"].Value);
                    var width = System.Convert.ToInt32(match.Groups["width"].Value);
                    var height = System.Convert.ToInt32(match.Groups["height"].Value);
                    var xoffset = System.Convert.ToInt32(match.Groups["xoffset"].Value);
                    var yoffset = System.Convert.ToInt32(match.Groups["yoffset"].Value);
                    var xadvance = System.Convert.ToInt32(match.Groups["xadvance"].Value);

                    CharacterInfo info = new CharacterInfo();
                    info.index = id;
                    float uvx = 1f * x / scaleW;  
                    float uvy = 1 - 1f * y / scaleH;  
                    float uvw = 1f * width / scaleW;  
                    float uvh = 1f * height / scaleH;
                    info.uvBottomLeft = new Vector2(uvx, uvy);  
                    info.uvBottomRight = new Vector2(uvx + uvw, uvy);  
                    info.uvTopLeft = new Vector2(uvx, uvy - uvh);  
                    info.uvTopRight = new Vector2(uvx + uvw, uvy - uvh);  

                    info.minX = xoffset;  
                    info.minY = yoffset;   
                    info.maxX = width;  
                    info.maxY = -height; 
                    info.advance = xadvance + 3;  
                    charList.Add(info);
                }
            }
            else if (line.IndexOf("scaleW=", StringComparison.Ordinal) != -1)
            {
                Regex reg2 = new Regex(@"common lineHeight=(?<lineHeight>\d+)\s+.*scaleW=(?<scaleW>\d+)\s+scaleH=(?<scaleH>\d+)");
                Match match = reg2.Match(line);
                if (match != Match.Empty)
                {
                    scaleW = System.Convert.ToInt32(match.Groups["scaleW"].Value);
                    scaleH = System.Convert.ToInt32(match.Groups["scaleH"].Value);
                }
            }
            else if (line.IndexOf("file=", StringComparison.Ordinal) != -1)
            {
                Regex reg2 = new Regex("page id=(?<id>\\d+)\\s+file=\\\"(?<file>.*)\\\"");
                Match match = reg2.Match(line);
                if (match != Match.Empty)
                {
                    string fileName = match.Groups["file"].Value;
                    string fntName = Selection.activeObject.name + ".fnt";
                    string texPath = fntPath.Replace(fntName, fileName);
                    Texture texture = AssetDatabase.LoadAssetAtPath<Texture>(texPath);
                    material.mainTexture = texture;
                }
            }
            line = reader.ReadLine();
        }
        reader.Close();
        customFont.characterInfo = charList.ToArray();
        AssetDatabase.DeleteAsset(fntPath);
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("创建Custom Font成功！");
    }
}