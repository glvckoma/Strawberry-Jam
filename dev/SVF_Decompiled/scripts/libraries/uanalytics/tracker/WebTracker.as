package libraries.uanalytics.tracker
{
   import flash.events.NetStatusEvent;
   import flash.net.SharedObject;
   import flash.system.ApplicationDomain;
   import libraries.uanalytics.tracker.senders.LoaderHitSender;
   import libraries.uanalytics.tracking.Configuration;
   import libraries.uanalytics.tracking.HitModel;
   import libraries.uanalytics.tracking.RateLimiter;
   import libraries.uanalytics.utils.generateUUID;
   
   public class WebTracker extends DefaultTracker
   {
      protected var _storage:SharedObject;
      
      public function WebTracker(param1:String = "", param2:Configuration = null)
      {
         super(param1,param2);
      }
      
      override protected function _ctor(param1:String = "") : void
      {
         var _loc2_:Class = null;
         _model = new HitModel();
         _temporary = new HitModel();
         if(_config.senderType != "")
         {
            _loc2_ = ApplicationDomain.currentDomain.getDefinition(_config.senderType) as Class;
            _sender = new _loc2_(this);
         }
         else
         {
            _sender = new LoaderHitSender(this);
         }
         _limiter = new RateLimiter(20,2,1);
         if(param1 != "")
         {
            set("trackingId",param1);
         }
         var _loc3_:String = _getClientID();
         if(_loc3_ != "")
         {
            set("clientId",_loc3_);
         }
         set("dataSource","web");
      }
      
      override protected function _getClientID() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = null;
         _storage = SharedObject.getLocal(_config.storageName);
         if(!_storage.data.clientid)
         {
            _loc2_ = generateUUID();
            _storage.data.clientid = _loc2_;
            _loc1_ = null;
            try
            {
               _loc1_ = _storage.flush(1024);
            }
            catch(e:Error)
            {
            }
            if(_loc1_ != null)
            {
               switch(_loc1_)
               {
                  case "pending":
                     _storage.addEventListener("netStatus",onFlushStatus);
                     break;
                  case "flushed":
               }
            }
         }
         else
         {
            _loc2_ = _storage.data.clientid;
         }
         return _loc2_;
      }
      
      protected function onFlushStatus(param1:NetStatusEvent) : void
      {
         _storage.removeEventListener("netStatus",onFlushStatus);
         switch(param1.info.code)
         {
            case "SharedObject.Flush.Success":
            case "SharedObject.Flush.Failed":
         }
      }
   }
}

