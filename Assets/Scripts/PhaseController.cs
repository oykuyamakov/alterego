using System;
using System.Collections.Generic;
using CameraHandling;
using DG.Tweening;
using InputManagement;
using Sirenix.OdinInspector;
using SoundManagement;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.SceneManagement;
using UnityEngine.Video;

public class PhaseController : MonoBehaviour
{
    [SerializeField]
    private List<BackgroundController> BackgroundController;
    
    [SerializeField] 
    private SongBeatTracker m_SongBeatTracker;
    
    [SerializeField]
    private CustomMoshManager m_CustomMoshManager;

    [SerializeField] private GameObject m_Terrain;
    [SerializeField] private List<GameObject> m_RandVideos;
    
    private AudioSource m_AudioSource => GetComponent<AudioSource>();
    
    private bool phase2 = false;
    
    private float m_Timer = 0f;

    private bool m_TimerStart = false;
    private float m_Length = 0f;
    

    //stopvideo kickglitch startsecond song


    private void Awake()
    {
        AdjustVignette(0);
    }

    private void StartPhase2()
    {
        if(phase2)
            return;

        if (MidiInputGetter.Instance.Do2 > 0f)
        {
            phase2 = true;
        
            m_AudioSource.Stop();
            
            foreach (var background in BackgroundController)
            {
                background.StopVideo();
            }
            m_CustomMoshManager.KickGlitch();
            m_SongBeatTracker.StartPlaying();
            m_Length = m_SongBeatTracker.Lenght;
            m_TimerStart = true;
            
            foreach (var vid in m_RandVideos)
            {
                vid.SetActive(false);
            }
            
            m_Terrain.SetActive(false);
        }
    }

    private bool videoToggle = false;

    private void PhaseCont()
    {
        if (MidiInputGetter.Instance.Re2 > 0f)
        {
            if (!videoToggle)
            {
                videoToggle = true;
                Debug.Log("hey");
                
                foreach (var background in BackgroundController)
                {
                    background.ToggleVideo();
                }
            }
        }
        else
        {
            videoToggle = false;
        }
    }
    
    private bool materialSwitch = false;

    private void MaterialSwitch()
    {
        if(materialSwitch)
            return;
        
        if (MidiInputGetter.Instance.Mi2 > 0f)
        {
            materialSwitch = true;
        
            foreach (var background in BackgroundController)
            {
                background.SwitchMaterial();
            }
            
        }
        
    }

    [SerializeField]
    private List<GameObject> m_FinishVideos;

    [SerializeField]
    private PostProcessProfile m_Profile;
    
    private VignetteMode vignette;

    [Button]
    private void AdjustVignette(float val)
    {
        var s = m_Profile.GetSetting<Vignette>();

        
        if (s!= null)
        {
            //Debug.Log("anani");

            DOTween.To(() => s.intensity.value, x => s.intensity.value = x, val, 3f);
        }
    }
    
    private void Update()
    {
        StartPhase2();
        PhaseCont();
        MaterialSwitch();
        
        if (m_TimerStart)
        {
            m_Timer += Time.deltaTime;
            if (m_Timer >= m_Length)
            {
                m_TimerStart = false;
                
                foreach (var vid in m_FinishVideos)
                {
                    vid.GetComponent<VideoPlayer>().Stop();
                }
                AdjustVignette(1);
            }
        }

        if (Input.GetKey(KeyCode.R))
        {
            if (Input.GetKeyDown(KeyCode.P))
            {
                SceneManager.LoadScene("Intro");
            }
        }
    }
}
