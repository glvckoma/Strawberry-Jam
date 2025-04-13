package com.hurlant.crypto.symmetric
{
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class TripleDESKey extends DESKey
   {
      protected var encKey2:Array;
      
      protected var encKey3:Array;
      
      protected var decKey2:Array;
      
      protected var decKey3:Array;
      
      public function TripleDESKey(param1:ByteArray)
      {
         super(param1);
         encKey2 = generateWorkingKey(false,param1,8);
         decKey2 = generateWorkingKey(true,param1,8);
         if(param1.length > 16)
         {
            encKey3 = generateWorkingKey(true,param1,16);
            decKey3 = generateWorkingKey(false,param1,16);
         }
         else
         {
            encKey3 = encKey;
            decKey3 = decKey;
         }
      }
      
      override public function dispose() : void
      {
         super.dispose();
         var _loc1_:uint = 0;
         if(encKey2 != null)
         {
            _loc1_ = 0;
            while(_loc1_ < encKey2.length)
            {
               encKey2[_loc1_] = 0;
               _loc1_++;
            }
            encKey2 = null;
         }
         if(encKey3 != null)
         {
            _loc1_ = 0;
            while(_loc1_ < encKey3.length)
            {
               encKey3[_loc1_] = 0;
               _loc1_++;
            }
            encKey3 = null;
         }
         if(decKey2 != null)
         {
            _loc1_ = 0;
            while(_loc1_ < decKey2.length)
            {
               decKey2[_loc1_] = 0;
               _loc1_++;
            }
            decKey2 = null;
         }
         if(decKey3 != null)
         {
            _loc1_ = 0;
            while(_loc1_ < decKey3.length)
            {
               decKey3[_loc1_] = 0;
               _loc1_++;
            }
            decKey3 = null;
         }
         Memory.gc();
      }
      
      override public function encrypt(param1:ByteArray, param2:uint = 0) : void
      {
         desFunc(encKey,param1,param2,param1,param2);
         desFunc(encKey2,param1,param2,param1,param2);
         desFunc(encKey3,param1,param2,param1,param2);
      }
      
      override public function decrypt(param1:ByteArray, param2:uint = 0) : void
      {
         desFunc(decKey3,param1,param2,param1,param2);
         desFunc(decKey2,param1,param2,param1,param2);
         desFunc(decKey,param1,param2,param1,param2);
      }
      
      override public function toString() : String
      {
         return "3des";
      }
   }
}

