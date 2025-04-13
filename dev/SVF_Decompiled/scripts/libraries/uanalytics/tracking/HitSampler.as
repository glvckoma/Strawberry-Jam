package libraries.uanalytics.tracking
{
   import flash.utils.ByteArray;
   import libraries.uanalytics.utils.crc32;
   import libraries.uanalytics.utils.isDigit;
   
   public class HitSampler
   {
      public function HitSampler()
      {
         super();
      }
      
      private static function _hashString(param1:String) : Number
      {
         var _loc2_:crc32 = new crc32();
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(param1);
         _loc2_.update(_loc3_);
         return _loc2_.valueOf();
      }
      
      private static function _parseNumber(param1:String) : Number
      {
         var _loc3_:* = 0;
         if(param1 == "")
         {
            return NaN;
         }
         var _loc4_:uint = uint(param1.length);
         var _loc2_:uint = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            if(param1.charAt(_loc3_) == "." && _loc2_ == 0)
            {
               _loc2_++;
            }
            else if(!isDigit(param1,_loc3_))
            {
               return NaN;
            }
            _loc3_++;
         }
         return parseFloat(param1);
      }
      
      public static function isSampled(param1:HitModel, param2:String = "") : Boolean
      {
         var _loc3_:Number = getSampleRate(param2);
         return _loc3_ < 100 && _hashString(param1.get("clientId")) % 10000 >= 100 * _loc3_;
      }
      
      public static function getSampleRate(param1:String) : Number
      {
         if(param1 == null || param1 == "")
         {
            return 100;
         }
         var _loc2_:Number = Math.max(0,Math.min(100,Math.round(_parseNumber(param1) * 100) / 100));
         if(isNaN(_loc2_))
         {
            return 0;
         }
         return _loc2_;
      }
   }
}

