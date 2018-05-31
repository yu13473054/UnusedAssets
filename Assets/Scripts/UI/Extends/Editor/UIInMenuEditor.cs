using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class UIInMenuEditor {

    private static Vector2 _textSize = new Vector2(160, 30);
//    private static Vector2 _rectSize = new Vector2(100, 100);
    static Sprite standardRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UISprite.psd");
    static Sprite backgroundRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/Background.psd");
    static Sprite inputFieldRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/InputFieldBackground.psd");
    static Sprite knobRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/Knob.psd");
    static Sprite checkmarkRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/Checkmark.psd");
//    static Sprite dropdownRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/DropdownArrow.psd");
    static Sprite maskRes = AssetDatabase.GetBuiltinExtraResource<Sprite>("UI/Skin/UIMask.psd");

    [MenuItem("GameObject/UI Extends/UIText &#t", false, 10)]
    static void AddUIText(MenuCommand menuCommand)
    {
        GameObject go = new GameObject("UIText");
        UIText obj = go.AddComponent<UIText>();
        obj.rectTransform.sizeDelta = new Vector2(160, 30);
        DefaultUITextProperty(obj);
        obj.alignment = TextAnchor.MiddleCenter;

        PlaceUIElementRoot(menuCommand, go);
    }

    [MenuItem("GameObject/UI Extends/UIImage &#e", false, 11)]
    static void AddUIImage(MenuCommand menuCommand)
    {
        GameObject go = new GameObject("UIImage");
        UIImage obj = go.AddComponent<UIImage>();
        obj.raycastTarget = false;

        PlaceUIElementRoot(menuCommand, go);
    }

    [MenuItem("GameObject/UI Extends/UIRawImage &#r", false, 12)]
    static void AddUIRawImage(MenuCommand menuCommand)
    {
        GameObject go = new GameObject("UIRawImage");
        UIRawImage obj = go.AddComponent<UIRawImage>();
        obj.raycastTarget = false;

        PlaceUIElementRoot(menuCommand, go);
    }

    [MenuItem("GameObject/UI Extends/UIButton &#b", false, 13)]
    static void AddUIButton(MenuCommand menuCommand)
    {
        GameObject buttonRoot = new GameObject("UIButton");
        RectTransform rectTransform = buttonRoot.AddComponent<RectTransform>();
        rectTransform.sizeDelta = _textSize;

        UIImage image = buttonRoot.AddComponent<UIImage>();
        image.type = Image.Type.Sliced;
        image.raycastTarget = false;

        buttonRoot.AddComponent<UIButton>();

        GameObject childText = new GameObject("UIText");
        RectTransform textRectTransform = childText.AddComponent<RectTransform>();
        childText.transform.SetParent(buttonRoot.transform, false);
        UIText text = childText.AddComponent<UIText>();
        DefaultUITextProperty(text);
        text.color = new Color(0.1960784f, 0.1960784f, 0.1960784f, 1f);
        text.text = "Button";
        text.alignment = TextAnchor.MiddleCenter;
        textRectTransform.anchorMin = Vector2.zero;
        textRectTransform.anchorMax = Vector2.one;
        textRectTransform.sizeDelta = Vector2.zero;

        AddRaycast(buttonRoot);

        PlaceUIElementRoot(menuCommand, buttonRoot);
    }

    [MenuItem("GameObject/UI Extends/UIToggle &#g", false, 14)]
    static void AddUIToggle(MenuCommand menuCommand)
    {
        GameObject toggleRoot = new GameObject("UIToggle");
        RectTransform rectTransform = toggleRoot.AddComponent<RectTransform>();
        rectTransform.sizeDelta = new Vector2(160,20);

        GameObject background = new GameObject("Background");
        background.transform.SetParent(toggleRoot.transform, false);
        UIImage bgImage = background.AddComponent<UIImage>();
        bgImage.sprite = standardRes;
        bgImage.raycastTarget = false;
        bgImage.type = Image.Type.Sliced;
        RectTransform bgRect = background.GetComponent<RectTransform>();
        bgRect.anchorMin = new Vector2(0f, 1f);
        bgRect.anchorMax = new Vector2(0f, 1f);
        bgRect.anchoredPosition = new Vector2(10f, -10f);
        bgRect.sizeDelta = new Vector2(20, 20);
        AddRaycast(background);

        GameObject checkmark = new GameObject("Checkmark");
        checkmark.transform.SetParent(background.transform, false);
        UIImage checkmarkImage = checkmark.AddComponent<UIImage>();
        checkmarkImage.sprite = checkmarkRes;
        checkmarkImage.raycastTarget = false;
        RectTransform checkmarkRect = checkmark.GetComponent<RectTransform>();
        checkmarkRect.anchorMin = new Vector2(0.5f, 0.5f);
        checkmarkRect.anchorMax = new Vector2(0.5f, 0.5f);
        checkmarkRect.anchoredPosition = Vector2.zero;
        checkmarkRect.sizeDelta = new Vector2(20f, 20f);

        GameObject childLabel = new GameObject("Label");
        childLabel.transform.SetParent(toggleRoot.transform, false);
        UIText label = childLabel.AddComponent<UIText>();
        label.text = "UIToggle";
        DefaultUITextProperty(label);
        label.color = new Color(0.1960784f, 0.1960784f, 0.1960784f, 1f);
        RectTransform labelRect = childLabel.GetComponent<RectTransform>();
        labelRect.anchorMin = Vector2.zero;
        labelRect.anchorMax = Vector2.one;
        labelRect.offsetMin=new Vector2(23,-2);
        labelRect.offsetMax=new Vector2(0,1);

        UIToggle toggle = toggleRoot.AddComponent<UIToggle>();
        toggle.isOn = true;
        toggle.graphic = checkmarkImage;
        toggle.targetGraphic = bgImage;
        
        PlaceUIElementRoot(menuCommand, toggleRoot);
    }
    [MenuItem("GameObject/UI Extends/UISlider &#d", false, 15)]
    static void AddUISlider(MenuCommand menuCommand)
    {
        GameObject root = new GameObject("UISlider");
        UISlider slider = root.AddComponent<UISlider>();
        RectTransform rootRect = root.GetComponent<RectTransform>();
        rootRect.sizeDelta = new Vector2(160,20);

        // Background
        GameObject background = new GameObject("Background");
        background.transform.SetParent(rootRect,false);
        UIImage backgroundImage = background.AddComponent<UIImage>();
        backgroundImage.sprite = backgroundRes;
        backgroundImage.raycastTarget = false;
        backgroundImage.type = Image.Type.Sliced;
        RectTransform backgroundRect = background.GetComponent<RectTransform>();
        backgroundRect.anchorMin = Vector2.zero;
        backgroundRect.anchorMax = Vector2.one;
        backgroundRect.sizeDelta = new Vector2(0, 0);

        // Fill 
        GameObject fill = new GameObject("Fill");
        fill.transform.SetParent(rootRect, false);
        UIImage fillImage = fill.AddComponent<UIImage>();
        fillImage.raycastTarget = false;
        fillImage.sprite = standardRes;
        fillImage.type = Image.Type.Sliced;
        RectTransform fillRect = fill.GetComponent<RectTransform>();
        fillRect.sizeDelta = Vector2.zero;

        // Handle
        GameObject handle = new GameObject("Handle");
        handle.transform.SetParent(rootRect, false);
        UIImage handleImage = handle.AddComponent<UIImage>();
        handleImage.sprite = knobRes;
        handleImage.raycastTarget = false;
        RectTransform handleRect = handle.GetComponent<RectTransform>();
        handleRect.sizeDelta = new Vector2(20, 0);

        AddRaycast(handle);

        // Setup slider component
        slider.fillRect = fill.GetComponent<RectTransform>();
        slider.handleRect = handle.GetComponent<RectTransform>();
        slider.targetGraphic = handleImage;
        slider.direction = Slider.Direction.LeftToRight;

        PlaceUIElementRoot(menuCommand, root);
    }

    [MenuItem("GameObject/UI Extends/UIScrollbar", false, 16)]
    static void AddUIScrollbar(MenuCommand menuCommand)
    {
        GameObject scrollbarRoot = new GameObject("UIScrollbar");

        UIImage bgImage = scrollbarRoot.AddComponent<UIImage>();
        bgImage.sprite = backgroundRes;
        bgImage.raycastTarget = false;
        bgImage.type = Image.Type.Sliced;

        RectTransform rootRect = scrollbarRoot.GetComponent<RectTransform>();
        rootRect.sizeDelta = new Vector2(160, 20);

        GameObject handle = new GameObject("Handle");
        UIImage handleImage = handle.AddComponent<UIImage>();
        handle.transform.SetParent(rootRect, false);
        handleImage.sprite = standardRes;
        handleImage.type = Image.Type.Sliced;
        handleImage.raycastTarget = false;
        RectTransform handleRect = handle.GetComponent<RectTransform>();
        handleRect.anchorMin = Vector2.zero;
        handleRect.sizeDelta = new Vector2(0, 0);
        handleRect.anchorMax = Vector2.one;

        AddRaycast(handle);

        UIScrollbar scrollbar = scrollbarRoot.AddComponent<UIScrollbar>();
        scrollbar.handleRect = handleRect;
        scrollbar.targetGraphic = handleImage;

        PlaceUIElementRoot(menuCommand, scrollbarRoot);
    }

    [MenuItem("GameObject/UI Extends/UIInputField &#f", false, 18)]
    static void AddUIInputField(MenuCommand menuCommand)
    {
        GameObject root = new GameObject("UIInputField");
        UIImage image = root.AddComponent<UIImage>();
        image.sprite = inputFieldRes;
        image.type = Image.Type.Sliced;
        RectTransform rootRect = root.GetComponent<RectTransform>();
        rootRect.sizeDelta = _textSize;

        GameObject childText = new GameObject("UIText");
        childText.transform.SetParent(root.transform, false);
        UIText text = childText.AddComponent<UIText>();
        text.text = "";
        text.color = new Color(0.1960784f, 0.1960784f, 0.1960784f, 1f);
        text.supportRichText = false;
        text.raycastTarget = false;
        RectTransform textRectTransform = childText.GetComponent<RectTransform>();
        textRectTransform.anchorMin = Vector2.zero;
        textRectTransform.anchorMax = Vector2.one;
        textRectTransform.sizeDelta = Vector2.zero;
        textRectTransform.offsetMin = new Vector2(10, 6);
        textRectTransform.offsetMax = new Vector2(-10, -7);

        GameObject childPlaceholder = new GameObject("Placeholder");
        childPlaceholder.transform.SetParent(root.transform, false);
        UIText placeholder = childPlaceholder.AddComponent<UIText>();
        placeholder.text = "Enter text...";
        placeholder.raycastTarget = false;
        Color placeholderColor = text.color;
        placeholderColor.a *= 0.5f;
        placeholder.color = placeholderColor;
        RectTransform placeholderRectTransform = childPlaceholder.GetComponent<RectTransform>();
        placeholderRectTransform.anchorMin = Vector2.zero;
        placeholderRectTransform.anchorMax = Vector2.one;
        placeholderRectTransform.sizeDelta = Vector2.zero;
        placeholderRectTransform.offsetMin = new Vector2(10, 6);
        placeholderRectTransform.offsetMax = new Vector2(-10, -7);

        UIInputField inputField = root.AddComponent<UIInputField>();
        inputField.textComponent = text;
        inputField.placeholder = placeholder;
        inputField.transition = Selectable.Transition.None;

        PlaceUIElementRoot(menuCommand, root);
    }
    [MenuItem("GameObject/UI Extends/UIScrollView &#s", false, 19)]
    static void AddUIScrollView(MenuCommand menuCommand)
    {
        GameObject root = new GameObject("UIScrollView");
        RectTransform rootRect = root.AddComponent<RectTransform>();
        rootRect.sizeDelta = new Vector2(200, 200);

        GameObject viewport = new GameObject("Viewport");
        viewport.transform.SetParent(root.transform, false);
        Mask viewportMask = viewport.AddComponent<Mask>();
        viewportMask.showMaskGraphic = false;
        UIImage viewportImage = viewport.AddComponent<UIImage>();
        viewportImage.sprite = maskRes;
        viewportImage.type = Image.Type.Sliced;
        RectTransform viewportRT = viewport.GetComponent<RectTransform>();
        viewportRT.anchorMin = Vector2.zero;
        viewportRT.anchorMax = Vector2.one;
        viewportRT.sizeDelta = Vector2.zero;
        viewportRT.pivot = Vector2.up;

        GameObject content = new GameObject("Content");
        content.transform.SetParent(viewport.transform, false);
        RectTransform contentRT = content.AddComponent<RectTransform>();
        contentRT.anchorMin = Vector2.up;
        contentRT.anchorMax = Vector2.one;
        contentRT.sizeDelta = new Vector2(0, 0);
        contentRT.pivot = Vector2.up;
        content.AddComponent<ContentSizeFitter>();

        UIScrollView scrollRect = root.AddComponent<UIScrollView>();
        scrollRect.content = contentRT;
        scrollRect.viewport = viewportRT;

        PlaceUIElementRoot(menuCommand, root);
    }

    [MenuItem("GameObject/UI Extends/UIPanel &#p", false, 20)]
    static void AddUIPanel(MenuCommand menuCommand)
    {
        GameObject panelRoot = new GameObject("UIPanel");
        RectTransform rectTransform = panelRoot.AddComponent<RectTransform>();
        rectTransform.anchorMin = Vector2.zero;
        rectTransform.anchorMax = Vector2.one;
        rectTransform.anchoredPosition = Vector2.zero;
        rectTransform.sizeDelta = Vector2.zero;

        PlaceUIElementRoot(menuCommand, panelRoot);
    }

    [MenuItem("GameObject/UI Extends/UIRaycast &#c", false, 21)]
    static void AddUIRaycast(MenuCommand menuCommand)
    {
        GameObject go = new GameObject("UIRaycast");
        UIRaycast obj = go.AddComponent<UIRaycast>();
        RectTransform rectTransform = obj.GetComponent<RectTransform>();
        rectTransform.anchorMin = Vector2.zero;
        rectTransform.anchorMax = Vector2.one;
        rectTransform.sizeDelta = Vector2.zero;
        PlaceUIElementRoot(menuCommand, go);
    }

    [MenuItem("GameObject/UI Extends/UIPolygonRaycast", false, 22)]
    static void AddUIPolygonRaycast(MenuCommand menuCommand)
    {
        GameObject go = new GameObject("UIPolygonRaycast");
        UIPolygonRaycast obj = go.AddComponent<UIPolygonRaycast>();

        PlaceUIElementRoot(menuCommand, go);
    }

    private static void AddRaycast(GameObject parent)
    {
        GameObject childRaycast = new GameObject("UIRaycast");
        RectTransform raycastRectTransform = childRaycast.AddComponent<RectTransform>();
        childRaycast.transform.SetParent(parent.transform, false);
        raycastRectTransform.anchorMin = Vector2.zero;
        raycastRectTransform.anchorMax = Vector2.one;
        raycastRectTransform.sizeDelta = Vector2.zero;
        childRaycast.AddComponent<UIRaycast>();
    }

    private static void DefaultUITextProperty(UIText obj)
    {
        obj.raycastTarget = false;
        obj.text = "new text";
        obj.fontSize = 20;
        obj.resizeTextForBestFit = true;
        obj.resizeTextMaxSize = obj.fontSize;
    }
    private static void PlaceUIElementRoot(MenuCommand menuCommand, GameObject go)
    {
        GameObject parent = menuCommand.context as GameObject;
        if (parent == null || parent.GetComponentInParent<Canvas>() == null)
        {
            parent = Selection.activeGameObject;
            if (parent == null || parent.GetComponentInParent<Canvas>() == null)
            {
                return;
            }
        }

        string uniqueName = GameObjectUtility.GetUniqueNameForSibling(parent.transform, go.name);
        go.name = uniqueName;
        GameObjectUtility.SetParentAndAlign(go, parent);
        Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        Undo.SetTransformParent(go.transform, parent.transform, "Parent " + go.name);

        Selection.activeObject = go;
    }
}
