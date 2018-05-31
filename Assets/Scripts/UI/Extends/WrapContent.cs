using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public delegate void UpdateItemDelegate(int index, Transform item);

/// <summary>
/// 数据列表渲染组件，Item缓存，支持无限循环列表，即用少量的Item实现大量的列表项显示
/// 注意事项：
/// 1，将此脚本挂载在Content上，同时需要在Content上添加Layout组件
/// 2，设置的渲染Item的大小必须一致
/// 3，GridLayout暂时只支持从左到右、从上到下的排列，另外的布局可能会有问题，后续出现需求了再做
/// </summary>
public class WrapContent : MonoBehaviour
{
    [SerializeField]
    private RectTransform[] _renderItems;

    private List<GameObject> _newGoBak;//所有产生的Item的备份

    private UIScrollView _scrollRect;
    private LayoutGroup _layoutGroup;
    private bool _isVertical;          //是否是垂直滚动方式，否则是水平滚动
    private float _space;              //item之间的间隔
    [SerializeField]
    private int _dataNum;              //数据的个数
    private int _constraintCount;      //约束常量（固定的行（列）数）
    private int _dataUnitCount;        //_dataNum / _constraintCount;
    private RectOffset _initPadding;
    private int _currUnitIndex;        //如果出现交换，交换的row或者col
    private int _initUnitIndex;        //初始化的Row或者col的个数
    private float _viewSize;           //可见区域长度
    private float _itemSize;          //每个Item的大小
    private float _contentSize;
    private float _initUnitSize;       //初始化时所有的row或者col的大小
    private float _lastDelta;

    private bool _inited;

    public RectOffset InitPadding
    {
        get { return _initPadding; }
    }

    public float Space
    {
        get { return _space; }
    }

    void Start()
    {
        _newGoBak = new List<GameObject>();

        //StartCoroutine(CoInit());
        _inited = true;
        _scrollRect = transform.GetComponentInParent<UIScrollView>();
        _isVertical = _scrollRect.vertical;
        //初始化_viewSpace
        RectTransform viewRectTrans = _scrollRect.viewport ? _scrollRect.viewport : (RectTransform)_scrollRect.transform;
        _viewSize = _isVertical ? viewRectTrans.rect.height : viewRectTrans.rect.width;

        _scrollRect.onValueChanged.AddListener(OnScroll);

        InitItemSpace();
        InitShowItem();
    }

    //private IEnumerator CoInit()
    //{
    //    yield return null;
    //    _inited = true;
    //    _scrollRect = transform.GetComponentInParent<ScrollRect>();
    //    _isVertical = _scrollRect.vertical;
    //    //初始化_viewSpace
    //    RectTransform viewRectTrans = _scrollRect.viewport ? _scrollRect.viewport : (RectTransform)_scrollRect.transform;
    //    _viewSize = _isVertical ? viewRectTrans.rect.height : viewRectTrans.rect.width;

    //    _scrollRect.onValueChanged.AddListener(OnScroll);

    //    InitItemSpace();
    //    InitShowItem();
    //}

    /// <summary>
    ///  初始化渲染item的大小
    /// </summary>
    /// <param name="item"></param> 进行渲染的item
    public void InitItemSpace(params RectTransform[] renderItems)
    {
        if (renderItems != null && renderItems.Length != 0) _renderItems = renderItems;
        _layoutGroup = GetComponent<LayoutGroup>();
        if (_layoutGroup != null)
        {
            _initPadding = _layoutGroup.padding;
            //计算itemSpace
            if (_layoutGroup is HorizontalOrVerticalLayoutGroup)
            {
                _constraintCount = 1;
                HorizontalOrVerticalLayoutGroup hvLayout = (HorizontalOrVerticalLayoutGroup)_layoutGroup;
                _space = hvLayout.spacing;
                if (_isVertical)
                {
                    if (hvLayout.childControlHeight)//item拥有自己的layoutElement
                    {
                        LayoutElement element = _renderItems[0].GetComponent<LayoutElement>();
                        _itemSize = element.preferredHeight + hvLayout.spacing;
                    }
                    else
                    {
                        _itemSize = _renderItems[0].rect.height + hvLayout.spacing;
                    }
                }
                else
                {
                    if (hvLayout.childControlWidth)//item拥有自己的layoutElement
                    {
                        LayoutElement element = _renderItems[0].GetComponent<LayoutElement>();
                        _itemSize = element.preferredWidth + hvLayout.spacing;
                    }
                    else
                    {
                        _itemSize = _renderItems[0].rect.width + hvLayout.spacing;
                    }
                }
            }
            else if (_layoutGroup is GridLayoutGroup)
            {
                GridLayoutGroup gridLayout = (GridLayoutGroup)_layoutGroup;
                _constraintCount = gridLayout.constraintCount;
                if (_isVertical)
                {
                    _space = gridLayout.spacing.y;
                    _itemSize = gridLayout.cellSize.y + _space;
                }
                else
                {
                    _space = gridLayout.spacing.x;
                    _itemSize = gridLayout.cellSize.x + _space;
                }
            }
        }
        else
        {
            Debug.LogErrorFormat("<WrapContent> {0}：缺少Layout!", name);
        }
    }

    /// <summary>
    /// 设置数据的条数
    /// </summary>
    /// <param name="dataNum"></param>
    public void SetDataNum(int dataNum, bool forceReCreate = false)
    {
        _dataNum = dataNum;
        if (forceReCreate && _inited)
        {
            if (_isVertical)
            {
                _scrollRect.verticalNormalizedPosition = 1;
            }
            else
            {
                _scrollRect.horizontalNormalizedPosition = 1;
            }
            InitShowItem();
        }
    }

    /// <summary>
    /// 初始化可视区域中的item
    /// </summary>
    private void InitShowItem()
    {
        _lastDelta = 0;

        float realShowSpace = _viewSize + _space;//第一个和最后一个item都缺少半个_layoutSpace

        int showUnitNum = Mathf.CeilToInt(realShowSpace / _itemSize) + 2;

        int initItemCount = showUnitNum * _constraintCount;
        //初始化数据
        int showCount = _dataNum > initItemCount ? initItemCount : _dataNum;
        int loadItemIndex = -1;
        int newGoCount = _newGoBak.Count;
        for (int i = 0; i < showCount; i++)
        {
            //计算该渲染哪个Item了
            loadItemIndex++;
            if (loadItemIndex == _renderItems.Length)
            {
                loadItemIndex = 0;
            }
            GameObject go;
            if (i < newGoCount)
            {
                go = _newGoBak[i];
                go.SetActive(true);
                go.transform.SetSiblingIndex(i);
            }
            else
            {
                //不在备份中的，需要重新存储：使用备份，保证Item的渲染顺序是正确的
                go = Instantiate(_renderItems[loadItemIndex].gameObject);
                go.name = go.name + "_" + i;
                go.transform.SetParent(transform, false);
                _newGoBak.Add(go);
            }
        }
        //隐藏多余的Item
        for (int i = showCount; i < newGoCount; i++)
        {
            _newGoBak[i].SetActive(false);
        }

        for (int i = 0; i < showCount; i++)
        {
            UpdateItem(i, transform.GetChild(i));
        }

        _dataUnitCount = Mathf.CeilToInt(_dataNum * 1f / _constraintCount);
        _currUnitIndex = _initUnitIndex = showUnitNum;
        if (_isVertical)
        {
            _contentSize = _dataUnitCount * _itemSize - _space + _initPadding.top + _initPadding.bottom;
        }
        else
        {
            _contentSize = _dataUnitCount * _itemSize - _space + _initPadding.left + _initPadding.right;
        }
        _initUnitSize = Mathf.CeilToInt(showCount * 1f / _constraintCount) * _itemSize - _space;

        UpdatePadding();

        StartCoroutine(CoInitDone());
    }

    private IEnumerator CoInitDone()
    {
        yield return null;
        if (_scrollRect.uiMod != null)
            _scrollRect.uiMod.OnEvent(UIEVENT.WRAPCONTENT_ONINITDONE, _scrollRect.controlID, 0);
    }

    private void OnScroll(Vector2 delta)
    {
        Vector3 transPos = transform.localPosition;
        if (_isVertical)
        {
            if (delta.y < _lastDelta)//上滑
            {
                //计算移出边框的内容
                float moveDelta = Mathf.Abs(transPos.y) -
                                  (_initPadding.top + _itemSize * (_currUnitIndex - _initUnitIndex + 1));
                if (moveDelta > 0)
                {
                    ExchangeChild(moveDelta, true);
                }
            }
            else//下滑
            {
                //计算移出边框的内容
                float moveDelta = Mathf.Abs(transPos.y) -
                                  (_initPadding.bottom + _itemSize * (_currUnitIndex - _initUnitIndex));
                if (moveDelta < 0)
                {
                    ExchangeChild(moveDelta, false);
                }
            }
            _lastDelta = Mathf.Clamp01(delta.y);
        }
        else
        {
            if (delta.x > _lastDelta)//左滑
            {
                //计算移出边框的内容
                float moveDelta = Mathf.Abs(transPos.x) -
                                  (_initPadding.left + _itemSize * (_currUnitIndex - _initUnitIndex + 1));
                if (moveDelta > 0)
                {
                    ExchangeChild(moveDelta, true);
                }
            }
            else//右滑
            {
                //计算移出边框的内容
                float moveDelta = Mathf.Abs(transPos.x) -
                                  (_initPadding.right + _itemSize * (_currUnitIndex - _initUnitIndex));
                if (moveDelta < 0)
                {
                    ExchangeChild(moveDelta, false);
                }
            }
            _lastDelta = Mathf.Clamp01(delta.x);
        }
    }

    private void ExchangeChild(float moveDelta, bool first2End)
    {
        int exchangeCount = Mathf.CeilToInt(Mathf.Abs(moveDelta) / _itemSize);
        int childCount = transform.childCount;
        for (int k = 0; k < exchangeCount; k++)
        {
            if (!first2End)
            {
                //把最后的child移动到第一个
                if (_currUnitIndex > _initUnitIndex)
                {
                    _currUnitIndex--;
                    for (int i = 0; i < _constraintCount; i++)
                    {
                        Transform firstChild = transform.GetChild(i);
                        Transform lastChild = transform.GetChild(childCount - (_constraintCount - i));
                        Vector3 endPos = firstChild.localPosition;
                        if (_isVertical)
                        {
                            endPos.y += _itemSize;
                        }
                        else
                        {
                            endPos.x -= _itemSize;
                        }
                        lastChild.localPosition = endPos;
                        UpdateItem((_currUnitIndex - _initUnitIndex) * _constraintCount + i, lastChild);

                    }
                    for (int i = 0; i < _constraintCount; i++)
                    {
                        transform.GetChild(childCount - 1).SetAsFirstSibling();
                    }
                    UpdatePadding();
                }
                else
                {
                    break;
                }
            }
            else
            {
                //把第一个child移动到后边
                if (_currUnitIndex < _dataUnitCount)
                {
                    _currUnitIndex++;
                    for (int i = 0; i < _constraintCount; i++)
                    {
                        Transform firstChild = transform.GetChild(i);
                        Transform lastChild = transform.GetChild(childCount - (_constraintCount - i));
                        Vector3 endPos = lastChild.localPosition;
                        if (_isVertical)
                        {
                            endPos.y -= _itemSize;
                        }
                        else
                        {
                            endPos.x += _itemSize;
                        }
                        firstChild.localPosition = endPos;
                        UpdateItem((_currUnitIndex - 1) * _constraintCount + i, firstChild);
                    }
                    for (int i = 0; i < _constraintCount; i++)
                    {
                        transform.GetChild(0).SetAsLastSibling();
                    }
                    UpdatePadding();
                }
                else
                {
                    break;
                }
            }

        }
    }


    public void UpdatePadding()
    {
        if (_isVertical)
        {
            int frontSpace = (int)(_initPadding.top + (_currUnitIndex - _initUnitIndex) * _itemSize);
            int behindSpace = (int)Mathf.Max(0, _contentSize - frontSpace - _initUnitSize);
            _layoutGroup.padding = new RectOffset(_initPadding.left, _initPadding.right, frontSpace, behindSpace);
        }
        else
        {
            int frontSpace = (int)(_initPadding.left + (_currUnitIndex - _initUnitIndex) * _itemSize);
            int behindSpace = (int)Mathf.Max(0, _contentSize - frontSpace - _initUnitSize);
            _layoutGroup.padding = new RectOffset(frontSpace, behindSpace, _initPadding.top, _initPadding.bottom);
        }
    }

    private void UpdateItem(int realIndex, Transform item)
    {
        if (realIndex >= _dataNum)
        {
            item.gameObject.SetActive(false);
        }
        else
        {
            item.gameObject.SetActive(true);
            if (_scrollRect.uiMod != null)
                _scrollRect.uiMod.OnEvent(UIEVENT.WRAPCONTENT_ONITEMUPDATE, _scrollRect.controlID, new object[]{ realIndex, item } );
        }
    }

    void OnDestroy()
    {
        _newGoBak = null;
        _scrollRect.onValueChanged.RemoveListener(OnScroll);
    }

}

public class WrapItemData
{
    public int realIndex;
    public Transform item;
    public WrapItemData(int realIndex, Transform item)
    {
        this.realIndex = realIndex;
        this.item = item;
    }
}
