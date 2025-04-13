package org.osmf.traits
{
   public class DRMTrait extends MediaTraitBase
   {
      private var _drmState:String = "uninitialized";
      
      private var _period:Number = 0;
      
      private var _endDate:Date;
      
      private var _startDate:Date;
      
      public function DRMTrait()
      {
         super("drm");
      }
      
      public function authenticate(param1:String = null, param2:String = null) : void
      {
      }
      
      public function authenticateWithToken(param1:Object) : void
      {
      }
      
      public function get drmState() : String
      {
         return _drmState;
      }
      
      public function get startDate() : Date
      {
         return _startDate;
      }
      
      public function get endDate() : Date
      {
         return _endDate;
      }
      
      public function get period() : Number
      {
         return _period;
      }
      
      final protected function setPeriod(param1:Number) : void
      {
         _period = param1;
      }
      
      final protected function setStartDate(param1:Date) : void
      {
         _startDate = param1;
      }
      
      final protected function setEndDate(param1:Date) : void
      {
         _endDate = param1;
      }
      
      final protected function setDrmState(param1:String) : void
      {
         _drmState = param1;
      }
   }
}

