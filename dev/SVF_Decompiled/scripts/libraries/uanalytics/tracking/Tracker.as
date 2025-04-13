package libraries.uanalytics.tracking
{
   import flash.utils.Dictionary;
   
   public class Tracker implements AnalyticsTracker
   {
      public static const PROTOCOL_VERSION:String = "protocolVersion";
      
      public static const TRACKING_ID:String = "trackingId";
      
      public static const ANON_IP:String = "anonymizeIp";
      
      public static const DATA_SOURCE:String = "dataSource";
      
      public static const QUEUE_TIME:String = "queueTime";
      
      public static const CACHE_BUSTER:String = "cacheBuster";
      
      public static const CLIENT_ID:String = "clientId";
      
      public static const USER_ID:String = "userId";
      
      public static const SESSION_CONTROL:String = "sessionControl";
      
      public static const IP_OVERRIDE:String = "ipOverride";
      
      public static const USER_AGENT_OVERRIDE:String = "userAgentOverride";
      
      public static const GEOGRAPHICAL_OVERRIDE:String = "geographicalOverride";
      
      public static const DOCUMENT_REFERRER:String = "documentReferrer";
      
      public static const CAMPAIGN_NAME:String = "campaignName";
      
      public static const CAMPAIGN_SOURCE:String = "campaignSource";
      
      public static const CAMPAIGN_MEDIUM:String = "campaignMedium";
      
      public static const CAMPAIGN_KEYWORD:String = "campaignKeyword";
      
      public static const CAMPAIGN_CONTENT:String = "campaignContent";
      
      public static const CAMPAIGN_ID:String = "campaignId";
      
      public static const GOOGLE_ADWORDS_ID:String = "googleAdwordsId";
      
      public static const GOOGLE_DISPLAY_ADS_ID:String = "googleDisplayAdsId";
      
      public static const SCREEN_RESOLUTION:String = "screenResolution";
      
      public static const VIEWPORT_SIZE:String = "viewportSize";
      
      public static const DOCUMENT_ENCODING:String = "documentEncoding";
      
      public static const SCREEN_COLORS:String = "screenColors";
      
      public static const USER_LANGUAGE:String = "userLanguage";
      
      public static const JAVA_ENABLED:String = "javaEnabled";
      
      public static const FLASH_VERSION:String = "flashVersion";
      
      public static const HIT_TYPE:String = "hitType";
      
      public static const NON_INTERACTION:String = "nonInteraction";
      
      public static const DOCUMENT_LOCATION:String = "documentLocation";
      
      public static const DOCUMENT_HOSTNAME:String = "documentHostname";
      
      public static const DOCUMENT_PATH:String = "documentPath";
      
      public static const DOCUMENT_TITLE:String = "documentTitle";
      
      public static const SCREEN_NAME:String = "screenName";
      
      public static const LINK_ID:String = "linkId";
      
      public static const APP_NAME:String = "appName";
      
      public static const APP_ID:String = "appId";
      
      public static const APP_VERSION:String = "appVersion";
      
      public static const APP_INSTALLER_ID:String = "appInstallerId";
      
      public static const EVENT_CATEGORY:String = "eventCategory";
      
      public static const EVENT_ACTION:String = "eventAction";
      
      public static const EVENT_LABEL:String = "eventLabel";
      
      public static const EVENT_VALUE:String = "eventValue";
      
      public static const TRANSACTION_ID:String = "transactionId";
      
      public static const TRANSACTION_AFFILIATION:String = "transactionAffiliation";
      
      public static const TRANSACTION_REVENUE:String = "transactionRevenue";
      
      public static const TRANSACTION_SHIPPING:String = "transactionShipping";
      
      public static const TRANSACTION_TAX:String = "transactionTax";
      
      public static const ITEM_NAME:String = "itemName";
      
      public static const ITEM_PRICE:String = "itemPrice";
      
      public static const ITEM_QUANTITY:String = "itemQuantity";
      
      public static const ITEM_CODE:String = "itemCode";
      
      public static const ITEM_CATEGORY:String = "itemCategory";
      
      public static const CURRENCY_CODE:String = "currencyCode";
      
      public static const PRODUCT_ACTION:String = "productAction";
      
      public static const COUPON_CODE:String = "couponCode";
      
      public static const PRODUCT_ACTION_LIST:String = "productActionList";
      
      public static const CHECKOUT_STEP:String = "checkoutStep";
      
      public static const CHECKOUT_STEP_OPTION:String = "checkoutStepOption";
      
      public static const PROMOTION_ACTION:String = "promotionAction";
      
      public static const SOCIAL_NETWORK:String = "socialNetwork";
      
      public static const SOCIAL_ACTION:String = "socialAction";
      
      public static const SOCIAL_TARGET:String = "socialTarget";
      
      public static const USER_TIMING_CATEGORY:String = "userTimingCategory";
      
      public static const USER_TIMING_VAR:String = "userTimingVar";
      
      public static const USER_TIMING_TIME:String = "userTimingTime";
      
      public static const USER_TIMING_LABEL:String = "userTimingLabel";
      
      public static const PAGE_LOAD_TIME:String = "pageLoadTime";
      
      public static const DNS_TIME:String = "dnsTime";
      
      public static const PAGE_DOWNLOAD_TIME:String = "pageDownloadTime";
      
      public static const REDIRECT_RESPONSE_TIME:String = "redirectResponseTime";
      
      public static const TCP_CONNECT_TIME:String = "tcpConnectTime";
      
      public static const SERVER_RESPONSE_TIME:String = "serverResponseTime";
      
      public static const DOM_INTERACTIVE_TIME:String = "domInteractiveTime";
      
      public static const CONTENT_LOAD_TIME:String = "contentLoadTime";
      
      public static const EXCEPT_DESCRIPTION:String = "exceptionDescription";
      
      public static const EXCEPT_FATAL:String = "exceptionFatal";
      
      protected var _model:HitModel;
      
      protected var _temporary:HitModel;
      
      protected var _sender:HitSender;
      
      protected var _limiter:RateLimiter;
      
      protected var _config:Configuration;
      
      public function Tracker()
      {
         super();
      }
      
      public static function CUSTOM_DIMENSION(param1:uint = 0) : String
      {
         if(param1 < 1)
         {
            param1 = 1;
         }
         if(param1 > 200)
         {
            param1 = 200;
         }
         return "dimension" + param1;
      }
      
      public static function CUSTOM_METRIC(param1:uint = 0) : String
      {
         if(param1 < 1)
         {
            param1 = 1;
         }
         if(param1 > 200)
         {
            param1 = 200;
         }
         return "metric" + param1;
      }
      
      public function get trackingId() : String
      {
         return get("trackingId");
      }
      
      public function get clientId() : String
      {
         return get("clientId");
      }
      
      public function get config() : Configuration
      {
         return _config;
      }
      
      public function set(param1:String, param2:String) : void
      {
         if(_model)
         {
            _model.set(param1,param2);
         }
      }
      
      public function setOneTime(param1:String, param2:String) : void
      {
         if(_temporary)
         {
            _temporary.set(param1,param2);
         }
      }
      
      public function get(param1:String) : String
      {
         if(_model)
         {
            return _model.get(param1);
         }
         return null;
      }
      
      public function add(param1:Dictionary) : void
      {
         if(_model)
         {
            for(var _loc2_ in param1)
            {
               set(_loc2_,param1[_loc2_]);
            }
         }
      }
      
      public function addOneTime(param1:Dictionary) : void
      {
         if(_temporary)
         {
            for(var _loc2_ in param1)
            {
               setOneTime(_loc2_,param1[_loc2_]);
            }
         }
      }
      
      public function send(param1:String = null, param2:Dictionary = null) : Boolean
      {
         return false;
      }
      
      public function pageview(param1:String, param2:String = "") : Boolean
      {
         return false;
      }
      
      public function screenview(param1:String, param2:Dictionary = null) : Boolean
      {
         return false;
      }
      
      public function event(param1:String, param2:String, param3:String = "", param4:int = -1) : Boolean
      {
         return false;
      }
      
      public function transaction(param1:String, param2:String = "", param3:Number = 0, param4:Number = 0, param5:Number = 0, param6:String = "") : Boolean
      {
         return false;
      }
      
      public function item(param1:String, param2:String, param3:Number = 0, param4:int = 0, param5:String = "", param6:String = "", param7:String = "") : Boolean
      {
         return false;
      }
      
      public function social(param1:String, param2:String, param3:String) : Boolean
      {
         return false;
      }
      
      public function exception(param1:String = "", param2:Boolean = true) : Boolean
      {
         return false;
      }
      
      public function timing(param1:String, param2:String, param3:int, param4:String = "", param5:Dictionary = null) : Boolean
      {
         return false;
      }
   }
}

