package com.hurlant.crypto.hash
{
   public class SHA256 extends SHABase implements IHash
   {
      protected static const k:Array = [1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298];
      
      protected var _h:Array = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225];
      
      public function SHA256()
      {
         super();
      }
      
      override public function getHashSize() : uint
      {
         return 32;
      }
      
      override protected function core(param1:Array, param2:uint) : Array
      {
         var _loc16_:* = 0;
         var _loc21_:* = 0;
         var _loc22_:* = 0;
         var _loc15_:* = 0;
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         var _loc20_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc19_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc25_:* = 0;
         var _loc24_:* = 0;
         param1[param2 >> 5] |= 128 << 24 - param2 % 32;
         param1[(param2 + 64 >> 9 << 4) + 15] = param2;
         var _loc23_:Array = [];
         var _loc7_:uint = uint(_h[0]);
         var _loc8_:* = uint(_h[1]);
         var _loc9_:* = uint(_h[2]);
         var _loc10_:* = uint(_h[3]);
         var _loc11_:uint = uint(_h[4]);
         var _loc12_:* = uint(_h[5]);
         var _loc13_:* = uint(_h[6]);
         var _loc14_:* = uint(_h[7]);
         _loc16_ = 0;
         while(_loc16_ < param1.length)
         {
            _loc21_ = _loc7_;
            _loc22_ = _loc8_;
            _loc15_ = _loc9_;
            _loc17_ = _loc10_;
            _loc18_ = _loc11_;
            _loc20_ = _loc12_;
            _loc3_ = _loc13_;
            _loc4_ = _loc14_;
            _loc19_ = 0;
            while(_loc19_ < 64)
            {
               if(_loc19_ < 16)
               {
                  _loc23_[_loc19_] = param1[_loc16_ + _loc19_] || 0;
               }
               else
               {
                  _loc5_ = uint(rrol(_loc23_[_loc19_ - 15],7) ^ rrol(_loc23_[_loc19_ - 15],18) ^ _loc23_[_loc19_ - 15] >>> 3);
                  _loc6_ = uint(rrol(_loc23_[_loc19_ - 2],17) ^ rrol(_loc23_[_loc19_ - 2],19) ^ _loc23_[_loc19_ - 2] >>> 10);
                  _loc23_[_loc19_] = _loc23_[_loc19_ - 16] + _loc5_ + _loc23_[_loc19_ - 7] + _loc6_;
               }
               _loc25_ = uint((rrol(_loc7_,2) ^ rrol(_loc7_,13) ^ rrol(_loc7_,22)) + (_loc7_ & _loc8_ ^ _loc7_ & _loc9_ ^ _loc8_ & _loc9_));
               _loc24_ = _loc14_ + (rrol(_loc11_,6) ^ rrol(_loc11_,11) ^ rrol(_loc11_,25)) + (_loc11_ & _loc12_ ^ _loc13_ & ~_loc11_) + k[_loc19_] + _loc23_[_loc19_];
               _loc14_ = _loc13_;
               _loc13_ = _loc12_;
               _loc12_ = _loc11_;
               _loc11_ = _loc10_ + _loc24_;
               _loc10_ = _loc9_;
               _loc9_ = _loc8_;
               _loc8_ = _loc7_;
               _loc7_ = _loc24_ + _loc25_;
               _loc19_++;
            }
            _loc7_ += _loc21_;
            _loc8_ += _loc22_;
            _loc9_ += _loc15_;
            _loc10_ += _loc17_;
            _loc11_ += _loc18_;
            _loc12_ += _loc20_;
            _loc13_ += _loc3_;
            _loc14_ += _loc4_;
            _loc16_ += 16;
         }
         return [_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_];
      }
      
      protected function rrol(param1:uint, param2:uint) : uint
      {
         return param1 << 32 - param2 | param1 >>> param2;
      }
      
      override public function toString() : String
      {
         return "sha256";
      }
   }
}

