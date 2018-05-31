using UnityEngine;
using System.Collections;

public class Shake : MonoBehaviour
{
	public Transform target;
    public bool playOnEnable = false;
    public float shakeDelay = 0;
    public float shakeStrength = 10f;
    public float shakeRate = 0.1f;
    public float shakeTime = 0;

    bool   _shake = false;


    void OnEnable()
    {
        if( playOnEnable )
            Play();
    }

    void OnDisable()
    {
        StopAllCoroutines();
    }

    public void Play( float strength, float rate, float time )
    {
        shakeStrength = strength;
        shakeRate = rate;
        shakeTime = time;

        Play();
    }

    public void Play()
    {
        _shake = true;
        StartCoroutine( ShakeUpdate() );

		if (target == null)
			target = transform;
    }

    public void Stop()
    {
        _shake = false;
    }

    IEnumerator ShakeUpdate()
    {
        float timer = 0;
        if( shakeTime == 0 )
            timer = -1;
        
        yield return new WaitForSeconds( shakeDelay );

		Vector3 orgPosition = target.localPosition;
        while ( timer < shakeTime && _shake )
        {
            if( shakeTime != 0 )
            {
                if( shakeRate != 0 )
                    timer += shakeRate;
                else
                    timer += Time.deltaTime;
            }

            Vector3 newPos = orgPosition + new Vector3( Random.Range( -shakeStrength, shakeStrength ), Random.Range( -shakeStrength, shakeStrength ), 0 );
			target.localPosition = newPos;

            yield return new WaitForSeconds( shakeRate );
        }

		target.localPosition = orgPosition;
    }
}
