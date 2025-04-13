package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import flash.media.Sound;
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class SoundLoadTrait extends LoadTrait
   {
      private var lastBytesTotal:Number;
      
      private var _sound:Sound;
      
      public function SoundLoadTrait(param1:LoaderBase, param2:MediaResourceBase)
      {
         super(param1,param2);
      }
      
      public function get sound() : Sound
      {
         return _sound;
      }
      
      public function set sound(param1:Sound) : void
      {
         _sound = param1;
      }
      
      override protected function loadStateChangeStart(param1:String) : void
      {
         if(param1 == "ready")
         {
            if(_sound != null)
            {
               _sound.addEventListener("open",bytesTotalCheckingHandler,false,0,true);
               _sound.addEventListener("progress",bytesTotalCheckingHandler,false,0,true);
            }
         }
         else if(param1 == "uninitialized")
         {
            _sound = null;
         }
      }
      
      override public function get bytesLoaded() : Number
      {
         return !!_sound ? _sound.bytesLoaded : NaN;
      }
      
      override public function get bytesTotal() : Number
      {
         return !!_sound ? _sound.bytesTotal : NaN;
      }
      
      private function bytesTotalCheckingHandler(param1:Event) : void
      {
         var _loc2_:LoadEvent = null;
         if(lastBytesTotal != _sound.bytesTotal)
         {
            _loc2_ = new LoadEvent("bytesTotalChange",false,false,null,_sound.bytesTotal);
            lastBytesTotal = _sound.bytesTotal;
            dispatchEvent(_loc2_);
         }
      }
   }
}

