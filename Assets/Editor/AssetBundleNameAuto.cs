using UnityEngine;
using System.Collections;
using System.IO;
using System.Collections.Generic;
using UnityEditor;
using UnityEditorInternal;
public class AssetBundleNameAuto
{
    enum BundleType
    {
        FOLDER,             // 当前目录(一般用于图片，或其他不常修改资源，新增时新起文件夹)  *Assetbundle名字为目录名称
        FOLDER_FOLDER,      // 目录内的所有目录(一般用于特效等，模块化的资源) *Assetbundle名字为子目录名称
        FOLDER_ALL,         // 目录内的所有文件(一般用于prefab) *Assetbundle名字为文件名称
    }

    struct AssetBundlePath
    {
        public BundleType type;
        public string path;
        public string prefix;

        public AssetBundlePath( BundleType type, string path, string prefix = "" )
        {
            this.type = type;
            this.path = path;
            this.prefix = prefix;
        }
    }

    static AssetBundlePath[] _AssetBundlePathList = new AssetBundlePath[]
    {
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Atlas" ,"atlas_"),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/AtlasCommon" ,"cm_"),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/FX" ,"fx_"),
        new AssetBundlePath( BundleType.FOLDER_ALL, "Assets/Res/Sprites" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/SpritesGroup" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Icon" , "icon_"),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Audio" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Font" ),
        new AssetBundlePath( BundleType.FOLDER_ALL, "Assets/Res/Prefab/UI" ),
        new AssetBundlePath( BundleType.FOLDER_ALL, "Assets/Res/Prefab/FightScene" ),
        new AssetBundlePath( BundleType.FOLDER_ALL, "Assets/Res/Prefab/Scene" ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/Prefab/Fight" ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/AssetsUpdate" ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/Shader" ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/Materials" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Char", "char_" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Spine", "spine_" ),
        new AssetBundlePath( BundleType.FOLDER_ALL, "Assets/Res/Char_Sprite/Role" ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/Char_Sprite/Card" , "char_" ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/Char_Sprite/Head", "char_"  ),
        new AssetBundlePath( BundleType.FOLDER, "Assets/Res/Char_Sprite/Portrait", "char_" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Char_Equipment/Atlas", "char_equipment_atlas_" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Char_Equipment/PartSpine", "char_equipment_part_" ),
        new AssetBundlePath( BundleType.FOLDER_FOLDER, "Assets/Res/Char_Equipment/RootSpine", "char_equipment_root_" ),
        new AssetBundlePath( BundleType.FOLDER_ALL, "Assets/Res/Char_Equipment/Sprite", "char_equipment_sp_" ),
    };

    [MenuItem( "Builder/设置所有AssetBundleName", false, 201 )]
	public static void AssetBundleSetNames()
	{
        // 开始设置
        for( int i = 0; i < _AssetBundlePathList.Length; i++ )
        {
            switch( _AssetBundlePathList[i].type )
            {
                case BundleType.FOLDER:
                    AssetBundleSetFolder( _AssetBundlePathList[i] );
                    break;
                case BundleType.FOLDER_FOLDER:
                    AssetBundleSetFolderFolder( _AssetBundlePathList[i] );
                    break;
                case BundleType.FOLDER_ALL:
                    AssetBundleSetFolderAll( _AssetBundlePathList[i] );
                    break;
            }
        }

        // 清理无用名称
        AssetDatabase.RemoveUnusedAssetBundleNames();
    }

    // 单个目录
    static void AssetBundleSetFolder( AssetBundlePath abPath )
    {
        string path = abPath.path;

        AssetImporter importer = AssetImporter.GetAtPath ( path );
        string[] strs = path.Split( '/' );
        string prefix = strs[ strs.Length - 2 ];
        string name = strs[ strs.Length - 1 ];
        if ( prefix == "Tiled2Unity" )
        {
            name = "Tiled2Unity_" + name;
        }
        if( importer == null )
        {
            Debug.LogError( "No Importer:" + name );
        }
        importer.assetBundleName = abPath.prefix + name.ToLower();

        AssetBundleClearName( path );
    }

    // 所有目录
    static void AssetBundleSetFolderFolder( AssetBundlePath abPath )
    {
        string path = abPath.path;

		DirectoryInfo raw = new DirectoryInfo( path );

        // 拿所有文件
        DirectoryInfo[] directory = raw.GetDirectories();
		foreach ( DirectoryInfo dir in directory )
		{
            if( dir.Name == ".svn" )
                continue;
			AssetImporter importer = AssetImporter.GetAtPath ( path + "/" + dir.Name );
            importer.assetBundleName = abPath.prefix + dir.Name.ToLower();

            AssetBundleClearName( path + "/" + dir.Name );
		}
    }

    // 所有文件
    static void AssetBundleSetFolderAll( AssetBundlePath abPath )
    {
        string path = abPath.path;

		DirectoryInfo raw = new DirectoryInfo( path );

        // 拿所有文件
        FileInfo[] files = raw.GetFiles( "*", SearchOption.AllDirectories );
		foreach ( FileInfo file in files )
		{
			// 文件跳过
            if( file.Directory.Name == ".svn" || file.Directory.Parent.Name == ".svn" || file.Directory.Parent.Parent.Name == ".svn" ||
                    file.Extension == ".meta" || file.Extension == ".cs" || file.Extension == ".js" )
                continue;

            string name = file.Name.Replace( file.Extension, "" );
            path = file.FullName.Substring( file.FullName.IndexOf( "Assets" ) ).Replace( "\\", "/" );
            
			AssetImporter importer = AssetImporter.GetAtPath ( path );
            if( importer == null )
            {
                Debug.LogError( "No Importer:" + path );
                break;
            }
            importer.assetBundleName = abPath.prefix + name.ToLower();
		}
    }

    // 清除路径下所有AssetBundleName
    static void AssetBundleClearName( string path )
    {
		DirectoryInfo raw = new DirectoryInfo( path );

        // 拿所有文件
        FileInfo[] files = raw.GetFiles( "*", SearchOption.AllDirectories );
		foreach ( FileInfo file in files )
		{
			// 文本文件跳过
            if( file.Extension == ".meta" || file.Extension == ".cs" || file.Extension == ".js" )
                continue;

            path = file.FullName.Substring( file.FullName.IndexOf( "Assets" ) ).Replace( "\\", "/" );
            
			AssetImporter importer = AssetImporter.GetAtPath ( path );
            if( importer != null )
            {
                importer.assetBundleName = "";
            }
		}
        

        // 拿所有文件夹
        DirectoryInfo[] dirs = raw.GetDirectories( "*", SearchOption.AllDirectories );
		foreach ( DirectoryInfo dir in dirs )
		{
            path = dir.FullName.Substring( dir.FullName.IndexOf( "Assets" ) ).Replace( "\\", "/" );
            
			AssetImporter importer = AssetImporter.GetAtPath ( path );
            if( importer != null )
            {
                importer.assetBundleName = "";
            }
		}
    }

    // 清除所有名字
    [MenuItem( "Builder/清除AssetBundleName", false, 202 )]
    static void ClearAllNames()
    {
        AssetBundleClearName( "Assets" );
    }
}
