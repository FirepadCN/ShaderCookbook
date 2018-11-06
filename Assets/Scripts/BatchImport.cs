#if UNITY_EDITOR
using UnityEngine;
using System.Collections;
using System.IO;
using UnityEditor;

public class BatchImport : Editor
{
    public static string mPath = "D:/";

    [MenuItem("Tools/BatchImporter")]
    public static void BatchImportr()
    {
        mPath = EditorUtility.OpenFolderPanel("选择批量导入的文件夹", mPath, "");
        string[] files = Directory.GetFiles(mPath);
        foreach (var file in files)
        {
            AssetDatabase.ImportPackage(file,false);
        }
    }
}

#endif
