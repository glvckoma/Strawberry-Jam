package libraries.uanalytics.utils
{
   import flash.crypto.generateRandomBytes;
   import flash.utils.ByteArray;
   
   public function generateUUID() : String
   {
      var toHex:Function;
      var str:String;
      var i:uint;
      var l:uint;
      var byte:uint;
      var uuid:String;
      var randomBytes:ByteArray = generateRandomBytes(16);
      randomBytes[6] &= 15;
      randomBytes[6] |= 64;
      randomBytes[8] &= 63;
      randomBytes[8] |= 128;
      toHex = function(param1:uint):String
      {
         var _loc2_:String = param1.toString(16);
         return _loc2_.length > 1 ? _loc2_ : "0" + _loc2_;
      };
      str = "";
      l = randomBytes.length;
      randomBytes.position = 0;
      i = 0;
      while(i < l)
      {
         byte = uint(randomBytes[i]);
         str += toHex(byte);
         i++;
      }
      uuid = "";
      uuid += str.substr(0,8);
      uuid += "-";
      uuid += str.substr(8,4);
      uuid += "-";
      uuid += str.substr(12,4);
      uuid += "-";
      uuid += str.substr(16,4);
      uuid += "-";
      uuid += str.substr(20,12);
      return uuid;
   }
}

