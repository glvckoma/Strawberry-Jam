package org.osmf.net
{
   import org.osmf.utils.URL;
   
   public class FMSURL extends URL
   {
      private static const APPNAME_START_INDEX:uint = 0;
      
      private static const INSTANCENAME_START_INDEX:uint = 2;
      
      private static const STREAMNAME_START_INDEX:uint = 4;
      
      private static const DEFAULT_INSTANCE_NAME:String = "_definst_";
      
      public static const MP4_STREAM:String = "mp4";
      
      public static const MP3_STREAM:String = "mp3";
      
      public static const ID3_STREAM:String = "id3";
      
      public static const QUERY_STRING_STREAM:String = "streamName";
      
      public static const QUERY_STRING_STREAMTYPE:String = "streamType";
      
      private var _useInstance:Boolean;
      
      private var _appName:String;
      
      private var _instanceName:String;
      
      private var _streamName:String;
      
      private var _fileFormat:String;
      
      private var _origins:Vector.<FMSHost>;
      
      private var _edges:Vector.<FMSHost>;
      
      public function FMSURL(param1:String, param2:Boolean = false)
      {
         super(param1);
         _useInstance = param2;
         _appName = "";
         _instanceName = "";
         _streamName = "";
         _fileFormat = "";
         parsePath();
         parseQuery();
      }
      
      public function get useInstance() : Boolean
      {
         return _useInstance;
      }
      
      public function get appName() : String
      {
         return _appName;
      }
      
      public function get instanceName() : String
      {
         return _instanceName;
      }
      
      public function get streamName() : String
      {
         return _streamName;
      }
      
      public function get fileFormat() : String
      {
         return _fileFormat;
      }
      
      public function get edges() : Vector.<FMSHost>
      {
         return _edges;
      }
      
      public function get origins() : Vector.<FMSHost>
      {
         return _origins;
      }
      
      private function parsePath() : void
      {
         var _loc9_:RegExp = null;
         var _loc3_:* = 0;
         var _loc7_:int = 0;
         if(path == null || path.length == 0)
         {
            _streamName = getParamValue("streamName");
            _fileFormat = getParamValue("streamType");
            return;
         }
         var _loc6_:RegExp = /(\/)/;
         var _loc1_:Array = path.split(_loc6_);
         if(_loc1_ != null)
         {
            _appName = _loc1_[0];
            _instanceName = "";
            _streamName = "";
            _loc9_ = new RegExp("^.*/_definst_","i");
            if(path.search(_loc9_) > -1)
            {
               _useInstance = true;
            }
            _loc3_ = 4;
            if(_useInstance)
            {
               _instanceName = _loc1_[2];
            }
            else
            {
               _loc3_ = 2;
            }
            _loc7_ = int(_loc3_);
            while(_loc7_ < _loc1_.length)
            {
               _streamName += _loc1_[_loc7_];
               _loc7_++;
            }
            if(_streamName == null || _streamName == "")
            {
               _streamName = getParamValue("streamName");
            }
            if(_streamName.search(/^mp4:/i) > -1)
            {
               _fileFormat = "mp4";
            }
            else if(_streamName.search(/^mp3:/i) > -1)
            {
               _fileFormat = "mp3";
            }
            else if(_streamName.search(/^id3:/i) > -1)
            {
               _fileFormat = "id3";
            }
            if(_fileFormat == null || _fileFormat == "")
            {
               _fileFormat = getParamValue("streamType");
            }
         }
         var _loc8_:int = int(_streamName.indexOf("/mp4:"));
         var _loc4_:int = int(_streamName.indexOf("/mp3:"));
         var _loc2_:int = int(_streamName.indexOf("/id3:"));
         var _loc5_:* = -1;
         if(_loc8_ > 0)
         {
            _loc5_ = _loc8_;
         }
         else if(_loc4_ > 0)
         {
            _loc5_ = _loc4_;
         }
         else if(_loc2_ > 0)
         {
            _loc5_ = _loc2_;
         }
         if(useInstance && _loc5_ > 0)
         {
            _instanceName += "/";
            _instanceName += _streamName.substr(0,_loc5_);
            _streamName = streamName.substr(_loc5_ + 1);
         }
      }
      
      private function parseQuery() : void
      {
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:FMSURL = null;
         if(query == null || query.length == 0 || query.search(/:\//) == -1)
         {
            return;
         }
         var _loc7_:Array = query.split("?");
         _loc2_ = 0;
         while(_loc2_ < _loc7_.length)
         {
            _loc5_ = int(_loc7_[_loc2_].toString().search(/:\//));
            if(_loc5_ == -1)
            {
               _loc7_.splice(_loc2_,1);
            }
            _loc2_++;
         }
         var _loc11_:Boolean = false;
         var _loc4_:int = 0;
         if(_loc7_.length >= 2)
         {
            _loc11_ = true;
            _loc4_ = _loc7_.length - 1;
         }
         var _loc13_:String = "";
         var _loc3_:String = "";
         var _loc1_:int = 0;
         var _loc14_:int = 0;
         var _loc10_:int = 0;
         var _loc12_:* = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc7_.length)
         {
            _loc9_ = int(_loc7_[_loc6_].toString().search(/:\//));
            _loc10_ = _loc9_ + 2;
            if(_loc7_[_loc6_].charAt(_loc10_) == "/")
            {
               _loc10_++;
            }
            _loc1_ = int(_loc7_[_loc6_].indexOf(":",_loc10_));
            _loc14_ = int(_loc7_[_loc6_].indexOf("/",_loc10_));
            if(_loc14_ < 0 && _loc1_ < 0)
            {
               _loc13_ = _loc7_[_loc6_].slice(_loc10_);
            }
            else if(_loc1_ >= 0 && _loc1_ < _loc14_)
            {
               _loc12_ = _loc1_;
               _loc13_ = _loc7_[_loc6_].slice(_loc10_,_loc12_);
               _loc10_ = _loc12_ + 1;
               _loc12_ = _loc14_;
               _loc3_ = _loc7_[_loc6_].slice(_loc10_,_loc12_);
            }
            else if(_loc7_[_loc6_].indexOf("://") != -1)
            {
               _loc12_ = _loc14_;
               _loc13_ = _loc7_[_loc6_].slice(_loc10_,_loc12_);
            }
            else
            {
               _loc12_ = int(_loc7_[_loc6_].indexOf("/"));
               _loc13_ = "localhost";
            }
            if(_loc6_ == _loc4_)
            {
               if(_origins == null)
               {
                  _origins = new Vector.<FMSHost>();
               }
               _origins.push(new FMSHost(_loc13_,_loc3_));
               _loc8_ = new FMSURL(_loc7_[_loc6_],_useInstance);
               if(_appName == "")
               {
                  _appName = _loc8_.appName;
               }
               if(_useInstance && _instanceName == "")
               {
                  _instanceName = _loc8_.instanceName;
               }
               if(_streamName == "")
               {
                  _streamName = _loc8_.streamName;
               }
            }
            else if(_loc7_[_loc6_] != query && _loc11_)
            {
               if(_edges == null)
               {
                  _edges = new Vector.<FMSHost>();
               }
               _edges.push(new FMSHost(_loc13_,_loc3_));
            }
            _loc6_++;
         }
      }
   }
}

