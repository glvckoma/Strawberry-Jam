package libraries.uanalytics.tracking
{
   public class HitSender implements AnalyticsSender
   {
      public function HitSender()
      {
         super();
      }
      
      protected function _addParameter(param1:String, param2:String) : String
      {
         var _loc3_:String = "";
         _loc3_ += "&";
         _loc3_ += _appendEncoded(param1.substring(1));
         _loc3_ += "=";
         return _loc3_ + _appendEncoded(param2);
      }
      
      protected function _appendEncoded(param1:String) : String
      {
         return encodeURIComponent(param1);
      }
      
      protected function _buildHit(param1:HitModel) : String
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc5_:* = 0;
         var _loc2_:String = "";
         _loc2_ += "v=1";
         if(Configuration.SDKversion != "")
         {
            _loc2_ += _addParameter("&_v",Configuration.SDKversion);
         }
         var _loc3_:Vector.<String> = param1.getFieldNames();
         _loc3_.sort(1);
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc5_];
            if(_loc4_.length > 0 && _loc4_.charAt(0) == "&")
            {
               _loc6_ = param1.get(_loc4_);
               if(_loc6_ != null)
               {
                  _loc2_ += _addParameter(_loc4_,_loc6_);
               }
            }
            _loc5_++;
         }
         return _loc2_;
      }
      
      public function send(param1:HitModel) : void
      {
      }
   }
}

