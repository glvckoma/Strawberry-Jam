package com.sbi.graphics
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class SortLayer extends Sprite
   {
      private var _bottoms:Dictionary;
      
      private var _nudge:Number = 0;
      
      private var _throttle:int;
      
      public function SortLayer()
      {
         super();
         _bottoms = new Dictionary(true);
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:int = int(param1.name);
         param1.name = (getNudge() + _loc2_).toString();
         return super.addChild(param1);
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         var _loc3_:int = int(param1.name);
         param1.name = (getNudge() + _loc3_).toString();
         return super.addChildAt(param1,param2);
      }
      
      public function release() : void
      {
         _nudge = 0;
         _bottoms = new Dictionary(true);
      }
      
      public function depthSort(param1:DisplayObject, param2:DisplayObject) : int
      {
         return _bottoms[param1] - _bottoms[param2];
      }
      
      public function heartbeat() : void
      {
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:Rectangle = null;
         var _loc9_:Boolean = false;
         var _loc5_:* = NaN;
         var _loc7_:Array = null;
         var _loc3_:DisplayObject = null;
         var _loc8_:Number = NaN;
         var _loc4_:Number = NaN;
         _throttle++;
         if(_throttle > 20)
         {
            _throttle = 0;
            _loc2_ = this.numChildren;
            _loc5_ = -999999999;
            if(_loc2_ < 2)
            {
               return;
            }
            _loc7_ = [_loc2_];
            _loc6_ = 0;
            while(_loc6_ < _loc2_)
            {
               _loc3_ = this.getChildAt(_loc6_);
               _loc7_[_loc6_] = _loc3_;
               _loc1_ = _loc3_.getBounds(this);
               _loc8_ = _loc1_.bottom;
               _loc4_ = Number(_loc3_.name);
               if(!_loc4_)
               {
                  _loc4_ = getNudge();
                  _loc3_.name = _loc4_.toString();
               }
               _loc8_ -= _loc4_;
               _bottoms[_loc3_] = _loc8_;
               if(!_loc9_)
               {
                  if(_loc8_ < _loc5_)
                  {
                     _loc9_ = true;
                  }
                  _loc5_ = _loc8_;
               }
               _loc6_++;
            }
            if(_loc9_)
            {
               _loc7_.sort(depthSort);
               _loc6_ = 0;
               while(_loc6_ < _loc2_)
               {
                  this.setChildIndex(_loc7_[_loc6_],_loc6_);
                  _loc6_++;
               }
            }
         }
      }
      
      private function getNudge() : Number
      {
         _nudge += 0.001;
         if(_nudge > 0.9)
         {
            _nudge = 0;
         }
         return _nudge;
      }
      
      private function sort(param1:Vector.<Number>) : void
      {
         quickSort(param1,0,param1.length - 1);
         InsertionSort(param1,0,param1.length - 1);
      }
      
      private function quickSort(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         if(param3 - param2 > 4)
         {
            _loc5_ = (param3 + param2) / 2;
            if(param1[param2] > param1[_loc5_])
            {
               swap(param1,param2,_loc5_);
            }
            if(param1[param2] > param1[param3])
            {
               swap(param1,param2,param3);
            }
            if(param1[_loc5_] > param1[param3])
            {
               swap(param1,_loc5_,param3);
            }
            _loc6_ = param3 - 1;
            swap(param1,_loc5_,_loc6_);
            _loc5_ = param2;
            _loc4_ = param1[_loc6_];
            while(true)
            {
               do
               {
                  _loc5_++;
               }
               while(param1[_loc5_] < _loc4_);
               
               do
               {
                  _loc6_--;
               }
               while(param1[_loc6_] > _loc4_);
               
               if(_loc6_ < _loc5_)
               {
                  break;
               }
               swap(param1,_loc5_,_loc6_);
            }
            swap(param1,_loc5_,param3 - 1);
            quickSort(param1,param2,_loc6_);
            quickSort(param1,_loc5_ + 1,param3);
         }
      }
      
      private function swap(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         var _loc4_:Number = NaN;
         _loc4_ = param1[param2];
         param1[param2] = param1[param3];
         param1[param3] = _loc4_;
         swapChildrenAt(param2,param3);
      }
      
      private function move(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         param1[param3] = param1[param2];
         addChildAt(getChildAt(param2),param3);
      }
      
      private function InsertionSort(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:* = 0;
         var _loc4_:Number = NaN;
         _loc5_ = param2 + 1;
         while(_loc5_ <= param3)
         {
            _loc4_ = param1[_loc5_];
            _loc6_ = _loc5_;
            while(_loc6_ > param2 && param1[_loc6_ - 1] > _loc4_)
            {
               move(param1,_loc6_ - 1,_loc6_);
               _loc6_--;
            }
            _loc5_++;
         }
      }
   }
}

