package libraries.uanalytics.utils
{
   import flash.net.LocalConnection;
   
   public function getHostname() : String
   {
      var _loc2_:LocalConnection = null;
      var _loc1_:String = "";
      if(LocalConnection.isSupported)
      {
         _loc2_ = new LocalConnection();
         _loc1_ = _loc2_.domain;
      }
      if(_loc1_.substr(0,4) == "app#" || _loc1_ == "")
      {
         _loc1_ = "localhost";
      }
      return _loc1_;
   }
}

