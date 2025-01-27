using System;
using System.Collections;
using InputManagement;
using Sirenix.OdinInspector;
using UnityEngine;

namespace CameraHandling
{
    public class CustomMoshManager : MonoBehaviour
    {
        #region Mosh Manipulation Variables

        [SerializeField] [Tooltip("Size of Macroblock.")]
        private int m_BlockSize = 16;
        
        public int BlockSize
        {
            get => Mathf.Clamp(m_BlockSize,0, 4);
            set => m_BlockSize = value;
        }
        
        [SerializeField, Range(0, 2)] [Tooltip("Scale factor for velocity vectors.")]
        private float m_VelocityVectorScale = 0.8f;

        public float VelocityVectorScale
        {
            get => m_VelocityVectorScale;
            set
            {
                if(value is >= 0f and <= 2f)
                    m_VelocityVectorScale = value;
                else
                {
                    Debug.Log("cant set VELOCITY to value outside of 0.5-4 range");
                }
            }
        }

        [SerializeField, Range(0, 1)] [Tooltip("The larger value makes the stronger noise.")]
        private float m_Entropy = 0.5f;

        public float Entropy
        {
            get => m_Entropy;
            set
            {
                if(value is >= 0f and <= 1f)
                    m_Entropy = value;
                else
                {
                    Debug.Log("cant set entropy to value outside of 0.5-4 range");
                }
            }
        }

        [SerializeField, Range(0.5f, 4.0f)]
        private float m_NoiseContrast = 1;
        
        /// Contrast of stripe-shaped noise.
        public float NoiseContrast
        {
            get => m_NoiseContrast;
            set
            {
                if(value is >= 0.5f and <= 4.0f)
                    m_NoiseContrast = value;
                else
                {
                    Debug.Log("cant set noise to value outside of 0.5-4 range");
                }
            }
        }

        [SerializeField, Range(0, 2)] 
        float m_Diffusion = 0.4f;
        
        /// Amount of random displacement.
        public float Diffusion
        {
            get => m_Diffusion;
            set
            {
                if(value >= 0 && value <= 2)
                    m_Diffusion = value;
                else
                {
                    Debug.Log("cant set diffusion to value outside of 0-2 range");
                }
            }
        }

        #endregion
        
        [SerializeField] 
        private Shader m_Shader;
        
        //Note: we wont be able to get motion vectors of video so no real moshing for videoitslef
        [SerializeField] 
        private RenderTexture m_VideoRenderTexture;

        private Material m_Material;
        
        //Blit changes RenderTexture.active. Store the active render texture before you use Blit if you need to use it afterwards.
        private RenderTexture m_WorkBuffer; 
        private RenderTexture m_DispBuffer; 

        private int m_MoshSequence;
        private int m_LastFrame;
        public enum Mode
        {
            Cam = 0,
            Video = 1
        }
        
        public Mode m_Mode = Mode.Video;
        
        private RenderTexture NewWorkBuffer(RenderTexture source)
        {
            return RenderTexture.GetTemporary(source.width, source.height);
        }

        private RenderTexture NewDispBuffer(RenderTexture source)
        {
            var rt = RenderTexture.GetTemporary(
                source.width / m_BlockSize,
                source.height / m_BlockSize,
                //In linear color space, set GL.sRGBWrite before using Blit, to make sure the sRGB-to-linear color conversion is what you expect.
                0, RenderTextureFormat.ARGBHalf
            );
            rt.filterMode = FilterMode.Point;
            return rt;
        }

        private void ReleaseBuffer(RenderTexture buffer)
        {
            if (buffer != null) RenderTexture.ReleaseTemporary(buffer);
        }
        
        void OnEnable()
        {
            m_Material = new Material(m_Shader);
            m_Material.hideFlags = HideFlags.DontSave;

            // TODO
            GetComponent<Camera>().depthTextureMode |=
                DepthTextureMode.Depth | DepthTextureMode.MotionVectors;

            m_MoshSequence = 0;
        }

        void OnDisable()
        {
            ReleaseBuffer(m_WorkBuffer);
            m_WorkBuffer = null;

            ReleaseBuffer(m_DispBuffer);
            m_DispBuffer = null;

            DestroyImmediate(m_Material);
            m_Material = null;
        }
        
        //Gets called after cam finished rendering, allowing you to manipulate the texture
        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            
            m_Material.SetFloat("_BlockSize", m_BlockSize);
            m_Material.SetFloat("_Quality", 1 - m_Entropy);
            m_Material.SetFloat("_Contrast", m_NoiseContrast);
            m_Material.SetFloat("_Velocity", m_VelocityVectorScale);
            m_Material.SetFloat("_Diffusion", m_Diffusion);
            
            //Switch between cam and video
            var viewTexture = m_Mode.GetHashCode() % 2 == 0 ? source : m_VideoRenderTexture;
            
            // Step 0: no effect, just keep the last frame.
            if (m_MoshSequence == 0)
            {
                // Initialize and update the working buffer with the current frame.
                ReleaseBuffer(m_WorkBuffer);
                m_WorkBuffer = NewWorkBuffer(viewTexture);
                //If you don't provide mat while blitting, Unity uses a default material.
                Graphics.Blit(viewTexture, m_WorkBuffer);

                // Blit without effect. Not sure why we are doing this......... and actually we should not blit same source and dest... TODO
                Graphics.Blit(viewTexture, destination);
            }
            // Step 1: start effect, no moshing.
            else if (m_MoshSequence == 1)
            {
                // Initialize the displacement buffer.
                ReleaseBuffer(m_DispBuffer);
                m_DispBuffer = NewDispBuffer(viewTexture);
           
                //If the value is -1, Unity draws all the passes in mat. Otherwise, Unity draws only the pass you set pass to, The default value is -1.
                //Initializes the displacement buffer with the first pass of the mosh material. Which does nothing
                Graphics.Blit(null, m_DispBuffer, m_Material, 0);

                // Simply blit the working buffer because motion vectors might not be ready (because of sudden camera pos change) TODO
                Graphics.Blit(m_WorkBuffer, destination);

                m_MoshSequence++;
            }
            else
            {
                // Final step: apply effect cont.

                if (Time.frameCount != m_LastFrame)
                {
                    // Update the displacement buffer with the adding the second pass of the mosh material.
                    var newDisp = NewDispBuffer(viewTexture);
                    Graphics.Blit(m_DispBuffer, newDisp, m_Material, 1);
                    ReleaseBuffer(m_DispBuffer);
                    m_DispBuffer = newDisp;

                    // Moshing!
                    m_Material.SetTexture("_WorkTex", m_WorkBuffer);
                    m_Material.SetTexture("_DispTex", m_DispBuffer);
                    
                    //Get the current view texture, and blit it with itself by adding the mosh mat with the third pass (which has previous frame 
                    //texture, and displaced texture.
                    var newWork = NewWorkBuffer(viewTexture);
                    Graphics.Blit(viewTexture, newWork, m_Material, 2);
                    
                    // Update the working buffer with the result.
                    ReleaseBuffer(m_WorkBuffer);
                    m_WorkBuffer = newWork;

                    m_LastFrame = Time.frameCount;
                }

                // Blit the result to the cam fully
                Graphics.Blit(m_WorkBuffer, destination);
            }
        }
        
        [Button]
        public void SwitchMode()
        {
            m_Mode = m_Mode.GetHashCode() % 2 == 0 ? Mode.Video : Mode.Cam;
        }
        
        public void SwitchMode(Mode mode)
        {
            m_Mode = mode;
        }
        
        [Button]
        public void KickGlitch()
        {
            m_MoshSequence = 1;
        }

        //TODO THIS SHOULD NOT BE HERE
        private bool beatKick = false;
        private bool beatSwitched = false;

        private void Update()
        {
            if (MidiInputGetter.Instance.Pad7 > 0f)
            {
                if(beatSwitched)
                    return;
                
                beatSwitched = true;
                
                beatKick = !beatKick;
            }
            else
            {
                beatSwitched = false;
            }
        }

        public void BeatKickGlitchWithPad()
        {
            if (beatKick)
            {
                KickGlitch();
            }
        }

        /// Stop glitching.
        public void Reset()
        {
            m_MoshSequence = 0;
        }
    }
}
