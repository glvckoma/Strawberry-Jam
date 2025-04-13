package org.osmf.traits
{
   import org.osmf.events.DVREvent;
   
   public class DVRTrait extends MediaTraitBase
   {
      private var _isRecording:Boolean;
      
      public function DVRTrait(param1:Boolean = false)
      {
         _isRecording = param1;
         super("dvr");
      }
      
      final public function get isRecording() : Boolean
      {
         return _isRecording;
      }
      
      final protected function setIsRecording(param1:Boolean) : void
      {
         if(param1 != _isRecording)
         {
            isRecordingChangeStart(param1);
            _isRecording = param1;
            isRecordingChangeEnd();
         }
      }
      
      protected function isRecordingChangeStart(param1:Boolean) : void
      {
      }
      
      protected function isRecordingChangeEnd() : void
      {
         dispatchEvent(new DVREvent("isRecordingChange"));
      }
   }
}

