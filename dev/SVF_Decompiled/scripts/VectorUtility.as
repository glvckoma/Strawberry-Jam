package
{
   public class VectorUtility
   {
      public function VectorUtility()
      {
         super();
      }
      
      public static function safeAdd(param1:*, param2:int, param3:*) : void
      {
         while(param2 > param1.length)
         {
            param1.push(null);
         }
         param1[param2] = param3;
      }
      
      public static function vectorToArray(param1:*) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         var _loc2_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_[_loc3_] = param1[_loc3_];
            _loc3_++;
         }
         return _loc2_;
      }
      
      public static function sortOn(param1:*, param2:Object, param3:Object = null) : Array
      {
         return vectorToArray(param1).sortOn(param2,param3);
      }
   }
}

