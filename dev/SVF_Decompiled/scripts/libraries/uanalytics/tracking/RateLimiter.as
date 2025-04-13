package libraries.uanalytics.tracking
{
   import flash.utils.getTimer;
   
   public class RateLimiter
   {
      private var _capacity:int;
      
      private var _rate:int;
      
      private var _span:Number;
      
      private var _lastTime:int;
      
      private var _tokenCount:int;
      
      public function RateLimiter(param1:int, param2:int, param3:Number = 1)
      {
         super();
         _capacity = param1;
         _rate = param2;
         _span = param3;
         _tokenCount = param1;
         _lastTime = now();
      }
      
      protected function now() : int
      {
         return getTimer();
      }
      
      public function consumeToken() : Boolean
      {
         var _loc2_:int = getTimer();
         var _loc1_:int = Math.max(0,(_loc2_ - _lastTime) * (_rate * _span / 1000));
         _tokenCount = Math.min(_tokenCount + _loc1_,_capacity);
         if(_tokenCount > 0)
         {
            _tokenCount--;
            _lastTime = _loc2_;
            return true;
         }
         return false;
      }
   }
}

