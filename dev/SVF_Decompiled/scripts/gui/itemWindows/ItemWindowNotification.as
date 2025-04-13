package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarDef;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import collection.AccItemCollection;
   import com.sbi.corelib.input.SBTextField;
   import com.sbi.graphics.LayerAnim;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.LoadingSpiral;
   import item.EquippedAvatars;
   import item.Item;
   import localization.LocalizationManager;
   import playerWall.PostMessage;
   
   public class ItemWindowNotification extends ItemWindowBase
   {
      private var _hasSetInitialConditions:Boolean;
      
      private var _smileyText:SBTextField;
      
      private var _dispAvtView:AvatarView;
      
      private var _isNew:Boolean;
      
      public function ItemWindowNotification(param1:Function, param2:Object, param3:String, param4:int, param5:Function, param6:Function, param7:Function, param8:Function, param9:Boolean = false)
      {
         super(6322,param1,param2,param3,param4,param5,onNotificationOver,onNotificationOut,param8,param9);
      }
      
      public function get senderUserName() : String
      {
         return PostMessage(_currItem).senderUserName;
      }
      
      public function get senderUUID() : String
      {
         return PostMessage(_currItem).senderUUID;
      }
      
      public function get messageId() : String
      {
         return PostMessage(_currItem).msgId;
      }
      
      public function get moderatedUsername() : String
      {
         return PostMessage(_currItem).senderModeratedUserName;
      }
      
      public function get parentOrCurrMessageId() : String
      {
         if(PostMessage(_currItem).parentMessageId != null && PostMessage(_currItem).parentMessageId.length > 0)
         {
            return PostMessage(_currItem).parentMessageId;
         }
         return PostMessage(_currItem).msgId;
      }
      
      public function get isRead() : Boolean
      {
         return PostMessage(_currItem).isRead;
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
            _window.timeTxt.text = Utility.calculatePrintTimeToNearest(_loc2_.mins,_loc2_.hours,true,_loc2_.days);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_window.timeTxt,11360,Utility.calculatePrintTimeToNearest(_loc2_.mins,_loc2_.hours,true,_loc2_.days));
         }
      }
      
      public function updateWithInput(param1:PostMessage) : void
      {
         if(_smileyText && param1)
         {
            _smileyText.text = param1.message;
         }
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            setChildrenAndInitialConditions();
            addEventListeners();
            setupCurrAvtImage();
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         super.onWindowLoadCallback();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_window)
         {
            if(!_hasSetInitialConditions)
            {
               _hasSetInitialConditions = true;
               _window.timeTxt.autoSize = "right";
               LocalizationManager.updateToFit(_window.nameTxt,_currItem.senderModeratedUserName);
               if(!_currItem.isRead)
               {
                  _window.gotoAndStop("new");
                  LocalizationManager.translateId(_window.newIcon.txt,24420);
                  _isNew = true;
               }
               if(_window.newIcon != null)
               {
                  _window.newIcon.visible = !_currItem.isRead;
               }
               if(!_spiral)
               {
                  _spiral = new LoadingSpiral(_window.iconLayer);
               }
               else
               {
                  _spiral.setNewParent(_window.iconLayer);
               }
               _smileyText = new SBTextField(null,_window.messageTxt,_window.textItemHolder,true);
               _smileyText.text = _currItem.message;
               _smileyText.mouseEnabled = false;
               _smileyText.selectable = false;
               update();
            }
         }
      }
      
      private function onNotificationOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _window.gotoAndStop("selected");
      }
      
      private function onNotificationOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _window.gotoAndStop(_isNew ? "new" : "norm");
      }
      
      private function setupCurrAvtImage() : void
      {
         var _loc3_:Avatar = new Avatar();
         _loc3_.init(-1,-1,"",_currItem.avtDefId,_currItem.avtColors,_currItem.avtCustomId,null,_currItem.senderUserName);
         var _loc2_:AccItemCollection = new AccItemCollection();
         var _loc1_:Item = new Item();
         _loc2_.setAccItem(0,_loc1_);
         _loc1_.init(1,1,0,EquippedAvatars.forced());
         _loc1_ = new Item();
         _loc2_.setAccItem(1,_loc1_);
         _loc1_.init(_currItem.avtEyeDefId > 0 ? _currItem.avtEyeDefId : 2,2,0,EquippedAvatars.forced());
         var _loc4_:AvatarDef = gMainFrame.userInfo.getAvatarDefByAvatar(_loc3_);
         if(_currItem.avtCustomId != -1 && _loc4_ && _currItem.avtPatternDefId < 1)
         {
            _currItem.avtPatternDefId = _loc4_.patternRefIds[0];
         }
         if(_currItem.avtPatternDefId > 0)
         {
            _loc1_ = new Item();
            _loc2_.setAccItem(2,_loc1_);
            _loc1_.init(_currItem.avtPatternDefId,3,0,EquippedAvatars.forced());
         }
         _loc3_.itemResponseIntegrate(_loc2_);
         _dispAvtView = new AvatarView();
         _dispAvtView.init(_loc3_,null);
         _dispAvtView.playAnim(15,false,1,onDisplayAvatarLoaded,true);
      }
      
      private function onDisplayAvatarLoaded(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = AvatarUtility.getAvatarHudPosition(_dispAvtView.avTypeId);
         _dispAvtView.scaleX = _window.charCont.width / _dispAvtView.width;
         _dispAvtView.scaleY = _window.charCont.height / _dispAvtView.height;
         _dispAvtView.x = _dispAvtView.scaleX * (_loc3_.x + _window.charCont.width * 0.5) + 10;
         _dispAvtView.y = _dispAvtView.scaleY * (_loc3_.y + _window.charCont.height * 0.5) + 10;
         _window.charCont.charLayer.addChild(_dispAvtView);
      }
   }
}

