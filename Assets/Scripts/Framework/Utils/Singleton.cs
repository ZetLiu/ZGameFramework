// ������

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
                    // ��֤�����̰߳�ȫ
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
