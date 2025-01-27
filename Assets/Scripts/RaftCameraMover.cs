using DG.Tweening;
using UnityCommon.Modules;
using UnityCommon.Runtime.Extensions;
using UnityEngine;

public class RaftCameraMover : MonoBehaviour
{
   [SerializeField] 
   private float yPos = -50;
   [SerializeField] 
   private float dur = 60;
   
   private void Start()
   {
      transform.DOMove(transform.position.WithY(yPos), dur).SetEase(Ease.InCirc);
   }
}
