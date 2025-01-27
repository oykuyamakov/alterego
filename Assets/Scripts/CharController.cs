using System;
using System.Collections;
using System.Collections.Generic;
using InputManagement;
using Sirenix.OdinInspector;
using UnityEngine;

public class CharController : MonoBehaviour
{
    [SerializeField]
    private List<GameObject> m_Characters;

    [SerializeField] 
    private float m_Speed;
    
    private bool m_Right = true;

    [SerializeField]
    public bool m_DoIt;

    private bool m_DoinIt;
    
    private bool m_LeftItOpen = false;
    private bool m_Opened = false;

    private void Update()
    {
        EnableAnim();
    }


    public void EnableAnim()
    {
        if (MidiInputGetter.Instance.Pad1 > 0)
        {
            if(m_Opened)
                return;
                
            m_Opened = true;
                
            m_LeftItOpen = !m_LeftItOpen;
        }
        else
        {
            m_Opened = false;
        }
        
        
        
        if (MidiInputGetter.Instance.Pad2 > 0)
        {
            if(m_DoinIt)
                return;
                
            m_DoinIt = true;
                
            m_DoIt = !m_DoIt;
        }
        else
        {
            m_DoinIt = false;
        }
            
    }
    
    
    public void Ananza()
    {
        if(!m_DoIt)
            return;
        
        StartCoroutine(ToggleChars());
    }

    private void EnableAll()
    {
        foreach (var chare in m_Characters)
        {
            chare.SetActive(true);
        }
    }

    private void DisableAll()
    {
        foreach (var chare in m_Characters)
        {
            chare.SetActive(false);
        }
    }


    private IEnumerator ToggleChars()
    {
        m_Right = !m_Right;

        if (m_Right)
        {
            for (int i = 0; i < m_Characters.Count; i++)
            {
                m_Characters[i].SetActive(!m_LeftItOpen);
                yield return new WaitForSeconds(m_Speed);
            }
        
            for (int i = m_Characters.Count-1; i >= 0; i--)
            {
                m_Characters[i].SetActive(m_LeftItOpen);
                yield return new WaitForSeconds(m_Speed);
            }
        }
        else
        {
            for (int i = m_Characters.Count-1; i >= 0; i--)
            {
                m_Characters[i].SetActive(!m_LeftItOpen);
                yield return new WaitForSeconds(m_Speed);
            }
            
            for (int i = 0; i < m_Characters.Count; i++)
            {
                m_Characters[i].SetActive(m_LeftItOpen);
                yield return new WaitForSeconds(m_Speed);
            }
        }

        //yield return new WaitForSeconds(m_Speed);
    }
    
   
}
