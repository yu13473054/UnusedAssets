using System;
using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.EventSystems;

/// <summary>
/// 城市专用Camara控制脚本
/// </summary>

[RequireComponent(typeof(Camera))]
public abstract class Camera2D : MonoBehaviour
{
    // 子摄影机
    public Camera subCamera;
    public UIMod uiMod;

    // 速度衰减（乘）
    public float moveDecay = 0.075f;
	// 缩放限制
	public float zoomInLimit = 4f;
	public float zoomOutLimit = 10f;
	// 缩放速度
	public float zoomSpeed = 0.02f;
	// 缩放回弹阈值
	public float zoomRestrict = 0.6f;
	// 缩放时移动速度
	public float zoomOffsetSpeed = 0.1f;
	// 地图大小
	public Vector2 mapSize;
    // 地图扩展 上右下左
    public Vector4 mapExpand;
    // 摄像机
    public Camera camera { get { return _Camera; } }
    public Vector3 position { get { return _Camera.transform.position; } set { _Camera.transform.position = value; } }

	// 记录上一次点击位置
	Vector2				_OldPosition1;
	Vector2				_OldPosition2;
    // 摄像机
    protected Camera    _Camera;
	// 触摸时焦点位置
	Vector2				_TargetPos;
	// 动量
	Vector2				_Momentum;
	// 是否发生过移动或缩放
	bool				_Moved = false;
	// 拖拽状态
	int					_DragState = 0;
	// 锁死触控
	bool				_Lock = false;
//	protected Camera2dDragable	_DragObj;
    //
    float               _TweenSize = 0;
    Vector3             _TweenPosition;
    float               _TweenDuration = 1f;
    //
    Coroutine           _TweenPosCoroutine;
    Coroutine           _TweenSizeCoroutine;

    protected Vector2 _initPos;
    protected float _initOrthographicSize;

    protected virtual void Awake()
    {
        _Camera = GetComponent<Camera>();
    }

	//初始化游戏信息设置
    protected virtual void Start()
	{
        _TweenSize = _Camera.orthographicSize;
        _initOrthographicSize = _TweenSize;
        _initPos = _Camera.transform.position;

        // 摄像机默认值
        Reset();
	}

    void OnDisable()
    {
        _Lock = false;
        _Momentum = Vector2.zero;
    }
	
	void Update ()
	{
#if UNITY_STANDALONE || UNITY_EDITOR
        // 鼠标版
        if( Input.GetMouseButtonUp(0) )
        {
            if( _Moved == false )
            {                            
                // 触碰释放
                OnTouchRelease( Input.mousePosition );
            }

            if( _Lock )
            {
                // 解锁
                _Lock = false;
            }
            else
            {
                if( _DragState == 1 )
                {
                    // 鼠标抬起时再进行事件检测，如果发生移动则Pass
                    if( _Moved == false )
                    {
                        Vector3 org = _Camera.ScreenToWorldPoint( Input.mousePosition );
                        RaycastHit2D hit = Physics2D.Raycast( new Vector2( org.x, org.y ), Vector2.zero );
                        if( hit.collider != null )
                        {
                            OnClick( hit.collider.transform );
                        }
                        else
                            OnClick( null );
                    }
                }
                else if( _DragState == 2 )
                {
                    OnDragEnd();
                }
                _DragState = 0;

                _Moved = false;
                _OldPosition1 = Vector2.zero;
            }

        }
        // 锁死则不接受鼠标事件
        else if( _Lock == false )
        {
            if( Input.GetMouseButtonDown(0) )
            {
                PointerEventData eventDataCurrentPosition = new PointerEventData( EventSystem.current );
                eventDataCurrentPosition.position = new Vector2( Input.mousePosition.x, Input.mousePosition.y );
				
                List<RaycastResult> results = new List<RaycastResult>();
                EventSystem.current.RaycastAll( eventDataCurrentPosition, results );

                // 触碰 
                OnTouch( Input.mousePosition );

                if( results.Count > 0 )
                {
                    for( int i = 0; i < results.Count; i++ )
                    {
                        if( results[i].gameObject.layer == LayerMask.NameToLayer("UI") )
                        {
                            _Lock = true;//防止点击UI元素后，也可以拖动
                            break;
                        }
                    }
                }
                if( _Lock == false )
                {
                    Vector3 org = _Camera.ScreenToWorldPoint( Input.mousePosition );
                    RaycastHit2D hit = Physics2D.Raycast( new Vector2( org.x, org.y ), Vector2.zero );
                    if ( hit.collider != null )
                    {
                        OnPress( hit.collider.transform );
                        _DragState = 1;
                    }
                }
            }
            else if( Input.GetMouseButton(0) )
            {
                // 拖动多少移动多少
                if( _OldPosition1 == Vector2.zero )
                {
                    _OldPosition1 = new Vector2( Input.mousePosition.x, Input.mousePosition.y );
                }
                Vector3 curPoint = _Camera.ScreenToWorldPoint( Input.mousePosition );
                Vector3 move = curPoint - _Camera.ScreenToWorldPoint( new Vector3( _OldPosition1.x, _OldPosition1.y, 0 ) );
                if( move.magnitude > 0 )
                {
                    // 可拖动物件
                    if( _DragState == 1 )
                    {
                        _DragState = 2;
                        OnDragStart( curPoint );
                    }
                    else if (_DragState == 2)
                    {
                        OnDrag( curPoint );
                    }
                    else
                    {
                        _Momentum = new Vector2( move.x, move.y );
                        _Moved = true;
                    }
                    _OldPosition1 = new Vector2( Input.mousePosition.x, Input.mousePosition.y );
                }
                else
                {
                    _Momentum = Vector2.zero;
                }

            }

            // 缩放
            float length = Input.GetAxis("Mouse ScrollWheel") * 200f;
            if (Math.Abs(length) > 0.0001f)
            {
                Zoom( length, Input.mousePosition );
            }
        }
#else
		// 触摸版
		if( Input.touchCount == 0 )
		{
			// 缩放回弹	
			if( _Camera.orthographicSize < zoomInLimit )
            {
				_Camera.orthographicSize += 0.05f;
                if( _Camera.orthographicSize > zoomInLimit )
                    _Camera.orthographicSize = zoomInLimit;
                // 矫正位置
                Move( 0f, 0f );

                RefreshSubCamera();
            }
			else if( _Camera.orthographicSize > zoomOutLimit )
            {
				_Camera.orthographicSize -= 0.05f;
                if ( _Camera.orthographicSize < zoomOutLimit )
                    _Camera.orthographicSize = zoomOutLimit;
                // 矫正位置
                Move( 0f, 0f );
                
                RefreshSubCamera();
            }

			_Lock = false;			
		}
		else
		{
            // 释放
            if( Input.touchCount == 1 )
			{
                if( Input.GetTouch(0).phase == TouchPhase.Ended )
                {
				    if( _Moved == false )
				    {
                        // 触碰释放
                        OnTouchRelease( Input.mousePosition );
                    }

                }
            }

		    // 锁死则不检测触摸
            if( _Lock == false )
            {
		        // 如果点到UI上了直接锁死
                if( Input.touchCount >= 1 ) 
                {
                    for( int i = 0; i < Input.touchCount; i++ )
                    {                    
                        if ( Input.GetTouch(i).phase == TouchPhase.Began )
				        {
				            PointerEventData eventDataCurrentPosition = new PointerEventData( EventSystem.current );
				            eventDataCurrentPosition.position = new Vector2( Input.GetTouch(0).position.x, Input.GetTouch(0).position.y );
					
				            List<RaycastResult> results = new List<RaycastResult>();
				            EventSystem.current.RaycastAll( eventDataCurrentPosition, results );
				            if( results.Count > 0 )
				            {
					            for( int j = 0; j < results.Count; j++ )
					            {
						            if( results[j].gameObject.layer == LayerMask.NameToLayer("UI") )
						            {
							            _Lock = true;
							            return;
						            }
					            }
				            }
                         }
                    }
                }

			    // 单点触摸
			    if( Input.touchCount == 1 )
			    {	
				    if ( Input.GetTouch(0).phase == TouchPhase.Began )
				    {
                        // 触碰 
                        OnTouch( Input.mousePosition );

					    Vector3 org = _Camera.ScreenToWorldPoint( Input.GetTouch(0).position );
					    RaycastHit2D hit = Physics2D.Raycast( new Vector2( org.x, org.y ), Vector2.zero );
					    if( hit.collider != null )
					    {
						    OnPress( hit.collider.transform );
							_DragState = 1;
					    }
				    }
				    // 移动
				    else if( Input.GetTouch(0).phase == TouchPhase.Moved )
				    {
					    // 拖动多少移动多少
					    if( _OldPosition1 == Vector2.zero )
					    {
						    _OldPosition1 = new Vector2( Input.GetTouch(0).position.x, Input.GetTouch(0).position.y );
					    }
					    Vector3 curPoint = _Camera.ScreenToWorldPoint( Input.GetTouch(0).position );
					    Vector3 move = curPoint - _Camera.ScreenToWorldPoint( new Vector3( _OldPosition1.x, _OldPosition1.y, 0 ) );
					    if( move.magnitude > 0 )
					    {
						    // 城市物件拖动
						    if( _DragState == 1 )
						    {
							    _DragState = 2;
							    OnDragStart( curPoint );
						    }
						    else if( _DragState == 2 )
							    OnDrag( curPoint );
						    else
						    {
							    _Momentum = new Vector2( move.x, move.y );
							    _Moved = true;
						    }
						    _OldPosition1 = new Vector2( Input.GetTouch(0).position.x, Input.GetTouch(0).position.y );
					    }
					    else
					    {
						    _Momentum = Vector2.zero;
					    }
				    }			
				    // 释放清空
				    else if( Input.GetTouch(0).phase == TouchPhase.Ended )
				    {					
					    if( _DragState == 1 )
					    {						
						    if( _Moved == false )
						    {
							    Vector3 org = _Camera.ScreenToWorldPoint( Input.GetTouch(0).position );
							    RaycastHit2D hit = Physics2D.Raycast( new Vector2( org.x, org.y ), Vector2.zero );
							    if( hit.collider != null )
                                {
								    OnClick( hit.collider.transform );
                                }
							    else
								    OnClick( null );
						    }
					    }
					    else if( _DragState == 2 )
					    {
						    OnDragEnd();
					    }
						_DragState = 0;

					    _Moved = false;

					    _TargetPos = Vector2.zero;
					    _OldPosition1 = Vector2.zero;
					    _OldPosition2 = Vector2.zero;
				    }
			    }
			    // 多点触摸
			    else if( Input.touchCount == 2 )
			    {			
				    // 初值
				    if( _OldPosition1 == Vector2.zero )
				    {
					    _OldPosition1 = Input.GetTouch(0).position;
				    }
				    if( _OldPosition2 == Vector2.zero )
				    {
					    _OldPosition2 = Input.GetTouch(1).position;
				    }

				    // 两只手指移动 - 缩放
				    if( Input.GetTouch(0).phase == TouchPhase.Moved || Input.GetTouch(1).phase == TouchPhase.Moved )
				    {
					    // 当前触摸点位置
					    Vector2 tempPosition1 = Input.GetTouch(0).position;
					    Vector2 tempPosition2 = Input.GetTouch(1).position;

					    if( _TargetPos == Vector2.zero )
					    {
						    _TargetPos = ( tempPosition1 + tempPosition2 ) / 2;
					    }
					
					    // 两点触摸之间的距离
					    float leng1 = Vector3.Distance( _OldPosition1, _OldPosition2 );
					    float leng2 = Vector3.Distance( tempPosition1, tempPosition2 );
					    // 移动缩放
				        float length = leng2 - leng1;
                        if (Math.Abs(length) > 0.0001f)
                        {
                            ZoomMove( length, new Vector3( _TargetPos.x, _TargetPos.y, 0 ), ( tempPosition1 - _OldPosition1 ) + ( tempPosition2 - _OldPosition2 ) );
                        }
					
					    // 上一次触摸点的位置，用于对比
					    _OldPosition1 = tempPosition1;
					    _OldPosition2 = tempPosition2;

					    _Moved = true;
				    }

				    // 释放清空
				    if( Input.GetTouch(0).phase == TouchPhase.Ended )
				    {
					    _OldPosition1 = Vector2.zero;
				    }
				    if( Input.GetTouch(1).phase == TouchPhase.Ended )
				    {
					    _OldPosition2 = Vector2.zero;
				    }
			    }
			    // 超过两点时调整
			    else if( Input.touchCount > 2 )
			    {
				    for( int i = 0; i < Input.touchCount; i++ )
				    {
					    if( Input.GetTouch(i).phase == TouchPhase.Ended )
					    {
						    _OldPosition1 = Vector2.zero;
						    _OldPosition2 = Vector2.zero;
						    break;
					    }
				    }
			    }
            }
		}
#endif

        // 移动动量
        if (moveDecay != 0 && _Momentum != Vector2.zero )
		{
			Move( _Momentum.x, _Momentum.y );
			
			_Momentum -= _Momentum * moveDecay;
			if( _Momentum.magnitude < 0.001 )
			{
				_Momentum = Vector2.zero;
			}
		}
    }

	// 焦点缩放
	protected virtual void Zoom( float length, Vector3 focus )
	{
        //不缩放
	    if (zoomInLimit == zoomOutLimit) return;

		length = -length;

		// 缩放前焦点位置
		Vector3 org = _Camera.ScreenToWorldPoint( focus );

		// 缩放
		_Camera.orthographicSize += zoomSpeed * length;		
		if( _Camera.orthographicSize < zoomInLimit )
			_Camera.orthographicSize = zoomInLimit;
		if( _Camera.orthographicSize > zoomOutLimit )
			_Camera.orthographicSize = zoomOutLimit;

		// 对齐焦点
		Vector3 offset = _Camera.ScreenToWorldPoint( focus ) - org;
		Move( offset.x, offset.y );

        RefreshSubCamera();
	}

	// 移动缩放
	protected virtual void ZoomMove( float length, Vector3 focus, Vector3 direction )
	{
        //不缩放
        if (zoomInLimit == zoomOutLimit) return;

        length = -length;
		
		// 缩放前焦点位置
		Vector3 org = _Camera.ScreenToWorldPoint( focus );
		
		// 缩放
		_Camera.orthographicSize += zoomSpeed * length;		
		if( _Camera.orthographicSize < zoomInLimit - zoomRestrict )
			_Camera.orthographicSize = zoomInLimit - zoomRestrict;
		if( _Camera.orthographicSize > zoomOutLimit + zoomRestrict )
			_Camera.orthographicSize = zoomOutLimit + zoomRestrict;
		_Camera.orthographicSize = _Camera.orthographicSize;
		
		// 对齐焦点
		Vector3 offset = _Camera.ScreenToWorldPoint( focus ) - org;
		Move( offset.x + direction.x * 0.0065f, offset.y + direction.y * 0.0065f );

        RefreshSubCamera();
	}

	// 移动
	protected virtual void Move( float offsetX, float offsetY )
	{
        // 反转
        offsetX = -offsetX;
		offsetY = -offsetY;

		//移动
		Vector3 pos = _Camera.transform.position;
		pos.x += offsetX;
		pos.y += offsetY;

		// 根据摄像机Size算出移动限制Y 1 position = 100 pixel
		float limitY = ( mapSize.y / 2f - _Camera.orthographicSize * 100f ) / 100f;
		// 分辨率算出X
		float limitX = ( mapSize.x / 2f - ( (float)Screen.width / (float)Screen.height ) * _Camera.orthographicSize * 100f ) / 100f;

		// 限制移动
		if( pos.x < -limitX - mapExpand.w )
			pos.x = -limitX - mapExpand.w;
		else if( pos.x > limitX + mapExpand.y )
			pos.x = limitX + mapExpand.y;
		
		if( pos.y < -limitY - mapExpand.z )
			pos.y = -limitY - mapExpand.z;
		else if( pos.y > limitY + mapExpand.x )
			pos.y = limitY + mapExpand.x;

		_Camera.transform.position = pos;
        Debug.Log(_Camera.transform.position);
	}

    public void MoveTo( Vector3 position )
    {
        Vector3 offset = position - _Camera.transform.position;
        Move( -offset.x , -offset.y );
    }

	protected virtual IEnumerator TweenPos( Vector3 pos, float duration )
	{
        Vector3 originPos = _Camera.transform.position;
        pos.z = originPos.z;
        float timer = 0f;
		while( timer < duration )
		{
            timer += Time.deltaTime;
            Vector3 target = Vector3.Lerp( originPos, pos, timer / duration );
            _Camera.transform.position = Vector3.Lerp( originPos, pos, timer / duration );

            RefreshSubCamera();
            OnTween();

			yield return null;
		}

        _Camera.transform.position = pos;
        _TweenPosCoroutine = null;

        RefreshSubCamera();
        OnTween();
	}

	protected virtual IEnumerator TweenPosInBound( Vector3 pos, float duration )
	{
        Vector2 speed = ( pos - _Camera.transform.position ) / duration;

        float timer = 0f;
		while( timer < duration )
		{
            timer += Time.deltaTime;
            Vector2 offset;
            if( timer < duration )
                offset = speed * Time.deltaTime;
            else
                offset = speed * ( duration - ( timer - Time.deltaTime ) );
 
            Move( -offset.x, -offset.y );

			yield return null;
		}

        _TweenPosCoroutine = null;
	}
	
	protected virtual IEnumerator TweenSize( float size, float duration )
	{
        float originSize = _Camera.orthographicSize;
        float timer = 0f;
		while( timer < duration )
		{
			_Camera.orthographicSize = originSize + timer / duration * ( size - originSize );
            timer += Time.deltaTime;

            RefreshSubCamera();
            OnTween();
			yield return null;
		}
        
        _Camera.orthographicSize = size;
        _TweenSizeCoroutine = null;

        RefreshSubCamera();
        OnTween();
	}

	public void TweenPosTo( Vector3 pos, float duration )
	{
        _TweenPosition = _Camera.transform.position;

        if( pos == _Camera.transform.position )
            return;

        if( _TweenPosCoroutine != null )
            return;

		_TweenPosCoroutine = StartCoroutine( TweenPos( pos, duration ) );

        _Momentum = Vector2.zero;
	}

    public void TweenPosBy( Vector3 offset, float duration )
    {
        if( offset == Vector3.zero )
            return;

        if( _TweenPosCoroutine != null )
            return;

        _TweenPosCoroutine = StartCoroutine( TweenPosInBound( _Camera.transform.position + offset, duration ) );
        
        _Momentum = Vector2.zero;
    }

    public void TweenPosToInBound( Vector3 pos, float duration )
    {
        if( pos == _Camera.transform.position )
            return;

        if( _TweenPosCoroutine != null )
            return;

		_TweenPosCoroutine = StartCoroutine( TweenPosInBound( pos, duration ) );

        _Momentum = Vector2.zero;
    }
    
    public float TweenPosToInBoundAtSpeed( Vector3 pos, float speed )
    {
        if( pos == _Camera.transform.position )
            return 0;

        if( _TweenPosCoroutine != null )
            return 0;

        pos.z = _Camera.transform.position.z;

        float duration = ( pos - _Camera.transform.position ).magnitude / speed;

		_TweenPosCoroutine = StartCoroutine( TweenPosInBound( pos, ( pos - _Camera.transform.position ).magnitude / speed ) );

        _Momentum = Vector2.zero;

        return duration;
    }

	public void TweenSizeTo( float size, float duration )
	{
        _TweenSize = _Camera.orthographicSize;

        if( size == _Camera.orthographicSize )
            return;

        if( _TweenSizeCoroutine != null )
            return;

        _TweenDuration = duration;
		_TweenSizeCoroutine = StartCoroutine( TweenSize( size, duration ) );
        
        _Momentum = Vector2.zero;
	}

    public void TweenSizeBack()
    {
		StartCoroutine( TweenSize( _TweenSize, _TweenDuration ) );
    }

    public void TweenAllBack()
    {
		StartCoroutine( TweenSize( _TweenSize, _TweenDuration ) );
		StartCoroutine( TweenPos( _TweenPosition, _TweenDuration ) );
        
        _Momentum = Vector2.zero;
    }

    public void TweenStop()
    {
        StopAllCoroutines();
        _TweenPosCoroutine = null;
        _TweenSizeCoroutine = null;
    }

    public void Shake( float strength, float rate, float time )
    {
        Shake shake = GetComponent<Shake>();

        if( shake == null )
        {
            shake = gameObject.AddComponent<Shake>();
        }
        shake.shakeStrength = strength;
        shake.shakeRate = rate;
        shake.shakeTime = time;

        shake.Play();
    }

    public void Reset()
    {
        _TweenSize = _initOrthographicSize;

        // 摄像机默认值
        _Camera.orthographicSize = _initOrthographicSize;
#if UNITY_STANDALONE || UNITY_EDITOR
        Zoom(0,Vector3.zero);
#else
        ZoomMove(0,Vector3.zero,Vector3.zero);
#endif
        MoveTo(_initPos);
    }

    // 矫正子摄影机的缩放 
    void RefreshSubCamera()
    {
        if ( subCamera == null )
            return;

        if ( subCamera.orthographic )
        {
            subCamera.orthographicSize = _Camera.orthographicSize;
        }
        else
        {
            subCamera.fieldOfView = 10f + _Camera.orthographicSize * 4.9f;
        }
    }
    
    protected virtual void OnTween(){}
    protected virtual void OnTouch( Vector2 screenPos ){}
    protected virtual void OnTouchRelease( Vector2 screenPos )
    {
    }
	
	protected abstract void OnDragStart( Vector2 pos );
	protected abstract void OnDrag( Vector2 pos );
	protected abstract void OnDragEnd();
	protected abstract void OnClick( Transform obj );
	protected abstract void OnPress( Transform obj );
}
