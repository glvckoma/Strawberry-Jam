package com.sbi.loader
{
   import com.adobe.crypto.MD5;
   import com.sbi.debug.DebugUtility;
   import flash.net.URLRequest;
   
   public class LoaderCache
   {
      public static var buildVersion:String = "0";
      
      public static var deployVersion:String = "0";
      
      public static var localMode:Boolean = true;
      
      public static var cdnSalt:String;
      
      public static var mainClassNames:Array;
      
      private static var _contentURL:String = "https://dev-content.animaljam.com/content/";
      
      private var _list:Array = null;
      
      public function LoaderCache()
      {
         super();
         _list = [];
      }
      
      public static function get contentURL() : String
      {
         return _contentURL;
      }
      
      public static function set contentURL(param1:String) : void
      {
         _contentURL = param1;
      }
      
      public static function fetchCDNURL(param1:String, param2:String = "/", param3:Boolean = true) : String
      {
         var _loc7_:String = null;
         var _loc4_:* = null;
         var _loc8_:String = null;
         var _loc6_:String = "";
         var _loc5_:String = deployVersion;
         if(_loc5_ != "0" && param3)
         {
            _loc6_ = _loc5_ + "/";
         }
         var _loc9_:Array = param1.split("/");
         if(_loc5_ == "0" || !param3)
         {
            _loc4_ = param1;
         }
         else if(_loc9_.length == 1)
         {
            _loc4_ = hashIt(_loc9_[0]);
         }
         else
         {
            _loc8_ = _loc9_.pop();
            _loc4_ = _loc9_.join("/") + "/" + hashIt(_loc8_);
         }
         if(param3)
         {
            if(_loc5_ == "0")
            {
               _loc7_ = contentURL + _loc6_ + param1 + "?v=" + LoaderCache.buildVersion;
            }
            else
            {
               _loc7_ = contentURL + _loc6_ + _loc4_ + "?v=" + LoaderCache.buildVersion;
            }
         }
         else if(_loc5_ == "0")
         {
            _loc7_ = contentURL + _loc6_ + param1;
         }
         else
         {
            _loc7_ = contentURL + _loc6_ + _loc4_;
         }
         return _loc7_;
      }
      
      public static function hashIt(param1:String) : String
      {
         return hashItV2(param1);
      }
      
      private static function hashItV1(param1:String) : String
      {
         return MD5.hash(param1);
      }
      
      private static function hashItV2(param1:String) : String
      {
         var _loc3_:int = 0;
         var _loc2_:String = "";
         param1 = "W3 7r4Ck h4X0r3rs" + param1;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(_loc3_ % 2 == 0)
            {
               _loc2_ += param1.charAt(_loc3_);
            }
            else
            {
               _loc2_ = param1.charAt(_loc3_) + _loc2_;
            }
            _loc3_++;
         }
         return MD5.hash(_loc2_);
      }
      
      public static function fetchCDNURLRequest(param1:String, param2:String = "/", param3:Boolean = true) : URLRequest
      {
         var _loc5_:String = fetchCDNURL(param1,param2,param3);
         return new URLRequest(_loc5_);
      }
      
      public function openFile(param1:String, param2:Function, param3:Function = null, param4:String = "binary") : void
      {
         var _loc5_:* = undefined;
         if(!findFile(param1))
         {
            _loc5_ = createLoaderCacheEntry(param1);
            _list[param1] = _loc5_;
         }
         else
         {
            DebugUtility.debugTrace("*LoaderCache name collision: " + param1);
         }
         _list[param1].setCompleteCallback(param2);
         if(param3 != null)
         {
            _list[param1].setProgressCallback(param3);
         }
         _list[param1].load(param4);
      }
      
      public function destroy() : void
      {
         for(var _loc1_ in _list)
         {
            remove(String(_loc1_));
         }
      }
      
      private function findFile(param1:String) : Boolean
      {
         return _list[param1] == null ? false : true;
      }
      
      public function remove(param1:String) : void
      {
         _list[param1].destroy();
         _list[param1] = null;
      }
      
      private function createLoaderCacheEntry(param1:String) : *
      {
         var _loc4_:* = undefined;
         var _loc3_:int = int(param1.lastIndexOf("."));
         var _loc2_:String = param1.slice(_loc3_ + 1,param1.length).toLowerCase();
         switch(_loc2_)
         {
            case "swf":
            case "png":
            case "jpg":
            case "jpeg":
               _loc4_ = new LoaderCacheEntry_Loader(param1);
               break;
            default:
               _loc4_ = new LoaderCacheEntry_URL(param1);
         }
         _loc4_.parent = this;
         return _loc4_;
      }
   }
}

