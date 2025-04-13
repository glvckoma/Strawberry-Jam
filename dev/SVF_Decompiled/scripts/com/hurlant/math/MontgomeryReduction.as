package com.hurlant.math
{
   use namespace bi_internal;
   
   internal class MontgomeryReduction implements IReduction
   {
      private var m:BigInteger;
      
      private var mp:int;
      
      private var mpl:int;
      
      private var mph:int;
      
      private var um:int;
      
      private var mt2:int;
      
      public function MontgomeryReduction(param1:BigInteger)
      {
         super();
         this.m = param1;
         mp = param1.bi_internal::invDigit();
         mpl = mp & 0x7FFF;
         mph = mp >> 15;
         um = 32767;
         mt2 = 2 * param1.t;
      }
      
      public function convert(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         param1.abs().bi_internal::dlShiftTo(m.t,_loc2_);
         _loc2_.bi_internal::divRemTo(m,null,_loc2_);
         if(param1.bi_internal::s < 0 && _loc2_.compareTo(BigInteger.ZERO) > 0)
         {
            m.bi_internal::subTo(_loc2_,_loc2_);
         }
         return _loc2_;
      }
      
      public function revert(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = new BigInteger();
         param1.bi_internal::copyTo(_loc2_);
         reduce(_loc2_);
         return _loc2_;
      }
      
      public function reduce(param1:BigInteger) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         while(param1.t <= mt2)
         {
            param1.bi_internal::a[param1.t++] = 0;
         }
         _loc2_ = 0;
         while(_loc2_ < m.t)
         {
            _loc3_ = param1.bi_internal::a[_loc2_] & 0x7FFF;
            _loc4_ = _loc3_ * mpl + ((_loc3_ * mph + (param1.bi_internal::a[_loc2_] >> 15) * mpl & um) << 15) & 0x3FFFFFFF;
            _loc3_ = _loc2_ + m.t;
            param1.bi_internal::a[_loc3_] += m.bi_internal::am(0,_loc4_,param1,_loc2_,0,m.t);
            while(param1.bi_internal::a[_loc3_] >= 1073741824)
            {
               var _loc6_:* = _loc3_;
               var _loc5_:* = param1.bi_internal::a[_loc6_] - 1073741824;
               param1.bi_internal::a[_loc6_] = _loc5_;
               _loc3_++;
               param1.bi_internal::a[_loc3_]++;
            }
            _loc2_++;
         }
         param1.bi_internal::clamp();
         param1.bi_internal::drShiftTo(m.t,param1);
         if(param1.compareTo(m) >= 0)
         {
            param1.bi_internal::subTo(m,param1);
         }
      }
      
      public function sqrTo(param1:BigInteger, param2:BigInteger) : void
      {
         param1.bi_internal::squareTo(param2);
         reduce(param2);
      }
      
      public function mulTo(param1:BigInteger, param2:BigInteger, param3:BigInteger) : void
      {
         param1.bi_internal::multiplyTo(param2,param3);
         reduce(param3);
      }
   }
}

