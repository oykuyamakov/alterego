using System;
using System.Collections;
using System.Collections.Generic;
using AlterEgo;
using Shaders.Shader_Toy_shaders.Promising.Fin.Trial;
using UnityCommon.Modules;
using UnityEngine;
using UnityEngine.Video;

public class BackgroundController : MonoBehaviour
{
    [SerializeField] 
    private Material m_SwitchMat;
    
    private Renderer m_Renderer => GetComponent<Renderer>();
    
    private VideoPlayer m_VideoPlayer => GetComponent<VideoPlayer>();


    public void ToggleVideo()
    {
        if (m_VideoPlayer.isPlaying)
        {
            m_VideoPlayer.playbackSpeed = 0;
        }
        else
        {
            m_VideoPlayer.playbackSpeed = 1;
        }
    }
    
    public void StopVideo()
    {
        m_VideoPlayer.playbackSpeed = 0;
    }
    
    public void SwitchMaterial()
    {
        m_Renderer.material = m_SwitchMat;

        if (TryGetComponent<SpiralOnBeat>(out var spiral))
        {
            spiral.enabled = true;
        }

        if (TryGetComponent<KaleiOnBeat>(out var kalei))
        {
            kalei.enabled = true;
        }
    }
}
