package com.sbi.corelib
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.ResourceStack;
   
   public class Utils
   {
      public function Utils()
      {
         super();
      }
      
      public static function getDefByName(param1:String) : Class
      {
         var _loc2_:Class = null;
         try
         {
            _loc2_ = ResourceStack.hudAssetsLoaderInfo.applicationDomain.getDefinition(param1) as Class;
         }
         catch(re:ReferenceError)
         {
            DebugUtility.debugTrace("WARNING: Missing class definition \"" + param1 + "\"!");
            _loc2_ = null;
         }
         return _loc2_;
      }
      
      public static function damerauLevenshteinDistance(param1:Array, param2:Array, param3:int) : int
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc12_:int = 0;
         var _loc15_:* = 0;
         var _loc13_:int = 0;
         var _loc11_:int = 0;
         var _loc9_:* = 0;
         var _loc7_:int = 0;
         var _loc4_:int = int(param1.length + param2.length);
         var _loc10_:SimpleMatrix = new SimpleMatrix(param1.length + 2,param2.length + 2);
         _loc10_[0][0] = _loc4_;
         _loc5_ = 0;
         while(_loc5_ <= param1.length)
         {
            _loc10_[_loc5_ + 1][1] = _loc5_;
            _loc10_[_loc5_ + 1][0] = _loc4_;
            _loc5_++;
         }
         _loc6_ = 0;
         while(_loc6_ <= param2.length)
         {
            _loc10_[1][_loc6_ + 1] = _loc6_;
            _loc10_[0][_loc6_ + 1] = _loc4_;
            _loc6_++;
         }
         var _loc14_:Array = new Array(param3);
         _loc8_ = 0;
         while(_loc8_ < param3)
         {
            _loc14_[_loc8_] = 0;
            _loc8_++;
         }
         _loc12_ = 1;
         while(_loc12_ <= param1.length)
         {
            _loc15_ = 0;
            _loc13_ = 1;
            while(_loc13_ <= param2.length)
            {
               _loc11_ = int(_loc14_[param2[_loc13_ - 1]]);
               _loc9_ = _loc15_;
               _loc7_ = param1[_loc12_ - 1] == param2[_loc13_ - 1] ? 0 : 1;
               if(_loc7_ == 0)
               {
                  _loc15_ = _loc13_;
               }
               _loc10_[_loc12_ + 1][_loc13_ + 1] = Math.min(_loc10_[_loc12_][_loc13_] + _loc7_,_loc10_[_loc12_ + 1][_loc13_] + 1,_loc10_[_loc12_][_loc13_ + 1] + 1,_loc10_[_loc11_][_loc9_] + (_loc12_ - _loc11_ - 1) + 1 + (_loc13_ - _loc9_ - 1));
               _loc13_++;
            }
            _loc14_[param1[_loc12_ - 1]] = _loc12_;
            _loc12_++;
         }
         return _loc10_[param1.length + 1][param2.length + 1];
      }
   }
}

dynamic class SimpleMatrix extends Array
{
   public var rows:int;
   
   public var cols:int;
   
   public function SimpleMatrix(param1:int = 0, param2:int = -1)
   {
      var _loc3_:int = 0;
      super(param1);
      if(param2 == -1)
      {
         param2 = param1;
      }
      _loc3_ = 0;
      while(_loc3_ < param1)
      {
         this[_loc3_] = new Array(param2);
         _loc3_++;
      }
      rows = param1;
      cols = param2;
   }
}
