using UnityEngine;
using UnityEngine.EventSystems;
using System.Collections;
using LuaInterface;
public enum UILayer
{
    FULL = 0,
    POP = 1,
    TOP = 2,
}

public enum UIState
{
    NORMAL,
    DONTDESTROY,
    DESTROYONCLOSE,
}

public class UISystem : UIMod
{
    public UILayer layer = UILayer.POP;
    public UIState uiState = UIState.NORMAL;

}
