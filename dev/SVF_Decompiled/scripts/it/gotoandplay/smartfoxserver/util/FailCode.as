package it.gotoandplay.smartfoxserver.util
{
   import flash.events.ErrorEvent;
   import flash.events.SecurityErrorEvent;
   
   public class FailCode
   {
      public static const TYPE_SOCKET:int = 1;
      
      public static const TYPE_BLUEBOX:int = 2;
      
      public static const PHASE_INIT:int = 256;
      
      public static const PHASE_CONNECTED:int = 512;
      
      public static const REASON_SECURITY:int = 65536;
      
      public static const REASON_IO:int = 131072;
      
      public static const REASON_PIN:int = 262144;
      
      public static const REASON_API:int = 524288;
      
      public static const REASON_POLL:int = 1048576;
      
      public static const REASON_UNSUPPORTED:int = 2097152;
      
      public function FailCode()
      {
         super();
      }
      
      public static function build(param1:int, param2:int, param3:int) : int
      {
         return param1 | param2 | param3;
      }
      
      public static function getReasonFromEvent(param1:ErrorEvent) : int
      {
         return param1 is SecurityErrorEvent ? 65536 : 131072;
      }
      
      public static function getTypeFromConnectionMode(param1:String) : int
      {
         return param1 == "http" ? 2 : 1;
      }
   }
}

