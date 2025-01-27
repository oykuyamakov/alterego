using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Loader : MonoBehaviour
{
    void Update()
    {
        if (Input.GetKey(KeyCode.R))
        {
            if (Input.GetKeyDown(KeyCode.P))
            {
                SceneManager.LoadScene("Trial 2");
            }
        }
        
    }
}
