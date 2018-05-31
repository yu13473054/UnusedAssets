using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class AssetsUpdate : MonoBehaviour
{
    [SerializeField]
    private Text _hintText;
    [SerializeField]
    private Slider _slider;

	void Start ()
	{
        _slider.gameObject.SetActive(false);
        _hintText.gameObject.SetActive(false);
    }

    public void UpdateProgress(string text, float value)
    {
        if(!_slider.IsActive())
            _slider.gameObject.SetActive(true);
        if(!_hintText.IsActive())
            _hintText.gameObject.SetActive(true);

        _hintText.text = text;
        _slider.value = value;
    }

    /// <summary>
    /// 资源更新和加载完毕，调用
    /// </summary>
    public void UpdateDone()
    {
        _slider.gameObject.SetActive(false);
        _hintText.gameObject.SetActive(false);
    }

}
