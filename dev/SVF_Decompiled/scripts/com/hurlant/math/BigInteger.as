package com.hurlant.math
{
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.util.Hex;
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   use namespace bi_internal;
   
   public class BigInteger
   {
      public static const DB:int = 30;
      
      public static const DV:int = 1073741824;
      
      public static const DM:int = 1073741823;
      
      public static const BI_FP:int = 52;
      
      public static const F1:int = 22;
      
      public static const F2:int = 8;
      
      public static const FV:Number = Math.pow(2,52);
      
      public static const ZERO:BigInteger = nbv(0);
      
      public static const ONE:BigInteger = nbv(1);
      
      public static const lowprimes:Array = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,431,433,439,443,449,457,461,463,467,479,487,491,499,503,509];
      
      public static const lplim:int = 67108864 / lowprimes[lowprimes.length - 1];
      
      public var t:int;
      
      bi_internal var s:int;
      
      bi_internal var a:Array;
      
      public function BigInteger(param1:* = null, param2:int = 0)
      {
         var _loc3_:ByteArray = null;
         var _loc4_:int = 0;
         super();
         bi_internal::a = [];
         if(param1 is String)
         {
            param1 = Hex.toArray(param1);
            param2 = 0;
         }
         if(param1 is ByteArray)
         {
            _loc3_ = param1 as ByteArray;
            _loc4_ = int(param2 || _loc3_.length - _loc3_.position);
            bi_internal::fromArray(_loc3_,_loc4_);
         }
      }
      
      public static function nbv(param1:int) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         _loc2_.bi_internal::fromInt(param1);
         return _loc2_;
      }
      
      public function dispose() : void
      {
         var _loc2_:* = 0;
         var _loc1_:Random = new Random();
         _loc2_ = 0;
         while(_loc2_ < bi_internal::a.length)
         {
            bi_internal::a[_loc2_] = _loc1_.nextByte();
            delete bi_internal::a[_loc2_];
            _loc2_++;
         }
         bi_internal::a = null;
         t = 0;
         bi_internal::s = 0;
         Memory.gc();
      }
      
      public function toString(param1:Number = 16) : String
      {
         var _loc7_:int = 0;
         if(bi_internal::s < 0)
         {
            return "-" + negate().toString(param1);
         }
         switch(param1)
         {
            case 2:
               _loc7_ = 1;
               break;
            case 4:
               _loc7_ = 2;
               break;
            case 8:
               _loc7_ = 3;
               break;
            case 16:
               _loc7_ = 4;
               break;
            case 32:
               _loc7_ = 5;
         }
         var _loc3_:int = (1 << _loc7_) - 1;
         var _loc5_:* = 0;
         var _loc8_:Boolean = false;
         var _loc4_:String = "";
         var _loc6_:int = t;
         var _loc2_:int = 30 - _loc6_ * 30 % _loc7_;
         if(_loc6_-- > 0)
         {
            if(_loc2_ < 30 && (_loc5_ = bi_internal::a[_loc6_] >> _loc2_) > 0)
            {
               _loc8_ = true;
               _loc4_ = _loc5_.toString(36);
            }
            while(_loc6_ >= 0)
            {
               if(_loc2_ < _loc7_)
               {
                  _loc6_--;
                  _loc5_ = (bi_internal::a[_loc6_] & (1 << _loc2_) - 1) << _loc7_ - _loc2_;
                  _loc5_ = _loc5_ | bi_internal::a[_loc6_] >> (_loc2_ += 30 - _loc7_);
               }
               else
               {
                  _loc5_ = bi_internal::a[_loc6_] >> (_loc2_ -= _loc7_) & _loc3_;
                  if(_loc2_ <= 0)
                  {
                     _loc2_ += 30;
                     _loc6_--;
                  }
               }
               if(_loc5_ > 0)
               {
                  _loc8_ = true;
               }
               if(_loc8_)
               {
                  _loc4_ += _loc5_.toString(36);
               }
            }
         }
         return _loc8_ ? _loc4_ : "0";
      }
      
      public function toArray(param1:ByteArray) : uint
      {
         var _loc7_:int = 0;
         _loc7_ = 8;
         var _loc3_:int = 0;
         _loc3_ = 255;
         var _loc5_:* = 0;
         var _loc6_:int = t;
         var _loc2_:int = 30 - _loc6_ * 30 % 8;
         var _loc8_:Boolean = false;
         var _loc4_:int = 0;
         if(_loc6_-- > 0)
         {
            if(_loc2_ < 30 && (_loc5_ = bi_internal::a[_loc6_] >> _loc2_) > 0)
            {
               _loc8_ = true;
               param1.writeByte(_loc5_);
               _loc4_++;
            }
            while(_loc6_ >= 0)
            {
               if(_loc2_ < 8)
               {
                  _loc6_--;
                  _loc5_ = (bi_internal::a[_loc6_] & (1 << _loc2_) - 1) << 8 - _loc2_;
                  _loc5_ = _loc5_ | bi_internal::a[_loc6_] >> (_loc2_ += 30 - 8);
               }
               else
               {
                  _loc5_ = bi_internal::a[_loc6_] >> (_loc2_ -= 8) & 0xFF;
                  if(_loc2_ <= 0)
                  {
                     _loc2_ += 30;
                     _loc6_--;
                  }
               }
               if(_loc5_ > 0)
               {
                  _loc8_ = true;
               }
               if(_loc8_)
               {
                  param1.writeByte(_loc5_);
                  _loc4_++;
               }
            }
         }
         return _loc4_;
      }
      
      public function valueOf() : Number
      {
         var _loc2_:* = 0;
         var _loc1_:Number = 1;
         var _loc3_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < t)
         {
            _loc3_ += bi_internal::a[_loc2_] * _loc1_;
            _loc1_ *= 1073741824;
            _loc2_++;
         }
         return _loc3_;
      }
      
      public function negate() : BigInteger
      {
         var _loc1_:BigInteger = nbi();
         ZERO.bi_internal::subTo(this,_loc1_);
         return _loc1_;
      }
      
      public function abs() : BigInteger
      {
         return bi_internal::s < 0 ? negate() : this;
      }
      
      public function compareTo(param1:BigInteger) : int
      {
         var _loc2_:int = bi_internal::s - param1.bi_internal::s;
         if(_loc2_ != 0)
         {
            return _loc2_;
         }
         var _loc3_:int = t;
         _loc2_ = _loc3_ - param1.t;
         if(_loc2_ != 0)
         {
            return _loc2_;
         }
         while(true)
         {
            _loc3_--;
            if(_loc3_ < 0)
            {
               break;
            }
            _loc2_ = bi_internal::a[_loc3_] - param1.bi_internal::a[_loc3_];
            if(_loc2_ != 0)
            {
               return _loc2_;
            }
         }
         return 0;
      }
      
      bi_internal function nbits(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = 1;
         _loc3_ = param1 >>> 16;
         if(_loc3_ != 0)
         {
            param1 = _loc3_;
            _loc2_ += 16;
         }
         _loc3_ = param1 >> 8;
         if(_loc3_ != 0)
         {
            param1 = _loc3_;
            _loc2_ += 8;
         }
         _loc3_ = param1 >> 4;
         if(_loc3_ != 0)
         {
            param1 = _loc3_;
            _loc2_ += 4;
         }
         _loc3_ = param1 >> 2;
         if(_loc3_ != 0)
         {
            param1 = _loc3_;
            _loc2_ += 2;
         }
         _loc3_ = param1 >> 1;
         if(_loc3_ != 0)
         {
            param1 = _loc3_;
            _loc2_ += 1;
         }
         return _loc2_;
      }
      
      public function bitLength() : int
      {
         if(t <= 0)
         {
            return 0;
         }
         return 30 * (t - 1) + bi_internal::nbits(bi_internal::a[t - 1] ^ bi_internal::s & 0x3FFFFFFF);
      }
      
      public function mod(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = nbi();
         abs().bi_internal::divRemTo(param1,null,_loc2_);
         if(bi_internal::s < 0 && _loc2_.compareTo(ZERO) > 0)
         {
            param1.bi_internal::subTo(_loc2_,_loc2_);
         }
         return _loc2_;
      }
      
      public function modPowInt(param1:int, param2:BigInteger) : BigInteger
      {
         var _loc3_:IReduction = null;
         if(param1 < 256 || param2.bi_internal::isEven())
         {
            _loc3_ = new ClassicReduction(param2);
         }
         else
         {
            _loc3_ = new MontgomeryReduction(param2);
         }
         return bi_internal::exp(param1,_loc3_);
      }
      
      bi_internal function copyTo(param1:BigInteger) : void
      {
         var _loc2_:int = 0;
         _loc2_ = t - 1;
         while(_loc2_ >= 0)
         {
            param1.bi_internal::a[_loc2_] = bi_internal::a[_loc2_];
            _loc2_--;
         }
         param1.t = t;
         param1.bi_internal::s = bi_internal::s;
      }
      
      bi_internal function fromInt(param1:int) : void
      {
         t = 1;
         bi_internal::s = param1 < 0 ? -1 : 0;
         if(param1 > 0)
         {
            bi_internal::a[0] = param1;
         }
         else if(param1 < -1)
         {
            bi_internal::a[0] = param1 + 1073741824;
         }
         else
         {
            t = 0;
         }
      }
      
      bi_internal function fromArray(param1:ByteArray, param2:int) : void
      {
         var _loc7_:int = 0;
         _loc7_ = 8;
         var _loc5_:int = 0;
         var _loc3_:int = int(param1.position);
         var _loc6_:int = _loc3_ + param2;
         var _loc4_:int = 0;
         t = 0;
         bi_internal::s = 0;
         while(true)
         {
            _loc6_--;
            if(_loc6_ < _loc3_)
            {
               break;
            }
            _loc5_ = int(_loc6_ < param1.length ? param1[_loc6_] : 0);
            if(_loc4_ == 0)
            {
               bi_internal::a[t++] = _loc5_;
            }
            else if(_loc4_ + 8 > 30)
            {
               var _loc8_:* = t - 1;
               var _loc9_:* = bi_internal::a[_loc8_] | (_loc5_ & (1 << 30 - _loc4_) - 1) << _loc4_;
               bi_internal::a[_loc8_] = _loc9_;
               bi_internal::a[t++] = _loc5_ >> 30 - _loc4_;
            }
            else
            {
               _loc9_ = t - 1;
               _loc8_ = bi_internal::a[_loc9_] | _loc5_ << _loc4_;
               bi_internal::a[_loc9_] = _loc8_;
            }
            _loc4_ += 8;
            if(_loc4_ >= 30)
            {
               _loc4_ -= 30;
            }
         }
         bi_internal::clamp();
         param1.position = Math.min(_loc3_ + param2,param1.length);
      }
      
      bi_internal function clamp() : void
      {
         var _loc1_:* = bi_internal::s & 0x3FFFFFFF;
         while(t > 0 && bi_internal::a[t - 1] == _loc1_)
         {
            --t;
         }
      }
      
      bi_internal function dlShiftTo(param1:int, param2:BigInteger) : void
      {
         var _loc3_:int = 0;
         _loc3_ = t - 1;
         while(_loc3_ >= 0)
         {
            param2.bi_internal::a[_loc3_ + param1] = bi_internal::a[_loc3_];
            _loc3_--;
         }
         _loc3_ = param1 - 1;
         while(_loc3_ >= 0)
         {
            param2.bi_internal::a[_loc3_] = 0;
            _loc3_--;
         }
         param2.t = t + param1;
         param2.bi_internal::s = bi_internal::s;
      }
      
      bi_internal function drShiftTo(param1:int, param2:BigInteger) : void
      {
         var _loc3_:* = 0;
         _loc3_ = param1;
         while(_loc3_ < t)
         {
            param2.bi_internal::a[_loc3_ - param1] = bi_internal::a[_loc3_];
            _loc3_++;
         }
         param2.t = Math.max(t - param1,0);
         param2.bi_internal::s = bi_internal::s;
      }
      
      bi_internal function lShiftTo(param1:int, param2:BigInteger) : void
      {
         var _loc6_:int = 0;
         var _loc3_:int = param1 % 30;
         var _loc5_:int = 30 - _loc3_;
         var _loc7_:int = (1 << _loc5_) - 1;
         var _loc8_:int = param1 / 30;
         var _loc4_:* = bi_internal::s << _loc3_ & 0x3FFFFFFF;
         _loc6_ = t - 1;
         while(_loc6_ >= 0)
         {
            param2.bi_internal::a[_loc6_ + _loc8_ + 1] = bi_internal::a[_loc6_] >> _loc5_ | _loc4_;
            _loc4_ = (bi_internal::a[_loc6_] & _loc7_) << _loc3_;
            _loc6_--;
         }
         _loc6_ = _loc8_ - 1;
         while(_loc6_ >= 0)
         {
            param2.bi_internal::a[_loc6_] = 0;
            _loc6_--;
         }
         param2.bi_internal::a[_loc8_] = _loc4_;
         param2.t = t + _loc8_ + 1;
         param2.bi_internal::s = bi_internal::s;
         param2.bi_internal::clamp();
      }
      
      bi_internal function rShiftTo(param1:int, param2:BigInteger) : void
      {
         var _loc5_:int = 0;
         param2.bi_internal::s = bi_internal::s;
         var _loc7_:int = param1 / 30;
         if(_loc7_ >= t)
         {
            param2.t = 0;
            return;
         }
         var _loc3_:int = param1 % 30;
         var _loc4_:int = 30 - _loc3_;
         var _loc6_:int = (1 << _loc3_) - 1;
         param2.bi_internal::a[0] = bi_internal::a[_loc7_] >> _loc3_;
         _loc5_ = _loc7_ + 1;
         while(_loc5_ < t)
         {
            var _loc8_:* = _loc5_ - _loc7_ - 1;
            var _loc9_:* = param2.bi_internal::a[_loc8_] | (bi_internal::a[_loc5_] & _loc6_) << _loc4_;
            param2.bi_internal::a[_loc8_] = _loc9_;
            param2.bi_internal::a[_loc5_ - _loc7_] = bi_internal::a[_loc5_] >> _loc3_;
            _loc5_++;
         }
         if(_loc3_ > 0)
         {
            _loc9_ = t - _loc7_ - 1;
            _loc8_ = param2.bi_internal::a[_loc9_] | (bi_internal::s & _loc6_) << _loc4_;
            param2.bi_internal::a[_loc9_] = _loc8_;
         }
         param2.t = t - _loc7_;
         param2.bi_internal::clamp();
      }
      
      bi_internal function subTo(param1:BigInteger, param2:BigInteger) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = 0;
         var _loc5_:int = Math.min(param1.t,t);
         while(_loc4_ < _loc5_)
         {
            _loc3_ += bi_internal::a[_loc4_] - param1.bi_internal::a[_loc4_];
            param2.bi_internal::a[_loc4_++] = _loc3_ & 0x3FFFFFFF;
            _loc3_ >>= 30;
         }
         if(param1.t < t)
         {
            _loc3_ -= param1.bi_internal::s;
            while(_loc4_ < t)
            {
               _loc3_ += bi_internal::a[_loc4_];
               param2.bi_internal::a[_loc4_++] = _loc3_ & 0x3FFFFFFF;
               _loc3_ >>= 30;
            }
            _loc3_ += bi_internal::s;
         }
         else
         {
            _loc3_ += bi_internal::s;
            while(_loc4_ < param1.t)
            {
               _loc3_ -= param1.bi_internal::a[_loc4_];
               param2.bi_internal::a[_loc4_++] = _loc3_ & 0x3FFFFFFF;
               _loc3_ >>= 30;
            }
            _loc3_ -= param1.bi_internal::s;
         }
         param2.bi_internal::s = _loc3_ < 0 ? -1 : 0;
         if(_loc3_ < -1)
         {
            param2.bi_internal::a[_loc4_++] = 1073741824 + _loc3_;
         }
         else if(_loc3_ > 0)
         {
            param2.bi_internal::a[_loc4_++] = _loc3_;
         }
         param2.t = _loc4_;
         param2.bi_internal::clamp();
      }
      
      bi_internal function am(param1:int, param2:int, param3:BigInteger, param4:int, param5:int, param6:int) : int
      {
         var _loc10_:* = 0;
         var _loc9_:* = 0;
         var _loc11_:int = 0;
         var _loc8_:* = param2 & 0x7FFF;
         var _loc7_:* = param2 >> 15;
         while(true)
         {
            param6--;
            if(param6 < 0)
            {
               break;
            }
            _loc10_ = bi_internal::a[param1] & 0x7FFF;
            _loc9_ = bi_internal::a[param1++] >> 15;
            _loc11_ = _loc7_ * _loc10_ + _loc9_ * _loc8_;
            _loc10_ = _loc8_ * _loc10_ + ((_loc11_ & 0x7FFF) << 15) + param3.bi_internal::a[param4] + (param5 & 0x3FFFFFFF);
            param5 = (_loc10_ >>> 30) + (_loc11_ >>> 15) + _loc7_ * _loc9_ + (param5 >>> 30);
            param3.bi_internal::a[param4++] = _loc10_ & 0x3FFFFFFF;
         }
         return param5;
      }
      
      bi_internal function multiplyTo(param1:BigInteger, param2:BigInteger) : void
      {
         var _loc3_:BigInteger = abs();
         var _loc4_:BigInteger = param1.abs();
         var _loc5_:int = _loc3_.t;
         param2.t = _loc5_ + _loc4_.t;
         while(true)
         {
            _loc5_--;
            if(_loc5_ < 0)
            {
               break;
            }
            param2.bi_internal::a[_loc5_] = 0;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc4_.t)
         {
            param2.bi_internal::a[_loc5_ + _loc3_.t] = _loc3_.bi_internal::am(0,_loc4_.bi_internal::a[_loc5_],param2,_loc5_,0,_loc3_.t);
            _loc5_++;
         }
         param2.bi_internal::s = 0;
         param2.bi_internal::clamp();
         if(bi_internal::s != param1.bi_internal::s)
         {
            ZERO.bi_internal::subTo(param2,param2);
         }
      }
      
      bi_internal function squareTo(param1:BigInteger) : void
      {
         var _loc2_:int = 0;
         var _loc3_:BigInteger = abs();
         var _loc4_:* = param1.t = 2 * _loc3_.t;
         while(true)
         {
            _loc4_--;
            if(_loc4_ < 0)
            {
               break;
            }
            param1.bi_internal::a[_loc4_] = 0;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_.t - 1)
         {
            _loc2_ = _loc3_.bi_internal::am(_loc4_,_loc3_.bi_internal::a[_loc4_],param1,2 * _loc4_,0,1);
            param1.bi_internal::a[_loc4_ + _loc3_.t] += _loc3_.bi_internal::am(_loc4_ + 1,2 * _loc3_.bi_internal::a[_loc4_],param1,2 * _loc4_ + 1,_loc2_,_loc3_.t - _loc4_ - 1);
            if(_loc6_ >= 1073741824)
            {
               var _loc6_:* = _loc4_ + _loc3_.t;
               var _loc5_:* = param1.bi_internal::a[_loc6_] - 1073741824;
               param1.bi_internal::a[_loc6_] = _loc5_;
               param1.bi_internal::a[_loc4_ + _loc3_.t + 1] = 1;
            }
            _loc4_++;
         }
         if(param1.t > 0)
         {
            _loc5_ = param1.t - 1;
            _loc6_ = param1.bi_internal::a[_loc5_] + _loc3_.bi_internal::am(_loc4_,_loc3_.bi_internal::a[_loc4_],param1,2 * _loc4_,0,1);
            param1.bi_internal::a[_loc5_] = _loc6_;
         }
         param1.bi_internal::s = 0;
         param1.bi_internal::clamp();
      }
      
      bi_internal function divRemTo(param1:BigInteger, param2:BigInteger = null, param3:BigInteger = null) : void
      {
         var _loc12_:int = 0;
         var _loc18_:BigInteger = param1.abs();
         if(_loc18_.t <= 0)
         {
            return;
         }
         var _loc5_:BigInteger = abs();
         if(_loc5_.t < _loc18_.t)
         {
            if(param2 != null)
            {
               param2.bi_internal::fromInt(0);
            }
            if(param3 != null)
            {
               bi_internal::copyTo(param3);
            }
            return;
         }
         if(param3 == null)
         {
            param3 = nbi();
         }
         var _loc15_:BigInteger = nbi();
         var _loc19_:int = bi_internal::s;
         var _loc7_:int = param1.bi_internal::s;
         var _loc4_:int = 30 - bi_internal::nbits(_loc18_.bi_internal::a[_loc18_.t - 1]);
         if(_loc4_ > 0)
         {
            _loc18_.bi_internal::lShiftTo(_loc4_,_loc15_);
            _loc5_.bi_internal::lShiftTo(_loc4_,param3);
         }
         else
         {
            _loc18_.bi_internal::copyTo(_loc15_);
            _loc5_.bi_internal::copyTo(param3);
         }
         var _loc16_:int = _loc15_.t;
         var _loc14_:int = int(_loc15_.bi_internal::a[_loc16_ - 1]);
         if(_loc14_ == 0)
         {
            return;
         }
         var _loc17_:Number = _loc14_ * (1 << 22) + (_loc16_ > 1 ? _loc15_.bi_internal::a[_loc16_ - 2] >> 8 : 0);
         var _loc10_:Number = FV / _loc17_;
         var _loc11_:Number = (1 << 22) / _loc17_;
         var _loc8_:int = param3.t;
         var _loc9_:int = _loc8_ - _loc16_;
         var _loc13_:BigInteger = param2 == null ? nbi() : param2;
         _loc15_.bi_internal::dlShiftTo(_loc9_,_loc13_);
         if(param3.compareTo(_loc13_) >= 0)
         {
            param3.bi_internal::a[param3.t++] = 1;
            param3.bi_internal::subTo(_loc13_,param3);
         }
         ONE.bi_internal::dlShiftTo(_loc16_,_loc13_);
         _loc13_.bi_internal::subTo(_loc15_,_loc15_);
         while(_loc15_.t < _loc16_)
         {
            _loc15_.(_loc15_.t++, false);
         }
         while(true)
         {
            _loc9_--;
            if(_loc9_ < 0)
            {
               break;
            }
            _loc8_--;
            _loc12_ = int(param3.bi_internal::a[_loc8_] == _loc14_ ? 1073741823 : Number(param3.bi_internal::a[_loc8_]) * _loc10_ + (Number(param3.bi_internal::a[_loc8_ - 1]) + 256) * _loc11_);
            param3.bi_internal::a[_loc8_] += _loc15_.bi_internal::am(0,_loc12_,param3,_loc9_,0,_loc16_);
            if(_loc21_ < _loc12_)
            {
               _loc15_.bi_internal::dlShiftTo(_loc9_,_loc13_);
               param3.bi_internal::subTo(_loc13_,param3);
               while(true)
               {
                  _loc12_--;
                  if(param3.bi_internal::a[_loc8_] >= _loc12_)
                  {
                     break;
                  }
                  param3.bi_internal::subTo(_loc13_,param3);
               }
            }
         }
         if(param2 != null)
         {
            param3.bi_internal::drShiftTo(_loc16_,param2);
            if(_loc19_ != _loc7_)
            {
               ZERO.bi_internal::subTo(param2,param2);
            }
         }
         param3.t = _loc16_;
         param3.bi_internal::clamp();
         if(_loc4_ > 0)
         {
            param3.bi_internal::rShiftTo(_loc4_,param3);
         }
         if(_loc19_ < 0)
         {
            ZERO.bi_internal::subTo(param3,param3);
         }
      }
      
      bi_internal function invDigit() : int
      {
         if(t < 1)
         {
            return 0;
         }
         var _loc1_:int = int(bi_internal::a[0]);
         if((_loc1_ & 1) == 0)
         {
            return 0;
         }
         var _loc2_:* = _loc1_ & 3;
         _loc2_ = _loc2_ * (2 - (_loc1_ & 0x0F) * _loc2_) & 0x0F;
         _loc2_ = _loc2_ * (2 - (_loc1_ & 0xFF) * _loc2_) & 0xFF;
         _loc2_ = _loc2_ * (2 - ((_loc1_ & 0xFFFF) * _loc2_ & 0xFFFF)) & 0xFFFF;
         _loc2_ = _loc2_ * (2 - _loc1_ * _loc2_ % 1073741824) % 1073741824;
         return _loc2_ > 0 ? 1073741824 - _loc2_ : -_loc2_;
      }
      
      bi_internal function isEven() : Boolean
      {
         return (t > 0 ? bi_internal::a[0] & 1 : bi_internal::s) == 0;
      }
      
      bi_internal function exp(param1:int, param2:IReduction) : BigInteger
      {
         var _loc5_:* = null;
         if(param1 > 4294967295 || param1 < 1)
         {
            return ONE;
         }
         var _loc4_:* = nbi();
         var _loc3_:* = nbi();
         var _loc6_:BigInteger = param2.convert(this);
         var _loc7_:int = bi_internal::nbits(param1) - 1;
         _loc6_.bi_internal::copyTo(_loc4_);
         while(true)
         {
            _loc7_--;
            if(_loc7_ < 0)
            {
               break;
            }
            param2.sqrTo(_loc4_,_loc3_);
            if((param1 & 1 << _loc7_) > 0)
            {
               param2.mulTo(_loc3_,_loc6_,_loc4_);
            }
            else
            {
               _loc5_ = _loc4_;
               _loc4_ = _loc3_;
               _loc3_ = _loc5_;
            }
         }
         return param2.revert(_loc4_);
      }
      
      bi_internal function intAt(param1:String, param2:int) : int
      {
         return parseInt(param1.charAt(param2),36);
      }
      
      protected function nbi() : *
      {
         return new BigInteger();
      }
      
      public function clone() : BigInteger
      {
         var _loc1_:BigInteger = new BigInteger();
         this.bi_internal::copyTo(_loc1_);
         return _loc1_;
      }
      
      public function intValue() : int
      {
         if(bi_internal::s < 0)
         {
            if(t == 1)
            {
               return bi_internal::a[0] - 1073741824;
            }
            if(t == 0)
            {
               return -1;
            }
         }
         else
         {
            if(t == 1)
            {
               return bi_internal::a[0];
            }
            if(t == 0)
            {
               return 0;
            }
         }
         return (bi_internal::a[1] & 3) << 30 | bi_internal::a[0];
      }
      
      public function byteValue() : int
      {
         return t == 0 ? bi_internal::s : bi_internal::a[0] << 24 >> 24;
      }
      
      public function shortValue() : int
      {
         return t == 0 ? bi_internal::s : bi_internal::a[0] << 16 >> 16;
      }
      
      protected function chunkSize(param1:Number) : int
      {
         return Math.floor(0.6931471805599453 * 30 / Math.log(param1));
      }
      
      public function sigNum() : int
      {
         if(bi_internal::s < 0)
         {
            return -1;
         }
         if(t <= 0 || t == 1 && bi_internal::a[0] <= 0)
         {
            return 0;
         }
         return 1;
      }
      
      protected function toRadix(param1:uint = 10) : String
      {
         if(sigNum() == 0 || param1 < 2 || param1 > 32)
         {
            return "0";
         }
         var _loc2_:int = chunkSize(param1);
         var _loc3_:Number = Math.pow(param1,_loc2_);
         var _loc5_:BigInteger = nbv(_loc3_);
         var _loc6_:BigInteger = nbi();
         var _loc7_:BigInteger = nbi();
         var _loc4_:String = "";
         bi_internal::divRemTo(_loc5_,_loc6_,_loc7_);
         while(_loc6_.sigNum() > 0)
         {
            _loc4_ = (_loc3_ + _loc7_.intValue()).toString(param1).substr(1) + _loc4_;
            _loc6_.bi_internal::divRemTo(_loc5_,_loc6_,_loc7_);
         }
         return _loc7_.intValue().toString(param1) + _loc4_;
      }
      
      protected function fromRadix(param1:String, param2:int = 10) : void
      {
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         bi_internal::fromInt(0);
         var _loc3_:int = chunkSize(param2);
         var _loc4_:Number = Math.pow(param2,_loc3_);
         var _loc9_:Boolean = false;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            _loc6_ = bi_internal::intAt(param1,_loc7_);
            if(_loc6_ < 0)
            {
               if(param1.charAt(_loc7_) == "-" && sigNum() == 0)
               {
                  _loc9_ = true;
               }
            }
            else
            {
               _loc5_ = param2 * _loc5_ + _loc6_;
               _loc8_++;
               if(_loc8_ >= _loc3_)
               {
                  bi_internal::dMultiply(_loc4_);
                  bi_internal::dAddOffset(_loc5_,0);
                  _loc8_ = 0;
                  _loc5_ = 0;
               }
            }
            _loc7_++;
         }
         if(_loc8_ > 0)
         {
            bi_internal::dMultiply(Math.pow(param2,_loc8_));
            bi_internal::dAddOffset(_loc5_,0);
         }
         if(_loc9_)
         {
            BigInteger.ZERO.bi_internal::subTo(this,this);
         }
      }
      
      public function toByteArray() : ByteArray
      {
         var _loc3_:* = 0;
         var _loc4_:int = t;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_[0] = bi_internal::s;
         var _loc1_:int = 30 - _loc4_ * 30 % 8;
         var _loc5_:int = 0;
         if(_loc4_-- > 0)
         {
            if(_loc1_ < 30 && (_loc3_ = bi_internal::a[_loc4_] >> _loc1_) != (bi_internal::s & 0x3FFFFFFF) >> _loc1_)
            {
               _loc2_[_loc5_++] = _loc3_ | bi_internal::s << 30 - _loc1_;
            }
            while(_loc4_ >= 0)
            {
               if(_loc1_ < 8)
               {
                  _loc3_ = (bi_internal::a[_loc4_] & (1 << _loc1_) - 1) << 8 - _loc1_;
                  _loc4_--;
                  _loc3_ |= bi_internal::a[_loc4_] >> (_loc1_ += 30 - 8);
               }
               else
               {
                  _loc3_ = bi_internal::a[_loc4_] >> (_loc1_ -= 8) & 0xFF;
                  if(_loc1_ <= 0)
                  {
                     _loc1_ += 30;
                     _loc4_--;
                  }
               }
               if((_loc3_ & 0x80) != 0)
               {
                  _loc3_ |= -256;
               }
               if(_loc5_ == 0 && (bi_internal::s & 0x80) != (_loc3_ & 0x80))
               {
                  _loc5_++;
               }
               if(_loc5_ > 0 || _loc3_ != bi_internal::s)
               {
                  _loc2_[_loc5_++] = _loc3_;
               }
            }
         }
         return _loc2_;
      }
      
      public function equals(param1:BigInteger) : Boolean
      {
         return compareTo(param1) == 0;
      }
      
      public function min(param1:BigInteger) : BigInteger
      {
         return compareTo(param1) < 0 ? this : param1;
      }
      
      public function max(param1:BigInteger) : BigInteger
      {
         return compareTo(param1) > 0 ? this : param1;
      }
      
      protected function bitwiseTo(param1:BigInteger, param2:Function, param3:BigInteger) : void
      {
         var _loc5_:* = 0;
         var _loc4_:* = 0;
         var _loc6_:int = Math.min(param1.t,t);
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            param3.bi_internal::a[_loc5_] = param2(this.bi_internal::a[_loc5_],param1.bi_internal::a[_loc5_]);
            _loc5_++;
         }
         if(param1.t < t)
         {
            _loc4_ = param1.bi_internal::s & 0x3FFFFFFF;
            _loc5_ = _loc6_;
            while(_loc5_ < t)
            {
               param3.bi_internal::a[_loc5_] = param2(this.bi_internal::a[_loc5_],_loc4_);
               _loc5_++;
            }
            param3.t = t;
         }
         else
         {
            _loc4_ = bi_internal::s & 0x3FFFFFFF;
            _loc5_ = _loc6_;
            while(_loc5_ < param1.t)
            {
               param3.bi_internal::a[_loc5_] = param2(_loc4_,param1.bi_internal::a[_loc5_]);
               _loc5_++;
            }
            param3.t = param1.t;
         }
         param3.bi_internal::s = param2(bi_internal::s,param1.bi_internal::s);
         param3.bi_internal::clamp();
      }
      
      private function op_and(param1:int, param2:int) : int
      {
         return param1 & param2;
      }
      
      public function and(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bitwiseTo(param1,op_and,_loc2_);
         return _loc2_;
      }
      
      private function op_or(param1:int, param2:int) : int
      {
         return param1 | param2;
      }
      
      public function or(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bitwiseTo(param1,op_or,_loc2_);
         return _loc2_;
      }
      
      private function op_xor(param1:int, param2:int) : int
      {
         return param1 ^ param2;
      }
      
      public function xor(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bitwiseTo(param1,op_xor,_loc2_);
         return _loc2_;
      }
      
      private function op_andnot(param1:int, param2:int) : int
      {
         return param1 & ~param2;
      }
      
      public function andNot(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bitwiseTo(param1,op_andnot,_loc2_);
         return _loc2_;
      }
      
      public function not() : BigInteger
      {
         var _loc2_:int = 0;
         var _loc1_:BigInteger = new BigInteger();
         _loc2_ = 0;
         while(_loc2_ < t)
         {
            _loc1_[_loc2_] = 0x3FFFFFFF & ~bi_internal::a[_loc2_];
            _loc2_++;
         }
         _loc1_.t = t;
         _loc1_.bi_internal::s = ~bi_internal::s;
         return _loc1_;
      }
      
      public function shiftLeft(param1:int) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         if(param1 < 0)
         {
            bi_internal::rShiftTo(-param1,_loc2_);
         }
         else
         {
            bi_internal::lShiftTo(param1,_loc2_);
         }
         return _loc2_;
      }
      
      public function shiftRight(param1:int) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         if(param1 < 0)
         {
            bi_internal::lShiftTo(-param1,_loc2_);
         }
         else
         {
            bi_internal::rShiftTo(param1,_loc2_);
         }
         return _loc2_;
      }
      
      private function lbit(param1:int) : int
      {
         if(param1 == 0)
         {
            return -1;
         }
         var _loc2_:int = 0;
         if((param1 & 0xFFFF) == 0)
         {
            param1 >>= 16;
            _loc2_ += 16;
         }
         if((param1 & 0xFF) == 0)
         {
            param1 >>= 8;
            _loc2_ += 8;
         }
         if((param1 & 0x0F) == 0)
         {
            param1 >>= 4;
            _loc2_ += 4;
         }
         if((param1 & 3) == 0)
         {
            param1 >>= 2;
            _loc2_ += 2;
         }
         if((param1 & 1) == 0)
         {
            _loc2_++;
         }
         return _loc2_;
      }
      
      public function getLowestSetBit() : int
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < t)
         {
            if(bi_internal::a[_loc1_] != 0)
            {
               return _loc1_ * 30 + lbit(bi_internal::a[_loc1_]);
            }
            _loc1_++;
         }
         if(bi_internal::s < 0)
         {
            return t * 30;
         }
         return -1;
      }
      
      private function cbit(param1:int) : int
      {
         var _loc2_:uint = 0;
         while(param1 != 0)
         {
            param1 &= param1 - 1;
            _loc2_++;
         }
         return _loc2_;
      }
      
      public function bitCount() : int
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:* = bi_internal::s & 0x3FFFFFFF;
         _loc3_ = 0;
         while(_loc3_ < t)
         {
            _loc1_ += cbit(bi_internal::a[_loc3_] ^ _loc2_);
            _loc3_++;
         }
         return _loc1_;
      }
      
      public function testBit(param1:int) : Boolean
      {
         var _loc2_:int = Math.floor(param1 / 30);
         if(_loc2_ >= t)
         {
            return bi_internal::s != 0;
         }
         return (bi_internal::a[_loc2_] & 1 << param1 % 30) != 0;
      }
      
      protected function changeBit(param1:int, param2:Function) : BigInteger
      {
         var _loc3_:BigInteger = BigInteger.ONE.shiftLeft(param1);
         bitwiseTo(_loc3_,param2,_loc3_);
         return _loc3_;
      }
      
      public function setBit(param1:int) : BigInteger
      {
         return changeBit(param1,op_or);
      }
      
      public function clearBit(param1:int) : BigInteger
      {
         return changeBit(param1,op_andnot);
      }
      
      public function flipBit(param1:int) : BigInteger
      {
         return changeBit(param1,op_xor);
      }
      
      protected function addTo(param1:BigInteger, param2:BigInteger) : void
      {
         var _loc4_:int = 0;
         var _loc3_:* = 0;
         var _loc5_:int = Math.min(param1.t,t);
         while(_loc4_ < _loc5_)
         {
            _loc3_ += this.bi_internal::a[_loc4_] + param1.bi_internal::a[_loc4_];
            param2.bi_internal::a[_loc4_++] = _loc3_ & 0x3FFFFFFF;
            _loc3_ >>= 30;
         }
         if(param1.t < t)
         {
            _loc3_ += param1.bi_internal::s;
            while(_loc4_ < t)
            {
               _loc3_ += this.bi_internal::a[_loc4_];
               param2.bi_internal::a[_loc4_++] = _loc3_ & 0x3FFFFFFF;
               _loc3_ >>= 30;
            }
            _loc3_ += bi_internal::s;
         }
         else
         {
            _loc3_ += bi_internal::s;
            while(_loc4_ < param1.t)
            {
               _loc3_ += param1.bi_internal::a[_loc4_];
               param2.bi_internal::a[_loc4_++] = _loc3_ & 0x3FFFFFFF;
               _loc3_ >>= 30;
            }
            _loc3_ += param1.bi_internal::s;
         }
         param2.bi_internal::s = _loc3_ < 0 ? -1 : 0;
         if(_loc3_ > 0)
         {
            param2.bi_internal::a[_loc4_++] = _loc3_;
         }
         else if(_loc3_ < -1)
         {
            param2.bi_internal::a[_loc4_++] = 1073741824 + _loc3_;
         }
         param2.t = _loc4_;
         param2.bi_internal::clamp();
      }
      
      public function add(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         addTo(param1,_loc2_);
         return _loc2_;
      }
      
      public function subtract(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bi_internal::subTo(param1,_loc2_);
         return _loc2_;
      }
      
      public function multiply(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bi_internal::multiplyTo(param1,_loc2_);
         return _loc2_;
      }
      
      public function divide(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bi_internal::divRemTo(param1,_loc2_,null);
         return _loc2_;
      }
      
      public function remainder(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         bi_internal::divRemTo(param1,null,_loc2_);
         return _loc2_;
      }
      
      public function divideAndRemainder(param1:BigInteger) : Array
      {
         var _loc2_:BigInteger = new BigInteger();
         var _loc3_:BigInteger = new BigInteger();
         bi_internal::divRemTo(param1,_loc2_,_loc3_);
         return [_loc2_,_loc3_];
      }
      
      bi_internal function dMultiply(param1:int) : void
      {
         bi_internal::a[t] = bi_internal::am(0,param1 - 1,this,0,0,t);
         ++t;
         bi_internal::clamp();
      }
      
      bi_internal function dAddOffset(param1:int, param2:int) : void
      {
         while(t <= param2)
         {
            bi_internal::a[t++] = 0;
         }
         var _loc3_:* = param2;
         var _loc4_:* = bi_internal::a[_loc3_] + param1;
         bi_internal::a[_loc3_] = _loc4_;
         while(bi_internal::a[param2] >= 1073741824)
         {
            _loc4_ = param2;
            _loc3_ = bi_internal::a[_loc4_] - 1073741824;
            bi_internal::a[_loc4_] = _loc3_;
            param2++;
            if(param2 >= t)
            {
               bi_internal::a[t++] = 0;
            }
            ++bi_internal::a[param2];
         }
      }
      
      public function pow(param1:int) : BigInteger
      {
         return bi_internal::exp(param1,new NullReduction());
      }
      
      bi_internal function multiplyLowerTo(param1:BigInteger, param2:int, param3:BigInteger) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = Math.min(t + param1.t,param2);
         param3.bi_internal::s = 0;
         param3.t = _loc4_;
         while(_loc4_ > 0)
         {
            _loc4_--;
            param3.bi_internal::a[_loc4_] = 0;
         }
         _loc5_ = param3.t - t;
         while(_loc4_ < _loc5_)
         {
            param3.bi_internal::a[_loc4_ + t] = bi_internal::am(0,param1.bi_internal::a[_loc4_],param3,_loc4_,0,t);
            _loc4_++;
         }
         _loc5_ = Math.min(param1.t,param2);
         while(_loc4_ < _loc5_)
         {
            bi_internal::am(0,param1.bi_internal::a[_loc4_],param3,_loc4_,0,param2 - _loc4_);
            _loc4_++;
         }
         param3.bi_internal::clamp();
      }
      
      bi_internal function multiplyUpperTo(param1:BigInteger, param2:int, param3:BigInteger) : void
      {
         param2--;
         var _loc4_:* = param3.t = t + param1.t - param2;
         param3.bi_internal::s = 0;
         while(true)
         {
            _loc4_--;
            if(_loc4_ < 0)
            {
               break;
            }
            param3.bi_internal::a[_loc4_] = 0;
         }
         _loc4_ = Math.max(param2 - t,0);
         while(_loc4_ < param1.t)
         {
            param3.bi_internal::a[t + _loc4_ - param2] = bi_internal::am(param2 - _loc4_,param1.bi_internal::a[_loc4_],param3,0,0,t + _loc4_ - param2);
            _loc4_++;
         }
         param3.bi_internal::clamp();
         param3.bi_internal::drShiftTo(1,param3);
      }
      
      public function modPow(param1:BigInteger, param2:BigInteger) : BigInteger
      {
         var _loc10_:int = 0;
         var _loc16_:IReduction = null;
         var _loc11_:BigInteger = null;
         var _loc15_:* = 0;
         var _loc14_:* = null;
         var _loc8_:int = param1.bitLength();
         var _loc13_:* = nbv(1);
         if(_loc8_ <= 0)
         {
            return _loc13_;
         }
         if(_loc8_ < 18)
         {
            _loc10_ = 1;
         }
         else if(_loc8_ < 48)
         {
            _loc10_ = 3;
         }
         else if(_loc8_ < 144)
         {
            _loc10_ = 4;
         }
         else if(_loc8_ < 768)
         {
            _loc10_ = 5;
         }
         else
         {
            _loc10_ = 6;
         }
         if(_loc8_ < 8)
         {
            _loc16_ = new ClassicReduction(param2);
         }
         else if(param2.bi_internal::isEven())
         {
            _loc16_ = new BarrettReduction(param2);
         }
         else
         {
            _loc16_ = new MontgomeryReduction(param2);
         }
         var _loc7_:Array = [];
         var _loc12_:* = 3;
         var _loc5_:int = _loc10_ - 1;
         var _loc4_:int = (1 << _loc10_) - 1;
         _loc7_[1] = _loc16_.convert(this);
         if(_loc10_ > 1)
         {
            _loc11_ = new BigInteger();
            _loc16_.sqrTo(_loc7_[1],_loc11_);
            while(_loc12_ <= _loc4_)
            {
               _loc7_[_loc12_] = new BigInteger();
               _loc16_.mulTo(_loc11_,_loc7_[_loc12_ - 2],_loc7_[_loc12_]);
               _loc12_ += 2;
            }
         }
         var _loc9_:int = param1.t - 1;
         var _loc6_:Boolean = true;
         var _loc3_:* = new BigInteger();
         _loc8_ = bi_internal::nbits(param1.bi_internal::a[_loc9_]) - 1;
         while(_loc9_ >= 0)
         {
            if(_loc8_ >= _loc5_)
            {
               _loc15_ = param1.bi_internal::a[_loc9_] >> _loc8_ - _loc5_ & _loc4_;
            }
            else
            {
               _loc15_ = (param1.bi_internal::a[_loc9_] & (1 << _loc8_ + 1) - 1) << _loc5_ - _loc8_;
               if(_loc9_ > 0)
               {
                  _loc15_ |= param1.bi_internal::a[_loc9_ - 1] >> 30 + _loc8_ - _loc5_;
               }
            }
            _loc12_ = _loc10_;
            while((_loc15_ & 1) == 0)
            {
               _loc15_ >>= 1;
               _loc12_--;
            }
            _loc8_ -= _loc12_;
            if(_loc8_ < 0)
            {
               _loc8_ += 30;
               _loc9_--;
            }
            if(_loc6_)
            {
               _loc7_[_loc15_].copyTo(_loc13_);
               _loc6_ = false;
            }
            else
            {
               while(_loc12_ > 1)
               {
                  _loc16_.sqrTo(_loc13_,_loc3_);
                  _loc16_.sqrTo(_loc3_,_loc13_);
                  _loc12_ -= 2;
               }
               if(_loc12_ > 0)
               {
                  _loc16_.sqrTo(_loc13_,_loc3_);
               }
               else
               {
                  _loc14_ = _loc13_;
                  _loc13_ = _loc3_;
                  _loc3_ = _loc14_;
               }
               _loc16_.mulTo(_loc3_,_loc7_[_loc15_],_loc13_);
            }
            while(_loc9_ >= 0 && (param1.bi_internal::a[_loc9_] & 1 << _loc8_) == 0)
            {
               _loc16_.sqrTo(_loc13_,_loc3_);
               _loc14_ = _loc13_;
               _loc13_ = _loc3_;
               _loc3_ = _loc14_;
               _loc8_--;
               if(_loc8_ < 0)
               {
                  _loc8_ = 30 - 1;
                  _loc9_--;
               }
            }
         }
         return _loc16_.revert(_loc13_);
      }
      
      public function gcd(param1:BigInteger) : BigInteger
      {
         var _loc2_:* = null;
         var _loc4_:* = bi_internal::s < 0 ? negate() : clone();
         var _loc5_:* = param1.bi_internal::s < 0 ? param1.negate() : param1.clone();
         if(_loc4_.compareTo(_loc5_) < 0)
         {
            _loc2_ = _loc4_;
            _loc4_ = _loc5_;
            _loc5_ = _loc2_;
         }
         var _loc6_:int = _loc4_.getLowestSetBit();
         var _loc3_:* = _loc5_.getLowestSetBit();
         if(_loc3_ < 0)
         {
            return _loc4_;
         }
         if(_loc6_ < _loc3_)
         {
            _loc3_ = _loc6_;
         }
         if(_loc3_ > 0)
         {
            _loc4_.bi_internal::rShiftTo(_loc3_,_loc4_);
            _loc5_.bi_internal::rShiftTo(_loc3_,_loc5_);
         }
         while(_loc4_.sigNum() > 0)
         {
            _loc6_ = _loc4_.getLowestSetBit();
            if(_loc6_ > 0)
            {
               _loc4_.bi_internal::rShiftTo(_loc6_,_loc4_);
            }
            _loc6_ = _loc5_.getLowestSetBit();
            if(_loc6_ > 0)
            {
               _loc5_.bi_internal::rShiftTo(_loc6_,_loc5_);
            }
            if(_loc4_.compareTo(_loc5_) >= 0)
            {
               _loc4_.bi_internal::subTo(_loc5_,_loc4_);
               _loc4_.bi_internal::rShiftTo(1,_loc4_);
            }
            else
            {
               _loc5_.bi_internal::subTo(_loc4_,_loc5_);
               _loc5_.bi_internal::rShiftTo(1,_loc5_);
            }
         }
         if(_loc3_ > 0)
         {
            _loc5_.bi_internal::lShiftTo(_loc3_,_loc5_);
         }
         return _loc5_;
      }
      
      protected function modInt(param1:int) : int
      {
         var _loc4_:int = 0;
         if(param1 <= 0)
         {
            return 0;
         }
         var _loc3_:int = 1073741824 % param1;
         var _loc2_:int = bi_internal::s < 0 ? param1 - 1 : 0;
         if(t > 0)
         {
            if(_loc3_ == 0)
            {
               _loc2_ = bi_internal::a[0] % param1;
            }
            else
            {
               _loc4_ = t - 1;
               while(_loc4_ >= 0)
               {
                  _loc2_ = (_loc3_ * _loc2_ + bi_internal::a[_loc4_]) % param1;
                  _loc4_--;
               }
            }
         }
         return _loc2_;
      }
      
      public function modInverse(param1:BigInteger) : BigInteger
      {
         var _loc3_:Boolean = param1.bi_internal::isEven();
         if(bi_internal::isEven() && _loc3_ || param1.sigNum() == 0)
         {
            return BigInteger.ZERO;
         }
         var _loc7_:BigInteger = param1.clone();
         var _loc8_:BigInteger = clone();
         var _loc2_:BigInteger = nbv(1);
         var _loc4_:BigInteger = nbv(0);
         var _loc5_:BigInteger = nbv(0);
         var _loc6_:BigInteger = nbv(1);
         while(_loc7_.sigNum() != 0)
         {
            while(_loc7_.bi_internal::isEven())
            {
               _loc7_.bi_internal::rShiftTo(1,_loc7_);
               if(_loc3_)
               {
                  if(!_loc2_.bi_internal::isEven() || !_loc4_.bi_internal::isEven())
                  {
                     _loc2_.addTo(this,_loc2_);
                     _loc4_.bi_internal::subTo(param1,_loc4_);
                  }
                  _loc2_.bi_internal::rShiftTo(1,_loc2_);
               }
               else if(!_loc4_.bi_internal::isEven())
               {
                  _loc4_.bi_internal::subTo(param1,_loc4_);
               }
               _loc4_.bi_internal::rShiftTo(1,_loc4_);
            }
            while(_loc8_.bi_internal::isEven())
            {
               _loc8_.bi_internal::rShiftTo(1,_loc8_);
               if(_loc3_)
               {
                  if(!_loc5_.bi_internal::isEven() || !_loc6_.bi_internal::isEven())
                  {
                     _loc5_.addTo(this,_loc5_);
                     _loc6_.bi_internal::subTo(param1,_loc6_);
                  }
                  _loc5_.bi_internal::rShiftTo(1,_loc5_);
               }
               else if(!_loc6_.bi_internal::isEven())
               {
                  _loc6_.bi_internal::subTo(param1,_loc6_);
               }
               _loc6_.bi_internal::rShiftTo(1,_loc6_);
            }
            if(_loc7_.compareTo(_loc8_) >= 0)
            {
               _loc7_.bi_internal::subTo(_loc8_,_loc7_);
               if(_loc3_)
               {
                  _loc2_.bi_internal::subTo(_loc5_,_loc2_);
               }
               _loc4_.bi_internal::subTo(_loc6_,_loc4_);
            }
            else
            {
               _loc8_.bi_internal::subTo(_loc7_,_loc8_);
               if(_loc3_)
               {
                  _loc5_.bi_internal::subTo(_loc2_,_loc5_);
               }
               _loc6_.bi_internal::subTo(_loc4_,_loc6_);
            }
         }
         if(_loc8_.compareTo(BigInteger.ONE) != 0)
         {
            return BigInteger.ZERO;
         }
         if(_loc6_.compareTo(param1) >= 0)
         {
            return _loc6_.subtract(param1);
         }
         if(_loc6_.sigNum() < 0)
         {
            _loc6_.addTo(param1,_loc6_);
            if(_loc6_.sigNum() < 0)
            {
               return _loc6_.add(param1);
            }
            return _loc6_;
         }
         return _loc6_;
      }
      
      public function isProbablePrime(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:BigInteger = abs();
         if(_loc2_.t == 1 && _loc2_.bi_internal::a[0] <= lowprimes[lowprimes.length - 1])
         {
            _loc3_ = 0;
            while(_loc3_ < lowprimes.length)
            {
               if(_loc2_[0] == lowprimes[_loc3_])
               {
                  return true;
               }
               _loc3_++;
            }
            return false;
         }
         if(_loc2_.bi_internal::isEven())
         {
            return false;
         }
         _loc3_ = 1;
         while(_loc3_ < lowprimes.length)
         {
            _loc5_ = int(lowprimes[_loc3_]);
            _loc4_ = _loc3_ + 1;
            while(_loc4_ < lowprimes.length && _loc5_ < lplim)
            {
               _loc5_ *= lowprimes[_loc4_++];
            }
            _loc5_ = _loc2_.modInt(_loc5_);
            while(_loc3_ < _loc4_)
            {
               if(_loc5_ % lowprimes[_loc3_++] == 0)
               {
                  return false;
               }
            }
         }
         return _loc2_.millerRabin(param1);
      }
      
      protected function millerRabin(param1:int) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:BigInteger = null;
         var _loc7_:int = 0;
         var _loc4_:BigInteger = subtract(BigInteger.ONE);
         var _loc8_:int = _loc4_.getLowestSetBit();
         if(_loc8_ <= 0)
         {
            return false;
         }
         var _loc3_:BigInteger = _loc4_.shiftRight(_loc8_);
         param1 = param1 + 1 >> 1;
         if(param1 > lowprimes.length)
         {
            param1 = int(lowprimes.length);
         }
         var _loc2_:BigInteger = new BigInteger();
         _loc5_ = 0;
         while(_loc5_ < param1)
         {
            _loc2_.bi_internal::fromInt(lowprimes[_loc5_]);
            _loc6_ = _loc2_.modPow(_loc3_,this);
            if(_loc6_.compareTo(BigInteger.ONE) != 0 && _loc6_.compareTo(_loc4_) != 0)
            {
               _loc7_ = 1;
               while(_loc7_++ < _loc8_ && _loc6_.compareTo(_loc4_) != 0)
               {
                  _loc6_ = _loc6_.modPowInt(2,this);
                  if(_loc6_.compareTo(BigInteger.ONE) == 0)
                  {
                     return false;
                  }
               }
               if(_loc6_.compareTo(_loc4_) != 0)
               {
                  return false;
               }
            }
            _loc5_++;
         }
         return true;
      }
      
      public function primify(param1:int, param2:int) : void
      {
         if(!testBit(param1 - 1))
         {
            bitwiseTo(BigInteger.ONE.shiftLeft(param1 - 1),op_or,this);
         }
         if(bi_internal::isEven())
         {
            bi_internal::dAddOffset(1,0);
         }
         while(!isProbablePrime(param2))
         {
            bi_internal::dAddOffset(2,0);
            while(bitLength() > param1)
            {
               bi_internal::subTo(BigInteger.ONE.shiftLeft(param1 - 1),this);
            }
         }
      }
   }
}

