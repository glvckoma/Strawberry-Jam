package game.trueFalse
{
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarViewExt_Splash;
   import avatar.NameBar;
   import avatar.UserInfo;
   import buddy.BuddyManager;
   import com.sbi.graphics.LayerBitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import game.MinigameManager;
   import gui.ChatBalloon;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class TrueFalseAvatarView extends AvatarView
   {
      private static const NAMEBAR_X_OFFSET:int = -15;
      
      private static const NAMEBAR_Y_OFFSET:int = 18;
      
      private var _chatBalloon:ChatBalloon;
      
      public var _chatLayer:Sprite;
      
      private var _splash:AvatarViewExt_Splash;
      
      private var _namebar:NameBar;
      
      private var _isMember:Boolean;
      
      private var _guiObj:Object;
      
      private var _isGuide:Boolean;
      
      public function TrueFalseAvatarView()
      {
         super();
      }
      
      override public function init(param1:Avatar, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:Boolean = false) : void
      {
         super.init(param1,param2);
         _chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset");
         _chatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,1,RoomManagerWorld.instance.layerManager.bkg.scaleX);
         _chatLayer.addChild(_chatBalloon);
         var _loc6_:LayerBitmap = _layerAnim.bitmap;
         _loc6_.x = 0;
         _loc6_.y = 0;
         _splash = new AvatarViewExt_Splash(this,_loc6_);
         BuddyManager.eventDispatcher.addEventListener("OnBuddyChanged",toggleNamebarSelNub,false,0,true);
      }
      
      public function setupNamebar(param1:Boolean = true) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
         var _loc3_:int = _loc2_.nameBarData;
         initNamebar(_loc2_.accountType);
         _guiObj = {"showUserInfoPopup":BuddyManager.showBuddyCard};
         setNamebarListenersWithUserName(userName);
         toggleNamebarSelNub(_loc3_);
         _namebar.setColorAndBadge(_loc3_);
         _namebar.mouseChildren = false;
         if(isSelf)
         {
            _namebar.mouseEnabled = false;
            _chatBalloon.mouseChildren = false;
            _chatBalloon.mouseEnabled = false;
         }
         _namebar.setAvName(gMainFrame.userInfo.getAvatarInfoByUserName(_loc2_.userName).avName);
      }
      
      public function heartbeat(param1:Number) : void
      {
         if(!_chatBalloon)
         {
            return;
         }
         _chatBalloon.heartbeat(param1 * 1000);
         if(parent)
         {
            _chatBalloon.x = x + parent.x;
            _chatBalloon.y = y - 100 + parent.y;
         }
      }
      
      public function addAvatarMessage(param1:String, param2:int) : void
      {
         var _loc3_:Boolean = false;
         if(param2 > 1)
         {
            if(param2 == 2)
            {
               param1 = LocalizationManager.translateIdOnly(int(param1.split("|")[0]));
            }
            _loc3_ = true;
         }
         _chatBalloon.setText(param1,_loc3_);
      }
      
      public function setEmote(param1:Sprite) : void
      {
         if(param1)
         {
            _chatBalloon.setEmote(param1);
         }
         else
         {
            _chatBalloon.setReadyForClear();
         }
      }
      
      override public function destroy(param1:Boolean = false) : void
      {
         super.destroy(param1);
         if(_splash)
         {
            _splash.destroy();
         }
         if(_chatBalloon && _chatBalloon.parent == _chatLayer)
         {
            _chatLayer.removeChild(_chatBalloon);
         }
         removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar.removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar["selnub"].removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _chatBalloon = null;
         if(_namebar)
         {
            _namebar.destroy();
         }
         _namebar = null;
      }
      
      private function initNamebar(param1:int) : void
      {
         _isMember = MinigameManager.isMember(param1);
         if(_isMember || Boolean(gMainFrame.userInfo.getUserInfoByUserName(userName).isGuide))
         {
            _namebar = GETDEFINITIONBYNAME("memberNameBar");
         }
         else
         {
            _namebar = GETDEFINITIONBYNAME("FreeNameBar");
         }
         _namebar.x = -15;
         _namebar.y = 18;
         addChild(_namebar);
      }
      
      private function setNamebarListenersWithUserName(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 != gMainFrame.server.userName || Boolean(gMainFrame.userInfo.isModerator))
         {
            _namebar.addEventListener("mouseDown",namebarAndAvatarDownHandler,false,0,true);
            _namebar["selnub"].addEventListener("mouseDown",namebarAndAvatarDownHandler,false,0,true);
         }
         else
         {
            _namebar.removeListeners();
         }
      }
      
      private function namebarAndAvatarDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Object = {
            "userName":userName,
            "onlineStatus":1
         };
         if(_guiObj)
         {
            _guiObj.showUserInfoPopup(_loc2_);
         }
      }
      
      public function toggleNamebarSelNub(param1:int = -1) : void
      {
         var _loc2_:* = 0;
         if(!_namebar)
         {
            return;
         }
         if(_isGuide)
         {
            _namebar.setNubType(NameBar.GUIDE);
         }
         else
         {
            if(param1 == -1)
            {
               _loc2_ = _namebar.packedNameBarData;
            }
            else
            {
               _loc2_ = param1;
            }
            if(BuddyManager.isBuddy(_avatar.userName) || isSelf || _isMember && NameBar.isVIPBadge(_loc2_))
            {
               _namebar.setNubType(NameBar.BUDDY);
            }
            else
            {
               _namebar.setNubType(NameBar.NON_BUDDY);
            }
         }
         if(!isSelf)
         {
            if(BuddyManager.isBlocked(_avatar.userName))
            {
               _namebar.isBlocked = true;
            }
            else
            {
               _namebar.isBlocked = false;
            }
         }
         else
         {
            _namebar.isBlocked = false;
         }
      }
      
      private function get isSelf() : Boolean
      {
         return userName == gMainFrame.userInfo.myUserName;
      }
   }
}

