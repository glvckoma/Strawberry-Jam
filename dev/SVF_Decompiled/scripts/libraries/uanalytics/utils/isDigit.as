package libraries.uanalytics.utils
{
   public function isDigit(param1:String, param2:uint = 0) : Boolean
   {
      if(param2 > 0)
      {
         param1 = param1.charAt(param2);
      }
      return "0" <= param1 && param1 <= "9";
   }
}

