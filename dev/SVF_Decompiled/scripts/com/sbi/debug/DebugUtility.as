package com.sbi.debug
{
   import flash.display.DisplayObjectContainer;
   import flash.external.ExternalInterface;
   
   public class DebugUtility
   {
      private static var _debugGUIHandler:Function;
      
      private static var _errorTrackingStrings:Vector.<String> = new Vector.<String>();
      
      public function DebugUtility()
      {
         super();
      }
      
      public static function setDebugGUIHandler(param1:Function) : void
      {
         _debugGUIHandler = param1;
      }
      
      public static function log(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:String = formatMessage(param1);
         trace(_loc3_);
         if(param2 && ExternalInterface.available)
         {
            ExternalInterface.call("console.log",_loc3_);
         }
      }
      
      public static function debugTrace(param1:String, param2:Boolean = true) : void
      {
      }
      
      public static function debugTraceObject(param1:String, param2:Object, param3:int = 0) : void
      {
      }
      
      public static function debugTraceArray(param1:String, param2:Array, param3:Boolean = false) : void
      {
      }
      
      public static function debugTraceDisplayObjectContainer(param1:String, param2:DisplayObjectContainer, param3:Boolean = false, param4:int = 0) : void
      {
      }
      
      public static function debugErrorTracking(param1:String) : void
      {
         if(_errorTrackingStrings.length >= 100)
         {
            _errorTrackingStrings = _errorTrackingStrings.slice(95);
         }
         else
         {
            _errorTrackingStrings.push(param1);
         }
      }
      
      public static function clearDebugErrorTracking() : void
      {
         _errorTrackingStrings = new Vector.<String>();
      }
      
      public static function getTrackedDebugStatements() : String
      {
         if(_errorTrackingStrings.length >= 10)
         {
            _errorTrackingStrings = _errorTrackingStrings.slice(_errorTrackingStrings.length - 5);
         }
         return _errorTrackingStrings.join("\n");
      }
      
      private static function formatMessage(param1:String) : String
      {
         return getTimestamp() + " " + param1;
      }
      
      private static function formatMessageHtml(param1:String) : String
      {
         param1 = param1.replace("\n","<br>") + "<br>";
         return "<font color=\"#3daee9\"><b>" + getTimestamp() + "</b></font> " + param1;
      }
      
      private static function getTimestamp() : String
      {
         var _loc1_:Date = new Date();
         return zeroPad(_loc1_.getHours(),2) + ":" + zeroPad(_loc1_.getMinutes(),2) + ":" + zeroPad(_loc1_.getSeconds(),2) + "." + zeroPad(_loc1_.getMilliseconds(),3);
      }
      
      private static function zeroPad(param1:int, param2:int) : String
      {
         var _loc3_:String = "" + param1;
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
   }
}

