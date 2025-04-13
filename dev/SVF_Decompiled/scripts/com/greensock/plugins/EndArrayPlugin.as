package com.greensock.plugins
{
   import com.greensock.TweenLite;
   
   public class EndArrayPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected var _a:Array;
      
      protected var _round:Boolean;
      
      protected var _info:Array = [];
      
      public function EndArrayPlugin()
      {
         super("endArray");
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(!(param1 is Array) || !(param2 is Array))
         {
            return false;
         }
         _init(param1 as Array,param2);
         return true;
      }
      
      public function _init(param1:Array, param2:Array) : void
      {
         _a = param1;
         var _loc4_:int = int(param2.length);
         var _loc3_:int = 0;
         while(true)
         {
            _loc4_--;
            if(_loc4_ <= -1)
            {
               break;
            }
            if(param1[_loc4_] != param2[_loc4_] && param1[_loc4_] != null)
            {
               _info[_loc3_++] = new ArrayTweenInfo(_loc4_,_a[_loc4_],param2[_loc4_] - _a[_loc4_]);
            }
         }
      }
      
      override public function _roundProps(param1:Object, param2:Boolean = true) : void
      {
         if("endArray" in param1)
         {
            _round = param2;
         }
      }
      
      override public function setRatio(param1:Number) : void
      {
         var _loc3_:ArrayTweenInfo = null;
         var _loc2_:Number = NaN;
         var _loc4_:int = int(_info.length);
         if(_round)
         {
            while(true)
            {
               _loc4_--;
               if(_loc4_ <= -1)
               {
                  break;
               }
               _loc3_ = _info[_loc4_];
               _a[_loc3_.i] = (_loc2_ = _loc3_.c * param1 + _loc3_.s) > 0 ? _loc2_ + 0.5 >> 0 : _loc2_ - 0.5 >> 0;
            }
         }
         else
         {
            while(true)
            {
               _loc4_--;
               if(_loc4_ <= -1)
               {
                  break;
               }
               _loc3_ = _info[_loc4_];
               _a[_loc3_.i] = _loc3_.c * param1 + _loc3_.s;
            }
         }
      }
   }
}

class ArrayTweenInfo
{
   public var i:uint;
   
   public var s:Number;
   
   public var c:Number;
   
   public function ArrayTweenInfo(param1:uint, param2:Number, param3:Number)
   {
      super();
      this.i = param1;
      this.s = param2;
      this.c = param3;
   }
}
