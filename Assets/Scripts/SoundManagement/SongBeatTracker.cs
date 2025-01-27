using System;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityCommon.Modules;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Serialization;

namespace SoundManagement
{
    [RequireComponent(typeof(AudioSource))]
    public class SongBeatTracker : MonoBehaviour
    {
        [SerializeField]
        private float m_Bpm;
        [SerializeField]
        private List<Beat> m_Beats;
        private AudioSource audioSource => GetComponent<AudioSource>();
        
        private bool m_IsPlaying = false;
        
        public float Lenght => audioSource.clip.length;
        

        public void StartPlaying()
        {
            m_IsPlaying = true;
            audioSource.Play();
        }

        private void Update()
        {
            if(m_IsPlaying == false) return;
            
            foreach (var interval in m_Beats)
            {
                float sampleTime = audioSource.timeSamples /
                                   (audioSource.clip.frequency * interval.GetBeatLenght(m_Bpm));
                interval.CheckForNewInterval(sampleTime);

            }
        }
        
    }


    [System.Serializable]
    public class Beat
    {
        public float Value;
        public UnityEvent ActionOnBeat;
        private int lastInterval;
        
        public float GetBeatLenght(float bpm)
        {
            return 60f / bpm * Value;
        }

        public void CheckForNewInterval(float interval)
        {
            if (Mathf.FloorToInt(interval) != lastInterval)
            {
                lastInterval = Mathf.FloorToInt(interval);
                ActionOnBeat?.Invoke();
            }
        }

    }
}
