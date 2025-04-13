package libraries.uanalytics.tracking
{
   public class Configuration
   {
      public static var SDKversion:String = "as3uanalytics1";
      
      private var _endpoint:String = "http://www.google-analytics.com/collect";
      
      private var _secureEndpoint:String = "https://ssl.google-analytics.com/collect";
      
      private var _maxGETlength:uint = 2000;
      
      private var _maxPOSTlength:uint = 8192;
      
      private var _storageName:String = "_ga";
      
      public var senderType:String = "";
      
      public var enableErrorChecking:Boolean = false;
      
      public var enableThrottling:Boolean = true;
      
      public var enableSampling:Boolean = true;
      
      public var enableCacheBusting:Boolean = false;
      
      public var forceSSL:Boolean = false;
      
      public var forcePOST:Boolean = false;
      
      public var sampleRate:Number = 100;
      
      public var anonymizeIp:Boolean = false;
      
      public var overrideIpAddress:String = "";
      
      public var overrideUserAgent:String = "";
      
      public var overrideGeographicalId:String = "";
      
      public function Configuration()
      {
         super();
      }
      
      public function get endpoint() : String
      {
         return _endpoint;
      }
      
      public function get secureEndpoint() : String
      {
         return _secureEndpoint;
      }
      
      public function get maxGETlength() : uint
      {
         return _maxGETlength;
      }
      
      public function get maxPOSTlength() : uint
      {
         return _maxPOSTlength;
      }
      
      public function get storageName() : String
      {
         return _storageName;
      }
   }
}

