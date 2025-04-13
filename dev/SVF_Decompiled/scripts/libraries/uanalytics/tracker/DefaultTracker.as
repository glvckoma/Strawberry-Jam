package libraries.uanalytics.tracker
{
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   import libraries.uanalytics.tracker.senders.LoaderHitSender;
   import libraries.uanalytics.tracking.Configuration;
   import libraries.uanalytics.tracking.HitModel;
   import libraries.uanalytics.tracking.HitSampler;
   import libraries.uanalytics.tracking.RateLimitError;
   import libraries.uanalytics.tracking.RateLimiter;
   import libraries.uanalytics.tracking.Tracker;
   import libraries.uanalytics.utils.generateUUID;
   import libraries.uanalytics.utils.getHostname;
   
   public class DefaultTracker extends Tracker
   {
      public function DefaultTracker(param1:String = "", param2:Configuration = null)
      {
         super();
         if(!param2)
         {
            param2 = new Configuration();
         }
         _config = param2;
         _ctor(param1);
      }
      
      protected function _ctor(param1:String = "") : void
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
         _limiter = new RateLimiter(100,10);
         if(param1 != "")
         {
            set("trackingId",param1);
         }
         var _loc3_:String = _getClientID();
         if(_loc3_ != "")
         {
            set("clientId",_loc3_);
         }
      }
      
      protected function _getClientID() : String
      {
         return generateUUID();
      }
      
      protected function _getCacheBuster() : String
      {
         var _loc1_:Date = new Date();
         var _loc2_:Number = Math.random();
         return String(_loc1_.valueOf() + _loc2_);
      }
      
      override public function send(param1:String = null, param2:Dictionary = null) : Boolean
      {
         if(trackingId == "" || trackingId == null)
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("tracking id is missing.");
            }
            return false;
         }
         if(clientId == "" || clientId == null)
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("client id is missing.");
            }
            return false;
         }
         var _loc5_:HitModel = _model.clone();
         _loc5_.add(_temporary);
         _temporary.clear();
         if(param2 != null)
         {
            for(var _loc3_ in param2)
            {
               _loc5_.set(_loc3_,param2[_loc3_]);
            }
         }
         if((param1 != "" || param1 != null) && HitType.isValid(param1))
         {
            _loc5_.set("hitType",param1);
            if(_config && _config.enableSampling)
            {
               if(HitSampler.isSampled(_loc5_,String(_config.sampleRate)))
               {
                  return false;
               }
            }
            if(_config && _config.enableThrottling)
            {
               if(!_limiter.consumeToken())
               {
                  if(_config && _config.enableErrorChecking)
                  {
                     throw new RateLimitError();
                  }
                  return false;
               }
            }
            if(_config && _config.enableCacheBusting)
            {
               _loc5_.set("cacheBuster",_getCacheBuster());
            }
            if(_config && _config.anonymizeIp)
            {
               _loc5_.set("anonymizeIp","1");
            }
            if(_config && _config.overrideIpAddress != "")
            {
               _loc5_.set("ipOverride",_config.overrideIpAddress);
            }
            if(_config && _config.overrideUserAgent != "")
            {
               _loc5_.set("userAgentOverride",_config.overrideUserAgent);
            }
            if(_config && _config.overrideGeographicalId != "")
            {
               _loc5_.set("geographicalOverride",_config.overrideGeographicalId);
            }
            var _loc4_:Error = null;
            try
            {
               _sender.send(_loc5_);
            }
            catch(e:Error)
            {
               _loc4_ = e;
            }
            if(_config && _config.enableErrorChecking && _loc4_)
            {
               throw _loc4_;
            }
            if(_loc4_)
            {
               return false;
            }
            return true;
         }
         if(_config && _config.enableErrorChecking)
         {
            throw new ArgumentError("hit type \"" + param1 + "\" is not valid.");
         }
         return false;
      }
      
      override public function pageview(param1:String, param2:String = "") : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("path is empty");
            }
            return false;
         }
         var _loc4_:Dictionary = new Dictionary();
         _loc4_["documentPath"] = param1;
         if(param2 && param2.length > 0)
         {
            if(param2.length > 1500)
            {
               if(_config && _config.enableErrorChecking)
               {
                  throw new ArgumentError("Title is bigger than 1500 bytes.");
               }
               return false;
            }
            _loc4_["documentTitle"] = param2;
         }
         var _loc3_:String = get("documentHostname");
         if(_loc3_ == null)
         {
            if(!("documentHostname" in _loc4_))
            {
               _loc3_ = getHostname();
               if(_loc3_ == "")
               {
                  if(_config && _config.enableErrorChecking)
                  {
                     throw new ArgumentError("hostname is not defined.");
                  }
                  return false;
               }
               _loc4_["documentHostname"] = _loc3_;
            }
         }
         return send("pageview",_loc4_);
      }
      
      override public function screenview(param1:String, param2:Dictionary = null) : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("name is empty");
            }
            return false;
         }
         var _loc5_:Dictionary = new Dictionary();
         if(param2 != null)
         {
            for(var _loc3_ in param2)
            {
               _loc5_[_loc3_] = param2[_loc3_];
            }
         }
         var _loc4_:String = get("appName");
         if(_loc4_ == null)
         {
            if(!("appName" in _loc5_))
            {
               if(_config && _config.enableErrorChecking)
               {
                  throw new ArgumentError("Application name is not defined.");
               }
               return false;
            }
         }
         _loc5_["screenName"] = param1;
         return send("screenview",_loc5_);
      }
      
      override public function event(param1:String, param2:String, param3:String = "", param4:int = -1) : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("category is empty");
            }
            return false;
         }
         if(param2 == null || param2 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("action is empty");
            }
            return false;
         }
         var _loc5_:Dictionary = new Dictionary();
         _loc5_["eventCategory"] = param1;
         _loc5_["eventAction"] = param2;
         if(param3 != "")
         {
            _loc5_["eventLabel"] = param3;
         }
         if(param4 > -1)
         {
            _loc5_["eventValue"] = param4;
         }
         return send("event",_loc5_);
      }
      
      override public function transaction(param1:String, param2:String = "", param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:String = "") : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("id is empty");
            }
            return false;
         }
         var _loc7_:Dictionary = new Dictionary();
         _loc7_["transactionId"] = param1;
         if(param2 != "")
         {
            _loc7_["transactionAffiliation"] = param2;
         }
         _loc7_["transactionRevenue"] = param3;
         _loc7_["transactionShipping"] = param4;
         _loc7_["transactionTax"] = param5;
         if(param6 != "")
         {
            _loc7_["currencyCode"] = param6;
         }
         return send("transaction",_loc7_);
      }
      
      override public function item(param1:String, param2:String, param3:Number = 0, param4:int = 0, param5:String = "", param6:String = "", param7:String = "") : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("transaction id is empty");
            }
            return false;
         }
         if(param2 == null || param2 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("name is empty");
            }
            return false;
         }
         var _loc8_:Dictionary = new Dictionary();
         _loc8_["transactionId"] = param1;
         _loc8_["itemName"] = param2;
         _loc8_["itemPrice"] = param3;
         _loc8_["itemQuantity"] = param4;
         if(param5 != "")
         {
            _loc8_["itemCode"] = param5;
         }
         if(param6 != "")
         {
            _loc8_["itemCategory"] = param6;
         }
         if(param7 != "")
         {
            _loc8_["currencyCode"] = param7;
         }
         return send("item",_loc8_);
      }
      
      override public function social(param1:String, param2:String, param3:String) : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("network is empty");
            }
            return false;
         }
         if(param2 == null || param2 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("action is empty");
            }
            return false;
         }
         if(param3 == null || param3 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("target is empty");
            }
            return false;
         }
         var _loc4_:Dictionary = new Dictionary();
         _loc4_["socialNetwork"] = param1;
         _loc4_["socialAction"] = param2;
         _loc4_["socialTarget"] = param3;
         return send("social",_loc4_);
      }
      
      override public function exception(param1:String = "", param2:Boolean = true) : Boolean
      {
         var _loc3_:Dictionary = new Dictionary();
         if(param1 != "")
         {
            _loc3_["exceptionDescription"] = param1;
         }
         if(param2)
         {
            _loc3_["exceptionFatal"] = "1";
         }
         else
         {
            _loc3_["exceptionFatal"] = "0";
         }
         return send("exception",_loc3_);
      }
      
      override public function timing(param1:String, param2:String, param3:int, param4:String = "", param5:Dictionary = null) : Boolean
      {
         if(param1 == null || param1 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("category is empty");
            }
            return false;
         }
         if(param2 == null || param2 == "")
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("name is empty");
            }
            return false;
         }
         if(param3 < 0)
         {
            if(_config && _config.enableErrorChecking)
            {
               throw new ArgumentError("value is empty");
            }
            return false;
         }
         var _loc7_:Dictionary = new Dictionary();
         _loc7_["userTimingCategory"] = param1;
         _loc7_["userTimingVar"] = param2;
         _loc7_["userTimingTime"] = param3;
         if(param4 != "")
         {
            _loc7_["userTimingLabel"] = param4;
         }
         if(param5 != null)
         {
            for(var _loc6_ in param5)
            {
               _loc7_[_loc6_] = param5[_loc6_];
            }
         }
         return send("timing",_loc7_);
      }
   }
}

