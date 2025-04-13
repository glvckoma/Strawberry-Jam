package createAccountGui
{
   import avatar.Avatar;
   import createAccountFlow.CreateAccount;
   import createAccountFlow.CreateAccountGui;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import inventory.Iitem;
   import loadProgress.LoadProgress;
   import loader.MediaHelper;
   
   public class GuiAvatarCreationAssets extends Sprite
   {
      public static const MOVEMENT_TYPE_FROM_PREVIOUS:int = -1;
      
      public static const MOVEMENT_TYPE_FROM_OURSELVES:int = 0;
      
      public static const MOVEMENT_TYPE_FROM_NEXT:int = 1;
      
      public static var screenPosition:int;
      
      public var notifyPopup:MovieClip;
      
      public var tipsPopup:MovieClip;
      
      private var nextBtn:MovieClip;
      
      private var backBtn:MovieClip;
      
      private var playBtn:MovieClip;
      
      private var buyBtnRed:MovieClip;
      
      private var buyBtnGreen:MovieClip;
      
      private var buyBtnDiamondRed:MovieClip;
      
      private var buyBtnDiamondGreen:MovieClip;
      
      private var closeBtn:MovieClip;
      
      private var _avatarAssets:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _createAccountIlAvatar:CreateAccount;
      
      private var _chooseAnimalScreen:GuiChooseAnimal;
      
      private var _createNameScreen:GuiCreateAName;
      
      private var _playerTagScreen:GuiPlayerTagScreen;
      
      private var _skipToNameScreen:Boolean;
      
      private var _numLoaded:int;
      
      private var _isInWorld:Boolean;
      
      private var _allLoaded:Boolean;
      
      public function GuiAvatarCreationAssets()
      {
         super();
      }
      
      public function initFromWorld(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false, param5:Boolean = false, param6:Iitem = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _createAccountIlAvatar = null;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1892,onAvatarCarouselLoaded,{
            "isChoosingOceanAvatars":param1,
            "isChoosing":param2,
            "avatarTypeToShow":param3,
            "skipToNameScreen":param4,
            "isFastPass":param5,
            "iItem":param6
         });
      }
      
      public function initFromAccountCreation(param1:MovieClip, param2:CreateAccount) : void
      {
         _avatarAssets = param1;
         _createAccountIlAvatar = param2;
         init(false,null);
      }
      
      public function destroy() : void
      {
         _chooseAnimalScreen.destroy();
         _chooseAnimalScreen = null;
         _createNameScreen.destroy();
         _createNameScreen = null;
         if(_playerTagScreen)
         {
            _playerTagScreen.destroy();
            _playerTagScreen = null;
         }
         removeChild(_avatarAssets);
         _avatarAssets = null;
      }
      
      public function get chooseAnimalScreen() : GuiChooseAnimal
      {
         return _chooseAnimalScreen;
      }
      
      public function get createNameScreen() : GuiCreateAName
      {
         return _createNameScreen;
      }
      
      public function get playerTagScreen() : GuiPlayerTagScreen
      {
         return _playerTagScreen;
      }
      
      public function get currAvatarImage() : MovieClip
      {
         return _chooseAnimalScreen.currAvatarImage;
      }
      
      public function get currAvatar() : Avatar
      {
         return _chooseAnimalScreen.currAvatar;
      }
      
      public function get currBG() : String
      {
         return _chooseAnimalScreen.currBG;
      }
      
      public function get currType() : int
      {
         return _chooseAnimalScreen.currType;
      }
      
      public function get currCustomAvId() : int
      {
         return _chooseAnimalScreen.currCustomAvId;
      }
      
      public function get hasEnoughGems() : Boolean
      {
         return _chooseAnimalScreen.hasEnoughGems;
      }
      
      public function get currAvatarCost() : int
      {
         return _chooseAnimalScreen.currAvatarCost;
      }
      
      public function get currAvatarName() : String
      {
         return _chooseAnimalScreen.currAvatarName;
      }
      
      public function get isCreatingWithoutChoosing() : Boolean
      {
         return _chooseAnimalScreen.isCreatingWithoutChoosing;
      }
      
      public function get isDiamondAvatar() : Boolean
      {
         return _chooseAnimalScreen.isDiamondAvatar;
      }
      
      public function get avatarDiamondDefId() : int
      {
         return _chooseAnimalScreen.avatarDiamondDefId;
      }
      
      public function get currencyType() : int
      {
         return _chooseAnimalScreen.currencyType;
      }
      
      public function destroyReloadedItems() : void
      {
         _chooseAnimalScreen.destroyReloadedItems();
      }
      
      public function loadNameLists() : void
      {
         _createNameScreen.loadNameLists();
      }
      
      private function onAvatarCarouselLoaded(param1:MovieClip) : void
      {
         _avatarAssets = MovieClip(param1.getChildAt(0));
         if(param1.passback.isFastPass)
         {
            LoadProgress.show(false);
            if(CreateAccountGui.vo1Sound == null)
            {
               CreateAccountGui.loadCreationVoSounds(init,{
                  "isInWorld":true,
                  "requiredParams":param1.passback
               });
            }
         }
         else
         {
            init(true,param1.passback);
         }
      }
      
      private function init(param1:Boolean, param2:Object) : void
      {
         var _loc3_:TextField = null;
         addChild(_avatarAssets);
         var _loc4_:Boolean = Boolean(!!param2 ? param2.isFastPass : null);
         screenPosition = 0;
         _numLoaded = 0;
         _allLoaded = false;
         _isInWorld = param1;
         _avatarAssets.visible = false;
         _chooseAnimalScreen = new GuiChooseAnimal(_avatarAssets,_isInWorld,_loc4_,onLoaded);
         _chooseAnimalScreen.init();
         _createNameScreen = new GuiCreateAName(_avatarAssets,_createAccountIlAvatar,this,_isInWorld,_loc4_,onLoaded);
         _createNameScreen.init();
         if(!_isInWorld)
         {
            _playerTagScreen = new GuiPlayerTagScreen(_avatarAssets,_createAccountIlAvatar,this,onLoaded);
            _playerTagScreen.init();
            _skipToNameScreen = gMainFrame.clientInfo.selectedAvatarId != null && gMainFrame.clientInfo.selectedAvatarId > 0;
         }
         notifyPopup = _avatarAssets.oopsPopup;
         notifyPopup.notifyTxt = _avatarAssets.oopsPopup.bodyTxtOops.oops_txt;
         notifyPopup.titleTxt = _avatarAssets.oopsPopup.oops_title_txt;
         notifyPopup.bx.addEventListener("mouseDown",notifyPopupBxHandler,false,0,true);
         notifyPopup.visible = false;
         if(!_isInWorld)
         {
            tipsPopup = _avatarAssets.tipsPopup;
            tipsPopup.bx.addEventListener("mouseDown",tipsPopupBxHandler,false,0,true);
            _loc3_ = tipsPopup.tips_pp_txt;
            _loc3_.htmlText = _loc3_.text.replace("Privacy Policy","<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>Privacy Policy</u></a>");
            playBtn = _avatarAssets.play_btn;
            playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
         }
         else
         {
            buyBtnRed = _avatarAssets.buy_btn_red;
            buyBtnRed.addEventListener("mouseDown",onBuyBtn,false,0,true);
            buyBtnGreen = _avatarAssets.buy_btn_green;
            buyBtnGreen.addEventListener("mouseDown",onBuyBtn,false,0,true);
            buyBtnDiamondRed = _avatarAssets.diamond_buy_btn_red;
            buyBtnDiamondRed.addEventListener("mouseDown",onBuyBtn,false,0,true);
            buyBtnDiamondGreen = _avatarAssets.diamond_buy_btn_green;
            buyBtnDiamondGreen.addEventListener("mouseDown",onBuyBtn,false,0,true);
            closeBtn = _avatarAssets.bx;
            playBtn = _avatarAssets.play_btn;
            if(param2.isFastPass)
            {
               playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
               closeBtn.visible = false;
            }
            else
            {
               closeBtn.addEventListener("mouseDown",onClose,false,0,true);
               playBtn.visible = false;
            }
         }
         nextBtn = _avatarAssets.next_btn;
         nextBtn.addEventListener("mouseDown",onNextBtn,false,0,true);
         backBtn = _avatarAssets.back_btn;
         backBtn.addEventListener("mouseDown",onBackBtn,false,0,true);
         _avatarAssets.addEventListener("mouseDown",onPopupDown,false,0,true);
         if(_isInWorld)
         {
            _skipToNameScreen = param2.skipToNameScreen;
            _chooseAnimalScreen.setup(param2.isChoosingOceanAvatars,param2.isChoosing,param2.avatarTypeToShow,param2.skipToNameScreen,param2.isFastPass,param2.iItem);
         }
      }
      
      private function onLoaded() : void
      {
         _numLoaded++;
         if(_isInWorld ? _numLoaded == 2 : _numLoaded == 3)
         {
            _allLoaded = true;
            _avatarAssets.visible = true;
            if(_skipToNameScreen)
            {
               onNextBtn(null);
            }
         }
      }
      
      private function notifyPopupBxHandler(param1:MouseEvent) : void
      {
         notifyPopup.visible = false;
      }
      
      private function tipsPopupBxHandler(param1:MouseEvent) : void
      {
         tipsPopup.visible = false;
      }
      
      public function onNextBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_allLoaded)
         {
            if(screenPosition == 0)
            {
               if(_chooseAnimalScreen.switchScreens(true,0))
               {
                  _createNameScreen.switchScreens(true,-1);
               }
            }
            else if(screenPosition == 1)
            {
               if(_createNameScreen.switchScreens(true,0))
               {
                  _playerTagScreen.switchScreens(true,-1);
               }
            }
         }
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_allLoaded)
         {
            if(screenPosition == 0)
            {
               _chooseAnimalScreen.switchScreens(false,0);
            }
            else if(screenPosition == 1)
            {
               if(_createNameScreen.switchScreens(false,0))
               {
                  _chooseAnimalScreen.switchScreens(false,1);
               }
            }
            else if(_playerTagScreen.switchScreens(false,0))
            {
               _createNameScreen.switchScreens(false,1);
            }
         }
      }
      
      private function onPlayBtn(param1:MouseEvent, param2:Boolean = false) : void
      {
         param1.stopPropagation();
         if(_allLoaded)
         {
            if(_isInWorld)
            {
               _createNameScreen.switchScreens(true,0);
            }
            else
            {
               _playerTagScreen.switchScreens(true,0);
            }
         }
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_allLoaded)
         {
            _createNameScreen.switchScreens(true,0);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _createNameScreen.close();
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

