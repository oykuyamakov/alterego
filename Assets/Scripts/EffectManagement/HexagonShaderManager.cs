using InputManagement;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Serialization;

namespace EffectManagement
{
    public class HexagonShaderManager : MonoBehaviour
    {
        private Material hexagonMaterial => GetComponent<MeshRenderer>().material;
        
        [SerializeField]
        private Vector2 m_RotationSpeedMinMax = new Vector2(0.01f, 20f);
        [SerializeField]
        private Vector2 m_ColorChangeSpeedMinMax =  new Vector2(0f, 25);
        [SerializeField]
        private Vector2 m_JitterSpeedMinMax =  new Vector2(0f, 200);
        [SerializeField]
        private Vector2 m_TextureScaleMinMax =  new Vector2(0.1f, 10.0f);
        
        private Vector2 m_ShapeSize = new Vector2(0.1f, 1.0f);
        private Vector2Int m_NumShapes = new Vector2Int(1, 10);
        
        private float rotationSpeed;
        private float colorChangeSpeed;
        private float jitterSpeed;
        private float textureScale;
        
        private int numShapes;
        private float shapeSize;
        
        private void Update()
        {
            rotationSpeed = math.remap(0, 1, m_RotationSpeedMinMax.x,m_RotationSpeedMinMax.y,MidiInputGetter.Instance.K1); 
            colorChangeSpeed = math.remap(0, 1, m_ColorChangeSpeedMinMax.x,m_ColorChangeSpeedMinMax.y,MidiInputGetter.Instance.K2);
            jitterSpeed = math.remap(0, 1, m_JitterSpeedMinMax.x,m_JitterSpeedMinMax.y,MidiInputGetter.Instance.K3);
            textureScale = math.remap(0, 1, m_TextureScaleMinMax.x,m_TextureScaleMinMax.y,MidiInputGetter.Instance.K4);
            
            
            shapeSize = math.remap(0, 1, m_ShapeSize.x,m_ShapeSize.y,MidiInputGetter.Instance.K5);
            numShapes = (int)math.remap(0, 1, m_NumShapes.x,m_NumShapes.y,MidiInputGetter.Instance.K6);
            
            
            
            hexagonMaterial.SetFloat("_ShapeSize", shapeSize);
            hexagonMaterial.SetFloat("_NumShapes", numShapes);
            
            hexagonMaterial.SetFloat("_RotationSpeed", rotationSpeed);
            hexagonMaterial.SetFloat("_ColorChangeSpeed", colorChangeSpeed);
            hexagonMaterial.SetFloat("_ShapeJitterSpeed", jitterSpeed);
            hexagonMaterial.SetFloat("_TextureScale", textureScale);
            
            
        }
    }
}
