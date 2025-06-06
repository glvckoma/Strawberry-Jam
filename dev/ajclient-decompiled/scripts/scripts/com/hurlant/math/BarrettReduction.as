package com.hurlant.math
{
   use namespace bi_internal;
   
   internal class BarrettReduction implements IReduction
   {
      
      private var m:BigInteger;
      
      private var r2:BigInteger;
      
      private var q3:BigInteger;
      
      private var mu:BigInteger;
      
      public function BarrettReduction(param1:BigInteger)
      {
         super();
         r2 = new BigInteger();
         q3 = new BigInteger();
         BigInteger.ONE.bi_internal::dlShiftTo(2 * param1.t,r2);
         mu = r2.divide(param1);
         this.m = param1;
      }
      
      public function revert(param1:BigInteger) : BigInteger
      {
         return param1;
      }
      
      public function mulTo(param1:BigInteger, param2:BigInteger, param3:BigInteger) : void
      {
         param1.bi_internal::multiplyTo(param2,param3);
         reduce(param3);
      }
      
      public function sqrTo(param1:BigInteger, param2:BigInteger) : void
      {
         param1.bi_internal::squareTo(param2);
         reduce(param2);
      }
      
      public function convert(param1:BigInteger) : BigInteger
      {
         var _loc2_:BigInteger = null;
         if(param1.bi_internal::s < 0 || param1.t > 2 * m.t)
         {
            return param1.mod(m);
         }
         if(param1.compareTo(m) < 0)
         {
            return param1;
         }
         _loc2_ = new BigInteger();
         param1.bi_internal::copyTo(_loc2_);
         reduce(_loc2_);
         return _loc2_;
      }
      
      public function reduce(param1:BigInteger) : void
      {
         var _loc2_:BigInteger = param1 as BigInteger;
         _loc2_.bi_internal::drShiftTo(m.t - 1,r2);
         if(_loc2_.t > m.t + 1)
         {
            _loc2_.t = m.t + 1;
            _loc2_.bi_internal::clamp();
         }
         mu.bi_internal::multiplyUpperTo(r2,m.t + 1,q3);
         m.bi_internal::multiplyLowerTo(q3,m.t + 1,r2);
         while(_loc2_.compareTo(r2) < 0)
         {
            _loc2_.bi_internal::dAddOffset(1,m.t + 1);
         }
         _loc2_.bi_internal::subTo(r2,_loc2_);
         while(_loc2_.compareTo(m) >= 0)
         {
            _loc2_.bi_internal::subTo(m,_loc2_);
         }
      }
   }
}

