using System;
using InputManagement;
using UnityCommon.Runtime.Extensions;
using UnityEngine;

namespace AlterEgo.Models.Woman
{
    public class CharAnimatorController : MonoBehaviour
    {
        public Animator m_Animator => GetComponent<Animator>();
        private bool m_Jumped = false;
        private bool m_JumpValue = false;
        
        private bool m_Floated = false;
        private bool m_FloatValue = false;
        
        public void Jump()
        {
            if (MidiInputGetter.Instance.Pad3 > 0)
            {
                if(m_Jumped)
                    return;
                
                m_Jumped = true;
                
                //m_Animator.SetTrigger("Jump");
                m_JumpValue = !m_JumpValue;
                m_Animator.SetBool("Float", m_JumpValue);
            }
            else
            {
                m_Jumped = false;
            }
            
        }
        
        public void Fly()
        {
            if (MidiInputGetter.Instance.Pad4 > 0)
            {
                if(m_Floated)
                    return;
                
                m_Floated = true;
                
                m_FloatValue = !m_FloatValue;
                m_Animator.SetBool("Flying", m_FloatValue);
            }
            else
            {
                m_Floated = false;
            }
            
        }
        
        private void Update()
        {
            //Jump();
            Fly();
        }
    }
}
