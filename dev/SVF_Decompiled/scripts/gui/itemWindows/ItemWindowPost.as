package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarDef;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import buddy.BuddyList;
   import buddy.BuddyManager;
   import collection.AccItemCollection;
   import com.sbi.corelib.input.SBTextField;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.LoadingSpiral;
   import item.EquippedAvatars;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import playerWall.PostMessage;
   
   public class ItemWindowPost extends ItemWindowBase
   {
      private var _iconMediaHelper:MediaHelper;
      
      private var _onReportDown:Function;
      
      private var _onDeleteDown:Function;
      
      private var _onReplyDown:Function;
      
      private var _smileyText:SBTextField;
      
      private var _isMyPost:Boolean;
      
      private var _patternWindow:ItemWindowPattern;
      
      private var _hasSetInitialConditions:Boolean;
      
      public function ItemWindowPost(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _onReportDown = param9.reportMsgBtnMouseDown;
         _onDeleteDown = param9.deleteMsgBtnMouseDown;
         _onReplyDown = param9.replyMsgBtnMouseDown;
         _isMyPost = param9.isMyPost;
         tabEnabled = false;
         super(1501,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get msgId() : String
      {
         return _currItem.msgId;
      }
      
      public function get senderUserName() : String
      {
         return _currItem.senderUserName;
      }
      
      public function get senderModeratedUserName() : String
      {
         return _currItem.senderModeratedUserName;
      }
      
      public function get parentOrMyPostMessageId() : String
      {
         if((_currItem as PostMessage).parentMessageId != null)
         {
            return (_currItem as PostMessage).parentMessageId;
         }
         return msgId;
      }
      
      public function get sizeCont() : MovieClip
      {
         return MovieClip(_window.parent).sizeCont;
      }
      
      public function darken(param1:Boolean) : void
      {
         if(_window)
         {
            _window.darkCont.visible = param1;
         }
      }
      
      public function update() : void
      {
         var _loc1_:Number = Number(new Date().valueOf());
         _loc1_ += Utility.getTimeOffset();
         var _loc2_:Object = Utility.calculateTime((_loc1_ - _currItem.postTime) / 1000);
         if(_loc2_.mins < 0)
         {
            _loc2_.mins = 0;
         }
         if(_loc2_.mins == 0 && _loc2_.hours < 1 && _loc2_.days < 1)
         {
            _window.dark.timeTxt.text = Utility.calculatePrintTimeToNearest(_loc2_.mins,_loc2_.hours,true,_loc2_.days);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_window.dark.timeTxt,11360,Utility.calculatePrintTimeToNearest(_loc2_.mins,_loc2_.hours,true,_loc2_.days));
         }
      }
      
      public function updateWithInput(param1:PostMessage) : void
      {
         if(_smileyText && param1)
         {
            _smileyText.text = param1.message;
         }
      }
      
      override public function destroy() : void
      {
         removeEventListeners();
         if(_iconMediaHelper)
         {
            _iconMediaHelper.destroy();
            _iconMediaHelper = null;
         }
         _onReportDown = null;
         _onDeleteDown = null;
         if(_smileyText)
         {
            _smileyText.destroy();
            _smileyText = null;
         }
         _window = null;
         _windowLoadedCallback = null;
         _currItem = null;
         _mouseDown = null;
         _mouseOver = null;
         _mouseOut = null;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded)
         {
            if(!_spiral)
            {
               _spiral = new LoadingSpiral(_window.iconLayer);
            }
            else
            {
               _spiral.setNewParent(_window.iconLayer);
            }
            _smileyText = new SBTextField(null,_window.dark.messageTxt,_window.textItemHolder,true);
            _smileyText.text = _currItem.message;
            _smileyText.mouseEnabled = false;
            _smileyText.selectable = false;
            if(!_isMyPost)
            {
               _window.reportMessageBtn.x += _window.reportMessageBtn.width;
            }
            _isCurrItemLoaded = true;
            setupCurrAvtImage();
         }
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         super.onWindowLoadCallback();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(!_hasSetInitialConditions)
         {
            _hasSetInitialConditions = true;
            if(_currItem)
            {
               if(_currItem.senderUserName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  if(hasParent())
                  {
                     _window.gotoAndStop("playerReply");
                     _window = _window.playerReply;
                  }
                  else
                  {
                     _window.gotoAndStop("player");
                     _window = _window.player;
                  }
               }
               else if(hasParent())
               {
                  _window.gotoAndStop("buddiesReply");
                  _window = _window.buddiesReply;
               }
               else
               {
                  _window.gotoAndStop("buddies");
                  _window = _window.buddies;
               }
               darken(false);
               loadPostPattern();
               _window.reportMessageBtn.visible = false;
               _window.deleteMessageBtn.visible = false;
               _window.replyMessageBtn.visible = false;
               _window.updateColor(_currItem.colorId);
               _window.dark.messageTxt.text = "";
               _window.dark.messageTxt.selectable = false;
               LocalizationManager.updateToFit(_window.dark.nameTxt,_currItem.senderModeratedUserName);
               _window.dark.timeTxt.autoSize = "right";
               if(_window.newIcon != null)
               {
                  _window.newIcon.visible = false;
               }
               if(_currItem.isBuddy && _currItem.senderUserName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
               {
                  _window.buddyIcon.visible = true;
               }
               else
               {
                  _window.buddyIcon.visible = false;
               }
               update();
            }
            addEventListeners();
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_isMyPost)
         {
            _window.deleteMessageBtn.addEventListener("mouseDown",_onDeleteDown,false,0,true);
         }
         _window.reportMessageBtn.addEventListener("mouseDown",_onReportDown,false,0,true);
         _window.replyMessageBtn.addEventListener("mouseDown",_onReplyDown,false,0,true);
         _window.darkCont.addEventListener("mouseDown",onDarkCont,false,0,true);
         addEventListener("rollOver",onPostRollOverOut,false,0,true);
         addEventListener("rollOut",onPostRollOverOut,false,0,true);
         addEventListener("mouseDown",onPostDown,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         if(_isMyPost)
         {
            _window.deleteMessageBtn.removeEventListener("mouseDown",_onDeleteDown);
         }
         _window.reportMessageBtn.removeEventListener("mouseDown",_onReportDown);
         _window.replyMessageBtn.removeEventListener("mouseDown",_onReplyDown);
         _window.darkCont.removeEventListener("mouseDown",onDarkCont);
         removeEventListener("rollOver",onPostRollOverOut);
         removeEventListener("rollOut",onPostRollOverOut);
         removeEventListener("mouseDown",onPostDown);
      }
      
      private function hasParent() : Boolean
      {
         return (_currItem as PostMessage).parentMessageId != null && (_currItem as PostMessage).parentMessageId.length > 0;
      }
      
      private function onDarkCont(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPostDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window && _currItem.senderUserName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            BuddyList.requestBuddyListIfNeeded(onBuddyListRequested);
         }
      }
      
      private function onBuddyListRequested() : void
      {
         var _loc1_:Buddy = BuddyManager.getBuddyByUserName(_currItem.senderUserName);
         if(_loc1_)
         {
            BuddyManager.showBuddyCard({
               "userName":_loc1_.userName,
               "onlineStatus":_loc1_.onlineStatus
            });
            return;
         }
         AvatarXtCommManager.requestAvatarGet(_currItem.senderUserName,onUserLookUpReceived,true);
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         if(param2)
         {
            BuddyManager.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function onPostRollOverOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window)
         {
            if(_window.messageHighlight.currentFrameLabel != "on")
            {
               _window.messageHighlight.gotoAndStop("on");
               _window.reportMessageBtn.visible = _currItem.senderUserName != gMainFrame.userInfo.myUserName;
               _window.replyMessageBtn.visible = true;
               if(_isMyPost)
               {
                  _window.deleteMessageBtn.visible = true;
               }
            }
            else
            {
               _window.messageHighlight.gotoAndStop("off");
               _window.reportMessageBtn.visible = false;
               _window.replyMessageBtn.visible = false;
               if(_isMyPost)
               {
                  _window.deleteMessageBtn.visible = false;
               }
            }
         }
      }
      
      private function loadPostPattern() : void
      {
         _patternWindow = new ItemWindowPattern(null,3983,"",0,null,null,null,null,{
            "type":(hasParent() ? "reply" : "message"),
            "colorIndex":_currItem.colorId,
            "patternIndex":_currItem.patternId
         });
         _window.messageBodyHolder.addChild(_patternWindow);
      }
      
      private function setupCurrAvtImage() : void
      {
         var _loc5_:Avatar = new Avatar();
         _loc5_.init(-1,-1,"",_currItem.avtDefId,_currItem.avtColors,_currItem.avtCustomId,null,_currItem.senderUserName);
         var _loc3_:AccItemCollection = new AccItemCollection();
         var _loc2_:Item = new Item();
         _loc3_.setAccItem(0,_loc2_);
         _loc2_.init(1,1,0,EquippedAvatars.forced());
         _loc2_ = new Item();
         _loc3_.setAccItem(1,_loc2_);
         _loc2_.init(_currItem.avtEyeDefId > 0 ? _currItem.avtEyeDefId : 2,2,0,EquippedAvatars.forced());
         var _loc6_:AvatarDef = gMainFrame.userInfo.getAvatarDefByAvatar(_loc5_);
         if(_currItem.avtCustomId != -1 && _loc6_ && _currItem.avtPatternDefId < 1)
         {
            _currItem.avtPatternDefId = _loc6_.patternRefIds[0];
         }
         if(_currItem.avtPatternDefId > 0)
         {
            _loc2_ = new Item();
            _loc3_.setAccItem(2,_loc2_);
            _loc2_.init(_currItem.avtPatternDefId,3,0,EquippedAvatars.forced());
         }
         _loc5_.itemResponseIntegrate(_loc3_);
         var _loc1_:AvatarView = new AvatarView();
         _loc1_.init(_loc5_,null);
         _loc1_.playAnim(15,false,1,null,true);
         var _loc4_:Point = AvatarUtility.getAvatarHudPosition(_loc1_.avTypeId);
         _loc1_.x = _loc4_.x + _window.charCont.width * 0.5;
         _loc1_.y = _loc4_.y + _window.charCont.height * 0.5;
         _window.charCont.charLayer.addChild(_loc1_);
      }
   }
}

