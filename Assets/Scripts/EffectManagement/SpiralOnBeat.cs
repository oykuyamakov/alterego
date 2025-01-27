using DG.Tweening;
using InputManagement;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

namespace AlterEgo
{
    public class SpiralOnBeat : MonoBehaviour
    {
        private Renderer m_Rend => GetComponent<MeshRenderer>();
        private Material m_Material => m_Rend.material;
        
        [SerializeField]
        private float m_ColorPulseDuration = 2.0f;
        
        private Vector2 speedMinMax =  new Vector2(0.8f, 4.0f);
        private Vector2 scaleMinMax =  new Vector2(0.1f, 20f);
        private Vector2 thicnessMinMax =  new Vector2(1.5f, 3f);
        
        private Vector2 waveIntensityMinMax =  new Vector2(0f, 2f);
        private Vector2 gradientMinMax =  new Vector2(0f, 1f);
        private Vector2 colorMinMax =  new Vector2(0.5f, 5f);
        
        private float speed;
        private float scale;
        private float thicness;

        private float wave;
        private float colorIntensity;
        private float gradientIntensity;
        
        private bool shapeChanged = false;
        private int shapeIndex = 1;
        
        private readonly Color[] colors = {
            new(0.5f, 0.0f, 0.5f), // Purple
            new(0.0f, 0.0f, 1.0f), // Blue
            new(.5f, 0.0f, .8f), // Pink
            new(.4f, 0.8f, 0.4f), // Orange
            new(.4f, 0.8f, 0.9f),
            new(.9f, 0.8f, 0.9f),
        };
        
        public void PulseColor()
        {
            m_Material.SetFloat("_ColorPulseBeat", 1.0f);
            
            float scaledValue = Random.Range(0f,1f) * (colors.Length - 1);
            int colorIndex = Mathf.FloorToInt(scaledValue);
            int nextColorIndex = Mathf.Clamp(colorIndex + 1, 0, colors.Length - 1);

            float t = scaledValue - colorIndex; // Fraction between two indices
            Color interpolatedColor = Color.Lerp(colors[colorIndex], colors[nextColorIndex], t);
            m_Material.SetColor("_PulseColor", interpolatedColor);
        }

        public void PulseThicness()
        {
            m_Material.SetFloat("_Linethicness", Random.Range(thicnessMinMax.x, thicnessMinMax.y));
        }

        public void PulseGradient()
        {
            if(scale < 15)
                return;
            
            m_Material.DOFloat(scale > 3 ? 1 : 0.1f, "_GradientMix", 0.6f).OnComplete(() =>
            {
                m_Material.DOFloat(0, "_GradientMix", 0.2f);
            });
        }

        private void SetSpeed()
        {
            var cVel = MidiInputGetter.Instance.K1 > 0 ? 0.0f : 0f;
            var tempSpeed = math.remap(0, 1, speedMinMax.x,speedMinMax.y,MidiInputGetter.Instance.K1);
            var smoothSpeed = MidiInputGetter.Instance.K1 > 0 ? 1f : 0.001f;
            speed = Mathf.SmoothDamp(speed, tempSpeed, ref cVel, smoothSpeed);
            
            m_Material.SetFloat("_Speed", speed);
        }

        private void SetScale()
        {
            var scaleVel = MidiInputGetter.Instance.K2 > 0 ? 0.0f : 0f;
            var tempScale = math.remap(0, 1, scaleMinMax.x, scaleMinMax.y, MidiInputGetter.Instance.K2);
            var smoothScale = MidiInputGetter.Instance.K2 > 0 ? 0.15f : 0.001f;
            scale = Mathf.SmoothDamp(scale, tempScale, ref scaleVel, smoothScale);
            m_Material.SetFloat("_Scale", scale);
        }

        private void SetWave()
        {
            if (scale < 4)
            {
                if (scale < 2)
                {
                    wave = 0;
                    m_Material.SetFloat("_WaveIntensity", wave);
                    return;
                }
                
                
                wave = math.remap(2, 5, 0, 0.3f, scale);
                m_Material.SetFloat("_WaveIntensity", wave);
                return;
            }
            
            // wave = math.remap(0, 1, waveIntensityMinMax.x,waveIntensityMinMax.y,MidiInputGetter.Instance.K3);
            // m_Material.SetFloat("_WaveIntensity", wave);
        }

        private void SetGradient()
        {
            gradientIntensity = math.remap(0, 1, gradientMinMax.x, gradientMinMax.y, MidiInputGetter.Instance.K4);
            m_Material.SetFloat("_GradientMix", gradientIntensity);
        }

        private void SetColorAndIntensity()
        {
            
            colorIntensity = math.remap(0, 1, colorMinMax.x,colorMinMax.y,MidiInputGetter.Instance.K8);
            m_Material.SetFloat("_PulseColorIntensity", colorIntensity);
        }

        private void TrySwitchShape()
        {
            if (MidiInputGetter.Instance.Pad8 > 0f)
            {
                if (shapeChanged)
                {
                    return;
                }
                shapeChanged = true;
                m_Material.SetFloat("_ShapeType", shapeIndex);
                shapeIndex = (shapeIndex + 1) % 2;
            }
            else
            {
                shapeChanged = false;
            }

        }
        
        private void Update()
        {
            float curReacBeat = m_Material.GetFloat("_ColorPulseBeat");
            if (curReacBeat > 0)
            {
                m_Material.SetFloat("_ColorPulseBeat", Mathf.Max(0, curReacBeat - (1.0f / m_ColorPulseDuration) * Time.deltaTime));
            }
            
            //SetColorAndIntensity();
            SetSpeed();
            SetScale();
            SetWave();
            //SetGradient();
            
            TrySwitchShape();
            
        }

        
    }
}
