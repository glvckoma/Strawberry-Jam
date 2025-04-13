package org.osmf.traits
{
   import org.osmf.events.SeekEvent;
   
   public class SeekTrait extends MediaTraitBase
   {
      private var _timeTrait:TimeTrait;
      
      private var _seeking:Boolean;
      
      public function SeekTrait(param1:TimeTrait)
      {
         super("seek");
         _timeTrait = param1;
      }
      
      final public function get seeking() : Boolean
      {
         return _seeking;
      }
      
      final public function seek(param1:Number) : void
      {
         if(canSeekTo(param1))
         {
            setSeeking(true,param1);
         }
      }
      
      public function canSeekTo(param1:Number) : Boolean
      {
         return !!_timeTrait ? isNaN(param1) == false && param1 >= 0 && (param1 <= _timeTrait.duration || param1 <= _timeTrait.currentTime) : false;
      }
      
      final protected function get timeTrait() : TimeTrait
      {
         return _timeTrait;
      }
      
      final protected function set timeTrait(param1:TimeTrait) : void
      {
         _timeTrait = param1;
      }
      
      final protected function setSeeking(param1:Boolean, param2:Number) : void
      {
         seekingChangeStart(param1,param2);
         _seeking = param1;
         seekingChangeEnd(param2);
      }
      
      protected function seekingChangeStart(param1:Boolean, param2:Number) : void
      {
      }
      
      protected function seekingChangeEnd(param1:Number) : void
      {
         dispatchEvent(new SeekEvent("seekingChange",false,false,seeking,param1));
      }
   }
}

