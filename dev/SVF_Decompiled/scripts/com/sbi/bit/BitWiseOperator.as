package com.sbi.bit
{
   public class BitWiseOperator
   {
      public static const AND:BitWiseOperator = new BitWiseOperator("&");
      
      public static const OR:BitWiseOperator = new BitWiseOperator("|");
      
      public static const XOR:BitWiseOperator = new BitWiseOperator("^");
      
      public static const NOT:BitWiseOperator = new BitWiseOperator("~");
      
      private var _op:String;
      
      public function BitWiseOperator(param1:String)
      {
         super();
         _op = param1;
      }
   }
}

