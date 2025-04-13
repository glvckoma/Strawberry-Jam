package org.osmf.net.rtmpstreaming
{
   import flash.utils.getTimer;
   import org.osmf.net.NetStreamMetricsBase;
   import org.osmf.net.SwitchingRuleBase;
   
   public class DroppedFramesRule extends SwitchingRuleBase
   {
      private static const LOCK_INTERVAL:Number = 30000;
      
      private var downSwitchByOne:int;
      
      private var downSwitchByTwo:int;
      
      private var downSwitchToZero:int;
      
      private var lockLevel:Number;
      
      private var lastLockTime:Number;
      
      public function DroppedFramesRule(param1:NetStreamMetricsBase, param2:int = 10, param3:int = 20, param4:int = 24)
      {
         super(param1);
         this.downSwitchByOne = param2;
         this.downSwitchByTwo = param3;
         this.downSwitchToZero = param4;
         lastLockTime = 0;
         lockLevel = 2147483647;
      }
      
      override public function getNewIndex() : int
      {
         var _loc2_:String = null;
         var _loc1_:int = -1;
         if(metrics.averageDroppedFPS > downSwitchToZero)
         {
            _loc1_ = 0;
            _loc2_ = "Average droppedFPS of " + Math.round(metrics.averageDroppedFPS) + " > " + downSwitchToZero;
         }
         else if(metrics.averageDroppedFPS > downSwitchByTwo)
         {
            _loc1_ = metrics.currentIndex - 2 < 0 ? 0 : metrics.currentIndex - 2;
            _loc2_ = "Average droppedFPS of " + Math.round(metrics.averageDroppedFPS) + " > " + downSwitchByTwo;
         }
         else if(metrics.averageDroppedFPS > downSwitchByOne)
         {
            _loc1_ = metrics.currentIndex - 1 < 0 ? 0 : metrics.currentIndex - 1;
            _loc2_ = "Average droppedFPS of " + Math.round(metrics.averageDroppedFPS) + " > " + downSwitchByOne;
         }
         if(_loc1_ != -1 && _loc1_ < metrics.currentIndex)
         {
            lockIndex(_loc1_);
         }
         if(_loc1_ == -1 && isLocked(metrics.currentIndex))
         {
            _loc1_ = metrics.currentIndex;
         }
         return _loc1_;
      }
      
      private function lockIndex(param1:int) : void
      {
         if(!isLocked(param1))
         {
            lockLevel = param1;
            lastLockTime = getTimer();
         }
      }
      
      private function isLocked(param1:int) : Boolean
      {
         return param1 >= lockLevel && getTimer() - lastLockTime < 30000;
      }
   }
}

