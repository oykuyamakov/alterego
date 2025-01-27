using System;
using System.Collections;
using System.Collections.Generic;
using CameraHandling;
using InputManagement;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;

public class MidiMoshController : MonoBehaviour
{
    private CustomMoshManager moshManager => GetComponent<CustomMoshManager>();

    private Vector2 entropyMaxMin = new Vector2(0.0f, 1.0f);
    private Vector2 noiseMaxMin = new Vector2(0.5f, 4.0f);
    private Vector2 diffMaxMin = new Vector2(0, 2);
    
    private void CheckMoshInputs()
    {
        moshManager.Entropy = math.remap(0, 1, entropyMaxMin.x, entropyMaxMin.y, MidiInputGetter.Instance.K5);
        moshManager.BlockSize = (int)math.remap(0, 1, 2, 200, MidiInputGetter.Instance.K6);
        // moshManager.NoiseContrast = math.remap(0, 1, noiseMaxMin.x, noiseMaxMin.y, MidiInputGetter.Instance.Pad2);
        // moshManager.Diffusion = math.remap(0, 1, diffMaxMin.x, diffMaxMin.y, MidiInputGetter.Instance.Pad3);
    }

    private bool moshSwitch = false;

    private void CheckSwitchMosh()
    {
        if (MidiInputGetter.Instance.Do1 > 0f)
        {
            if (!moshSwitch)
            {
                moshManager.SwitchMode();
                moshSwitch = true;
            }
        }
        else
        {
            moshSwitch = false;
        }
    }

    private bool moshKick = false;

    private void CheckStartMosh()
    {
        if (MidiInputGetter.Instance.Pad6 > 0f)
        {
            if (!moshKick)
            {
                moshManager.KickGlitch();
                moshKick = true;
            }
        }
        else
        {
            moshKick = false;
        }
    }
    private void CheckResetMosh()
    {
        if (MidiInputGetter.Instance.Pad5 > 0f)
        {
            if (!moshKick)
            {
                moshManager.Reset();
                moshKick = true;
                moshManager.KickGlitch();
            }
        }
        else
        {
            moshKick = false;
        }
    }
    
    private void Update()
    {
        CheckMoshInputs();
        CheckStartMosh();
        CheckSwitchMosh();
        CheckResetMosh();
    }
}
