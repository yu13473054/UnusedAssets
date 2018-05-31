using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIImage : Image
{
    private Material _defaultMat;

    public bool isGray
    {
        set
        {
            if (value)
            {
                if(!defaultMaterial) _defaultMat = material;
                material = ResourceManager.instance.LoadMaterial("UI_Mat_SpriteGray");
            }
            else
            {
                if (defaultMaterial) material = _defaultMat;
            }
        }
    }
}
