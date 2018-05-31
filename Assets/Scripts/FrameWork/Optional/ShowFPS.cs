using UnityEngine;
using System.Collections;

public class ShowFPS : MonoBehaviour
{
    public float updateInterval = 0.5f;
    private double lastInterval;
    private int frames = 0;
    private float currFPS;
    GUIStyle style = new GUIStyle();


    // Use this for initialization
    void Start()
    {
        lastInterval = Time.realtimeSinceStartup;
        frames = 0;

        style.fontSize = 24;
    }

    // Update is called once per frame
    void Update()
    {
        ++frames;
        float timeNow = Time.realtimeSinceStartup;
        if( timeNow > lastInterval + updateInterval )
        {
            currFPS = (float)( frames / ( timeNow - lastInterval ) );
            frames = 0;
            lastInterval = timeNow;
        }
    }

    private void OnGUI()
    {
        if( currFPS >= 20 )
            style.normal.textColor = Color.green;
        else if( currFPS > 10 )
            style.normal.textColor = Color.yellow;
        else
            style.normal.textColor = Color.red;

        GUILayout.Label( "FPS:" + currFPS.ToString( "f2" ), style );
    }
}
