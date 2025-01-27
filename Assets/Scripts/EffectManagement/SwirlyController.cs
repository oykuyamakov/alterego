using System;
using InputManagement;
using Unity.Mathematics;
using UnityEngine;

namespace Shaders.Shader_Toy_shaders.Promising.Fin.Trial
{
    public class SwirlyController : MonoBehaviour
    {
        // public Renderer rend => GetComponent<MeshRenderer>();
        // private Material material => rend.material;
        // public float pulseDuration = 1.0f;
        // public float ColorPulseDuration = 1.0f;
        // private float pulseDecay;
        //
        // [SerializeField]
        // private Vector2 reactiveSpeedMinMax = new Vector2(0.0f, 2f);
        // [SerializeField]
        // private Vector2 speedMinMax =  new Vector2(0f, 5f);
        // [SerializeField]
        // private Vector2 scaleMinMax =  new Vector2(0.1f, 20f);
        // [SerializeField]
        // private Vector2 thicnessMinMax =  new Vector2(0.1f, 2.0f);
        //
        // private float reactiveSpeed;
        // private float speed;
        // private float scale;
        // private float thicness;
        //
        //
        // void Start()
        // {
        //     pulseDecay = 1.0f / pulseDuration;
        // }
        //
        // // public void PulseCircle()
        // // {
        // //     material.SetFloat("_CirclePulseBeat", 1.0f);
        // // }
        // //
        // public void PulseColor()
        // {
        //     material.SetFloat("_ColorPulseBeat", 1.0f);
        // }
        //
        // public void PulseGlow()
        // {
        //     material.SetFloat("_GlowPulseBeat", 1.0f);
        // }
        //
        //
        // public float reactivePulseAmount = 0.5f;
        // public void PulseReactive()
        // {
        //     Debug.Log(reactiveSpeed);
        //     scale += reactivePulseAmount;
        // }
        //
        //
        // void Update()
        // {
        //     // float curCircBeat = material.GetFloat("_CirclePulseBeat");
        //     // if (curCircBeat > 0)
        //     // {
        //     //     material.SetFloat("_CirclePulseBeat", Mathf.Max(0, curCircBeat - pulseDecay * Time.deltaTime));
        //     // }
        //     
        //     float curGlowBeat = material.GetFloat("_GlowPulseBeat");
        //     if (curGlowBeat > 0)
        //     {
        //         material.SetFloat("_GlowPulseBeat", Mathf.Max(0, curGlowBeat - pulseDecay * Time.deltaTime));
        //     }
        //     
        //     
        //     float curReacBeat = material.GetFloat("_ColorPulseBeat");
        //     if (curReacBeat > 0)
        //     {
        //         material.SetFloat("_ColorPulseBeat", Mathf.Max(0, curReacBeat - (1.0f / ColorPulseDuration) * Time.deltaTime));
        //     }
        //     
        //
        //     // material.SetFloat("_PulseDuration", pulseDuration);
        //     // material.SetFloat("_PulseDuration", ColorPulseDuration);
        //     //
        //     
        //     var rVel = MidiInputGetter.Instance.K1 > 0 ? 0.0f : 0f;
        //     var tempReactSeed = math.remap(0, 1, reactiveSpeedMinMax.x,reactiveSpeedMinMax.y,MidiInputGetter.Instance.K1);
        //     var smoothTimeReact = (MidiInputGetter.Instance.K1 > 0) || (MidiInputGetter.Instance.K1 > 0.9f) ? 0.3f : 0.001f;
        //     reactiveSpeed = Mathf.SmoothDamp(reactiveSpeed, tempReactSeed, ref rVel, smoothTimeReact);
        //     
        //     ///
        //     //speedMinMax.y = reactiveSpeed > 1.0f ? 3.0f : 10.0f;
        //     
        //     var cVel = MidiInputGetter.Instance.K2 > 0 ? 0.0f : 0f;
        //     var tempSpeed = math.remap(0, 1, speedMinMax.x,speedMinMax.y,MidiInputGetter.Instance.K2);
        //     var smoothSpeed = MidiInputGetter.Instance.K2 > 0 ? 1f : 0.001f;
        //     smoothSpeed = reactiveSpeed > 1.0f ? 10f : smoothSpeed;
        //     speed = Mathf.SmoothDamp(speed, tempSpeed, ref cVel, smoothSpeed);
        //     
        //     //speed = Mathf.Lerp(speedMinMax.x, speedMinMax.y, MidiInputGetter.Instance.K2);
        //     //speed = Mathf.SmoothStep(speedMinMax.x, speedMinMax.y, MidiInputGetter.Instance.K2);
        //     
        //     var scaleVel = MidiInputGetter.Instance.K3 > 0 ? 0.0f : 0f;
        //     var tempScale = math.remap(0, 1, scaleMinMax.x,scaleMinMax.y,MidiInputGetter.Instance.K3);
        //     var smoothScale = MidiInputGetter.Instance.K3 > 0 ? 0.15f : 0.001f;
        //     scale = Mathf.SmoothDamp(scale, tempScale, ref scaleVel, smoothScale);
        //     //scale = math.remap(0, 1, scaleMinMax.x,scaleMinMax.y,MidiInputGetter.Instance.K3);
        //     
        //     
        //     thicness = math.remap(0, 1, thicnessMinMax.x,thicnessMinMax.y,MidiInputGetter.Instance.K4);
        //     
        //     
        //     material.SetFloat("_ReactiveSpeed", reactiveSpeed);
        //     material.SetFloat("_Speed", speed);
        //     material.SetFloat("_Scale", scale);
        //     material.SetFloat("_Linethicness", thicness);
        //     
        //     
        //     
        //     
        //     //IDK
        //     // if (material != null)
        //     // {
        //         // Map midiKo to an index range within colors
        //         float scaledValue = MidiInputGetter.Instance.K5 * (colors.Length - 1);
        //         int colorIndex = Mathf.FloorToInt(scaledValue);
        //         int nextColorIndex = Mathf.Clamp(colorIndex + 1, 0, colors.Length - 1);
        //
        //         // Interpolate between two colors
        //         float t = scaledValue - colorIndex; // Fraction between two indices
        //         Color interpolatedColor = Color.Lerp(colors[colorIndex], colors[nextColorIndex], t);
        //
        //         // Set the interpolated color to the shader
        //         material.SetColor("_PulseColor", interpolatedColor);
        //     //}
        //
        // }
        //
        // private readonly Color[] colors = new Color[]
        // {
        //     new Color(0.5f, 0.0f, 0.5f), // Purple
        //     new Color(0.0f, 0.0f, 1.0f), // Blue
        //     new Color(.5f, 0.0f, .8f), // Pink
        //     new Color(.4f, 0.8f, 0.4f), // Orange
        // };
    }
}