using UnityEngine;

/// <summary>
/// 功能：Unity单例
/// </summary>

namespace ZFramework
{
    public class MonoSingleton<T> : MonoBehaviour where T : Component
    {
        private static T instance = null;

        public static T Instance
        {
            get
            {
                if (instance == null)
                {
                    instance = FindObjectOfType(typeof(T)) as T;
                    if (instance == null)
                    {
                        GameObject go = new GameObject();
                        go.name = typeof(T).Name;
                        instance = go.AddComponent<T>();
                    }
                }

                return instance;
            }
        }

        public virtual void Awake()
        {
            DontDestroyOnLoad(this.gameObject);
            if (instance == null)
            {
                instance = this as T;
            }
            else
            {
                GameObject.Destroy(this.gameObject);
            }
        }

        public virtual void Init() { }
    }
}
