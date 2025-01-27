using System;
using System.Collections.Generic;
using DG.Tweening;
using InputManagement;
using Unity.Mathematics;
using UnityEngine;

namespace AlterEgo
{
    public class KaleiOnBeat : MonoBehaviour
    {
        private Renderer m_Rend => GetComponent<MeshRenderer>();
        private Material m_Material => m_Rend.material;
        
        private List<float> m_KaleiNValues = new List<float>()
        {
            0f,
            40f,
            20f,
            5f,
            50f
        };
        
        private Vector2 m_LineCountMinMax = new Vector2(0f,100);
        private Vector2 m_ScaleMinMax = new Vector2(1f,35f);
        private Vector2 m_FlowerNMinMax = new Vector2(1f, 5f);

        private float m_LineCount;
        private float m_Scale;
        private float m_FlowerN;
        
        private float m_LineKnob => MidiInputGetter.Instance.K7;
        private float m_ScaleKnob => MidiInputGetter.Instance.K8;
        //private float m_FlowerNKnob => MidiInputGetter.Instance.K8;
        
        private int m_KaleiNIndex = 0;

        private int m_FlowerIndex = 0;
        
        public void PulseKaleiN()
        {
            m_KaleiNIndex = m_KaleiNIndex+1;

            m_Material.DOFloat(m_KaleiNValues[m_KaleiNIndex % m_KaleiNValues.Count], "_KaleiX",0.2f);

        } 
        
        public void PulseFlower()
        {
            m_FlowerIndex += 1;

            m_Material.DOFloat(m_FlowerIndex % 2 == 0 ? m_FlowerNMinMax.x : m_FlowerNMinMax.y, "_FlowerN",0.2f);

        }

        private void SetLineCount()
        {
            var lineVel = 0f;
            var tempLine = math.remap(0, 1, m_LineCountMinMax.x, m_LineCountMinMax.y, m_LineKnob);
            var smoothScale = 0.1f;
            m_LineCount = Mathf.SmoothDamp(m_LineCount, tempLine, ref lineVel, smoothScale);
            m_Material.SetFloat("_Count", m_LineCount);
        }  
        
        private void SetScale()
        {
            var scaleVel = 0f;
            var tempScale = math.remap(0, 1, m_ScaleMinMax.x, m_ScaleMinMax.y, m_ScaleKnob);
            var smoothScale = 0.1f;
            m_Scale = Mathf.SmoothDamp(m_Scale, tempScale, ref scaleVel, smoothScale);
            m_Material.SetFloat("_Scale", m_Scale);
        }

        // private void SetFlower()
        // {
        //     var flowerVel = 0f;
        //     var tempFlower = math.remap(0, 1, m_FlowerNMinMax.x, m_FlowerNMinMax.y, m_FlowerNKnob);
        //     var smoothFlower = 0.1f;
        //     m_FlowerN = Mathf.SmoothDamp(m_FlowerN, tempFlower, ref flowerVel, smoothFlower);
        //     m_Material.SetFloat("_FlowerN", m_FlowerN);
        // }

        private void Update()
        {
            SetLineCount();
            SetScale();
            //SetFlower();
        }
    }
}
