package com.sbi.analytics
{
   import libraries.uanalytics.tracker.WebTracker;
   import libraries.uanalytics.tracking.Configuration;
   
   public class GATracker
   {
      private static var _tracker:WebTracker;
      
      private static var _eventTracker:WebTracker;
      
      public function GATracker()
      {
         super();
      }
      
      public static function init() : void
      {
         var _loc3_:Configuration = new Configuration();
         _loc3_.enableThrottling = true;
         _loc3_.forcePOST = true;
         _loc3_.forceSSL = true;
         false;
         var _loc1_:String = (gMainFrame.clientInfo.websiteURL as String).indexOf("stage") != -1 ? "UA-55037062-1" : "UA-16265056-4";
         false;
         var _loc2_:String = (gMainFrame.clientInfo.websiteURL as String).indexOf("stage") != -1 ? "UA-55037062-1" : "UA-16265056-1";
         _tracker = new WebTracker(_loc1_,_loc3_);
         _eventTracker = new WebTracker(_loc2_,_loc3_);
      }
      
      public static function trackError(param1:String, param2:Boolean) : Boolean
      {
         return _tracker.exception(param1,param2);
      }
      
      public static function trackEvent(param1:String, param2:String, param3:String = "", param4:int = -1) : Boolean
      {
         return _eventTracker.event(param1,param2,param3,param4);
      }
   }
}

