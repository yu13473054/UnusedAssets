using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using DG.Tweening;
using Spine.Unity;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.U2D;
using UnityEngine.UI;

public class Test : MonoBehaviour
{
    public UIScrollView sv;
    public UIScrollbar bar;
    void Awake()
    {
        GameObject go = new GameObject();

        SkeletonAnimation anim = go.GetComponent<SkeletonAnimation>();
        transform.localScale = new Vector3(100,100,100);
        transform.gameObject.layer = LayerMask.NameToLayer("UI");
        if (anim)
        {
        }
        UIToggle uiToggle;
    }

    void OnEnable()
    {
        sv.onValueChanged.AddListener(SetBarPostion);
        bar.onValueChanged.AddListener(SetSVNormalizedPosition);
    }


    void OnDisable()
    {
        sv.onValueChanged.RemoveListener(SetBarPostion);
        bar.onValueChanged.RemoveListener(SetSVNormalizedPosition);
    }

    private void SetBarPostion(Vector2 delta)
    {
        Debug.Log(111111111111);
        bar.value = delta.y;
    }

    void SetSVNormalizedPosition(float value)
    {
        Debug.Log(22222222222);
        sv.verticalNormalizedPosition = value;
    }

    void Start()
    {
    }

    // Update is called once per frame
	void Update () {
	    if (Input.anyKeyDown)
	    {
//            go.SetActive(true);
//	        Transform trans = go.transform;
//	        for (int i = 0; i < trans.childCount; i++)
//	        {
//	            trans.GetChild(i).gameObject.SetActive(false);
//	        }
//            DOTweenAnimation[] anims = go.GetComponents<DOTweenAnimation>();
//	        DOTweenAnimation longestAnim = anims[0];
//	        float dura = 0;
//	        for (int i = 0; i < anims.Length; i++)
//	        {
//	            DOTweenAnimation anim = anims[i];
////                anim.CreateTween();
//	            anim.DOPlay();
//
//	            if (anim.duration > dura)
//	            {
//	                dura = anim.duration;
//	                longestAnim = anim;
//	            }
//	        }
//            longestAnim.tween.onComplete = () =>
//            {
//                longestAnim.DORewind();
//                longestAnim.gameObject.SetActive(false);
//            };
        }
	}

    void OnDestroy()
    {
        
        Debug.Log(gameObject.name+"    "+gameObject.transform.childCount);
    }
}
