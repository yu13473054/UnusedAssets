using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

//content的内容对齐到哪儿
[Serializable]
public enum ItemAlignTo
{
    None,//不对齐任何对象，常规状态
    Target,//选中的item，会对齐到指定目标的位置
}

public delegate void AlignToFinish(int itemIndex);

public class UIScrollView : ScrollRect
{
    public UIMod uiMod;
    public int controlID = 0;

    public bool constractDragOnFit;
    public ItemAlignTo alignTo = ItemAlignTo.None;
    public RectTransform alignTarget;
    [SerializeField]
    private int _alignItemIndex=0;
    [SerializeField]
    private bool _forceClamp;//对齐到目标时，强制不能拖出边界，某些情况下，必须能拖出边界，慎用！

    public AlignToFinish onAlignToFinish; //对齐过程完成
//    public EnterTargetBounds onEnterTargetBounds;//开始进入对齐目标的范围
//    public ToTarget onToTarget;//到达对齐目标的位置
//    public ExitTargetBounds onExitTargetBounds;//

    private bool _isAlignInit;
    private ItemAlignTo _lastAlignTo;
    private LayoutGroup _contentLayout;
    private bool _isClosing;
    private bool _hasClosingAnim;
    private float _lastSize;
    private float _targetPos;
    private int _itemIndex;//对齐过程停止时的itemIndex
    private float[] _itemAlignEdges;

    //target属性
    private float _space;
    private float _itemSize;
    private Vector2 _paddingSize;
    private float _alignToPos;
    private bool _isDragging;
    private bool _cacuTarget;
    private Vector2 closingVelocity;
    private int _lastAlignItemIndex = -1;

    protected override void Awake()
    {
        base.Awake();
        onValueChanged.AddListener(OnValueChange);
    }

    protected override void Start()
    {
        base.Start();
#if UNITY_EDITOR
        // 挂载uiMod
        if (uiMod == null)
        {
            uiMod = gameObject.GetComponentInParent<UIMod>();
        }
#endif

        _contentLayout = content.GetComponent<LayoutGroup>();

        InitLayoutData();
    }

    private void OnValueChange(Vector2 delta)
    {
        if (uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLVIEW_ONVALUECHANGE, controlID, delta);
    }

    protected override void OnDestroy()
    {
        base.OnDestroy();
        onValueChanged.RemoveListener(OnValueChange);
    }

    public override void OnBeginDrag(PointerEventData eventData)
    {
        _isDragging = true;
        base.OnBeginDrag(eventData);
        //是否进行定点停止
        if (CanAlignTo())
        {
            _isClosing = false;
            _cacuTarget = true;
        }
        if (eventData.button != PointerEventData.InputButton.Left || !this.IsActive() || uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLVIEW_DRAG, controlID, 0);
    }

    public override void OnDrag(PointerEventData eventData)
    {
        Vector2 localPoint;
        if (eventData.button != PointerEventData.InputButton.Left || !this.IsActive() || !RectTransformUtility.ScreenPointToLocalPointInRectangle(this.viewRect, eventData.position, eventData.pressEventCamera, out localPoint))
            return;

        // 限定在内容没有超过可视高度时，不能被拖动
        MovementType odlMoveType = movementType;
        if (constractDragOnFit)
        {
            if (horizontal && content.rect.width <= viewRect.rect.width)
            {
                movementType = MovementType.Clamped;
            }
            if (vertical && content.rect.height <= viewRect.rect.height)
            {
                movementType = MovementType.Clamped;
            }
        }
        base.OnDrag(eventData);
        movementType = odlMoveType;

        if (_forceClamp)
        {
            ForceClamp();
        }

        if (uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLVIEW_DRAG, controlID, 1);
    }

    //拖拽时，内容不能拖拽超过对齐边界：不能有回弹效果
    private void ForceClamp()
    {
        int index = horizontal ? 0 : 1;
        float minEdge = 0;
        float maxEdge = 0;
        if (horizontal)
        {
            minEdge = GetTargetPosByTarget(_itemAlignEdges.Length - 1);
            maxEdge = GetTargetPosByTarget(0);
        }
        else
        {
            minEdge = GetTargetPosByTarget(0);
            maxEdge = GetTargetPosByTarget(_itemAlignEdges.Length - 1);
        }
        Vector2 newPos = content.anchoredPosition;
        newPos[index] = Mathf.Clamp(newPos[index], minEdge, maxEdge);
        SetContentAnchoredPosition(newPos);
    }

    public override void OnEndDrag(PointerEventData eventData)
    {
        _isDragging = false;
        base.OnEndDrag(eventData);

        if (eventData.button != PointerEventData.InputButton.Left || uiMod == null) return;
        uiMod.OnEvent(UIEVENT.UISCROLLVIEW_DRAG, controlID, 2);
    }

    //记录初始的Layout数据
    private void InitLayoutData()
    {
        //挂载循环列表后，padding值会被修改
        WrapContent wrapContent = _contentLayout.GetComponent<WrapContent>();
        if (wrapContent && wrapContent.InitPadding!=null)
        {
            if (horizontal)
            {
                _paddingSize.Set(wrapContent.InitPadding.left, wrapContent.InitPadding.right);
            }
            else if (vertical)
            {
                _paddingSize.Set(wrapContent.InitPadding.top, wrapContent.InitPadding.bottom);
            }
            _space = wrapContent.Space;
            return;
        }
        if (_contentLayout is HorizontalLayoutGroup || _contentLayout is VerticalLayoutGroup)
        {
            HorizontalOrVerticalLayoutGroup hvLayout = (HorizontalOrVerticalLayoutGroup)_contentLayout;
            _space = hvLayout.spacing;
            if (horizontal)
            {
                _paddingSize.Set(hvLayout.padding.left, hvLayout.padding.right);
            }
            else if (vertical)
            {
                _paddingSize.Set(hvLayout.padding.top, hvLayout.padding.bottom);
            }
        }
        else if (_contentLayout is GridLayoutGroup)
        {
            GridLayoutGroup grid = (GridLayoutGroup)_contentLayout;
            if (horizontal)
            {
                _space = grid.spacing.x;
                _paddingSize.Set(grid.padding.left, grid.padding.right);
            }
            else if (vertical)
            {
                _space = grid.spacing.y;
                _paddingSize.Set(grid.padding.top, grid.padding.bottom);
            }
        }
    }

    protected override void LateUpdate()
    {
        // 限定在内容没有超过可视高度时，不能被拖动
        MovementType odlMoveType = movementType;
        if (constractDragOnFit)
        {
            if (horizontal && content.rect.width <= viewRect.rect.width)
            {
                movementType = MovementType.Clamped;
            }
            if (vertical && content.rect.height <= viewRect.rect.height)
            {
                movementType = MovementType.Clamped;
            }
        }
        base.LateUpdate();
        movementType = odlMoveType;

        //自动对齐的逻辑
        if (CanAlignTo())
        {
            //重新计算边界数值
            if (NeedReCaculateEdges())
            {
                ReCaculateEdges();
            }

            //拖动时限制边界
            if (_isDragging && _forceClamp)
            {
                ForceClamp();
            }

            if (_lastAlignItemIndex != _alignItemIndex)
            {
                //获取对齐到的item的index值
                _isClosing = true;
                _lastAlignItemIndex = _alignItemIndex;
                if (alignTo == ItemAlignTo.Target)
                {
                    CacuItemIndex(_lastAlignItemIndex + 2);
                    _targetPos = GetTargetPosByTarget(_lastAlignItemIndex + 2);
                }
            }

            if (!_isDragging && _cacuTarget)
            {
                _cacuTarget = false;
                if (velocity != Vector2.zero)
                {
                    float deltaTime = Time.unscaledDeltaTime;
                    int index = horizontal ? 0 : 1;
                    Vector2 velocityTmp = velocity;

                    Vector2 oldPos = content.anchoredPosition;
                    Vector2 newPos = oldPos;
                    while (true)
                    {
                        velocityTmp[index] *= Mathf.Pow(decelerationRate, deltaTime);
                        if (Mathf.Abs(velocityTmp[index]) < 1)
                        {
                            CaculateTargetPos();
                            closingVelocity = velocity;
                            StopMovement();
                            break;
                        }
                        newPos[index] += velocityTmp[index] * deltaTime;
                        SetContentAnchoredPosition(newPos);
                    }
                    SetContentAnchoredPosition(oldPos);
                }
                else
                {
                    CaculateTargetPos();
                    closingVelocity = new Vector2(0.001f, 0.001f);
                }
            }
        }

        //开始让让页面接近
        if (_isClosing)
        {
            int index = horizontal ? 0 : 1;
            if (alignTo == ItemAlignTo.Target)
            {
                Vector2 newPos = content.anchoredPosition;
                if (_hasClosingAnim)
                {
                    float speed = closingVelocity[index];
                    newPos[index] = Mathf.SmoothDamp(newPos[index], _targetPos, ref speed, elasticity, Mathf.Infinity, Time.unscaledDeltaTime);
                    if (Mathf.Abs(speed) < 1)
                    {
                        speed = 0;
                        newPos[index] = _targetPos;
                        AlignFinish();
                    }
                    closingVelocity[index] = speed;
                }
                else
                {
                    newPos[index] = _targetPos;
                    AlignFinish();
                }
                SetContentAnchoredPosition(newPos);
                //计算出移动位置时限制边界
                if (_forceClamp)
                {
                    ForceClamp();
                }
            }
        }
    }

    void AlignFinish()
    {
        velocity = Vector2.zero;
        _isClosing = false;
        if (onAlignToFinish != null)
        {
            onAlignToFinish(_itemIndex);
        }
    }

    /// 设置对齐到某个item上，index从0开始
    /// <param name="hasAnim"></param> 是否显示对齐动画
    public void SetAlignItemIndex(int index, bool hasAnim = false)
    {
        if (_alignItemIndex != index || _hasClosingAnim != hasAnim)
        {
            _alignItemIndex = index;
            _hasClosingAnim = hasAnim;
        }
    }

    public void SetForceClamp(bool flag)
    {
        if (alignTo != ItemAlignTo.Target) return;
        _forceClamp = flag;
    }

    private bool NeedReCaculateEdges()
    {
        bool result = false;
        float contentSize = 0;
        if (horizontal)
        {
            contentSize = content.rect.width;
        }
        else if (vertical)
        {
            contentSize = content.rect.height;
        }
        //内容有变化，需要重新计算对齐边界
        if (Mathf.Abs(_lastSize - contentSize) > 10f)
        {
            _lastSize = contentSize;
            result = true;
        }

        //对齐方式变化，也需要重新计算对齐边界
        if (_lastAlignTo != alignTo)
        {
            _lastAlignTo = alignTo;
            result = true;
        }
        return result;
    }

    private void ReCaculateEdges()
    {
        if (alignTo == ItemAlignTo.Target)
        {
            //对齐到某个目标位置，需要ScrollView的拖动方式为Unrestricted
            if (alignTarget == null) return;
            constractDragOnFit = false;
            movementType = MovementType.Unrestricted;
            ReCaculateTargetEdges();
        }
    }

    public bool IsCanDrag()
    {
        if (horizontal)
        {
            return content.rect.width > viewRect.rect.width;
        }
        if (vertical)
        {
            return content.rect.height > viewRect.rect.height;
        }
        return false;
    }

    //对齐到目标的边界计算逻辑
    void ReCaculateTargetEdges()
    {
        //坐标转换
        Vector3 point = viewport.InverseTransformPoint(alignTarget.position);
        //计算中心点
        Vector2 centerPoint = GetCenterPos(point, alignTarget.pivot, alignTarget.rect.size);

        int index = horizontal ? 0 : 1;
        _alignToPos = centerPoint[index];

        int itemNum = 0;
        //获取child的大小
        if (_contentLayout is HorizontalLayoutGroup || _contentLayout is VerticalLayoutGroup)
        {
            RectTransform childRect = (RectTransform)_contentLayout.transform.GetChild(0);
            _itemSize = childRect.rect.size[index];
        }
        else if (_contentLayout is GridLayoutGroup)
        {
            GridLayoutGroup grid = (GridLayoutGroup)_contentLayout;
            _itemSize = grid.cellSize[index];
        }
        //加上0.5是为了防止浮点数计算的误差
        itemNum = (int) ((content.rect.size[index]+_space - _paddingSize.x - _paddingSize.y) /(_itemSize+_space) + 0.5f);
        itemNum += 2;//增加padding的两个区域
        CaculateAlignEdges(itemNum, _itemSize);
    }

    private void CaculateAlignEdges(int itemNum, float interval)
    {
        _itemAlignEdges = new float[itemNum + 1];
        switch (alignTo)
        {
            case ItemAlignTo.Target:
                for (int i = 0; i < _itemAlignEdges.Length; i++)
                {
                    if (horizontal)
                    {
                        if (i == itemNum)
                            _itemAlignEdges[i] = content.rect.width;
                        else if (i == itemNum - 1)//最边缘
                            _itemAlignEdges[i] = content.rect.width - _paddingSize.y;
                        else if (i == itemNum - 2)
                            _itemAlignEdges[i] = content.rect.width - _paddingSize.y - interval - _space / 2;
                        else if (i == 0)//最边缘
                            _itemAlignEdges[i] = 0;
                        else if (i == 1)
                            _itemAlignEdges[i] = _paddingSize.x;
                        else if (i == 2)
                            _itemAlignEdges[i] = _itemAlignEdges[i - 1] + interval + _space / 2;
                        else
                            _itemAlignEdges[i] = _itemAlignEdges[i - 1] + interval + _space;
                    }
                    else if (vertical)
                    {
                        if (i == itemNum)
                            _itemAlignEdges[i] = -content.rect.height;
                        else if (i == itemNum - 1)//最边缘
                            _itemAlignEdges[i] = -content.rect.height + _paddingSize.y;
                        else if (i == itemNum - 2)
                            _itemAlignEdges[i] = -content.rect.height + _paddingSize.y + interval + _space / 2;
                        else if (i == 0)//最边缘
                            _itemAlignEdges[i] = 0;
                        else if (i == 1)
                            _itemAlignEdges[i] = -_paddingSize.x;
                        else if (i == 2)
                            _itemAlignEdges[i] = _itemAlignEdges[i - 1] - interval - _space / 2;
                        else
                            _itemAlignEdges[i] = _itemAlignEdges[i - 1] - interval - _space;
                    }

                }
                break;
        }
    }

    /// <summary>
    /// 获取RectTranform的中心点坐标
    /// </summary>
    /// <param name="currPos"></param> 当前Transform的坐标
    /// <param name="pivot"></param> 中心点（也叫对齐点）
    /// <returns></returns>
    Vector2 GetCenterPos(Vector3 currPos, Vector2 pivot, Vector2 size)
    {
        Vector2 offsetV = Vector2.one / 2 - pivot;
        Vector2 targetSize = size;
        Vector2 centerPoint = new Vector2(currPos.x + targetSize.x * offsetV.x, currPos.y + targetSize.y * offsetV.y);
        return centerPoint;
    }

    //计算定点停止的位置
    private void CaculateTargetPos()
    {
        if (_itemAlignEdges == null) return;

        switch (alignTo)
        {
            case ItemAlignTo.Target:
                //使用坐标对齐
                for (int i = 0; i < _itemAlignEdges.Length; i++)
                {
                    if( (horizontal && 
                            (_alignToPos <= content.anchoredPosition.x + _itemAlignEdges[i] ||
                            (i == _itemAlignEdges.Length-1 && _alignToPos >= content.anchoredPosition.x + _itemAlignEdges[i])))
                     || (vertical && 
                            (_alignToPos >= content.anchoredPosition.y + _itemAlignEdges[i]  || 
                            (i == _itemAlignEdges.Length - 1 && _alignToPos <= content.anchoredPosition.y + _itemAlignEdges[i]))))
                    {
                        CacuItemIndex(i);
                        _targetPos = GetTargetPosByTarget(i);
                        _hasClosingAnim = true;
                        _isClosing = true;
                        break;
                    }
                }
                break;
        }
    }

    void CacuItemIndex(int i)
    {
        _itemIndex = Mathf.Clamp(i, 2, _itemAlignEdges.Length - 2) - 2;
    }

    //对齐到目标时，取得目标位置
    private float GetTargetPosByTarget(int i)
    {
        float itemPos = 0;
        if (i == 0 || i == 1 || i == 2)
        {
            if (horizontal)
            {
                itemPos = (_itemAlignEdges[2] + _itemAlignEdges[1] - _space / 2) / 2;
            }
            else if (vertical)
            {
                itemPos = (_itemAlignEdges[2] + _itemAlignEdges[1] + _space / 2) / 2;
            }
           
        }
        else if (i == _itemAlignEdges.Length - 1 || i == _itemAlignEdges.Length - 2)
        {
            if (horizontal)
            {
                itemPos = _itemAlignEdges[_itemAlignEdges.Length - 2] -
                          (_itemAlignEdges[_itemAlignEdges.Length - 2] - _itemAlignEdges[_itemAlignEdges.Length - 3] -
                           _space/2)/2;
            }
            else if (vertical)
            {
                itemPos = _itemAlignEdges[_itemAlignEdges.Length - 2] -
                          (_itemAlignEdges[_itemAlignEdges.Length - 2] - _itemAlignEdges[_itemAlignEdges.Length - 3] +
                           _space/2)/2;
            }
        }
        else
        {
            itemPos = (_itemAlignEdges[i] + _itemAlignEdges[i - 1])/2;
        }
        return _alignToPos - itemPos;
    }

    bool CanAlignTo()
    {
        if (_contentLayout == null || _contentLayout.transform.childCount == 0) return false;
        if (alignTo == ItemAlignTo.None) return false;
        return true;
    }
}
