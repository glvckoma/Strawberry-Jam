package com.sbi.corelib.crypto
{
   import com.hurlant.crypto.Crypto;
   import com.hurlant.crypto.hash.HMAC;
   import com.hurlant.crypto.hash.SHA256;
   import com.hurlant.crypto.symmetric.ICipher;
   import com.hurlant.crypto.symmetric.IVMode;
   import com.hurlant.crypto.symmetric.PKCS5;
   import com.hurlant.util.Base64;
   import flash.utils.ByteArray;
   
   public class SBCrypto
   {
      public function SBCrypto()
      {
         super();
      }
      
      public static function hmacSha256(param1:String, param2:String) : String
      {
         return param1 != null && param2 != null && param2.length > 0 ? Base64.encodeByteArray(new HMAC(new SHA256()).compute(getUTFBytes(param1),getUTFBytes(param2))) : "";
      }
      
      public static function getUTFBytes(param1:String) : ByteArray
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return _loc2_;
      }
      
      public static function encrypt(param1:String, param2:String) : String
      {
         var _loc5_:ByteArray = new SHA256().hash(getUTFBytes(param2));
         var _loc4_:ByteArray = getUTFBytes(param1);
         var _loc3_:ICipher = Crypto.getCipher("aes-256-cbc",_loc5_,new PKCS5());
         _loc3_.encrypt(_loc4_);
         var _loc7_:IVMode = _loc3_ as IVMode;
         var _loc6_:ByteArray = _loc7_.IV;
         _loc6_.writeBytes(_loc4_);
         return Base64.encodeByteArray(_loc6_);
      }
   }
}

