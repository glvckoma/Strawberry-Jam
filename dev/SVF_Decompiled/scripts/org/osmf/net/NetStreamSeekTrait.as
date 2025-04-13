package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.media.Video;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   
   public class NetStreamSeekTrait extends SeekTrait
   {
      private var video:Video;
      
      private var loadTrait:LoadTrait;
      
      private var audioDelay:Number = 0;
      
      private var seekBugTimer:Timer;
      
      private var netStream:NetStream;
      
      private var expectedTime:Number;
      
      private var previousTime:Number;
      
      private var suppressSeekNotifyEvent:Boolean = false;
      
      public function NetStreamSeekTrait(param1:TimeTrait, param2:LoadTrait, param3:NetStream, param4:Video = null)
      {
         super(param1);
         this.netStream = param3;
         this.video = param4;
         this.loadTrait = param2;
         NetClient(param3.client).addHandler("onMetaData",onMetaData);
         param3.addEventListener("netStatus",onNetStatus);
         seekBugTimer = new Timer(10,100);
         seekBugTimer.addEventListener("timer",onSeekBugTimer,false,0,true);
         seekBugTimer.addEventListener("timerComplete",onSeekBugTimerDone,false,0,true);
      }
      
      override public function canSeekTo(param1:Number) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc2_:* = super.canSeekTo(param1);
         if(_loc2_ && !isNaN(loadTrait.bytesTotal) && loadTrait.bytesTotal > 0)
         {
            _loc3_ = timeTrait.duration * (loadTrait.bytesLoaded / loadTrait.bytesTotal);
            _loc2_ = param1 <= _loc3_;
         }
         return _loc2_;
      }
      
      override protected function seekingChangeStart(param1:Boolean, param2:Number) : void
      {
         if(param1)
         {
            suppressSeekNotifyEvent = false;
            previousTime = netStream.time - audioDelay;
            expectedTime = param2;
            netStream.seek(param2 + audioDelay);
            if(previousTime == expectedTime)
            {
               seekBugTimer.start();
               suppressSeekNotifyEvent = true;
            }
         }
      }
      
      override protected function seekingChangeEnd(param1:Number) : void
      {
         var _loc2_:NetStreamTimeTrait = null;
         super.seekingChangeEnd(param1);
         if(seeking == true && video != null)
         {
            _loc2_ = timeTrait as NetStreamTimeTrait;
            if(_loc2_ != null && _loc2_.currentTime + _loc2_.audioDelay >= _loc2_.duration)
            {
               video.clear();
            }
         }
      }
      
      private function onMetaData(param1:Object) : void
      {
         audioDelay = !!param1.hasOwnProperty("audiodelay") ? param1.audiodelay : 0;
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Seek.Notify":
               runSeekBugTimer();
               break;
            case "NetStream.Seek.InvalidTime":
            case "NetStream.Seek.Failed":
               setSeeking(false,previousTime);
               break;
            case "NetStream.Play.Start":
            case "NetStream.Play.Reset":
            case "NetStream.Pause.Notify":
            case "NetStream.Play.Stop":
            case "NetStream.Unpause.Notify":
               if(seeking && seekBugTimer.running == false)
               {
                  runSeekBugTimer();
                  break;
               }
         }
      }
      
      private function runSeekBugTimer() : void
      {
         if(suppressSeekNotifyEvent == false)
         {
            seekBugTimer.start();
         }
         else
         {
            suppressSeekNotifyEvent = false;
         }
      }
      
      private function onSeekBugTimer(param1:TimerEvent) : void
      {
         if(previousTime != netStream.time - audioDelay || previousTime == expectedTime)
         {
            onSeekBugTimerDone(null);
         }
      }
      
      private function onSeekBugTimerDone(param1:TimerEvent) : void
      {
         seekBugTimer.reset();
         setSeeking(false,expectedTime);
      }
   }
}

