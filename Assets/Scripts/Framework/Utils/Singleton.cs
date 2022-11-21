/// <summary>
/// 功能：单例类
/// </summary>

namespace ZFramework
{
    public abstract class Singleton<T> where T : new()
    {
        private static T instance;
        private static object mutex = new object();

        public static T Instance
        {
            get
            {
                if (instance == null)
                {
                    // 保证单例线程安全
                    lock (mutex)
                    {
                        if (instance == null)
                        {
                            instance = new T();
                        }
                    }
                }

                return instance;
            }
        }
    }
}
