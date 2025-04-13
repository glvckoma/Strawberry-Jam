package customParty
{
   import Enums.DenItemDef;
   import Party.PartyManager;
   import Party.PartyXtCommManager;
   import avatar.AvatarManager;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiCarousel;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.PartyPreviewManager;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class CustomPartyCreatePopup
   {
      private const CUSTOM_PARTY_COST:int = 1;
      
      private const CUSTOM_PARTY_MEDIA_ID:int = 4413;
      
      public const PARTY_NAMES_1:int = 386;
      
      public const PARTY_NAMES_2:int = 387;
      
      public const PARTY_NAMES_3:int = 388;
      
      private const CUSTOM_PARTY_DEF_LIST_ID:int = 370;
      
      private const CUSTOM_PARTY_AUDIO_LIST_ID:int = 401;
      
      private var _mediaHelper:MediaHelper;
      
      private var _roomIconMediaHelper:MediaHelper;
      
      private var _partyTagMediaHelper:MediaHelper;
      
      private var _callback:Function;
      
      private var _customCreatePopup:MovieClip;
      
      private var _currRoomIcon:MovieClip;
      
      private var _currPartyTag:MovieClip;
      
      private var names1Index:int = 0;
      
      private var names2Index:int = 1;
      
      private var names3Index:int = 2;
      
      private var _name1Carousel:GuiCarousel;
      
      private var _name2Carousel:GuiCarousel;
      
      private var _name3Carousel:GuiCarousel;
      
      private var _roomIconLoadingSpiral:LoadingSpiral;
      
      private var _partyTagLoadingSpiral:LoadingSpiral;
      
      private var _previewManager:PartyPreviewManager;
      
      private var _roomMgr:RoomManagerWorld;
      
      private var _wheelBarrelNames:Array;
      
      private var _partyNameIndexes:Array;
      
      private var _partyNameChosenIds:Array;
      
      private var _partyDefIds:Array;
      
      private var _currPartyDef:Object;
      
      private var _audioItemDefIds:Array;
      
      private var _currAudioDef:DenItemDef;
      
      private var _currIconIndex:int;
      
      private var _currAudioIndex:int;
      
      private var _diamondCount:int;
      
      private var _isRandomSpin:Boolean;
      
      private var _startingHosting:Boolean;
      
      private var _originalFilename:String;
      
      private var _originalVolume:Number;
      
      private var _originalCustomMusicDef:int;
      
      public function CustomPartyCreatePopup(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _callback = param1;
         _roomMgr = RoomManagerWorld.instance;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4413,onCustomPartyPopupLoaded);
         _previewManager = new PartyPreviewManager();
         _previewManager.setCreatePopup(this);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         if(_previewManager)
         {
            if(param1)
            {
               _previewManager.handlePartyPurchase(true);
            }
            _previewManager.destroy();
            _previewManager = null;
         }
         if(_customCreatePopup)
         {
            removeEventListeners();
            _callback = null;
            _mediaHelper.destroy();
            _mediaHelper = null;
            if(_roomIconMediaHelper)
            {
               _roomIconMediaHelper.destroy();
               _roomIconMediaHelper = null;
            }
            if(_partyTagMediaHelper)
            {
               _partyTagMediaHelper.destroy();
               _partyTagMediaHelper = null;
            }
            _roomIconLoadingSpiral.destroy();
            _roomIconLoadingSpiral = null;
            _partyTagLoadingSpiral.destroy();
            _partyTagLoadingSpiral = null;
            if(param1 || !_startingHosting)
            {
               _roomMgr.playOriginalMusic(_originalFilename,_originalVolume);
               _roomMgr.customMusicDef = _originalCustomMusicDef;
            }
            DarkenManager.unDarken(_customCreatePopup);
            GuiManager.guiLayer.removeChild(_customCreatePopup);
            _customCreatePopup = null;
         }
      }
      
      public function showPopup(param1:Boolean) : void
      {
         if(_customCreatePopup)
         {
            _customCreatePopup.visible = param1;
            if(param1)
            {
               DarkenManager.darken(_customCreatePopup);
            }
            else
            {
               DarkenManager.unDarken(_customCreatePopup);
            }
         }
      }
      
      public function tryToHostPartyFromPreview() : void
      {
         onHostPartyBtn(null);
      }
      
      private function onCustomPartyPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _customCreatePopup = param1.getChildAt(0) as MovieClip;
         _roomIconLoadingSpiral = new LoadingSpiral(_customCreatePopup.room_itemWindow,_customCreatePopup.room_itemWindow.width * 0.5,_customCreatePopup.room_itemWindow.height * 0.5);
         _partyTagLoadingSpiral = new LoadingSpiral(_customCreatePopup.tag_itemWindow,_customCreatePopup.tag_itemWindow.width * 0.5,_customCreatePopup.tag_itemWindow.height * 0.5);
         loadAndSetupNamingWheels();
         loadAndSetupTags();
         loadAndSetupAudioSelection();
         setupPricingAndTags();
         addEventListeners();
         _customCreatePopup.x = 900 * 0.5;
         _customCreatePopup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_customCreatePopup);
         DarkenManager.darken(_customCreatePopup);
      }
      
      private function loadAndSetupNamingWheels() : void
      {
         _partyNameIndexes = [-1,-1,1];
         _partyNameChosenIds = [0,0,0];
         Utility.loadNameBarrelListAndReturnSetupArrays(_wheelBarrelNames,setupNameLists,false,true,386,387,388);
      }
      
      private function loadAndSetupTags() : void
      {
         GenericListXtCommManager.requestGenericList(370,onCustomPartyDefIdsLoaded);
      }
      
      private function loadAndSetupAudioSelection() : void
      {
         var _loc1_:SBMusic = _roomMgr.roomMusic;
         _originalCustomMusicDef = _roomMgr.customMusicDef;
         if(_loc1_)
         {
            _originalFilename = _loc1_.currFilename;
            _originalVolume = _loc1_.currVolume;
         }
         GenericListXtCommManager.requestGenericList(401,onCustomPartyAudioDefIdsLoaded);
      }
      
      private function addEventListeners() : void
      {
         _customCreatePopup.addEventListener("mouseDown",onPopup,false,0,true);
         _customCreatePopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _customCreatePopup.nameLever.addEventListener("mouseDown",onRandomLever,false,0,true);
         _customCreatePopup.hostPartyBtn_red.addEventListener("mouseDown",onHostPartyBtn,false,0,true);
         _customCreatePopup.hostPartyBtn_green.addEventListener("mouseDown",onHostPartyBtn,false,0,true);
         _customCreatePopup.leftBtn.addEventListener("mouseDown",onLeftRightBtn,false,0,true);
         _customCreatePopup.rightBtn.addEventListener("mouseDown",onLeftRightBtn,false,0,true);
         _customCreatePopup.previewBtn.addEventListener("mouseDown",onPreviewBtn,false,0,true);
         _customCreatePopup.lAudioBtn.addEventListener("mouseDown",onLeftRightAudio,false,0,true);
         _customCreatePopup.rAudioBtn.addEventListener("mouseDown",onLeftRightAudio,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _customCreatePopup.removeEventListener("mouseDown",onPopup);
         _customCreatePopup.bx.removeEventListener("mouseDown",onCloseBtn);
         _customCreatePopup.nameLever.removeEventListener("mouseDown",onRandomLever);
         _customCreatePopup.hostPartyBtn_red.removeEventListener("mouseDown",onHostPartyBtn);
         _customCreatePopup.hostPartyBtn_green.removeEventListener("mouseDown",onHostPartyBtn);
         _customCreatePopup.leftBtn.removeEventListener("mouseDown",onLeftRightBtn);
         _customCreatePopup.rightBtn.removeEventListener("mouseDown",onLeftRightBtn);
         _customCreatePopup.previewBtn.removeEventListener("mouseDown",onPreviewBtn);
         _customCreatePopup.lAudioBtn.removeEventListener("mouseDown",onLeftRightAudio);
         _customCreatePopup.rAudioBtn.removeEventListener("mouseDown",onLeftRightAudio);
      }
      
      private function loadRoomAndPartyIcon() : void
      {
         _currPartyDef = PartyManager.getPartyDef(_partyDefIds[_currIconIndex]);
         if(_currPartyDef)
         {
            _partyTagLoadingSpiral.visible = true;
            _partyTagMediaHelper = new MediaHelper();
            _partyTagMediaHelper.init(_currPartyDef.mediaRefId,onPartyTagLoaded);
            _roomIconLoadingSpiral.visible = true;
            _roomIconMediaHelper = new MediaHelper();
            _roomIconMediaHelper.init(_currPartyDef.iconMediaRefId,onRoomIconLoaded);
         }
      }
      
      private function loadAndSetAudio() : void
      {
         _currAudioDef = DenXtCommManager.getDenItemDef(_audioItemDefIds[_currAudioIndex]);
         if(_currAudioDef)
         {
            _roomMgr.playMusic(_currAudioDef.abbrName + ".mp3",_currAudioDef.flag / 100);
            _roomMgr.customMusicDef = _currAudioDef.id;
            LocalizationManager.translateId(_customCreatePopup.audioTitle,_currAudioDef.nameStrId);
         }
      }
      
      private function setupPartyTagText() : void
      {
         if(_currPartyTag)
         {
            LocalizationManager.updateToFit(_currPartyTag.txt.titleTxtCont.titleTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + " " + _name3Carousel.selectedContentItem);
         }
      }
      
      private function setupPricingAndTags() : void
      {
         _diamondCount = UserCurrency.getCurrency(3);
         _customCreatePopup.tag.gotoAndStop(_diamondCount < 1 ? "red" : "green");
         _customCreatePopup.hostPartyBtn_green.visible = _diamondCount >= 1;
         _customCreatePopup.hostPartyBtn_red.visible = !_customCreatePopup.hostPartyBtn_green.visible;
         _customCreatePopup.gem_count_txt.text = Utility.convertNumberToString(_diamondCount);
         _customCreatePopup.tag.costTxt.text = 1;
      }
      
      private function setupNameLists(param1:Array) : void
      {
         _wheelBarrelNames = param1;
         _name1Carousel = new GuiCarousel(_customCreatePopup.nameScroller1);
         _name2Carousel = new GuiCarousel(_customCreatePopup.nameScroller2);
         _name3Carousel = new GuiCarousel(_customCreatePopup.nameScroller3);
         if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
         {
            names1Index = 2;
            names2Index = 0;
            names3Index = 1;
         }
         else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
         {
            names1Index = 2;
            names2Index = 1;
            names3Index = 0;
         }
         _name1Carousel.init(param1[names1Index].names,names1Changed,null,false,_partyNameIndexes[0]);
         _name2Carousel.init(param1[names2Index].names,names2Changed,null,false,_partyNameIndexes[1]);
         _name3Carousel.init(param1[names3Index].names,names3Changed,null,false,_partyNameIndexes[2]);
      }
      
      private function names1Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            setupPartyTagText();
         }
         if(_name1Carousel.selectedContentItem)
         {
            _partyNameChosenIds[0] = _wheelBarrelNames[names1Index].locIds[_name1Carousel.contentItemIndex];
            _partyNameIndexes[0] = _name1Carousel.contentItemIndex;
         }
      }
      
      private function names2Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            setupPartyTagText();
         }
         if(_name2Carousel.selectedContentItem)
         {
            _partyNameChosenIds[1] = _wheelBarrelNames[names2Index].locIds[_name2Carousel.contentItemIndex];
            _partyNameIndexes[1] = _name2Carousel.contentItemIndex;
         }
         if(!_name2Carousel.soundsEnabled && _isRandomSpin)
         {
            _name2Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _name3Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _isRandomSpin = false;
         }
         if(_wheelBarrelNames[names3Index] && _name3Carousel.hasLoaded)
         {
            if(_name3Carousel.soundsEnabled)
            {
               _name3Carousel.soundsEnabled = false;
               _name3Carousel.spinToIndex(_name3Carousel.contentItemIndex,true);
               _name3Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            }
            else
            {
               _name3Carousel.spinToIndex(_name3Carousel.contentItemIndex,true);
            }
         }
      }
      
      private function names3Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            setupPartyTagText();
         }
         if(_name3Carousel.selectedContentItem)
         {
            _partyNameChosenIds[2] = _wheelBarrelNames[names3Index].locIds[_name3Carousel.contentItemIndex];
            _partyNameIndexes[2] = _name3Carousel.contentItemIndex;
         }
         if(!_name3Carousel.soundsEnabled && _isRandomSpin)
         {
            _name3Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _name2Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _isRandomSpin = false;
         }
      }
      
      private function onCustomPartyDefIdsLoaded(param1:int, param2:Array, param3:Function) : void
      {
         _partyDefIds = param2;
         loadRoomAndPartyIcon();
      }
      
      private function onCustomPartyAudioDefIdsLoaded(param1:int, param2:Array) : void
      {
         _audioItemDefIds = param2.slice(9);
         loadAndSetAudio();
      }
      
      private function onRoomIconLoaded(param1:MovieClip) : void
      {
         if(_currRoomIcon != null)
         {
            _customCreatePopup.room_itemWindow.removeChild(_currRoomIcon);
         }
         _currRoomIcon = param1.getChildAt(0) as MovieClip;
         _customCreatePopup.room_itemWindow.addChild(_currRoomIcon);
         _roomIconLoadingSpiral.visible = false;
      }
      
      private function onPartyTagLoaded(param1:MovieClip) : void
      {
         if(_currPartyTag != null)
         {
            _customCreatePopup.tag_itemWindow.removeChild(_currPartyTag);
         }
         _currPartyTag = param1.getChildAt(0) as MovieClip;
         _currPartyTag.mouseChildren = false;
         _currPartyTag.mouseChildren = false;
         _currPartyTag.goBtn.visible = false;
         if(_currPartyTag.timerBg)
         {
            _currPartyTag.timerBg.visible = false;
         }
         _partyTagLoadingSpiral.visible = false;
         _customCreatePopup.tag_itemWindow.addChild(_currPartyTag);
         setupPartyTagText();
      }
      
      private function onConfirmHost() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _previewManager.handlePartyPurchase();
         _startingHosting = true;
         PartyXtCommManager.sendCustomPartyHostRequest(_currPartyDef.id,_partyNameChosenIds,_currAudioDef.id);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_callback != null)
         {
            _callback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onRandomLever(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_customCreatePopup.nameLever.currentFrameLabel == "_up")
         {
            _isRandomSpin = true;
            _name2Carousel.soundsEnabled = false;
            _name3Carousel.soundsEnabled = false;
            AJAudio.playRandomLever();
            _customCreatePopup.nameLever.gotoAndPlay("_play");
            _name1Carousel.pickRandomItem();
            _name2Carousel.pickRandomItem();
            _name3Carousel.pickRandomItem();
         }
      }
      
      private function onHostPartyBtn(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup("adventures","customAdventure/" + _currPartyDef.id);
         }
         else if(_diamondCount >= 1)
         {
            if(_currPartyDef)
            {
               _loc2_ = "";
               _loc2_ = LocalizationManager.translateIdOnly(24266);
               GuiManager.showDiamondConfirmation(1,onConfirmHost,_loc2_,LocalizationManager.translateIdOnly(24223));
            }
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(24247));
         }
      }
      
      private function onLeftRightBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _customCreatePopup.leftBtn)
         {
            _currIconIndex--;
            if(_currIconIndex < 0)
            {
               _currIconIndex = _partyDefIds.length - 1;
            }
         }
         else
         {
            _currIconIndex++;
            if(_currIconIndex >= _partyDefIds.length)
            {
               _currIconIndex = 0;
            }
         }
         loadRoomAndPartyIcon();
      }
      
      private function onPreviewBtn(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_currPartyDef)
         {
            _loc2_ = RoomXtCommManager.getRoomDef(_currPartyDef.roomDefId);
            if(_loc2_)
            {
               if(Utility.isSameEnviroType(AvatarManager.playerAvatar.enviroTypeFlag,_loc2_.enviroType))
               {
                  DarkenManager.unDarken(_customCreatePopup);
                  RoomManagerWorld.instance.loadPreviewRoom(_loc2_.pathName,_loc2_.enviroType,_previewManager);
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(Utility.isOcean(AvatarManager.playerAvatar.enviroTypeFlag) ? 24263 : 24262));
               }
            }
         }
      }
      
      private function onLeftRightAudio(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _customCreatePopup.lAudioBtn)
         {
            if(_currAudioIndex - 1 < 0)
            {
               _currAudioIndex = _audioItemDefIds.length - 1;
            }
            else
            {
               _currAudioIndex--;
            }
         }
         else if(_currAudioIndex + 1 > _audioItemDefIds.length - 1)
         {
            _currAudioIndex = 0;
         }
         else
         {
            _currAudioIndex++;
         }
         loadAndSetAudio();
      }
   }
}

