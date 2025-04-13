package libraries.uanalytics.tracking
{
   import flash.utils.Dictionary;
   
   public interface AnalyticsTracker
   {
      function get trackingId() : String;
      
      function get clientId() : String;
      
      function get config() : Configuration;
      
      function send(param1:String = null, param2:Dictionary = null) : Boolean;
      
      function pageview(param1:String, param2:String = "") : Boolean;
      
      function screenview(param1:String, param2:Dictionary = null) : Boolean;
      
      function event(param1:String, param2:String, param3:String = "", param4:int = -1) : Boolean;
      
      function transaction(param1:String, param2:String = "", param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:String = "") : Boolean;
      
      function item(param1:String, param2:String, param3:Number = 0, param4:int = 0, param5:String = "", param6:String = "", param7:String = "") : Boolean;
      
      function social(param1:String, param2:String, param3:String) : Boolean;
      
      function exception(param1:String = "", param2:Boolean = true) : Boolean;
      
      function timing(param1:String, param2:String, param3:int, param4:String = "", param5:Dictionary = null) : Boolean;
   }
}

