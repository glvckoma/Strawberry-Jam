package buddy
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBPopupManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.MySettings;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class BuddyRequest
   {
      public static const ACCEPT_REJECT:int = 1;
      
      public static const CONFIRMATION:int = 2;
      
      private var _mediaHelper:MediaHelper;
      
      private var _requestPopup:MovieClip;
      
      private var _playerUserName:String;
      
      private var _mainAvatarView:AvatarView;
      
      private var _loadingSpiralAvatar:LoadingSpiral;
      
      private var _mainAvatar:Avatar;
      
      private var _requestCallback:Function;
      
      private var _popupType:int;
      
      public function BuddyRequest(param1:String, param2:Function, param3:int)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _playerUserName = param1;
         _requestCallback = param2;
         _popupType = param3;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2778,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.destroySpecificNonSBPopup(this);
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_mainAvatarView)
         {
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
         _mainAvatar = null;
         removeEventListeners();
         DarkenManager.unDarken(_requestPopup);
         if(_requestPopup.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(_requestPopup);
         }
         _requestPopup = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _requestPopup = MovieClip(param1.getChildAt(0));
            _requestPopup.x = 900 * 0.5;
            _requestPopup.y = 550 * 0.5;
            GuiManager.guiLayer.addChild(_requestPopup);
            DarkenManager.darken(_requestPopup);
            setupRequestPopup();
            addEventListeners();
         }
      }
      
      private function setupRequestPopup() : void
      {
         _requestPopup.gotoAndStop(_popupType);
         _loadingSpiralAvatar = new LoadingSpiral(_requestPopup.charBox);
         var _loc1_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(_playerUserName);
         if(!_loc1_)
         {
            AvatarXtCommManager.requestAvatarGet(_playerUserName,onAvatarGetReceived);
         }
         else
         {
            onAvatarGetReceived(_playerUserName,true,0,_loc1_);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:AvatarInfo = null) : void
      {
         var _loc5_:UserInfo = null;
         if(param2 && param1.toLowerCase() == _playerUserName.toLowerCase())
         {
            if(!param4)
            {
               param4 = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
               if(!param4)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(_playerUserName);
            if(param4.isMember)
            {
               _requestPopup.nonmember.visible = false;
               _requestPopup.userName_txt.visible = false;
               _requestPopup.member.setNubType("buddy",false);
               _requestPopup.member.setColorAndBadge(_loc5_.nameBarData);
               _requestPopup.member.isBlocked = false;
               _requestPopup.member.setAvName(_loc5_.getModeratedUserName(),Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc5_,false);
               _requestPopup.member.mouseEnabled = false;
               _requestPopup.member.mouseChildren = false;
            }
            else
            {
               _requestPopup.member.visible = false;
               _requestPopup.userName_txt.visible = true;
               _requestPopup.userName_txt.text = _loc5_.getModeratedUserName();
            }
            if(_popupType == 2)
            {
               if(BuddyManager.warnAboutBuddyCount())
               {
                  LocalizationManager.translateIdAndInsert(_requestPopup.txt,18509,BuddyManager.getRemainingBuddyCount());
               }
               else
               {
                  LocalizationManager.translateId(_requestPopup.txt,9491);
               }
            }
            _mainAvatar = AvatarManager.getAvatarByUserName(_playerUserName);
            if(_mainAvatar == null)
            {
               _mainAvatar = AvatarUtility.generateNew(param4.perUserAvId,null,_playerUserName,-1,0,onAvatarItemData);
            }
            drawMainAvatar(_mainAvatar);
         }
         else
         {
            destroy();
         }
      }
      
      public function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _mainAvatar != null)
         {
            drawMainAvatar(_mainAvatar);
         }
         else
         {
            destroy();
         }
      }
      
      private function drawMainAvatar(param1:Avatar) : void
      {
         if(Utility.isOcean(param1.enviroTypeFlag))
         {
            if(Utility.isLand(param1.enviroTypeFlag))
            {
               _requestPopup.charBox.gotoAndStop(3);
            }
            else
            {
               _requestPopup.charBox.gotoAndStop(2);
            }
         }
         else
         {
            _requestPopup.charBox.gotoAndStop(1);
         }
         _mainAvatarView = new AvatarView();
         _mainAvatarView.init(param1);
         if(param1.uuid != "")
         {
            _mainAvatarView.playAnim(13,false,1,positionAndAddMainAvatarView);
         }
      }
      
      private function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = null;
         if(_mainAvatarView)
         {
            _loc3_ = AvatarUtility.getAvOffsetByDefId(_mainAvatarView.avTypeId);
            _mainAvatarView.x = _loc3_.x;
            _mainAvatarView.y = _loc3_.y;
            if(_requestPopup)
            {
               _requestPopup.charBox.addChild(_mainAvatarView);
            }
         }
         if(_loadingSpiralAvatar)
         {
            _loadingSpiralAvatar.visible = false;
         }
      }
      
      private function addEventListeners() : void
      {
         if(_requestPopup.currentFrame == 1)
         {
            _requestPopup.cancelBtn.addEventListener("mouseDown",onCancelBtn,false,0,true);
         }
         _requestPopup.okBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         if(_requestPopup.currentFrame == 1)
         {
            _requestPopup.cancelBtn.removeEventListener("mouseDown",onCancelBtn);
         }
         _requestPopup.okBtn.removeEventListener("mouseDown",onOkBtn);
      }
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_requestPopup.currentFrame == 1)
         {
            _requestCallback({
               "status":true,
               "passback":_playerUserName
            });
         }
         else
         {
            destroy();
         }
      }
      
      private function onCancelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _requestCallback({
            "status":false,
            "passback":_playerUserName
         });
      }
   }
}

