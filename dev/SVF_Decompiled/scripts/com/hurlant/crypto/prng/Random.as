package com.hurlant.crypto.prng
{
   import com.hurlant.util.Memory;
   import flash.system.Capabilities;
   import flash.system.System;
   import flash.text.Font;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class Random
   {
      private var state:IPRNG;
      
      private var ready:Boolean = false;
      
      private var pool:ByteArray;
      
      private var psize:int;
      
      private var pptr:int;
      
      private var seeded:Boolean = false;
      
      public function Random(param1:Class = null)
      {
         var _loc2_:* = 0;
         super();
         if(param1 == null)
         {
            param1 = ARC4;
         }
         state = new param1() as IPRNG;
         psize = state.getPoolSize();
         pool = new ByteArray();
         pptr = 0;
         while(pptr < psize)
         {
            _loc2_ = 65536 * Math.random();
            pool[pptr++] = _loc2_ >>> 8;
            pool[pptr++] = _loc2_ & 0xFF;
         }
         pptr = 0;
         seed();
      }
      
      public function seed(param1:int = 0) : void
      {
         if(param1 == 0)
         {
            param1 = int(new Date().getTime());
         }
         var _loc2_:* = pptr++;
         var _loc3_:* = pool[_loc2_] ^ param1 & 0xFF;
         pool[_loc2_] = _loc3_;
         pool[pptr++] ^= param1 >> 8 & 0xFF;
         pool[pptr++] ^= param1 >> 16 & 0xFF;
         pool[pptr++] ^= param1 >> 24 & 0xFF;
         pptr %= psize;
         seeded = true;
      }
      
      public function autoSeed() : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(System.totalMemory);
         _loc2_.writeUTF(Capabilities.serverString);
         _loc2_.writeUnsignedInt(getTimer());
         _loc2_.writeUnsignedInt(new Date().getTime());
         var _loc1_:Array = Font.enumerateFonts(true);
         for each(var _loc3_ in _loc1_)
         {
            _loc2_.writeUTF(_loc3_.fontName);
            _loc2_.writeUTF(_loc3_.fontStyle);
            _loc2_.writeUTF(_loc3_.fontType);
         }
         _loc2_.position = 0;
         while(_loc2_.bytesAvailable >= 4)
         {
            seed(_loc2_.readUnsignedInt());
         }
      }
      
      public function nextBytes(param1:ByteArray, param2:int) : void
      {
         while(param2--)
         {
            param1.writeByte(nextByte());
         }
      }
      
      public function nextByte() : int
      {
         if(!ready)
         {
            if(!seeded)
            {
               autoSeed();
            }
            state.init(pool);
            pool.length = 0;
            pptr = 0;
            ready = true;
         }
         return state.next();
      }
      
      public function dispose() : void
      {
         var _loc1_:* = 0;
         _loc1_ = 0;
         while(_loc1_ < pool.length)
         {
            pool[_loc1_] = Math.random() * 256;
            _loc1_++;
         }
         pool.length = 0;
         pool = null;
         state.dispose();
         state = null;
         psize = 0;
         pptr = 0;
         Memory.gc();
      }
      
      public function toString() : String
      {
         return "random-" + state.toString();
      }
   }
}

