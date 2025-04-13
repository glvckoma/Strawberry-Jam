package libraries.uanalytics.tracking
{
   import flash.utils.Dictionary;
   
   public class Metadata
   {
      public static const FIELD_PREFIX:String = "&";
      
      private var _nameToParameterMap:Dictionary = new Dictionary();
      
      private var _patternToParameterMap:Dictionary = new Dictionary();
      
      public function Metadata()
      {
         super();
         addAlias("protocolVersion","v");
         addAlias("trackingId","tid");
         addAlias("anonymizeIp","aip");
         addAlias("dataSource","ds");
         addAlias("queueTime","qt");
         addAlias("cacheBuster","z");
         addAlias("clientId","cid");
         addAlias("userId","uid");
         addAlias("sessionControl","sc");
         addAlias("ipOverride","uip");
         addAlias("userAgentOverride","ua");
         addAlias("geographicalOverride","geoid");
         addAlias("documentReferrer","dr");
         addAlias("campaignName","cn");
         addAlias("campaignSource","cs");
         addAlias("campaignMedium","cm");
         addAlias("campaignKeyword","ck");
         addAlias("campaignContent","cc");
         addAlias("campaignId","ci");
         addAlias("googleAdwordsId","gclid");
         addAlias("googleDisplayAdsId","dclid");
         addAlias("screenResolution","sr");
         addAlias("viewportSize","vp");
         addAlias("documentEncoding","de");
         addAlias("screenColors","sd");
         addAlias("userLanguage","ul");
         addAlias("javaEnabled","je");
         addAlias("flashVersion","fl");
         addAlias("hitType","t");
         addAlias("nonInteraction","ni");
         addAlias("documentLocation","dl");
         addAlias("documentHostname","dh");
         addAlias("documentPath","dp");
         addAlias("documentTitle","dt");
         addAlias("screenName","cd");
         addAlias("linkId","linkid");
         addAlias("appName","an");
         addAlias("appId","aid");
         addAlias("appVersion","av");
         addAlias("appInstallerId","aiid");
         addAlias("eventCategory","ec");
         addAlias("eventAction","ea");
         addAlias("eventLabel","el");
         addAlias("eventValue","ev");
         addAlias("transactionId","ti");
         addAlias("transactionAffiliation","ta");
         addAlias("transactionRevenue","tr");
         addAlias("transactionShipping","ts");
         addAlias("transactionTax","tt");
         addAlias("itemName","in");
         addAlias("itemPrice","ip");
         addAlias("itemQuantity","iq");
         addAlias("itemCode","ic");
         addAlias("itemCategory","iv");
         addAlias("currencyCode","cu");
         addAlias("productAction","pa");
         addAlias("couponCode","tcc");
         addAlias("productActionList","pal");
         addAlias("checkoutStep","cos");
         addAlias("checkoutStepOption","col");
         addAlias("promotionAction","promoa");
         addAlias("socialNetwork","sn");
         addAlias("socialAction","sa");
         addAlias("socialTarget","st");
         addAlias("userTimingCategory","utc");
         addAlias("userTimingVar","utv");
         addAlias("userTimingTime","utt");
         addAlias("userTimingLabel","utl");
         addAlias("pageLoadTime","plt");
         addAlias("dnsTime","dns");
         addAlias("pageDownloadTime","pdt");
         addAlias("redirectResponseTime","rrt");
         addAlias("tcpConnectTime","tcp");
         addAlias("serverResponseTime","srt");
         addAlias("domInteractiveTime","dit");
         addAlias("contentLoadTime","clt");
         addAlias("exceptionDescription","exd");
         addAlias("exceptionFatal","exf");
         addPatternAlias("dimension([0-9]+)","cd");
         addPatternAlias("metric([0-9]+)","cm");
      }
      
      private function _getKeyFromPattern(param1:String) : String
      {
         var _loc3_:RegExp = null;
         var _loc2_:Object = null;
         var _loc4_:String = null;
         for(var _loc5_ in _patternToParameterMap)
         {
            _loc3_ = new RegExp(_loc5_);
            _loc2_ = _loc3_.exec(param1);
            if(_loc2_ && _loc2_[1])
            {
               _loc4_ = "&" + _patternToParameterMap[_loc5_] + _loc2_[1];
               addAlias(param1,_loc4_);
               return _loc4_;
            }
         }
         return param1;
      }
      
      protected function addAlias(param1:String, param2:String) : void
      {
         _nameToParameterMap[param1] = "&" + param2;
      }
      
      protected function addPatternAlias(param1:String, param2:String) : void
      {
         _patternToParameterMap[param1] = param2;
      }
      
      public function getHitModelKey(param1:String) : String
      {
         if(param1.length > 0 && param1.charAt(0) == "&")
         {
            return param1;
         }
         var _loc2_:String = _nameToParameterMap[param1];
         if(_loc2_ == null)
         {
            _loc2_ = _getKeyFromPattern(param1);
         }
         return _loc2_;
      }
   }
}

