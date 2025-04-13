package avatar
{
   import com.sbi.bit.BitUtility;
   
   public class UserVarCache
   {
      private var _cache:Object;
      
      public function UserVarCache()
      {
         super();
      }
      
      public function init() : void
      {
         _cache = {};
      }
      
      public function set playerUserVars(param1:Object) : void
      {
         _cache = {};
         for(var _loc2_ in param1)
         {
            _cache[_loc2_] = {
               "value":param1[_loc2_].value,
               "type":param1[_loc2_].type
            };
         }
      }
      
      public function get playerUserVars() : Object
      {
         return _cache;
      }
      
      public function getUserVarValueById(param1:int) : Number
      {
         if(_cache && _cache[param1])
         {
            return _cache[param1].value;
         }
         return -1;
      }
      
      public function getUserVarTypeById(param1:int) : int
      {
         if(_cache && _cache[param1])
         {
            return _cache[param1].type;
         }
         return -1;
      }
      
      public function isBitSet(param1:int, param2:int) : Boolean
      {
         if(_cache && _cache[param1])
         {
            return BitUtility.bitwiseAnd(_cache[param1].value,BitUtility.leftShiftNumbers(param2)) > 0;
         }
         return false;
      }
      
      public function numBitsSet(param1:int, param2:int) : int
      {
         var _loc4_:int = 0;
         if(param1 == 0)
         {
            return 0;
         }
         var _loc3_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < param2)
         {
            if(BitUtility.bitwiseAnd(param1,BitUtility.leftShiftNumbers(_loc4_)) > 0)
            {
               _loc3_++;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function updateUserVar(param1:int, param2:Number, param3:int = -1) : void
      {
         if(!_cache)
         {
            _cache = {};
         }
         if(_cache[param1])
         {
            _cache[param1].value = param2;
         }
         else
         {
            _cache[param1] = {
               "value":param2,
               "type":param3
            };
         }
      }
   }
}

