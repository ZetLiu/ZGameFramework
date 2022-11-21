using UnityEngine;

/// <summary>
/// 功能：显示 FPS
/// </summary>

namespace ZFramework
{
    public class FPS : MonoSingleton<FPS>
    {
        // FPS 刷新间隔
        private float m_fRefreshDeltaTime = 0.5f;
        // 上一次统计FPS的时间;
        private float m_fLastRecordTime = 0.0f;
        // 计算出来的FPS的值;
        private float m_fFpsNum = 0.0f;
        // 累计我们刷新的帧数;
        private int m_iFrameCount = 0;
        // GUI 风格
        private GUIStyle m_kStyle;

        public override void Awake()
        {
            base.Awake();
            Application.targetFrameRate = 60;
        }

        void Start()
        {
            m_fLastRecordTime = Time.realtimeSinceStartup;
            m_iFrameCount = 0;

            m_kStyle = new GUIStyle();
            m_kStyle.fontSize = 15;
            m_kStyle.normal.textColor = Color.white;
        }

        void Update()
        {
            m_iFrameCount++;

            if (Time.realtimeSinceStartup >= m_fLastRecordTime + m_fRefreshDeltaTime)
            {
                m_fFpsNum = m_iFrameCount / (Time.realtimeSinceStartup - m_fLastRecordTime);
                m_fLastRecordTime = Time.realtimeSinceStartup;
                m_iFrameCount = 0;
            }
        }

        void OnGUI()
        {
            GUI.Label(new Rect(0, Screen.height - 20, 200, 200), "FPS:" + m_fFpsNum.ToString("f2"), m_kStyle);
        }
    }
}
