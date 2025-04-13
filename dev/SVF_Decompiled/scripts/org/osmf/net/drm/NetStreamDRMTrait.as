package org.osmf.net.drm
{
   import flash.events.DRMStatusEvent;
   import flash.system.SystemUpdater;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.MediaError;
   import org.osmf.traits.DRMTrait;
   
   public class NetStreamDRMTrait extends DRMTrait
   {
      private var drmServices:DRMServices = new DRMServices();
      
      public function NetStreamDRMTrait()
      {
         super();
         drmServices.addEventListener("drmStateChange",onStateChange);
      }
      
      public function set drmMetadata(param1:Object) : void
      {
         if(param1 != drmServices.drmMetadata)
         {
            drmServices.drmMetadata = param1;
         }
      }
      
      public function get drmMetadata() : Object
      {
         return drmServices.drmMetadata;
      }
      
      public function update(param1:String) : SystemUpdater
      {
         return drmServices.update(param1);
      }
      
      override public function authenticate(param1:String = null, param2:String = null) : void
      {
         drmServices.authenticate(param1,param2);
      }
      
      override public function authenticateWithToken(param1:Object) : void
      {
         drmServices.authenticateWithToken(param1);
      }
      
      public function inlineDRMFailed(param1:MediaError) : void
      {
         drmServices.inlineDRMFailed(param1);
      }
      
      public function inlineOnVoucher(param1:DRMStatusEvent) : void
      {
         drmServices.inlineOnVoucher(param1);
      }
      
      private function onStateChange(param1:DRMEvent) : void
      {
         setPeriod(param1.period);
         setStartDate(param1.startDate);
         setEndDate(param1.endDate);
         setDrmState(param1.drmState);
         dispatchEvent(new DRMEvent("drmStateChange",drmState,false,false,startDate,endDate,period,param1.serverURL,param1.token,param1.mediaError));
      }
   }
}

