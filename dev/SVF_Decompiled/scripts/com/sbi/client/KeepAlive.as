package com.sbi.client
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import localization.LocalizationManager;
   
   public class KeepAlive
   {
      private static var KICK_INTERVAL:int = 420000;
      
      private static var SEND_MSG_INTERVAL:int = 180000;
      
      private static var NOTIFY_USER_INTERVAL:int = 10000;
      
      private static var NOTIFY_USER_TIME:int = 30000;
      
      public static var popupLayer:DisplayObjectContainer;
      
      private static var _keepAliveTimer:Timer;
      
      private static var _timeLeftTimer:Timer;
      
      private static var _bInputReceived:Boolean;
      
      private static var _mcsToKeepAlive:Array;
      
      private static var _lastMsgSentToServer:Number;
      
      private static var _inputTimer:Timer;
      
      private static var _kickWarningPopupShowing:Boolean;
      
      private static var _isConnected:Function;
      
      private static var _disconnectClient:Function;
      
      private static var _playIdleWarningSound:Function;
      
      public function KeepAlive()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer, param2:Function, param3:Function = null, param4:Function = null) : void
      {
         popupLayer = param1;
         _keepAliveTimer = new Timer(SEND_MSG_INTERVAL);
         _keepAliveTimer.addEventListener("timer",sendKeepAliveMsg);
         _timeLeftTimer = new Timer(NOTIFY_USER_INTERVAL);
         _timeLeftTimer.addEventListener("timer",timeLeftTimer);
         _timeLeftTimer.start();
         _lastMsgSentToServer = new Date().getTime();
         _mcsToKeepAlive = [];
         _isConnected = param2;
         _disconnectClient = param3;
         _playIdleWarningSound = param4;
      }
      
      public static function startKATimer(param1:DisplayObjectContainer) : void
      {
         param1.addEventListener("mouseDown",inputReceivedHandler,false,0,true);
         param1.addEventListener("keyDown",inputReceivedHandler,false,0,true);
         _mcsToKeepAlive.push(param1);
         _bInputReceived = true;
         sendKeepAliveMsg(null);
         _keepAliveTimer.start();
      }
      
      public static function stopKATimer(param1:DisplayObjectContainer) : void
      {
         var _loc2_:int = 0;
         gMainFrame.server.setXtObject_Str("ka",[],gMainFrame.server.isWorldZone);
         _keepAliveTimer.stop();
         _loc2_ = 0;
         while(_loc2_ < _mcsToKeepAlive.length)
         {
            if(_mcsToKeepAlive[_loc2_] == param1)
            {
               _mcsToKeepAlive[_loc2_].removeEventListener("mouseDown",inputReceivedHandler);
               _mcsToKeepAlive[_loc2_].removeEventListener("keyDown",inputReceivedHandler);
               _mcsToKeepAlive.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
      
      public static function restartTimeLeftTimer() : void
      {
         if(_timeLeftTimer)
         {
            _lastMsgSentToServer = new Date().getTime();
            _timeLeftTimer.stop();
            _timeLeftTimer.start();
         }
      }
      
      public static function sendKeepAliveReset() : void
      {
         _bInputReceived = true;
         sendKeepAliveMsg(null);
      }
      
      private static function sendKeepAliveMsg(param1:TimerEvent) : void
      {
         if(_bInputReceived)
         {
            gMainFrame.server.setXtObject_Str("ka",[],gMainFrame.server.isWorldZone);
            _lastMsgSentToServer = new Date().getTime();
            _bInputReceived = false;
         }
      }
      
      private static function timeLeftTimer(param1:TimerEvent) : void
      {
         var _loc2_:DisplayObject = null;
         var _loc3_:Number = new Date().getTime() - _lastMsgSentToServer;
         if(!_kickWarningPopupShowing && _loc3_ > KICK_INTERVAL - NOTIFY_USER_TIME)
         {
            _loc2_ = new SBOkPopup(popupLayer,LocalizationManager.translateIdOnly(14681),true,onKickWarningPopup);
            _kickWarningPopupShowing = true;
            if(_playIdleWarningSound != null)
            {
               _playIdleWarningSound();
            }
            if((gMainFrame.userInfo.isModerator || gMainFrame.clientInfo.accountType == 4) && !gMainFrame.server.isBlueboxMode())
            {
               _bInputReceived = true;
               sendKeepAliveMsg(null);
               _kickWarningPopupShowing = false;
               SBOkPopup.destroyInParentChain(_loc2_);
            }
         }
         if(_loc3_ > KICK_INTERVAL)
         {
            if(_isConnected())
            {
               if(_disconnectClient != null)
               {
                  _disconnectClient();
               }
            }
         }
      }
      
      private static function onKickWarningPopup(param1:MouseEvent) : void
      {
         _bInputReceived = true;
         sendKeepAliveMsg(null);
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         _kickWarningPopupShowing = false;
      }
      
      public static function inputReceivedHandler(param1:Event) : void
      {
         if(!_bInputReceived)
         {
            _bInputReceived = true;
         }
         if(new Date().getTime() - _lastMsgSentToServer > SEND_MSG_INTERVAL)
         {
            sendKeepAliveMsg(null);
         }
      }
   }
}

