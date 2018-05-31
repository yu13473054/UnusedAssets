using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.UI;
using UnityEngine;

[CustomEditor(typeof(UIToggle),true)]
[CanEditMultipleObjects]
public class UIToggleEditor : ToggleEditor {
    private SerializedProperty _UIModProperty;
    private SerializedProperty _controlIDProperty;
    private SerializedProperty _audioIdProperty;

    protected override void OnEnable()
    {
        base.OnEnable();
        _UIModProperty = serializedObject.FindProperty("uiMod");
        _controlIDProperty = serializedObject.FindProperty("controlID");
        _audioIdProperty = serializedObject.FindProperty("audioId");
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.PropertyField(_UIModProperty);
        EditorGUILayout.PropertyField(_controlIDProperty);
        EditorGUILayout.PropertyField(_audioIdProperty);

        serializedObject.ApplyModifiedProperties();

        base.OnInspectorGUI();
    }
}
