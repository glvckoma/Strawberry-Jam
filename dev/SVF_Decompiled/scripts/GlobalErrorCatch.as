package
{
   import com.sbi.analytics.GATracker;
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   
   public class GlobalErrorCatch
   {
      public function GlobalErrorCatch()
      {
         super();
      }
      
      public static function globalErrorListener(param1:UncaughtErrorEvent) : void
      {
         var _loc4_:UncaughtErrorEvent = UncaughtErrorEvent(param1);
         var _loc5_:String = "Default";
         if(_loc4_)
         {
            _loc4_.preventDefault();
            if(_loc4_.error is Error)
            {
               _loc5_ = Error(_loc4_.error).message + _loc4_.error.toString() + "\n";
               _loc5_ = _loc4_.error.getStackTrace();
            }
            else if(_loc4_.error is ErrorEvent)
            {
               _loc5_ = ErrorEvent(_loc4_.error).text + _loc4_.error.toString();
               _loc5_ = _loc5_ + "\n This is an ErrorEvent";
            }
            else
            {
               _loc5_ = _loc4_.error.toString();
               _loc5_ = _loc5_ + ("\n This is not an Error or Error event: " + _loc4_.error);
            }
         }
         var _loc3_:String = DebugUtility.getTrackedDebugStatements();
         if(_loc3_.length > 0)
         {
            DebugUtility.debugTrace("Tracked Debug Statements:\n" + _loc3_);
         }
         DebugUtility.debugTrace(_loc5_,false);
         GATracker.trackError(_loc5_ + _loc3_,false);
      }
   }
}

