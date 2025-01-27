using InputManagement;
using UnityEngine;

namespace AlterEgo.Models.Woman
{
    public class WingController : MonoBehaviour
    {
        private bool m_Winged = false;
        [SerializeField] private GameObject m_Wings;
        
        public void Jump()
        {
            if(m_Winged)
                return;
            
            if (MidiInputGetter.Instance.Mi2 > 0f)
            {
                m_Winged = true;
                m_Wings.SetActive(true);
            }
            
        }

        private void Update()
        {
            Jump();
        }
    }
}
