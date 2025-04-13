package org.osmf.metadata
{
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MetadataEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.SeekEvent;
   import org.osmf.events.TimelineMetadataEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.traits.PlayTrait;
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class TimelineMetadata extends Metadata
   {
      private static const CHECK_INTERVAL:Number = 100;
      
      private static const TOLERANCE:Number = 0.25;
      
      private var temporalKeyCollection:Vector.<Number>;
      
      private var temporalValueCollection:Vector.<TimelineMarker>;
      
      private var media:MediaElement;
      
      private var timeTrait:TimeTrait;
      
      private var seekTrait:SeekTrait;
      
      private var playTrait:PlayTrait;
      
      private var lastFiredTemporalMetadataIndex:int;
      
      private var intervalTimer:Timer;
      
      private var restartTimer:Boolean;
      
      private var _enabled:Boolean;
      
      private var durationTimers:Dictionary;
      
      public function TimelineMetadata(param1:MediaElement)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         this.media = param1;
         _enabled = true;
         intervalTimer = new Timer(100);
         intervalTimer.addEventListener("timer",onIntervalTimer);
         timeTrait = param1.getTrait("time") as TimeTrait;
         seekTrait = param1.getTrait("seek") as SeekTrait;
         setupTraitEventListener("seek");
         playTrait = param1.getTrait("play") as PlayTrait;
         setupTraitEventListener("play");
         param1.addEventListener("traitAdd",onTraitAdd);
         param1.addEventListener("traitRemove",onTraitRemove);
      }
      
      public function get numMarkers() : int
      {
         return !!temporalValueCollection ? temporalValueCollection.length : 0;
      }
      
      public function getMarkerAt(param1:int) : TimelineMarker
      {
         if(param1 >= 0 && temporalValueCollection != null && param1 < temporalValueCollection.length)
         {
            return temporalValueCollection[param1];
         }
         return null;
      }
      
      public function addMarker(param1:TimelineMarker) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         addValue("" + param1.time,param1);
      }
      
      public function removeMarker(param1:TimelineMarker) : TimelineMarker
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         return removeValue("" + param1.time);
      }
      
      override public function addValue(param1:String, param2:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Number = new Number(param1);
         var _loc3_:TimelineMarker = param2 as TimelineMarker;
         if(param1 == null || isNaN(_loc5_) || _loc5_ < 0 || _loc3_ == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         if(temporalValueCollection == null)
         {
            temporalKeyCollection = new Vector.<Number>();
            temporalKeyCollection.push(_loc5_);
            temporalValueCollection = new Vector.<TimelineMarker>();
            temporalValueCollection.push(param2);
         }
         else
         {
            _loc4_ = findTemporalMetadata(0,temporalValueCollection.length - 1,_loc5_);
            if(_loc4_ < 0)
            {
               _loc4_ *= -1;
               temporalKeyCollection.splice(_loc4_,0,_loc5_);
               temporalValueCollection.splice(_loc4_,0,_loc3_);
            }
            else if(_loc4_ == 0 && _loc5_ != temporalKeyCollection[0])
            {
               temporalKeyCollection.splice(_loc4_,0,_loc5_);
               temporalValueCollection.splice(_loc4_,0,_loc3_);
            }
            else
            {
               temporalKeyCollection[_loc4_] = _loc5_;
               temporalValueCollection[_loc4_] = _loc3_;
            }
         }
         enabled = true;
         dispatchEvent(new MetadataEvent("valueAdd",false,false,param1,_loc3_));
         dispatchEvent(new TimelineMetadataEvent("markerAdd",false,false,_loc3_));
      }
      
      override public function removeValue(param1:String) : *
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         var _loc4_:Number = new Number(param1);
         var _loc2_:* = null;
         var _loc3_:int = int(!!temporalValueCollection ? findTemporalMetadata(0,temporalValueCollection.length - 1,_loc4_) : -1);
         if(_loc3_ >= 0)
         {
            temporalKeyCollection.splice(_loc3_,1);
            _loc2_ = temporalValueCollection.splice(_loc3_,1)[0];
            if(temporalValueCollection.length == 0)
            {
               reset(false);
               temporalValueCollection = null;
               temporalKeyCollection = null;
            }
            dispatchEvent(new MetadataEvent("valueRemove",false,false,param1,_loc2_));
            dispatchEvent(new TimelineMetadataEvent("markerRemove",false,false,_loc2_ as TimelineMarker));
         }
         return _loc2_;
      }
      
      override public function getValue(param1:String) : *
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         var _loc4_:Number = new Number(param1);
         if(!isNaN(_loc4_))
         {
            _loc2_ = 0;
            while(_loc2_ < temporalKeyCollection.length)
            {
               _loc3_ = temporalKeyCollection[_loc2_];
               if(_loc3_ == _loc4_)
               {
                  return temporalValueCollection[_loc2_];
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      public function get enabled() : Boolean
      {
         return _enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         _enabled = param1;
         reset(param1);
      }
      
      private function startTimer(param1:Boolean = true) : void
      {
         if(!param1)
         {
            intervalTimer.stop();
         }
         else if(timeTrait != null && temporalValueCollection != null && temporalValueCollection.length > 0 && restartTimer && enabled && !intervalTimer.running)
         {
            if(playTrait != null && playTrait.playState == "playing")
            {
               intervalTimer.start();
            }
         }
      }
      
      private function reset(param1:Boolean) : void
      {
         lastFiredTemporalMetadataIndex = -1;
         restartTimer = true;
         intervalTimer.reset();
         intervalTimer.delay = 100;
         if(param1)
         {
            this.startTimer();
         }
      }
      
      private function checkForTemporalMetadata() : void
      {
         var _loc1_:Number = timeTrait.currentTime;
         var _loc2_:int = findTemporalMetadata(lastFiredTemporalMetadataIndex + 1,temporalValueCollection.length - 1,_loc1_);
         if(_loc2_ <= 0)
         {
            _loc2_ *= -1;
            _loc2_ = _loc2_ > 0 ? _loc2_ - 1 : 0;
         }
         if(!checkTemporalMetadata(_loc2_,_loc1_) && _loc2_ + 1 < temporalValueCollection.length)
         {
            checkTemporalMetadata(_loc2_ + 1,_loc1_);
         }
      }
      
      private function setupTraitEventListener(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:PlayEvent = null;
         if(param2)
         {
            if(param1 == "seek" && seekTrait != null)
            {
               seekTrait.addEventListener("seekingChange",onSeekingChange);
            }
            else if(param1 == "play" && playTrait != null)
            {
               playTrait.addEventListener("playStateChange",onPlayStateChange);
               if(playTrait.playState == "playing")
               {
                  _loc3_ = new PlayEvent("playStateChange",false,false,"playing");
                  onPlayStateChange(_loc3_);
               }
            }
         }
         else if(param1 == "seek" && seekTrait != null)
         {
            seekTrait.removeEventListener("seekingChange",onSeekingChange);
         }
         else if(param1 == "play" && playTrait != null)
         {
            playTrait.removeEventListener("playStateChange",onPlayStateChange);
         }
      }
      
      private function onSeekingChange(param1:SeekEvent) : void
      {
         if(param1.seeking)
         {
            reset(true);
         }
      }
      
      private function onPlayStateChange(param1:PlayEvent) : void
      {
         var _loc2_:* = null;
         if(param1.playState == "playing")
         {
            if(durationTimers != null)
            {
               for each(_loc2_ in durationTimers)
               {
                  _loc2_.start();
               }
            }
            startTimer();
         }
         else
         {
            if(durationTimers != null)
            {
               for each(_loc2_ in durationTimers)
               {
                  _loc2_.stop();
               }
            }
            startTimer(false);
         }
      }
      
      private function findTemporalMetadata(param1:int, param2:int, param3:Number) : int
      {
         var _loc4_:int = 0;
         if(param1 <= param2)
         {
            _loc4_ = (param1 + param2) / 2;
            if(param3 == temporalKeyCollection[_loc4_])
            {
               return _loc4_;
            }
            if(param3 < temporalKeyCollection[_loc4_])
            {
               return findTemporalMetadata(param1,_loc4_ - 1,param3);
            }
            return findTemporalMetadata(_loc4_ + 1,param2,param3);
         }
         return -param1;
      }
      
      private function dispatchTemporalEvents(param1:int) : void
      {
         var timer:Timer;
         var endTime:Number;
         var onDurationTimer:*;
         var index:int = param1;
         var marker:TimelineMarker = temporalValueCollection[index];
         dispatchEvent(new TimelineMetadataEvent("markerTimeReached",false,false,marker));
         if(marker.duration > 0)
         {
            onDurationTimer = function(param1:TimerEvent):void
            {
               if(timeTrait && timeTrait.currentTime >= endTime)
               {
                  timer.removeEventListener("timer",onDurationTimer);
                  delete durationTimers[marker];
                  dispatchEvent(new TimelineMetadataEvent("markerDurationReached",false,false,marker));
               }
            };
            timer = new Timer(100);
            endTime = marker.time + marker.duration;
            if(durationTimers == null)
            {
               durationTimers = new Dictionary();
            }
            durationTimers[marker] = timer;
            timer.addEventListener("timer",onDurationTimer);
            timer.start();
         }
      }
      
      private function checkTemporalMetadata(param1:int, param2:Number) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!temporalValueCollection || !temporalValueCollection.length)
         {
            return false;
         }
         var _loc3_:Boolean = false;
         if(temporalValueCollection[param1].time >= param2 - 0.25 && temporalValueCollection[param1].time <= param2 + 0.25 && param1 != lastFiredTemporalMetadataIndex)
         {
            lastFiredTemporalMetadataIndex = param1;
            dispatchTemporalEvents(param1);
            _loc4_ = temporalKeyCollection[param1];
            _loc5_ = calcNextTime(param1);
            _loc6_ = (_loc5_ - _loc4_) * 1000 / 4;
            _loc6_ = _loc6_ > 100 ? _loc6_ : 100;
            if(_loc4_ == _loc5_)
            {
               startTimer(false);
               restartTimer = false;
            }
            else if(_loc6_ != intervalTimer.delay)
            {
               intervalTimer.reset();
               intervalTimer.delay = _loc6_;
               startTimer();
            }
            _loc3_ = true;
         }
         else if(intervalTimer.delay != 100 && param2 + intervalTimer.delay / 1000 > calcNextTime(param1))
         {
            this.intervalTimer.reset();
            this.intervalTimer.delay = 100;
            startTimer();
         }
         return _loc3_;
      }
      
      private function calcNextTime(param1:int) : Number
      {
         return temporalValueCollection[param1 + 1 < temporalKeyCollection.length ? param1 + 1 : temporalKeyCollection.length - 1].time;
      }
      
      private function onIntervalTimer(param1:TimerEvent) : void
      {
         checkForTemporalMetadata();
      }
      
      private function onTraitAdd(param1:MediaElementEvent) : void
      {
         switch(param1.traitType)
         {
            case "time":
               timeTrait = media.getTrait("time") as TimeTrait;
               startTimer();
               break;
            case "seek":
               seekTrait = media.getTrait("seek") as SeekTrait;
               break;
            case "play":
               playTrait = media.getTrait("play") as PlayTrait;
         }
         setupTraitEventListener(param1.traitType);
      }
      
      private function onTraitRemove(param1:MediaElementEvent) : void
      {
         setupTraitEventListener(param1.traitType,false);
         switch(param1.traitType)
         {
            case "time":
               timeTrait = null;
               if(media.hasOwnProperty("numChildren") == false)
               {
                  startTimer(false);
               }
               break;
            case "seek":
               seekTrait = null;
               break;
            case "play":
               playTrait = null;
         }
      }
   }
}

