using UnityEngine;
using UnityEditor;
using UnityEditor.UI;
using System.Collections;

[CustomEditor(typeof(UIScrollView))]
[CanEditMultipleObjects]
public class UIScrollViewEditor : ScrollRectEditor
{
    private SerializedProperty _UIModProperty;
    private SerializedProperty _controlIDProperty;
    private SerializedProperty _constractDragOnFitProperty;
    private SerializedProperty _alignToProperty;
    private SerializedProperty _alignTargetProperty;
    private SerializedProperty _alignItemIndexProperty;
    private SerializedProperty _forceClampProperty;

    protected override void OnEnable()
    {
        base.OnEnable();
        _UIModProperty = serializedObject.FindProperty("uiMod");
        _controlIDProperty = serializedObject.FindProperty("controlID");
        _constractDragOnFitProperty = serializedObject.FindProperty("constractDragOnFit");
        _alignToProperty = serializedObject.FindProperty("alignTo");
        _alignTargetProperty = serializedObject.FindProperty("alignTarget");
        _alignItemIndexProperty = serializedObject.FindProperty("_alignItemIndex");
        _forceClampProperty = serializedObject.FindProperty("_forceClamp");
    }

    public override void OnInspectorGUI()
    {
        EditorGUILayout.PropertyField(_UIModProperty);
        EditorGUILayout.PropertyField(_controlIDProperty);

        serializedObject.ApplyModifiedProperties();

        base.OnInspectorGUI();

        EditorGUILayout.PropertyField(_constractDragOnFitProperty);

	    ItemAlignTo alignType = (ItemAlignTo)_alignToProperty.enumValueIndex;
        EditorGUILayout.PropertyField(_alignToProperty);

        ++EditorGUI.indentLevel;
	    if (alignType != ItemAlignTo.None)
	    {
            if (alignType == ItemAlignTo.Target)
	        {
                EditorGUILayout.PropertyField(_alignTargetProperty);
                EditorGUILayout.PropertyField(_alignItemIndexProperty);
                EditorGUILayout.PropertyField(_forceClampProperty);
            }
	    }
        --EditorGUI.indentLevel;

        serializedObject.ApplyModifiedProperties();
	}
}
