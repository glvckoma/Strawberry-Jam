package org.osmf.net
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import org.osmf.utils.OSMFStrings;
   
   public class NetStreamSwitchManager extends NetStreamSwitchManagerBase
   {
      private static const RULE_CHECK_INTERVAL:Number = 500;
      
      private static const DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM:int = 3;
      
      private static const DEFAULT_WAIT_DURATION_AFTER_DOWN_SWITCH:int = 30000;
      
      private static const DEFAULT_CLEAR_FAILED_COUNTS_INTERVAL:Number = 300000;
      
      private var netStream:NetStream;
      
      private var dsResource:DynamicStreamingResource;
      
      private var switchingRules:Vector.<SwitchingRuleBase>;
      
      private var metrics:NetStreamMetricsBase;
      
      private var checkRulesTimer:Timer;
      
      private var clearFailedCountsTimer:Timer;
      
      private var actualIndex:int = -1;
      
      private var oldStreamName:String;
      
      private var switching:Boolean;
      
      private var _currentIndex:int;
      
      private var lastTransitionIndex:int = -1;
      
      private var connection:NetConnection;
      
      private var dsiFailedCounts:Vector.<int>;
      
      private var failedDSI:Dictionary;
      
      private var _bandwidthLimit:Number = 0;
      
      public function NetStreamSwitchManager(param1:NetConnection, param2:NetStream, param3:DynamicStreamingResource, param4:NetStreamMetricsBase, param5:Vector.<SwitchingRuleBase>)
      {
         super();
         this.connection = param1;
         this.netStream = param2;
         this.dsResource = param3;
         this.metrics = param4;
         this.switchingRules = param5 || new Vector.<SwitchingRuleBase>();
         _currentIndex = Math.max(0,Math.min(maxAllowedIndex,dsResource.initialIndex));
         checkRulesTimer = new Timer(500);
         checkRulesTimer.addEventListener("timer",checkRules);
         failedDSI = new Dictionary();
         _bandwidthLimit = 1.4 * param3.streamItems[param3.streamItems.length - 1].bitrate * 1000 / 8;
         param2.addEventListener("netStatus",onNetStatus);
         NetClient(param2.client).addHandler("onPlayStatus",onPlayStatus,2147483647);
      }
      
      override public function set autoSwitch(param1:Boolean) : void
      {
         super.autoSwitch = param1;
         if(autoSwitch)
         {
            checkRulesTimer.start();
         }
         else
         {
            checkRulesTimer.stop();
         }
      }
      
      override public function get currentIndex() : uint
      {
         return _currentIndex;
      }
      
      override public function get maxAllowedIndex() : int
      {
         var _loc1_:int = dsResource.streamItems.length - 1;
         return _loc1_ < super.maxAllowedIndex ? _loc1_ : super.maxAllowedIndex;
      }
      
      override public function set maxAllowedIndex(param1:int) : void
      {
         if(param1 > dsResource.streamItems.length)
         {
            throw new RangeError(OSMFStrings.getString("streamSwitchInvalidIndex"));
         }
         super.maxAllowedIndex = param1;
         metrics.maxAllowedIndex = param1;
      }
      
      override public function switchTo(param1:int) : void
      {
         if(!autoSwitch)
         {
            if(param1 < 0 || param1 > maxAllowedIndex)
            {
               throw new RangeError(OSMFStrings.getString("streamSwitchInvalidIndex"));
            }
            if(actualIndex == -1)
            {
               prepareForSwitching();
            }
            executeSwitch(param1);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString("streamSwitchStreamNotInManualMode"));
      }
      
      protected function canAutoSwitchNow(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         if(dsiFailedCounts[param1] >= 1)
         {
            _loc2_ = getTimer();
            if(_loc2_ - failedDSI[param1] < 30000)
            {
               return false;
            }
         }
         else if(dsiFailedCounts[param1] > 3)
         {
            return false;
         }
         return true;
      }
      
      final protected function get bandwidthLimit() : Number
      {
         return _bandwidthLimit;
      }
      
      final protected function set bandwidthLimit(param1:Number) : void
      {
         _bandwidthLimit = param1;
      }
      
      private function executeSwitch(param1:int) : void
      {
         var _loc3_:NetStreamPlayOptions = new NetStreamPlayOptions();
         var _loc2_:Object = NetStreamUtils.getPlayArgsForResource(dsResource);
         _loc3_.start = _loc2_.start;
         _loc3_.len = _loc2_.len;
         _loc3_.streamName = dsResource.streamItems[param1].streamName;
         var _loc4_:String = oldStreamName;
         if(_loc4_ != null && _loc4_.indexOf("?") >= 0)
         {
            _loc3_.oldStreamName = _loc4_.substr(0,_loc4_.indexOf("?"));
         }
         else
         {
            _loc3_.oldStreamName = oldStreamName;
         }
         _loc3_.transition = "switch";
         switching = true;
         netStream.play2(_loc3_);
         oldStreamName = dsResource.streamItems[param1].streamName;
         if(param1 < actualIndex && autoSwitch)
         {
            incrementDSIFailedCount(actualIndex);
            failedDSI[actualIndex] = getTimer();
         }
      }
      
      private function checkRules(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(switchingRules == null || switching)
         {
            return;
         }
         var _loc3_:* = 2147483647;
         _loc2_ = 0;
         while(_loc2_ < switchingRules.length)
         {
            _loc4_ = switchingRules[_loc2_].getNewIndex();
            if(_loc4_ != -1 && _loc4_ < _loc3_)
            {
               _loc3_ = _loc4_;
            }
            _loc2_++;
         }
         if(_loc3_ != -1 && _loc3_ != 2147483647 && _loc3_ != actualIndex)
         {
            _loc3_ = Math.min(_loc3_,maxAllowedIndex);
         }
         if(_loc3_ != -1 && _loc3_ != 2147483647 && _loc3_ != actualIndex && !switching && _loc3_ <= maxAllowedIndex && canAutoSwitchNow(_loc3_))
         {
            executeSwitch(_loc3_);
         }
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Start":
               if(actualIndex == -1)
               {
                  prepareForSwitching();
                  break;
               }
               if(autoSwitch && checkRulesTimer.running == false)
               {
                  checkRulesTimer.start();
               }
               break;
            case "NetStream.Play.Transition":
               switching = false;
               actualIndex = dsResource.indexFromName(param1.info.details);
               metrics.currentIndex = actualIndex;
               lastTransitionIndex = actualIndex;
               break;
            case "NetStream.Play.Failed":
               switching = false;
               break;
            case "NetStream.Seek.Notify":
               switching = false;
               if(lastTransitionIndex >= 0)
               {
                  _currentIndex = lastTransitionIndex;
               }
               break;
            case "NetStream.Play.Stop":
               checkRulesTimer.stop();
         }
      }
      
      private function onPlayStatus(param1:Object) : void
      {
         var _loc2_:* = param1.code;
         if("NetStream.Play.TransitionComplete" === _loc2_)
         {
            if(lastTransitionIndex >= 0)
            {
               _currentIndex = lastTransitionIndex;
               lastTransitionIndex = -1;
            }
         }
      }
      
      private function prepareForSwitching() : void
      {
         initDSIFailedCounts();
         metrics.resource = dsResource;
         actualIndex = 0;
         lastTransitionIndex = -1;
         if(dsResource.initialIndex >= 0 && dsResource.initialIndex < dsResource.streamItems.length)
         {
            actualIndex = dsResource.initialIndex;
         }
         if(autoSwitch)
         {
            checkRulesTimer.start();
         }
         setThrottleLimits(dsResource.streamItems.length - 1);
         metrics.currentIndex = actualIndex;
      }
      
      private function initDSIFailedCounts() : void
      {
         var _loc1_:int = 0;
         if(dsiFailedCounts != null)
         {
            dsiFailedCounts.length = 0;
            dsiFailedCounts = null;
         }
         dsiFailedCounts = new Vector.<int>();
         _loc1_ = 0;
         while(_loc1_ < dsResource.streamItems.length)
         {
            dsiFailedCounts.push(0);
            _loc1_++;
         }
      }
      
      private function incrementDSIFailedCount(param1:int) : void
      {
         dsiFailedCounts[param1]++;
         if(dsiFailedCounts[param1] > 3)
         {
            if(clearFailedCountsTimer == null)
            {
               clearFailedCountsTimer = new Timer(300000,1);
               clearFailedCountsTimer.addEventListener("timer",clearFailedCounts);
            }
            clearFailedCountsTimer.start();
         }
      }
      
      private function clearFailedCounts(param1:TimerEvent) : void
      {
         clearFailedCountsTimer.removeEventListener("timer",clearFailedCounts);
         clearFailedCountsTimer = null;
         initDSIFailedCounts();
      }
      
      private function setThrottleLimits(param1:int) : void
      {
         connection.call("setBandwidthLimit",null,_bandwidthLimit,_bandwidthLimit);
      }
   }
}

