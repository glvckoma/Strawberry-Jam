package com.sbi.analytics
{
   import com.sbi.debug.DebugUtility;
   import flash.utils.getTimer;
   
   public class URIObj
   {
      private var _type:int;
      
      private var _trackingObject:Object;
      
      private var _containsAnUndefined:Boolean;
      
      private var _pageView:String;
      
      private var _userId:int;
      
      private var _isFromLogin:Boolean;
      
      private var _throttled:Boolean;
      
      private var _index:int;
      
      private var _hasTrackedLastOne:Boolean;
      
      public function URIObj(param1:String, param2:Number, param3:Boolean, param4:int, param5:int, param6:Boolean, param7:Object = null)
      {
         var _loc12_:int = 0;
         var _loc10_:URIObj = null;
         super();
         param1 = param1.replace(/[',]/g,"");
         var _loc9_:Array = param1.split(/#/i);
         _isFromLogin = param3;
         _throttled = param6;
         _type = param4;
         _index = param5;
         if(param7 && param7.userId)
         {
            _userId = param7.userId;
         }
         else
         {
            _userId = param3 ? 0 : (gMainFrame.clientInfo.dbUserId == undefined ? -1 : gMainFrame.clientInfo.dbUserId);
         }
         if(param7 && param7.sessionId)
         {
            _loc12_ = int(param7.sessionId);
         }
         else
         {
            _loc12_ = int(gMainFrame.clientInfo.sessionId);
         }
         var _loc8_:int = -1;
         if(param7 && param7.duration)
         {
            _loc8_ = int(param7.duration);
         }
         else
         {
            _loc10_ = SBTracker.getPreviousURIObjByType(param5,param4);
            if(_loc10_)
            {
               _loc10_.setTimeAndDurationAndOrder();
            }
         }
         if(_loc8_ == -1 && param4 == 1)
         {
            _loc8_ = 0;
         }
         _trackingObject = {
            "userId":_userId,
            "time":param2,
            "order":(param7 && param7.order ? param7.order : 0),
            "duration":_loc8_,
            "sessionId":_loc12_,
            "uri":_loc9_[0],
            "uriParams":(_loc9_[1] != null ? _loc9_[1] : ""),
            "pop":(_loc9_[2] != null && _loc9_[2] == "pop" ? 1 : 0),
            "value":(_loc9_[3] != null ? _loc9_[3] : ""),
            "type":param4
         };
         var _loc11_:String = "userId: " + _trackingObject.userId + "\n" + "time: " + _trackingObject.time + "\n" + "order: " + _trackingObject.order + "\n" + "duration: " + _trackingObject.duration + "\n" + "sessionId: " + _trackingObject.sessionId + "\n" + "URI: " + _trackingObject.uri + "\n" + "uriParams: " + _trackingObject.uriParams + "\n" + "pop: " + _trackingObject.pop + "\n" + "value: " + _trackingObject.value + "\ntype: " + _trackingObject.type;
         DebugUtility.debugTrace(_loc11_);
      }
      
      public function destroy() : void
      {
         _trackingObject = null;
      }
      
      public function get isFromLogin() : Boolean
      {
         return _isFromLogin;
      }
      
      public function get trackingObject() : Object
      {
         return _trackingObject;
      }
      
      public function get throttled() : Boolean
      {
         return _throttled;
      }
      
      public function set index(param1:int) : void
      {
         _index = param1;
      }
      
      public function setTimeAndDurationAndOrder() : void
      {
         var _loc3_:URIObj = null;
         var _loc1_:Number = SBTracker.getLastTimestamp(_type);
         var _loc4_:* = _trackingObject.time - _loc1_ == 0;
         SBTracker.setLastTimestamp(_type,_trackingObject.time);
         if(_loc4_ && _trackingObject.order == 0)
         {
            _loc3_ = SBTracker.getPreviousURIObjByType(_index,_type);
            if(_loc3_)
            {
               _trackingObject.order = _loc3_.trackingObject.order + 1;
            }
         }
         var _loc2_:Number = SBTracker.getLastDuration(_type);
         var _loc5_:Number = getTimer();
         SBTracker.setLastDuration(_type,_loc5_);
         if(_trackingObject.duration == -1)
         {
            _trackingObject.duration = Math.round((_loc5_ - _loc2_) / 100);
         }
      }
      
      public function get pageView() : String
      {
         if(_trackingObject.duration != -1)
         {
            return (_isFromLogin ? _userId : gMainFrame.clientInfo.dbUserId) + "\n" + _trackingObject.time + "\n" + _trackingObject.order + "\n" + _trackingObject.duration + "\n" + _trackingObject.sessionId + "\n" + _trackingObject.uri + "\n" + _trackingObject.uriParams + "\n" + _trackingObject.pop + "\n" + _trackingObject.value + "\n" + _trackingObject.type + "\n";
         }
         return "";
      }
      
      public function get ownPageView() : String
      {
         setTimeAndDurationAndOrder();
         return pageView;
      }
      
      public function get hasTrackedLastOne() : Boolean
      {
         return _hasTrackedLastOne;
      }
      
      public function set hasTrackedLastOne(param1:Boolean) : void
      {
         _hasTrackedLastOne = param1;
      }
   }
}

