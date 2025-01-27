using System;
using Minis;
using UnityCommon.Singletons;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Layouts;


namespace InputManagement
{
    [RequireComponent(typeof(PlayerInput))]
    public class MidiInputGetter : SingletonBehaviour<MidiInputGetter>
    {
        private PlayerInput playerInput => GetComponent<PlayerInput>();
        
        public float K1 { get; private set; }
        public float K2 { get; private set; }
        public float K3 { get; private set; }
        public float K4 { get; private set; }
        public float K5 { get; private set; }
        public float K6 { get; private set; }
        public float K7 { get; private set; }
        public float K8 { get; private set; }
        
        public float Pad1 { get; private set; }
        public float Pad2 { get; private set; }
        public float Pad3 { get; private set; }
        public float Pad4 { get; private set; }
        public float Pad5 { get; private set; }
        public float Pad6 { get; private set; }
        public float Pad7 { get; private set; }
        public float Pad8 { get; private set; }
        
        public float Do1 {get; private set; }
        public float Do2 {get; private set; }
        public float Re2 {get; private set; }
        public float Mi2 {get; private set; }
        
        private void SetKnobValue(int knobNumber, float value)
        {
            switch (knobNumber)
            {
                case 70:
                    K1 = value;
                    break;
                case 71:
                    K2 = value;
                    break;
                case 72:
                    K3 = value;
                    break;
                case 73:
                    K4 = value;
                    break;
                case 74:
                    K5 = value;
                    break;
                case 75:
                    K6 = value;
                    break;
                case 76:
                    K7 = value;
                    break;
                case 77:
                    K8 = value;
                    break;
            }
        }
        
        private void SetPadValue(int padNumber, float value)
        {
            switch (padNumber)
            {
                case 36:
                    Pad1 = value;
                    break;
                case 37:
                    Pad2 = value;
                    break;
                case 38:
                    Pad3 = value;
                    break;
                case 39:
                    Pad4 = value;
                    break;
                case 40:
                    Pad5 = value;
                    break;
                case 41:
                    Pad6 = value;
                    break;
                case 42:
                    Pad7 = value;
                    break;
                case 43:
                    Pad8 = value;
                    break;
                
                case 48:
                    Do1 = value;
                    break;
                
                case 60:
                    Do2 = value;
                    break;
                case 62:
                    Re2 = value;
                    break;
                case 64:
                    Mi2 = value;
                    break;
            }
        }
        
        
        [SerializeField] 
        string _productName = null;

        // Search by a channel number
        [SerializeField] 
        int _channel = -1;

        Minis.MidiDevice Search()
        {
            // Matcher object with Minis devices
            var match = new InputDeviceMatcher().WithInterface("Minis");

            // Product name specifier
            if (!string.IsNullOrEmpty(_productName))
                match = match.WithProduct(_productName);

            // Channel number specifier with a capability match
            if (_channel >= 0 && _channel < 16)
                match = match.WithCapability("channel", _channel);

            // Scan all the devices found in the input system.
            foreach (var dev in InputSystem.devices)
                if (match.MatchPercentage(dev.description) > 0)
                    return (Minis.MidiDevice)dev;

            return null;
        }

        System.Collections.IEnumerator Look()
        {
            while (true)
            {
                var device = Search();

                if (device != null)
                {
                    Debug.Log("Device found: " + device.description);
                    break;
                }

                yield return new WaitForSeconds(0.1f);
            }
        }
        
        
        void Start()
        {
            Application.targetFrameRate = 60;
            
            StartCoroutine(Look());
            
            InputSystem.onDeviceChange += (device, change) =>
            {
                var midiDevice = device as Minis.MidiDevice;
                if (midiDevice == null) return;

                // Debug.Log(string.Format("{0} ({1}) {2}",
                //     device.description.product, midiDevice.channel, change));
            };
            
            InputSystem.onDeviceChange += (device, change) =>
            {
                if (change != InputDeviceChange.Added) return;

                var midiDevice = device as Minis.MidiDevice;
                
                if (midiDevice == null) 
                    return;
                
                midiDevice.onWillControlChange += (control, value) => {
                    
                    SetKnobValue(control.controlNumber, value);

                    // Debug.Log(string.Format(
                    //     "KUKU #{0} ({1}) val:{2:0.00} ch:{3} dev:'{4}'",
                    //     control.controlNumber,
                    //     control.shortDisplayName,
                    //     value,
                    //     midiDevice.channel,
                    //     midiDevice.description.product
                    // ));
                };

                midiDevice.onWillNoteOn += (note, velocity) => {
                    
                    SetPadValue(note.noteNumber, velocity);
                    
                    // Debug.Log(string.Format(
                    //     "Note On #{0} ({1}) vel:{2:0.00} ch:{3} dev:'{4}'",
                    //     note.noteNumber,
                    //     note.shortDisplayName,
                    //     velocity,
                    //     (note.device as Minis.MidiDevice)?.channel,
                    //     note.device.description.product
                    // ));
                };

                midiDevice.onWillNoteOff += (note) => {
                    
                    SetPadValue(note.noteNumber, 0);
                    
                    // Debug.Log(string.Format(
                    //     "Note Off #{0} ({1}) ch:{2} dev:'{3}'",
                    //     note.noteNumber,
                    //     note.shortDisplayName,
                    //     (note.device as Minis.MidiDevice)?.channel,
                    //     note.device.description.product
                    // ));
                };
            };
        }
        
        private void Awake()
        {
            if (!SetupInstance())
                return;
        }
    }
}