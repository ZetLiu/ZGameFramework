using UnityEngine;
using ZFramework;

public class GameLaunch : MonoBehaviour
{
    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
        Debug.Log("Game GameLaunch!");
    }

    void Start()
    {
        LuaManager.Instance.Init();
    }
}
