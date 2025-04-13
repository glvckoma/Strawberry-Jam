package org.osmf.net.drm
{
   import flash.errors.IllegalOperationError;
   import flash.events.DRMAuthenticationCompleteEvent;
   import flash.events.DRMAuthenticationErrorEvent;
   import flash.events.DRMErrorEvent;
   import flash.events.DRMStatusEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.net.drm.DRMContentData;
   import flash.net.drm.DRMManager;
   import flash.net.drm.DRMVoucher;
   import flash.system.SystemUpdater;
   import flash.utils.ByteArray;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.MediaError;
   import org.osmf.utils.OSMFStrings;
   
   internal class DRMServices extends EventDispatcher
   {
      private static const DRM_AUTHENTICATION_FAILED:int = 3301;
      
      private static const DRM_NEEDS_AUTHENTICATION:int = 3330;
      
      private static const DRM_CONTENT_NOT_YET_VALID:int = 3331;
      
      private static var updater:SystemUpdater;
      
      private var _drmState:String = "uninitialized";
      
      private var lastToken:ByteArray;
      
      private var drmContentData:DRMContentData;
      
      private var voucher:DRMVoucher;
      
      private var drmManager:DRMManager;
      
      public function DRMServices()
      {
         super();
         drmManager = DRMManager.getDRMManager();
      }
      
      public function get drmState() : String
      {
         return _drmState;
      }
      
      public function set drmMetadata(param1:Object) : void
      {
         var onComplete:*;
         var value:Object = param1;
         lastToken = null;
         if(value is DRMContentData)
         {
            drmContentData = value as DRMContentData;
            retrieveVoucher();
         }
         else
         {
            try
            {
               drmContentData = new DRMContentData(value as ByteArray);
               retrieveVoucher();
            }
            catch(argError:ArgumentError)
            {
               updateDRMState("authenticationError",new MediaError(argError.errorID,"DRMContentData invalid"));
            }
            catch(error:IllegalOperationError)
            {
               onComplete = function(param1:Event):void
               {
                  updater.removeEventListener("complete",onComplete);
                  drmMetadata = value;
               };
               update("drm");
               updater.addEventListener("complete",onComplete);
            }
         }
      }
      
      public function get drmMetadata() : Object
      {
         return drmContentData;
      }
      
      public function authenticate(param1:String = null, param2:String = null) : void
      {
         if(drmContentData == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("drmMetadataNotSet"));
         }
         drmManager.addEventListener("authenticationError",authError);
         drmManager.addEventListener("authenticationComplete",authComplete);
         if(param2 == null && param1 == null)
         {
            retrieveVoucher();
         }
         else
         {
            drmManager.authenticate(drmContentData.serverURL,drmContentData.domain,param1,param2);
         }
      }
      
      public function authenticateWithToken(param1:Object) : void
      {
         if(drmContentData == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("drmMetadataNotSet"));
         }
         drmManager.setAuthenticationToken(drmContentData.serverURL,drmContentData.domain,param1 as ByteArray);
         retrieveVoucher();
      }
      
      public function get startDate() : Date
      {
         if(voucher != null)
         {
            return !!voucher.playbackTimeWindow ? voucher.playbackTimeWindow.startDate : voucher.voucherStartDate;
         }
         return null;
      }
      
      public function get endDate() : Date
      {
         if(voucher != null)
         {
            return !!voucher.playbackTimeWindow ? voucher.playbackTimeWindow.endDate : voucher.voucherEndDate;
         }
         return null;
      }
      
      public function get period() : Number
      {
         if(voucher != null)
         {
            return !!voucher.playbackTimeWindow ? voucher.playbackTimeWindow.period : (voucher.voucherEndDate && voucher.voucherStartDate ? (voucher.voucherEndDate.time - voucher.voucherStartDate.time) / 1000 : 0);
         }
         return NaN;
      }
      
      public function inlineDRMFailed(param1:MediaError) : void
      {
         updateDRMState("authenticationError",param1);
      }
      
      public function inlineOnVoucher(param1:DRMStatusEvent) : void
      {
         drmContentData = param1.contentData;
         onVoucherLoaded(param1);
      }
      
      public function update(param1:String) : SystemUpdater
      {
         updateDRMState("drmSystemUpdating");
         if(updater == null)
         {
            updater = new SystemUpdater();
            toggleErrorListeners(updater,true);
            updater.update(param1);
         }
         else
         {
            toggleErrorListeners(updater,true);
         }
         return updater;
      }
      
      private function retrieveVoucher() : void
      {
         updateDRMState("authenticating");
         drmManager.addEventListener("drmError",onDRMError);
         drmManager.addEventListener("drmStatus",onVoucherLoaded);
         drmManager.loadVoucher(drmContentData,"allowServer");
      }
      
      private function onVoucherLoaded(param1:DRMStatusEvent) : void
      {
         var _loc2_:Date = null;
         if(param1.contentData == drmContentData)
         {
            _loc2_ = new Date();
            if(param1.voucher && ((param1.voucher.voucherEndDate == null || param1.voucher.voucherEndDate.time >= _loc2_.time) && (param1.voucher.voucherStartDate == null || param1.voucher.voucherStartDate.time <= _loc2_.time)))
            {
               this.voucher = param1.voucher;
               removeEventListeners();
               if(voucher.playbackTimeWindow == null)
               {
                  updateDRMState("authenticationComplete",null,voucher.voucherStartDate,voucher.voucherEndDate,period,lastToken);
               }
               else
               {
                  updateDRMState("authenticationComplete",null,voucher.playbackTimeWindow.startDate,voucher.playbackTimeWindow.endDate,voucher.playbackTimeWindow.period,lastToken);
               }
            }
            else
            {
               forceRefreshVoucher();
            }
         }
      }
      
      private function forceRefreshVoucher() : void
      {
         drmManager.loadVoucher(drmContentData,"forceRefresh");
      }
      
      private function onDRMError(param1:DRMErrorEvent) : void
      {
         if(param1.contentData == drmContentData)
         {
            switch(param1.errorID - 3330)
            {
               case 0:
                  updateDRMState("authenticationNeeded",null,null,null,0,null,param1.contentData.serverURL);
                  break;
               case 1:
                  forceRefreshVoucher();
                  break;
               default:
                  removeEventListeners();
                  updateDRMState("authenticationError",new MediaError(param1.errorID,param1.text));
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         drmManager.removeEventListener("drmError",onDRMError);
         drmManager.removeEventListener("drmStatus",onVoucherLoaded);
      }
      
      private function authComplete(param1:DRMAuthenticationCompleteEvent) : void
      {
         drmManager.removeEventListener("authenticationError",authError);
         drmManager.removeEventListener("authenticationComplete",authComplete);
         lastToken = param1.token;
         retrieveVoucher();
      }
      
      private function authError(param1:DRMAuthenticationErrorEvent) : void
      {
         drmManager.removeEventListener("authenticationError",authError);
         drmManager.removeEventListener("authenticationComplete",authComplete);
         updateDRMState("authenticationError",new MediaError(param1.errorID,param1.toString()));
      }
      
      private function toggleErrorListeners(param1:SystemUpdater, param2:Boolean) : void
      {
         if(param2)
         {
            param1.addEventListener("complete",onUpdateComplete);
            param1.addEventListener("cancel",onUpdateComplete);
            param1.addEventListener("ioError",onUpdateError);
            param1.addEventListener("securityError",onUpdateError);
            param1.addEventListener("status",onUpdateError);
         }
         else
         {
            param1.removeEventListener("complete",onUpdateComplete);
            param1.removeEventListener("cancel",onUpdateComplete);
            param1.removeEventListener("ioError",onUpdateError);
            param1.removeEventListener("securityError",onUpdateError);
            param1.removeEventListener("status",onUpdateError);
         }
      }
      
      private function onUpdateComplete(param1:Event) : void
      {
         toggleErrorListeners(updater,false);
      }
      
      private function onUpdateError(param1:Event) : void
      {
         toggleErrorListeners(updater,false);
         updateDRMState("authenticationError",new MediaError(19,param1.toString()));
      }
      
      private function updateDRMState(param1:String, param2:MediaError = null, param3:Date = null, param4:Date = null, param5:Number = 0, param6:Object = null, param7:String = null) : void
      {
         _drmState = param1;
         dispatchEvent(new DRMEvent("drmStateChange",param1,false,false,param3,param4,param5,param7,param6,param2));
      }
   }
}

