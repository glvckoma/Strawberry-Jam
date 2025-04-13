package org.osmf.utils
{
   public class URL
   {
      private var _rawUrl:String;
      
      private var _protocol:String;
      
      private var _userInfo:String;
      
      private var _host:String;
      
      private var _port:String;
      
      private var _path:String;
      
      private var _query:String;
      
      private var _fragment:String;
      
      public function URL(param1:String)
      {
         super();
         _rawUrl = param1;
         _protocol = "";
         _userInfo = "";
         _host = "";
         _port = "";
         _path = "";
         _query = "";
         _fragment = "";
         if(_rawUrl != null && _rawUrl.length > 0)
         {
            _rawUrl = _rawUrl.replace(/^\s+|\s+$/g,"");
            parseUrl();
         }
      }
      
      public function get rawUrl() : String
      {
         return _rawUrl;
      }
      
      public function get protocol() : String
      {
         return _protocol;
      }
      
      public function set protocol(param1:String) : void
      {
         if(param1 != null)
         {
            _protocol = param1.replace(/:\/?\/?$/,"");
            _protocol = _protocol.toLowerCase();
         }
      }
      
      public function get userInfo() : String
      {
         return _userInfo;
      }
      
      public function set userInfo(param1:String) : void
      {
         if(param1 != null)
         {
            _userInfo = param1.replace(/@$/,"");
         }
      }
      
      public function get host() : String
      {
         return _host;
      }
      
      public function set host(param1:String) : void
      {
         _host = param1;
      }
      
      public function get port() : String
      {
         return _port;
      }
      
      public function set port(param1:String) : void
      {
         if(param1 != null)
         {
            _port = param1.replace(/(:)/,"");
         }
      }
      
      public function get path() : String
      {
         return _path;
      }
      
      public function set path(param1:String) : void
      {
         if(param1 != null)
         {
            _path = param1.replace(/^\//,"");
         }
      }
      
      public function get query() : String
      {
         return _query;
      }
      
      public function set query(param1:String) : void
      {
         if(param1 != null)
         {
            _query = param1.replace(/^\?/,"");
         }
      }
      
      public function get fragment() : String
      {
         return _fragment;
      }
      
      public function set fragment(param1:String) : void
      {
         if(param1 != null)
         {
            _fragment = param1.replace(/^#/,"");
         }
      }
      
      public function toString() : String
      {
         return _rawUrl;
      }
      
      public function getParamValue(param1:String) : String
      {
         if(_query == null)
         {
            return "";
         }
         var _loc3_:RegExp = new RegExp("[/?&]*" + param1 + "=([^&#]*)","i");
         var _loc2_:Array = _query.match(_loc3_);
         return _loc2_ == null ? "" : _loc2_[1];
      }
      
      public function get absolute() : Boolean
      {
         return protocol != "";
      }
      
      public function get extension() : String
      {
         var _loc1_:int = int(path.lastIndexOf("."));
         if(_loc1_ != -1)
         {
            return path.substr(_loc1_ + 1);
         }
         return "";
      }
      
      private function parseUrl() : void
      {
         var _loc3_:RegExp = null;
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc4_:RegExp = null;
         var _loc1_:Array = null;
         var _loc2_:String = null;
         if(_rawUrl == null || _rawUrl.length == 0)
         {
            return;
         }
         if(_rawUrl.search(/:\//) == -1 && _rawUrl.indexOf(":") != _rawUrl.length - 1)
         {
            path = _rawUrl;
         }
         else
         {
            _loc3_ = /^(rtmp|rtmp[tse]|rtmpte)(:\/[^\/])/i;
            _loc5_ = _rawUrl.match(_loc3_);
            _loc6_ = _rawUrl;
            if(_loc5_ != null)
            {
               _loc6_ = _rawUrl.replace(/:\//,"://localhost/");
            }
            _loc4_ = /^([a-z+\w\+\.\-]+:\/?\/?)?([^\/?#]*)?(\/[^?#]*)?(\?[^#]*)?(\#.*)?/i;
            _loc1_ = _loc6_.match(_loc4_);
            if(_loc1_ != null)
            {
               protocol = _loc1_[1];
               _loc2_ = _loc1_[2];
               path = _loc1_[3];
               query = _loc1_[4];
               fragment = _loc1_[5];
               _loc4_ = /^([!-~]+@)?([^\/?#:]*)(:[\d]*)?/i;
               _loc1_ = _loc2_.match(_loc4_);
               if(_loc1_ != null)
               {
                  this.userInfo = _loc1_[1];
                  this.host = _loc1_[2];
                  this.port = _loc1_[3];
               }
            }
         }
      }
   }
}

