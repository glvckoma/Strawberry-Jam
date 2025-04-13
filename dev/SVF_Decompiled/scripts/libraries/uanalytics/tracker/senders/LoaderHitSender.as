package libraries.uanalytics.tracker.senders
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.errors.IOError;
   import flash.errors.IllegalOperationError;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.net.URLRequest;
   import libraries.uanalytics.tracking.AnalyticsTracker;
   import libraries.uanalytics.tracking.HitModel;
   import libraries.uanalytics.tracking.HitSender;
   
   public class LoaderHitSender extends HitSender
   {
      protected var _tracker:AnalyticsTracker;
      
      public function LoaderHitSender(param1:AnalyticsTracker)
      {
         super();
         _tracker = param1;
      }
      
      protected function _hookEvents(param1:Loader) : void
      {
         param1.uncaughtErrorEvents.addEventListener("uncaughtError",onUncaughtError);
         param1.contentLoaderInfo.addEventListener("httpStatus",onHTTPStatus);
         param1.contentLoaderInfo.addEventListener("ioError",onIOError);
         param1.contentLoaderInfo.addEventListener("complete",onComplete);
      }
      
      protected function _unhookEvents(param1:Loader) : void
      {
         param1.uncaughtErrorEvents.removeEventListener("uncaughtError",onUncaughtError);
         param1.contentLoaderInfo.removeEventListener("httpStatus",onHTTPStatus);
         param1.contentLoaderInfo.removeEventListener("ioError",onIOError);
         param1.contentLoaderInfo.removeEventListener("complete",onComplete);
      }
      
      protected function onUncaughtError(param1:UncaughtErrorEvent) : void
      {
         var _loc3_:Error = null;
         var _loc2_:ErrorEvent = null;
         _unhookEvents(param1.target as Loader);
         if(param1.error is Error)
         {
            _loc3_ = param1.error as Error;
         }
         else if(param1.error is ErrorEvent)
         {
            _loc2_ = param1.error as ErrorEvent;
            _loc3_ = new Error(_loc2_.text,_loc2_.errorID);
         }
         else
         {
            _loc3_ = new Error("a non-Error, non-ErrorEvent type was thrown and uncaught");
         }
         if(_tracker.config.enableErrorChecking)
         {
            throw _loc3_;
         }
      }
      
      protected function onHTTPStatus(param1:HTTPStatusEvent) : void
      {
      }
      
      protected function onIOError(param1:IOErrorEvent) : void
      {
         var _loc3_:* = null;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _unhookEvents(_loc2_.loader);
         if(_tracker.config.enableErrorChecking)
         {
            throw new IOError(param1.text,param1.errorID);
         }
      }
      
      protected function onComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _unhookEvents(_loc2_.loader);
      }
      
      override public function send(param1:HitModel) : void
      {
         var _loc5_:String = _buildHit(param1);
         var _loc7_:String = "";
         var _loc3_:Boolean = false;
         if(_tracker.config.forcePOST || _loc5_.length > _tracker.config.maxGETlength)
         {
            _loc3_ = true;
         }
         if(_loc5_.length > _tracker.config.maxPOSTlength)
         {
            throw new ArgumentError("POST data is bigger than " + _tracker.config.maxPOSTlength + " bytes.");
         }
         if(_tracker.config.forceSSL)
         {
            _loc7_ = _tracker.config.secureEndpoint;
         }
         else
         {
            _loc7_ = _tracker.config.endpoint;
         }
         var _loc2_:URLRequest = new URLRequest();
         _loc2_.url = _loc7_;
         if(_loc3_)
         {
            _loc2_.method = "POST";
         }
         else
         {
            _loc2_.method = "GET";
         }
         _loc2_.data = _loc5_;
         var _loc6_:Loader = new Loader();
         _hookEvents(_loc6_);
         var _loc4_:§--UNKNOWN--§ = null;
         try
         {
            _loc6_.load(_loc2_);
         }
         catch(e:IOError)
         {
            _unhookEvents(_loc6_);
            _loc4_ = e;
         }
         catch(e:SecurityError)
         {
            _unhookEvents(_loc6_);
            _loc4_ = e;
         }
         catch(e:IllegalOperationError)
         {
            _unhookEvents(_loc6_);
            _loc4_ = e;
         }
         catch(e:Error)
         {
            _unhookEvents(_loc6_);
            _loc4_ = e;
         }
         if(_loc4_)
         {
            throw _loc4_;
         }
      }
   }
}

