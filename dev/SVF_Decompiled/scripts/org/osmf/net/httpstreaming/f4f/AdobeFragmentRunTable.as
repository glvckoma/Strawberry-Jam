package org.osmf.net.httpstreaming.f4f
{
   internal class AdobeFragmentRunTable extends FullBox
   {
      private var _timeScale:uint;
      
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _fragmentDurationPairs:Vector.<FragmentDurationPair>;
      
      public function AdobeFragmentRunTable()
      {
         super();
         _fragmentDurationPairs = new Vector.<FragmentDurationPair>();
      }
      
      public function get timeScale() : uint
      {
         return _timeScale;
      }
      
      public function set timeScale(param1:uint) : void
      {
         _timeScale = param1;
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return _qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(param1:Vector.<String>) : void
      {
         _qualitySegmentURLModifiers = param1;
      }
      
      public function get fragmentDurationPairs() : Vector.<FragmentDurationPair>
      {
         return _fragmentDurationPairs;
      }
      
      public function addFragmentDurationPair(param1:FragmentDurationPair) : void
      {
         _fragmentDurationPairs.push(param1);
      }
      
      public function findFragmentIdByTime(param1:Number, param2:Number, param3:Boolean = false) : FragmentAccessInformation
      {
         var _loc5_:* = 0;
         if(_fragmentDurationPairs.length <= 0)
         {
            return null;
         }
         var _loc4_:FragmentDurationPair = null;
         _loc5_ = 1;
         while(_loc5_ < _fragmentDurationPairs.length)
         {
            _loc4_ = _fragmentDurationPairs[_loc5_];
            if(_loc4_.durationAccrued >= param1)
            {
               return validateFragment(calculateFragmentId(_fragmentDurationPairs[_loc5_ - 1],param1),param2,param3);
            }
            _loc5_++;
         }
         return validateFragment(calculateFragmentId(_fragmentDurationPairs[_fragmentDurationPairs.length - 1],param1),param2,param3);
      }
      
      public function validateFragment(param1:uint, param2:Number, param3:Boolean = false) : FragmentAccessInformation
      {
         var _loc9_:* = 0;
         var _loc7_:FragmentDurationPair = null;
         var _loc8_:FragmentDurationPair = null;
         var _loc6_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc10_:FragmentDurationPair = null;
         var _loc5_:uint = uint(_fragmentDurationPairs.length - 1);
         var _loc11_:FragmentAccessInformation = null;
         _loc9_ = 0;
         while(_loc9_ < _loc5_)
         {
            _loc7_ = _fragmentDurationPairs[_loc9_];
            _loc8_ = _fragmentDurationPairs[_loc9_ + 1];
            if(_loc7_.firstFragment <= param1 && param1 < _loc8_.firstFragment)
            {
               if(_loc7_.duration <= 0)
               {
                  _loc11_ = getNextValidFragment(_loc9_ + 1,param2);
                  break;
               }
               _loc11_ = new FragmentAccessInformation();
               _loc11_.fragId = param1;
               _loc11_.fragDuration = _loc7_.duration;
               _loc11_.fragmentEndTime = _loc7_.durationAccrued + _loc7_.duration * (param1 - _loc7_.firstFragment + 1);
               break;
            }
            if(_loc7_.firstFragment <= param1 && endOfStreamEntry(_loc8_))
            {
               if(_loc7_.duration > 0)
               {
                  _loc6_ = param2 - _loc7_.durationAccrued;
                  _loc12_ = (param1 - _loc7_.firstFragment + 1) * _loc7_.duration;
                  _loc4_ = (param1 - _loc7_.firstFragment) * _loc7_.duration;
                  if(_loc6_ > _loc4_)
                  {
                     if(!param3 || _loc4_ + _loc7_.duration + _loc7_.durationAccrued <= param2)
                     {
                        _loc11_ = new FragmentAccessInformation();
                        _loc11_.fragId = param1;
                        _loc11_.fragDuration = _loc7_.duration;
                        if(_loc6_ >= _loc12_)
                        {
                           _loc11_.fragmentEndTime = _loc7_.durationAccrued + _loc12_;
                           break;
                        }
                        _loc11_.fragmentEndTime = _loc7_.durationAccrued + _loc6_;
                        break;
                     }
                  }
               }
            }
            _loc9_++;
         }
         if(_loc11_ == null)
         {
            _loc10_ = _fragmentDurationPairs[_loc5_];
            if(_loc10_.duration > 0 && param1 >= _loc10_.firstFragment)
            {
               _loc6_ = param2 - _loc10_.durationAccrued;
               _loc12_ = (param1 - _loc10_.firstFragment + 1) * _loc10_.duration;
               _loc4_ = (param1 - _loc10_.firstFragment) * _loc10_.duration;
               if(_loc6_ > _loc4_)
               {
                  if(!param3 || _loc4_ + _loc10_.duration + _loc10_.durationAccrued <= param2)
                  {
                     _loc11_ = new FragmentAccessInformation();
                     _loc11_.fragId = param1;
                     _loc11_.fragDuration = _loc10_.duration;
                     if(_loc6_ >= _loc12_)
                     {
                        _loc11_.fragmentEndTime = _loc10_.durationAccrued + _loc12_;
                     }
                     else
                     {
                        _loc11_.fragmentEndTime = _loc10_.durationAccrued + _loc6_;
                     }
                  }
               }
            }
         }
         return _loc11_;
      }
      
      private function getNextValidFragment(param1:uint, param2:Number) : FragmentAccessInformation
      {
         var _loc4_:* = 0;
         var _loc3_:FragmentDurationPair = null;
         var _loc5_:FragmentAccessInformation = null;
         _loc4_ = param1;
         while(_loc4_ < _fragmentDurationPairs.length)
         {
            _loc3_ = _fragmentDurationPairs[_loc4_];
            if(_loc3_.duration > 0)
            {
               _loc5_ = new FragmentAccessInformation();
               _loc5_.fragId = _loc3_.firstFragment;
               _loc5_.fragDuration = _loc3_.duration;
               _loc5_.fragmentEndTime = _loc3_.durationAccrued + _loc3_.duration;
               break;
            }
            _loc4_++;
         }
         return _loc5_;
      }
      
      private function endOfStreamEntry(param1:FragmentDurationPair) : Boolean
      {
         return param1.duration == 0 && param1.discontinuityIndicator == 0;
      }
      
      public function fragmentsLeft(param1:uint, param2:Number) : uint
      {
         if(_fragmentDurationPairs == null || _fragmentDurationPairs.length == 0)
         {
            return 0;
         }
         var _loc3_:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
         return uint((param2 - _loc3_.durationAccrued) / _loc3_.duration + _loc3_.firstFragment - param1 - 1);
      }
      
      public function tableComplete() : Boolean
      {
         if(_fragmentDurationPairs == null || _fragmentDurationPairs.length <= 0)
         {
            return false;
         }
         var _loc1_:FragmentDurationPair = _fragmentDurationPairs[fragmentDurationPairs.length - 1] as FragmentDurationPair;
         return _loc1_.duration == 0 && _loc1_.discontinuityIndicator == 0;
      }
      
      public function adjustEndEntryDurationAccrued(param1:Number) : void
      {
         var _loc2_:FragmentDurationPair = _fragmentDurationPairs[_fragmentDurationPairs.length - 1];
         if(_loc2_.duration == 0)
         {
            _loc2_.durationAccrued = param1;
         }
      }
      
      private function findValidFragmentDurationPair(param1:uint) : FragmentDurationPair
      {
         var _loc3_:* = 0;
         var _loc2_:FragmentDurationPair = null;
         _loc3_ = param1;
         while(param1 < _fragmentDurationPairs.length)
         {
            _loc2_ = _fragmentDurationPairs[_loc3_];
            if(_loc2_.duration > 0)
            {
               return _loc2_;
            }
            _loc3_++;
         }
         return null;
      }
      
      private function calculateFragmentId(param1:FragmentDurationPair, param2:Number) : uint
      {
         if(param1.duration <= 0)
         {
            return param1.firstFragment;
         }
         var _loc3_:Number = param2 - param1.durationAccrued;
         var _loc4_:uint = _loc3_ > 0 ? _loc3_ / param1.duration : 1;
         if(_loc3_ % param1.duration > 0)
         {
            _loc4_++;
         }
         return param1.firstFragment + _loc4_ - 1;
      }
   }
}

