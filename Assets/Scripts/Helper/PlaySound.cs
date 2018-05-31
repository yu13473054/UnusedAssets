using UnityEngine;
using UnityEngine.EventSystems;

public enum Trigger
{
    Awake,
    OnEnable,
    Start,
    OnDisable,
    OnClick,
    OnPress,
    OnRelease,
    OnBeginDrag,
    OnDrag,
    OnEndDrag,
    OnSelect,
    OnDeselect,
    OnMove,
    OnSumbit,
    OnCancel,
    
}

public class PlaySound : MonoBehaviour, IPointerClickHandler,IPointerDownHandler,IPointerUpHandler,
    IBeginDragHandler,IDragHandler,IEndDragHandler,
    ISelectHandler,IDeselectHandler,
    IMoveHandler,
    ISubmitHandler,ICancelHandler
{

    public int soundId = 0;	//音效名
	public Trigger trigger = Trigger.OnEnable;

    void Play(Trigger t)
    {
        if (trigger == t && soundId>0)
        {
            AudioManager.instance.Play(soundId);
        }
    }

    void Awake()
    {
        Play(Trigger.Awake);
    }
    void Start()
    {
        Play(Trigger.Start);
    }

    void OnEnable ()
	{
        Play(Trigger.OnEnable);
	}

	void OnDisable ()
	{
        Play(Trigger.OnDisable);
	}

    public void OnPointerClick(PointerEventData eventData)
    {
        Play(Trigger.OnClick);
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        Play(Trigger.OnPress);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        Play(Trigger.OnRelease);
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        Play(Trigger.OnBeginDrag);
    }

    public void OnDrag(PointerEventData eventData)
    {
        Play(Trigger.OnDrag);
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        Play(Trigger.OnEndDrag);
    }

    public void OnSelect(BaseEventData eventData)
    {
        Play(Trigger.OnSelect);
    }

    public void OnDeselect(BaseEventData eventData)
    {
        Play(Trigger.OnDeselect);
    }

    public void OnMove(AxisEventData eventData)
    {
        Play(Trigger.OnMove);
    }

    public void OnSubmit(BaseEventData eventData)
    {
        Play(Trigger.OnSumbit);
    }

    public void OnCancel(BaseEventData eventData)
    {
        Play(Trigger.OnCancel);
    }
}

