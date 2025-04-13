package org.osmf.traits
{
   import org.osmf.events.AudioEvent;
   
   public class AudioTrait extends MediaTraitBase
   {
      private var _volume:Number = 1;
      
      private var _muted:Boolean = false;
      
      private var _pan:Number = 0;
      
      public function AudioTrait()
      {
         super("audio");
      }
      
      public function get volume() : Number
      {
         return _volume;
      }
      
      final public function set volume(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 != _volume)
         {
            volumeChangeStart(param1);
            _volume = param1;
            volumeChangeEnd();
         }
      }
      
      public function get muted() : Boolean
      {
         return _muted;
      }
      
      final public function set muted(param1:Boolean) : void
      {
         if(param1 != _muted)
         {
            mutedChangeStart(param1);
            _muted = param1;
            mutedChangeEnd();
         }
      }
      
      public function get pan() : Number
      {
         return _pan;
      }
      
      final public function set pan(param1:Number) : void
      {
         if(isNaN(param1))
         {
            param1 = 0;
         }
         else if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < -1)
         {
            param1 = -1;
         }
         if(param1 != _pan)
         {
            panChangeStart(param1);
            _pan = param1;
            panChangeEnd();
         }
      }
      
      protected function volumeChangeStart(param1:Number) : void
      {
      }
      
      protected function volumeChangeEnd() : void
      {
         dispatchEvent(new AudioEvent("volumeChange",false,false,false,_volume));
      }
      
      protected function mutedChangeStart(param1:Boolean) : void
      {
      }
      
      protected function mutedChangeEnd() : void
      {
         dispatchEvent(new AudioEvent("mutedChange",false,false,_muted));
      }
      
      protected function panChangeStart(param1:Number) : void
      {
      }
      
      protected function panChangeEnd() : void
      {
         dispatchEvent(new AudioEvent("panChange",false,false,false,NaN,_pan));
      }
   }
}

