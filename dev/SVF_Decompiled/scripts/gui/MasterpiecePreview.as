package gui
{
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import buddy.BuddyList;
   import buddy.BuddyManager;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.display.Bitmap;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import loader.MasterpieceDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import resourceArray.ResourceArrayXtCommManager;
   
   public class MasterpiecePreview
   {
      private static var _masterpiecePreviewIconStrIds:Array;
      
      private static var _masterpiecePreviewIconIdsOrdered:Array;
      
      private const POPUP_MEDIA_ID:int = 4810;
      
      private var _guiLayer:DisplayObjectContainer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _masterpieceMediaHelper:MasterpieceDefHelper;
      
      private var _previewLoadingSpiral:LoadingSpiral;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _previewImage:Sprite;
      
      private var _previewPopup:MovieClip;
      
      private var _itemLayer:MovieClip;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _currFrame:MovieClip;
      
      private var _itemVersion:int;
      
      private var _hasLoadedIcons:Boolean;
      
      private var _isBuying:Boolean;
      
      private var _creatorUsername:String;
      
      private var _uniqueImageId:String;
      
      private var _creatorDbId:int;
      
      private var _creatorUUID:String;
      
      private var _numPasterpieceTokens:int;
      
      private var _itemToSetName:DenItem;
      
      private var _hasRequestedName:Boolean;
      
      private var _likeCount:int;
      
      public function MasterpiecePreview(param1:DisplayObjectContainer, param2:int, param3:String, param4:String, param5:int, param6:String, param7:int, param8:Function, param9:String, param10:DenItem = null, param11:Object = null, param12:Boolean = false)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _numPasterpieceTokens = param2;
         _itemVersion = param7;
         _uniqueImageId = param3;
         _creatorUsername = param4;
         _creatorDbId = param5;
         _creatorUUID = param6;
         _itemToSetName = param10;
         if(param11 != null)
         {
            if(param11 is Bitmap)
            {
               _previewImage = new Sprite();
               _previewImage.addChild(param11 as Bitmap);
            }
            else
            {
               _previewImage = param11 as Sprite;
            }
         }
         _isBuying = param12;
         if(_masterpiecePreviewIconIdsOrdered == null)
         {
            GenericListXtCommManager.requestGenericList(424,onMasterpieceIconOrderListLoaded);
         }
         else
         {
            _hasLoadedIcons = true;
         }
         if(param4 == "" && param6 != "" && param5 != -1 && param9 != null && param3 != "")
         {
            _hasRequestedName = false;
            DenXtCommManager.requestDenMasterpieceCreatorName(param9,_uniqueImageId,onCreatorUsernameResponse);
         }
         else
         {
            _hasRequestedName = true;
         }
         _closeCallback = param8;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4810,onPreviewLoaded);
      }
      
      public static function get masterpiecePreviewIconStrIds() : Array
      {
         return _masterpiecePreviewIconStrIds;
      }
      
      public static function set masterpiecePreviewIconStrIds(param1:Array) : void
      {
         _masterpiecePreviewIconStrIds = param1;
      }
      
      public static function set masterpiecePreviewIconIdsOrdered(param1:Array) : void
      {
         _masterpiecePreviewIconIdsOrdered = param1;
      }
      
      public static function get masterpiecePreviewIconIdsOrdered() : Array
      {
         return _masterpiecePreviewIconIdsOrdered;
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var _loc2_:Function = null;
         if(_closeCallback != null)
         {
            _loc2_ = _closeCallback;
            _closeCallback = null;
            _loc2_(param1);
            return;
         }
         if(_currFrame)
         {
            if(_previewImage)
            {
               _currFrame.itemWindow.removeChild(_previewImage);
            }
            if(!_isBuying)
            {
               _currFrame.report_btn.removeEventListener("mouseDown",onReportDown);
            }
            _currFrame.removeEventListener("mouseOver",onIconOver);
            _currFrame.removeEventListener("mouseOut",onIconOut);
            _currFrame.nameBar.removeEventListener("mouseDown",onNameBarDown);
         }
         removeEventListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_previewLoadingSpiral)
         {
            _previewLoadingSpiral.destroy();
            _previewLoadingSpiral = null;
         }
         if(_masterpieceMediaHelper)
         {
            _masterpieceMediaHelper.destroy();
            _masterpieceMediaHelper = null;
         }
         DarkenManager.unDarken(_previewPopup);
         _guiLayer.removeChild(_previewPopup);
         _previewPopup = _itemLayer = _buyBtnGreen = _buyBtnRed = _closeBtn = null;
      }
      
      public function set closeCallback(param1:Function) : void
      {
         _closeCallback = param1;
      }
      
      private function onMasterpieceIconOrderListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _masterpiecePreviewIconIdsOrdered = param2;
         _masterpiecePreviewIconStrIds = param3;
         _hasLoadedIcons = true;
         if(_previewPopup)
         {
            setupPreview();
         }
      }
      
      private function onCreatorUsernameResponse(param1:String) : void
      {
         _creatorUsername = param1;
         if(_itemToSetName != null)
         {
            _itemToSetName.uniqueImageCreator = param1;
         }
         completeSettingUp();
         _hasRequestedName = true;
      }
      
      private function onPreviewLoaded(param1:MovieClip) : void
      {
         _previewPopup = param1.getChildAt(0) as MovieClip;
         _itemLayer = _previewPopup.itemLayer;
         _buyBtnGreen = _previewPopup.diamond_buy_btn_green;
         _buyBtnRed = _previewPopup.diamond_buy_btn_red;
         _closeBtn = _previewPopup.bx;
         _previewPopup.x = 900 * 0.5;
         _previewPopup.y = 550 * 0.5;
         if(_hasRequestedName)
         {
            completeSettingUp();
         }
      }
      
      private function completeSettingUp() : void
      {
         if(_previewPopup && _previewPopup.parent != _guiLayer)
         {
            DarkenManager.showLoadingSpiral(false);
            setupPreview();
            addEventListeners();
            _guiLayer.addChild(_previewPopup);
            DarkenManager.darken(_previewPopup);
         }
      }
      
      private function setupPreview() : void
      {
         var _loc1_:Object = null;
         if(_hasLoadedIcons)
         {
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_masterpiecePreviewIconIdsOrdered[_itemVersion],onPreviewIconLoaded);
         }
         if(_isBuying)
         {
            _loc1_ = DiamondXtCommManager.getDiamondDef(221);
            if(!UserCurrency.hasEnoughCurrency(3,_loc1_.value) && _numPasterpieceTokens < 1)
            {
               _buyBtnGreen.visible = false;
               _buyBtnRed.visible = true;
            }
            else
            {
               _buyBtnGreen.visible = true;
               _buyBtnRed.visible = false;
            }
         }
         else
         {
            _buyBtnGreen.visible = false;
            _buyBtnRed.visible = false;
         }
      }
      
      private function onPreviewIconLoaded(param1:MovieClip) : void
      {
         _currFrame = param1.getChildAt(0) as MovieClip;
         _previewLoadingSpiral = new LoadingSpiral(_itemLayer);
         if(_previewImage)
         {
            onPreviewImageLoaded(_previewImage);
         }
         else if(_uniqueImageId)
         {
            _masterpieceMediaHelper = new MasterpieceDefHelper();
            _masterpieceMediaHelper.init(_uniqueImageId,onPreviewImageLoaded);
         }
         else
         {
            onPreviewImageLoaded(null);
         }
      }
      
      private function onPreviewImageLoaded(param1:Sprite) : void
      {
         _previewImage = param1;
         if(_previewLoadingSpiral)
         {
            _previewLoadingSpiral.destroy();
            _previewLoadingSpiral = null;
         }
         var _loc2_:Number = _currFrame.itemWindow.scaleX - 1;
         var _loc3_:Number = _currFrame.itemWindow.scaleY - 1;
         if(_previewImage)
         {
            _previewImage.width = _currFrame.itemWindow.width - _currFrame.itemWindow.width * _loc2_;
            _previewImage.height = _currFrame.itemWindow.height - _currFrame.itemWindow.height * _loc3_;
            _previewImage.x = -_previewImage.width * 0.5;
            _previewImage.y = -_previewImage.height * 0.5;
            _currFrame.itemWindow.addChild(_previewImage);
            _currFrame.likeBtn.setTextInLayer("","numTxt");
            if(_isBuying || _creatorUsername == "" || _creatorUsername == gMainFrame.userInfo.myUserName)
            {
               _currFrame.nameBar.mouseChildren = false;
               _currFrame.nameBar.mouseEnabled = false;
            }
            else
            {
               _currFrame.nameBar.mouseChildren = true;
               _currFrame.nameBar.mouseEnabled = true;
               _currFrame.addEventListener("mouseOver",onIconOver,false,0,true);
               _currFrame.addEventListener("mouseOut",onIconOut,false,0,true);
               _currFrame.nameBar.addEventListener("mouseDown",onNameBarDown,false,0,true);
            }
            _currFrame.report_btn.visible = false;
            if(_creatorUsername == null || _creatorUsername == "")
            {
               (_currFrame.nameBar as GuiSoundButton).setTextInLayer(LocalizationManager.translateIdOnly(25212),"name_txt");
            }
            else
            {
               (_currFrame.nameBar as GuiSoundButton).setTextInLayer(_creatorUsername,"name_txt");
            }
            if(!_isBuying)
            {
               _currFrame.likeBtn.mouseEnabled = true;
               _currFrame.likeBtn.mouseChildren = true;
               _currFrame.report_btn.addEventListener("mouseDown",onReportDown,false,0,true);
               _currFrame.likeBtn.addEventListener("mouseDown",onLikeBtn,false,0,true);
               _currFrame.nameBar.visible = true;
               _currFrame.likeBtn.activateLoadingState(true);
               ResourceArrayXtCommManager.sendResourceArrayGetRequest("masterpiece",_uniqueImageId,true,onResourceArrayGet,_currFrame);
            }
            else
            {
               _currFrame.likeBtn.visible = false;
               _currFrame.likeBtn.activateLoadingState(false);
            }
         }
         else
         {
            _currFrame.nameBar.visible = false;
            _currFrame.report_btn.visible = false;
            _currFrame.likeBtn.visible = false;
            while(_currFrame.itemWindow.numChildren > 1)
            {
               _currFrame.itemWindow.removeChildAt(_currFrame.itemWindow.numChildren - 1);
            }
         }
         if("frame" in _currFrame)
         {
            _currFrame.frame.filters = null;
         }
         _itemLayer.addChild(_currFrame);
      }
      
      private function addEventListeners() : void
      {
         _previewPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _buyBtnGreen.addEventListener("mouseDown",onBuyBtn,false,0,true);
         _buyBtnRed.addEventListener("mouseDown",onBuyBtn,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _previewPopup.removeEventListener("mouseDown",onPopup);
         _buyBtnGreen.removeEventListener("mouseDown",onBuyBtn);
         _buyBtnRed.removeEventListener("mouseDown",onBuyBtn);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _buyBtnRed)
         {
            UpsellManager.displayPopup("","extraDiamonds");
         }
         else if(_numPasterpieceTokens == 0 && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup("denArt","den_art");
         }
         else
         {
            destroy(true);
         }
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _reportAPlayer = new ReportAPlayer();
         _reportAPlayer.init(4,_guiLayer,onPostReport,true,_creatorUsername,_creatorUsername,false,_uniqueImageId,7);
      }
      
      private function onPostReport(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      private function onIconOver(param1:MouseEvent) : void
      {
         param1.currentTarget.report_btn.visible = true;
      }
      
      private function onIconOut(param1:MouseEvent) : void
      {
         param1.currentTarget.report_btn.visible = false;
      }
      
      private function onNameBarDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_previewPopup && _creatorUsername.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            DarkenManager.showLoadingSpiral(true);
            BuddyList.requestBuddyListIfNeeded(onBuddyListRequested);
         }
      }
      
      private function onBuddyListRequested() : void
      {
         var _loc1_:Buddy = BuddyManager.getBuddyByUserName(_creatorUsername);
         if(_loc1_)
         {
            BuddyManager.showBuddyCard({
               "userName":_loc1_.userName,
               "onlineStatus":_loc1_.onlineStatus
            });
            return;
         }
         AvatarXtCommManager.requestAvatarGet(_creatorUsername,onUserLookUpReceived,true);
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
         else
         {
            _currFrame.nameBar.mouseChildren = false;
            _currFrame.nameBar.mouseEnabled = false;
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onLikeBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.loadingCont.visible)
         {
            if(param1.currentTarget.down)
            {
               param1.currentTarget.downToUpState();
               param1.currentTarget.activateLoadingState(true);
               ResourceArrayXtCommManager.sendResourceArrayPutRequest("masterpiece",_uniqueImageId,_creatorUUID,_creatorDbId,_itemVersion,"",onResourceArrayPut,param1.currentTarget.parent);
            }
         }
      }
      
      private function onResourceArrayGet(param1:Boolean, param2:Boolean, param3:int, param4:Object) : void
      {
         var _loc5_:MovieClip = param4 as MovieClip;
         _loc5_.likeBtn.activateLoadingState(false);
         if(param1)
         {
            _loc5_.likeBtn.setTextInLayer(Utility.convertNumberToString(param3),"numTxt");
            _likeCount = param3;
            if(param2 || (_creatorUsername == null || _creatorUsername == ""))
            {
               _loc5_.likeBtn.upToDownState();
               _loc5_.likeBtn.removeEventListener("mouseDown",onLikeBtn);
               _loc5_.likeBtn.mouseChildren = false;
               _loc5_.likeBtn.mouseEnabled = false;
            }
            _loc5_.likeBtn.visible = true;
         }
         else
         {
            _loc5_.likeBtn.setTextInLayer(Utility.convertNumberToString(0),"numTxt");
         }
      }
      
      private function onResourceArrayPut(param1:Boolean, param2:Object) : void
      {
         var _loc3_:MovieClip = param2 as MovieClip;
         _loc3_.likeBtn.activateLoadingState(false);
         if(param1)
         {
            _loc3_.likeBtn.upToDownState();
            _loc3_.likeBtn.removeEventListener("mouseDown",onLikeBtn);
            _loc3_.likeBtn.mouseChildren = false;
            _loc3_.likeBtn.mouseEnabled = false;
            _likeCount++;
            _loc3_.likeBtn.setTextInLayer(Utility.convertNumberToString(_likeCount),"numTxt");
         }
      }
   }
}

