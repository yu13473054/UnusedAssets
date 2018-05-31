using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Text;

public class TextureModifier : AssetPostprocessor
{
    //不需要压缩的资源，在此处填写名字key值，越精确越好
    private readonly string[] filterKey = { "Atlas", "/Editor" };
    private readonly string[] forceModifyKey = { "DlgChapter_BackBtn", "DlgChapter_Curr" };

    bool CanModifier()
    {
#if UNITY_IOS
        for (int i = 0; i < forceModifyKey.Length; i++)
        {
            if (assetPath.Contains(filterKey[i]))
            {
                return true;
            }
        }

        for (int i = 0; i < filterKey.Length; i++)
        {
            if (assetPath.Contains(filterKey[i]))
            {
                return false;
            }
        }
        return true;
#endif
        return false;
    }

    void OnPreprocessTexture()
    {
        Debug.Log(assetPath);
        var importer = (assetImporter as TextureImporter);

        TextureImporterPlatformSettings pts = importer.GetPlatformTextureSettings("iPhone");
        if (CanModifier())
        {
            pts.overridden = true;
            pts.format = TextureImporterFormat.RGBA32;
        }
        else
        {
            pts.overridden = false;
        }
        importer.SetPlatformTextureSettings(pts);
    }

    // Floyd–Steinberg dithering实现参考：https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering
    void OnPostprocessTexture(Texture2D texture)
    {
        //剔除图集资源
        if (!CanModifier())
        {
            return;
        }

        var texw = texture.width;
        var texh = texture.height;

        var pixels = texture.GetPixels();
        var offs = 0;

        var k1Per15 = 1.0f / 15.0f;
        var k1Per16 = 1.0f / 16.0f;
        var k3Per16 = 3.0f / 16.0f;
        var k5Per16 = 5.0f / 16.0f;
        var k7Per16 = 7.0f / 16.0f;

//        StringBuilder sb = new StringBuilder();

        for (var y = 0; y < texh; y++)
        {
            for (var x = 0; x < texw; x++)
            {
                float a = pixels[offs].a;
                float r = pixels[offs].r;
                float g = pixels[offs].g;
                float b = pixels[offs].b;

                var a2 = Mathf.Clamp01(Mathf.Floor(a * 16) * k1Per15);
                var r2 = Mathf.Clamp01(Mathf.Floor(r * 16) * k1Per15);
                var g2 = Mathf.Clamp01(Mathf.Floor(g * 16) * k1Per15);
                var b2 = Mathf.Clamp01(Mathf.Floor(b * 16) * k1Per15);

                var ae = a - a2;
                var re = r - r2;
                var ge = g - g2;
                var be = b - b2;

                pixels[offs].a = a2;
                pixels[offs].r = r2;
                pixels[offs].g = g2;
                pixels[offs].b = b2;

                var n1 = offs + 1;   // (x+1,y)
                var n2 = offs + texw - 1; // (x-1 , y+1)
                var n3 = offs + texw;  // (x, y+1)
                var n4 = offs + texw + 1; // (x+1 , y+1)

                if (x < texw - 1)
                {
                    pixels[n1].a += ae * k7Per16;
                    pixels[n1].r += re * k7Per16;
                    pixels[n1].g += ge * k7Per16;
                    pixels[n1].b += be * k7Per16;
                }

                if (y < texh - 1)
                {
                    pixels[n3].a += ae * k5Per16;
                    pixels[n3].r += re * k5Per16;
                    pixels[n3].g += ge * k5Per16;
                    pixels[n3].b += be * k5Per16;

                    if (x > 0)
                    {
                        pixels[n2].a += ae * k3Per16;
                        pixels[n2].r += re * k3Per16;
                        pixels[n2].g += ge * k3Per16;
                        pixels[n2].b += be * k3Per16;
                    }

                    if (x < texw - 1)
                    {
                        pixels[n4].a += ae * k1Per16;
                        pixels[n4].r += re * k1Per16;
                        pixels[n4].g += ge * k1Per16;
                        pixels[n4].b += be * k1Per16;
                    }
                }

//                sb.Append(offs).Append("--").Append(pixels[offs]).Append("；");
                offs++;
            }
        }
//        Debug.Log(assetPath+"    "+sb);
        texture.SetPixels(pixels);
        EditorUtility.CompressTexture(texture, TextureFormat.RGBA4444, TextureCompressionQuality.Normal);
    }
}