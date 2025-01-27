using UnityEngine;

public class WebcamGetter : MonoBehaviour
{
    public RenderTexture renderTexture; // Assign your RenderTexture in the Inspector
    private WebCamTexture webcamTexture;

    void Start()
    {
        // Get the list of connected webcams
        WebCamDevice[] devices = WebCamTexture.devices;

        if (devices.Length > 0)
        {
            // Use the first available webcam
            string cameraName = devices[0].name;
            webcamTexture = new WebCamTexture(cameraName);

            // Start the webcam
            webcamTexture.Play();
        }
        else
        {
            Debug.LogError("No webcams found!");
        }
    }

    void Update()
    {
        if (webcamTexture != null && webcamTexture.isPlaying)
        {
            // Copy the webcam texture to the render texture
            Graphics.Blit(webcamTexture, renderTexture);
        }
    }

    void OnDisable()
    {
        // Stop the webcam when the script is disabled
        if (webcamTexture != null && webcamTexture.isPlaying)
        {
            webcamTexture.Stop();
        }
    }
}