using UnityEngine;
using UnityEditor;
using UnityEditor.UI;
using System.Collections;

[CustomEditor(typeof(UIButton))]
[CanEditMultipleObjects]
public class UIButtonEditor : ButtonEditor
{
    private SerializedProperty _UIModProperty;
    private SerializedProperty _controlIDProperty;
    private SerializedProperty _clickIntervalProperty;
    private SerializedProperty _audioIdProperty;

    protected override void OnEnable()
    {
        base.OnEnable();
        _UIModProperty = serializedObject.FindProperty("uiMod");
        _controlIDProperty = serializedObject.FindProperty("controlID");
        _clickIntervalProperty = serializedObject.FindProperty("clickInterval");
        _audioIdProperty = serializedObject.FindProperty("audioId");
    }

    public override void OnInspectorGUI(){
        EditorGUILayout.PropertyField(_UIModProperty);
        EditorGUILayout.PropertyField(_controlIDProperty);
        EditorGUILayout.PropertyField(_clickIntervalProperty);
        EditorGUILayout.PropertyField(_audioIdProperty);

        serializedObject.ApplyModifiedProperties();

        base.OnInspectorGUI();
	}
}
