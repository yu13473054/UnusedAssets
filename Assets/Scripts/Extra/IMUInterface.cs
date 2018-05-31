using System;
using UnityEngine;

public class IMUInterface : MonoBehaviour
{
    [Serializable]
    public class SetUp
    {
        [Header( "变化速率" )]
        public float change = 1f;   // 敏感度

        [Header( "回复速率" )]
        public float recover = 1f;   // 敏感度

        [Header( "最大值" )]
        public float maxValue = 10f;    // 最大值

        [Header( "比率" )]
        public Vector3 ratio = Vector3.one; // 比率
    }

    public Transform    changeTarget;     // 变化对象
    public Transform    recoverTarget;    // 回弹对象

    public bool         rotaionEnable = false;
    public SetUp        setUpRotation;

    public bool         positionEnable = false;
    public SetUp        setUpPostion;

    Vector3             _targetRotation;
    Vector3             _targetPos;

    void LateUpdate()
    {
        //////////////////////////////////////////////////////////////////
        // 变化流程
        if( changeTarget == null )
            return;

        Vector3 acceleration = Input.acceleration;

        // 旋转
        if( rotaionEnable )
        {
            _targetRotation.x = acceleration.y * setUpRotation.maxValue * setUpRotation.ratio.x;
            _targetRotation.y = -acceleration.x * setUpRotation.maxValue * setUpRotation.ratio.y;
            _targetRotation.z = -acceleration.z * setUpRotation.maxValue * setUpRotation.ratio.z;
            changeTarget.localRotation = Quaternion.Lerp( changeTarget.localRotation, Quaternion.Euler( _targetRotation ), Time.deltaTime * setUpRotation.change );
        }

        // 位移
        if( positionEnable )
        {
            _targetPos.x = acceleration.x * setUpPostion.ratio.x * setUpPostion.maxValue;
            _targetPos.y = acceleration.y * setUpPostion.ratio.y * setUpPostion.maxValue;
            _targetPos.z = -acceleration.z * setUpPostion.ratio.z * setUpPostion.maxValue;
            changeTarget.localPosition = Vector3.Lerp( changeTarget.localPosition, _targetPos, Time.deltaTime * setUpPostion.change );
        }

        /////////////////////////////////////////////////////////////////
        // 回弹流程
        if( recoverTarget == null )
            return;

        // 旋转
        if( rotaionEnable )
            recoverTarget.localRotation = Quaternion.Lerp( recoverTarget.localRotation, Quaternion.Inverse( changeTarget.localRotation ), Time.deltaTime * setUpRotation.recover );

        // 位移
        if( positionEnable )
            recoverTarget.localPosition = Vector3.Lerp( recoverTarget.localPosition, -changeTarget.localPosition, Time.deltaTime * setUpPostion.recover );
    }
}