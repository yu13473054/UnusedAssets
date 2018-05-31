using UnityEngine;
using UnityEditor;
using UnityEditor.UI;
using System.Collections;

[CustomEditor(typeof(UIText))]
[CanEditMultipleObjects]
public class UITextEditor : UnityEditor.UI.TextEditor
{
    private SerializedProperty _localizationIDProperty;
    private float _lastFontSize;
    private int _lastTextID = 0;

    protected override void OnEnable()
    {
        base.OnEnable();
        _localizationIDProperty = serializedObject.FindProperty("localizationID");
    }

    public override void OnInspectorGUI()
    {
        UIText txt = target as UIText;
        int localizeID = _localizationIDProperty.intValue;
        EditorGUILayout.PropertyField(_localizationIDProperty);
        if (_lastTextID != localizeID)
        {
            if (txt != null)
            {
                _lastTextID = localizeID;

                Localization.Init();
                string dataText = Localization.Get(localizeID);
                if (!string.IsNullOrEmpty(dataText))
                {
                    txt.text = dataText;
                }
            }
        }
        if (txt.resizeTextForBestFit)
        {
            if (_lastFontSize != txt.fontSize)
            {

                txt.resizeTextMaxSize = txt.fontSize;
                _lastFontSize = txt.fontSize;
            }
        }
        this.serializedObject.ApplyModifiedProperties();
        base.OnInspectorGUI();
	}
}
