using UnityEngine;

namespace Shaders.Eye
{
    [RequireComponent(typeof(AudioSource))]
    public class AudioDataEye : MonoBehaviour
    {
        public Material targetMaterial; // Assign your material with the shader
        private AudioSource audioSource;
        private float[] spectrumData = new float[64]; // Array to hold frequency data

        void Start()
        {
            // Get the AudioSource component
            audioSource = GetComponent<AudioSource>();

            // Ensure the audio source is playing
            if (!audioSource.isPlaying)
            {
                audioSource.Play();
            }
        }

        void Update()
        {
            // Get spectrum data from the audio source
            audioSource.GetSpectrumData(spectrumData, 0, FFTWindow.Hamming);

            // Use a specific frequency band or aggregate
            float audioValue = spectrumData[1] * 10.0f; // Amplify for visibility

            // Pass the audio data to the shader
            if (targetMaterial != null)
            {
                targetMaterial.SetVector("_AudioData", new Vector4(audioValue, 0, 0, 0));
            }
        }
    }
}