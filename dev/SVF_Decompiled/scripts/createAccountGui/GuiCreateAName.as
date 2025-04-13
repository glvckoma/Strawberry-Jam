package createAccountGui
{
   import Party.PartyManager;
   import avatar.Avatar;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.INewAvatar;
   import avatar.NewWorldAvatar;
   import com.greensock.TweenLite;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import createAccountFlow.CreateAccountGui;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiCarousel;
   import gui.GuiManager;
   import gui.UpsellManager;
   import localization.LocalizationManager;
   
   public class GuiCreateAName
   {
      private static const AVT_NAMES_1:int = 200;
      
      private static const AVT_NAMES_2:int = 202;
      
      private static const AVT_NAMES_3:int = 203;
      
      private const REGISTRATION_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const REGISTRATION_PANEL_X_DIRECTION:Number = -580;
      
      private const BACKGROUND_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const BACKGROUND_PANEL_X_DIRECTION:Number = -450;
      
      private var _createANameScreen:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _playBtn:MovieClip;
      
      private var _voBtn:MovieClip;
      
      private var _name1Carousel:GuiCarousel;
      
      private var _name2Carousel:GuiCarousel;
      
      private var _name3Carousel:GuiCarousel;
      
      private var _randomNameLever:MovieClip;
      
      private var _avatarNameTxt:TextField;
      
      private var _titleTxt:TextField;
      
      private var _avatarNameIndexes:Array;
      
      private var _avatarNameChosenIds:Array;
      
      private var _avtNames:Array;
      
      private var _newAvatarFacilitator:INewAvatar;
      
      private var _isFromWorld:Boolean;
      
      private var _isChoosingFirstNonMember:Boolean;
      
      private var _isValid:Boolean;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _buyBtnDiamondGreen:MovieClip;
      
      private var _buyBtnDiamondRed:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _registrationPanel:MovieClip;
      
      private var _isRandomSpin:Boolean;
      
      private var _creationAssets:GuiAvatarCreationAssets;
      
      private var _isFastPass:Boolean;
      
      private var _hasDoneRandomSpinOnFirstEnter:Boolean;
      
      private var _onLoaded:Function;
      
      private var _backgroundTween:TweenLite;
      
      private var _createANameTween:TweenLite;
      
      public function GuiCreateAName(param1:Object, param2:INewAvatar, param3:GuiAvatarCreationAssets, param4:Boolean, param5:Boolean, param6:Function)
      {
         super();
         _createANameScreen = param1.registrationPanel.createAName;
         _backBtn = param1.back_btn;
         _playBtn = param1.play_btn;
         _voBtn = _createANameScreen.vo_btn;
         _creationAssets = param3;
         _onLoaded = param6;
         _registrationPanel = MovieClip(_createANameScreen.parent);
         _name1Carousel = new GuiCarousel(_createANameScreen.nameScroller1);
         _name2Carousel = new GuiCarousel(_createANameScreen.nameScroller2);
         _name3Carousel = new GuiCarousel(_createANameScreen.nameScroller3);
         _randomNameLever = _createANameScreen.nameLever;
         _randomNameLever.addEventListener("mouseDown",randomLeverMouseDownHandler,false,0,true);
         _avatarNameTxt = _createANameScreen.aml_name_txt;
         _titleTxt = _createANameScreen.choose_name_title_txt;
         _isFastPass = param5;
         _isFromWorld = param4;
         _newAvatarFacilitator = _isFromWorld ? new NewWorldAvatar() : param2;
         if(param4)
         {
            _nextBtn = param1.next_btn;
            _buyBtnGreen = param1.buy_btn_green;
            _buyBtnRed = param1.buy_btn_red;
            _buyBtnDiamondGreen = param1.diamond_buy_btn_green;
            _buyBtnDiamondRed = param1.diamond_buy_btn_red;
         }
      }
      
      public function init() : void
      {
         _avatarNameTxt.restrict = "A-Za-z0-9 ";
         _avatarNameTxt.maxChars = 23;
         if(!_isFromWorld || _isFastPass)
         {
            _voBtn.stop();
            _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
         }
         _backBtn.visible = false;
         _avatarNameIndexes = [-1,-1,-1];
         _avatarNameChosenIds = [0,0,0];
         if(_avtNames == null)
         {
            _avtNames = [-1,-1,-1];
         }
         if(_isFromWorld)
         {
            GenericListXtCommManager.requestGenericList(200,onNamesLoaded);
            GenericListXtCommManager.requestGenericList(202,onNamesLoaded);
            GenericListXtCommManager.requestGenericList(203,onNamesLoaded);
         }
      }
      
      public function destroy() : void
      {
         _createANameScreen = null;
         _name1Carousel.destroy();
         _name1Carousel = null;
         _name2Carousel.destroy();
         _name2Carousel = null;
         _name3Carousel.destroy();
         _name3Carousel = null;
         _newAvatarFacilitator = null;
      }
      
      public function switchScreens(param1:Boolean, param2:int) : Boolean
      {
         if(_createANameTween)
         {
            _createANameTween.progress(1);
         }
         if(_backgroundTween)
         {
            _backgroundTween.progress(1);
         }
         var _loc3_:Number = -580;
         switch(param2 - -1)
         {
            case 0:
               enterFromPrev();
               if(!_hasDoneRandomSpinOnFirstEnter)
               {
                  randomLeverMouseDownHandler(null);
                  _hasDoneRandomSpinOnFirstEnter = true;
               }
               break;
            case 1:
               if(param1 && leaveToNext() || !param1 && leaveToPrev())
               {
                  leaveToBoth();
                  GuiAvatarCreationAssets.screenPosition += param1 ? 1 : -1;
                  _backgroundTween = new TweenLite(MovieClip(_registrationPanel.parent).bg[_creationAssets.currBG + "Bg"],0.5,{"x":"+=" + -450 * (param1 ? 1 : -1)});
                  if(param1)
                  {
                     _loc3_ *= 2;
                  }
                  break;
               }
               return false;
               break;
            case 2:
               enterFromNext();
               _loc3_ *= 2;
         }
         _createANameTween = new TweenLite(_createANameScreen,0.5,{"x":"+=" + _loc3_ * (param1 ? 1 : -1)});
         return true;
      }
      
      private function enterFromNext(param1:Boolean = false) : void
      {
         _isChoosingFirstNonMember = param1;
         _isValid = false;
         enterFromBoth();
      }
      
      private function enterFromPrev() : void
      {
         _newAvatarFacilitator.hideConnectingMsg();
         if(_isFromWorld)
         {
            _nextBtn.visible = false;
            if(_creationAssets.isDiamondAvatar && !AvatarUtility.getAvatarDefIsViewable(_creationAssets.currAvatar,_creationAssets.currCustomAvId != -1))
            {
               _buyBtnDiamondGreen.visible = _creationAssets.hasEnoughGems;
               _buyBtnDiamondRed.visible = !_buyBtnDiamondGreen.visible;
               _buyBtnGreen.visible = _buyBtnRed.visible = false;
            }
            else if(_isFastPass)
            {
               _playBtn.visible = true;
               _buyBtnGreen.visible = _buyBtnRed.visible = _buyBtnDiamondGreen.visible = _buyBtnDiamondRed.visible = false;
            }
            else
            {
               _buyBtnGreen.visible = _creationAssets.hasEnoughGems;
               _buyBtnRed.visible = !_buyBtnGreen.visible;
               _buyBtnDiamondGreen.visible = _buyBtnDiamondRed.visible = false;
            }
            _backBtn.sparkle.visible = _creationAssets.isDiamondAvatar;
         }
         _backBtn.visible = _isFromWorld ? !_creationAssets.isCreatingWithoutChoosing : true;
         _isValid = false;
         enterFromBoth();
      }
      
      private function enterFromBoth() : void
      {
         if(_newAvatarFacilitator.playSound || _isFastPass)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.play();
               if(CreateAccountGui.vo2Sound.sc)
               {
                  CreateAccountGui.vo2Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
                  _voBtn.play();
               }
            }
         }
         if(_isFromWorld)
         {
            SBTracker.trackPageview("/game/play/popup/avatarCreation/CreateAName");
         }
         else
         {
            CreateAccountGui.trackUserCreateAccountPageChange("CreateAName");
         }
      }
      
      private function leaveToNext() : Boolean
      {
         var _loc3_:Avatar = null;
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         if(_isFastPass)
         {
            AvatarSwitch.addFastPassAvatarCallback = onFastPassComplete;
         }
         if(!_isValid)
         {
            if(_isFromWorld)
            {
               if(gMainFrame.clientInfo.roomType == 5)
               {
                  _loc3_ = new Avatar();
                  _loc3_.init(0,-1,"",_creationAssets.currType,[]);
                  if(!PartyManager.canSwitchToAvatar(_loc3_,true))
                  {
                     _loc3_.destroy();
                     _loc3_ = null;
                     return false;
                  }
               }
               if(AvatarSwitch.numTotalAvatars >= 1000)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14690),true,onSlotsFullOk);
                  return true;
               }
               if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
               {
                  if(!gMainFrame.userInfo.isMember)
                  {
                     _loc2_ = AvatarUtility.findAvDefByType(_creationAssets.currType,_creationAssets.currCustomAvId);
                     if(_loc2_.isMemberOnly)
                     {
                        UpsellManager.displayPopup("animals","createMembersOnlyAvatar");
                        return false;
                     }
                     if(AvatarUtility.numNonMemberAvatars() >= 2 && !_isChoosingFirstNonMember)
                     {
                        UpsellManager.displayPopup("animalSlots","buyThirdAvatar");
                        return false;
                     }
                  }
               }
               if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
               {
                  if(AvatarUtility.getAvatarDefIsViewable(_creationAssets.currAvatar,_creationAssets.currCustomAvId != -1))
                  {
                     new SBYesNoPopup(_registrationPanel.parent.parent.parent,LocalizationManager.translateIdAndInsertOnly(14782,_creationAssets.currAvatarName,_creationAssets.currAvatarCost),true,onDiamondShopConfirmBuy);
                     return false;
                  }
                  GuiManager.showDiamondConfirmation(_creationAssets.currAvatarCost,onDiamondApprovePurchase);
                  return false;
               }
               if(!_isChoosingFirstNonMember && !_creationAssets.hasEnoughGems)
               {
                  DarkenManager.showLoadingSpiral(true);
                  if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
                  {
                     onCloseNotEnoughGems();
                  }
                  else
                  {
                     Utility.setupNotEnoughGemsPopup(_creationAssets.parent,_creationAssets.currAvatarCost,_creationAssets.currencyType);
                  }
                  return false;
               }
            }
            _loc1_ = _isFromWorld ? _creationAssets.currType : CreateAccountGui.currType();
            _newAvatarFacilitator.newAvatarData(_loc1_,_avatarNameTxt.text,_avatarNameChosenIds,avNameValidCallback,_creationAssets.avatarDiamondDefId,_creationAssets.currCustomAvId,_isFastPass);
         }
         if(_isValid)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.stop();
            }
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
            if(!_isFromWorld)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function leaveToBoth() : Boolean
      {
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         _name1Carousel.forceStop();
         _name2Carousel.forceStop();
         _name3Carousel.forceStop();
         return true;
      }
      
      private function leaveToPrev() : Boolean
      {
         _backBtn.visible = false;
         if(!_isFromWorld || _isFastPass)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.stop();
            }
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         return true;
      }
      
      public function loadNameLists() : void
      {
         GenericListXtCommManager.requestGenericList(200,onNamesLoaded,null,_isFromWorld);
         GenericListXtCommManager.requestGenericList(202,onNamesLoaded,null,_isFromWorld);
         GenericListXtCommManager.requestGenericList(203,onNamesLoaded,null,_isFromWorld);
      }
      
      public function close() : void
      {
         AvatarSwitch.addAvatarCallback = null;
         AvatarSwitch.addFastPassAvatarCallback = null;
         _newAvatarFacilitator.nameTypeScreenDone();
      }
      
      private function onNamesLoaded(param1:int, param2:Array) : void
      {
         var _loc3_:Array = null;
         var _loc7_:String = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Object = [];
         var _loc5_:int = -1;
         switch(param1 - 200)
         {
            case 0:
               _loc5_ = 0;
               _loc8_ = {
                  "names":[],
                  "locIds":[]
               };
               break;
            case 2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc8_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc5_ = 2;
                  break;
               }
               _loc8_ = {
                  "names":[],
                  "types":[],
                  "locIds":[]
               };
               _loc5_ = 1;
               break;
            case 3:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc8_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc5_ = 1;
                  break;
               }
               _loc8_ = {
                  "names":[],
                  "femNames":[],
                  "locIds":[]
               };
               _loc5_ = 2;
               break;
         }
         if(_loc5_ != -1)
         {
            _loc6_ = 0;
            while(_loc6_ < param2.length)
            {
               if(_loc5_ == 1)
               {
                  _loc3_ = LocalizationManager.translateIdOnly(param2[_loc6_]).split("$");
                  _loc7_ = _loc3_[0];
                  _loc4_ = Utility.findIndexToInsert(_loc8_.names,_loc7_);
                  _loc8_.names.splice(_loc4_,0,_loc7_);
                  if(_loc3_[1])
                  {
                     _loc8_.types.splice(_loc4_,0,_loc3_[1]);
                  }
                  else
                  {
                     _loc8_.types.splice(_loc4_,0,"m");
                  }
               }
               else if(_loc5_ == 2)
               {
                  _loc3_ = LocalizationManager.translateIdOnly(param2[_loc6_]).split("$");
                  _loc7_ = _loc3_[0].toLowerCase();
                  _loc4_ = Utility.findIndexToInsert(_loc8_.names,_loc7_);
                  _loc8_.names.splice(_loc4_,0,_loc7_);
                  if(_loc3_[1])
                  {
                     _loc8_.femNames.splice(_loc4_,0,_loc3_[1].toLowerCase());
                  }
                  else
                  {
                     _loc8_.femNames.splice(_loc4_,0,_loc7_);
                  }
               }
               else
               {
                  _loc7_ = LocalizationManager.translateIdOnly(param2[_loc6_]);
                  _loc4_ = Utility.findIndexToInsert(_loc8_.names,_loc7_);
                  _loc8_.names.splice(_loc4_,0,_loc7_);
               }
               _loc8_.locIds.splice(_loc4_,0,param2[_loc6_]);
               _loc6_++;
            }
            _avtNames[_loc5_] = _loc8_;
         }
         if(_avtNames[0] != -1 && _avtNames[1] != -1 && _avtNames[2] != -1)
         {
            setupNameLists(_avtNames[0].names,_avtNames[1].names,_avtNames[2].names);
         }
      }
      
      private function onCloseNotEnoughGems() : void
      {
         UpsellManager.displayPopup("","extraDiamonds");
      }
      
      private function onDiamondApprovePurchase() : void
      {
         var _loc1_:int = _isFromWorld ? _creationAssets.currType : CreateAccountGui.currType();
         _newAvatarFacilitator.newAvatarData(_loc1_,_avatarNameTxt.text,_avatarNameChosenIds,avNameValidCallback,_creationAssets.avatarDiamondDefId,_creationAssets.currCustomAvId);
      }
      
      private function onSlotsFullOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         close();
      }
      
      private function onDiamondShopConfirmBuy(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         if(param1.status)
         {
            _loc3_ = AvatarUtility.findAvDefByType(_creationAssets.currType,_creationAssets.currCustomAvId);
            if(_loc3_ != null)
            {
               _loc2_ = UserCurrency.getCurrency(0);
               if(_loc2_ < _loc3_.diamondItem.value)
               {
                  DarkenManager.showLoadingSpiral(true);
                  Utility.setupNotEnoughGemsPopup(_creationAssets.parent,_loc3_.diamondItem.value,0);
               }
               else
               {
                  _newAvatarFacilitator.newAvatarData(_creationAssets.currType,_avatarNameTxt.text,_avatarNameChosenIds,avNameValidCallback,_creationAssets.avatarDiamondDefId,_creationAssets.currCustomAvId);
               }
            }
            else
            {
               close();
            }
         }
         else
         {
            close();
         }
      }
      
      private function avNameValidCallback(param1:Boolean) : void
      {
         if(param1)
         {
            _isValid = true;
            if(_creationAssets != null)
            {
               _creationAssets.onNextBtn(null);
            }
            _newAvatarFacilitator.nameTypeScreenDone();
         }
         else
         {
            DebugUtility.debugTrace("ERROR: Invalid avname?!");
         }
      }
      
      private function onFastPassComplete(param1:Boolean) : void
      {
         if(param1)
         {
            avNameValidCallback(true);
            gMainFrame.userInfo.needFastPass = false;
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(11233));
         }
      }
      
      private function setupNameLists(param1:Array, param2:Array, param3:Array) : void
      {
         _name1Carousel.init(param1,names1Changed,null,false,_avatarNameIndexes[0]);
         _name2Carousel.init(param2,names2Changed,null,false,_avatarNameIndexes[1]);
         _name3Carousel.init(param3,names3Changed,null,false,_avatarNameIndexes[2]);
         if(_onLoaded != null)
         {
            _onLoaded();
            _onLoaded = null;
         }
      }
      
      private function names1Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            LocalizationManager.updateToFit(_avatarNameTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + _name3Carousel.selectedContentItem);
         }
         if(_name1Carousel.selectedContentItem)
         {
            _avatarNameChosenIds[0] = _avtNames[0].locIds[_name1Carousel.contentItemIndex];
            _avatarNameIndexes[0] = _name1Carousel.contentItemIndex;
         }
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
      }
      
      private function names2Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            LocalizationManager.updateToFit(_avatarNameTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + _name3Carousel.selectedContentItem);
         }
         if(_name2Carousel.selectedContentItem)
         {
            _avatarNameChosenIds[1] = _avtNames[1].locIds[_name2Carousel.contentItemIndex];
            _avatarNameIndexes[1] = _name2Carousel.contentItemIndex;
         }
         if(!_name2Carousel.soundsEnabled && _isRandomSpin)
         {
            _name2Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _name3Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _isRandomSpin = false;
         }
         if(_avtNames[2] && _name3Carousel.hasLoaded)
         {
            if(_avtNames[1].types[_name2Carousel.contentItemIndex] != "f")
            {
               if(_name3Carousel.contentItems != _avtNames[2].names)
               {
                  _name3Carousel.contentItems = _avtNames[2].names;
               }
            }
            else if(_avtNames[2].femNames && _avtNames[2].femNames[0] && _name3Carousel.contentItems != _avtNames[2].femNames)
            {
               _name3Carousel.contentItems = _avtNames[2].femNames;
            }
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
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
      }
      
      private function names3Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            LocalizationManager.updateToFit(_avatarNameTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + _name3Carousel.selectedContentItem);
         }
         if(_name3Carousel.selectedContentItem)
         {
            _avatarNameChosenIds[2] = _avtNames[2].locIds[_name3Carousel.contentItemIndex];
            _avatarNameIndexes[2] = _name3Carousel.contentItemIndex;
         }
         if(!_name3Carousel.soundsEnabled && _isRandomSpin)
         {
            _name3Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _name2Carousel.soundsEnabled = !SBAudio.areSoundsMuted;
            _isRandomSpin = false;
         }
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
      }
      
      private function randomLeverMouseDownHandler(param1:MouseEvent) : void
      {
         if(_randomNameLever.currentFrameLabel == "_up" && _name2Carousel && _name3Carousel)
         {
            _isRandomSpin = true;
            _name2Carousel.soundsEnabled = false;
            _name3Carousel.soundsEnabled = false;
            AJAudio.playRandomLever();
            _randomNameLever.gotoAndPlay("_play");
            _name1Carousel.pickRandomItem();
            _name2Carousel.pickRandomItem();
            _name3Carousel.pickRandomItem();
         }
      }
      
      private function stopVOButton(param1:Event) : void
      {
         CreateAccountGui.vo2Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(CreateAccountGui.vo2Sound.isPlaying)
         {
            CreateAccountGui.vo2Sound.stop();
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo2Sound.play();
            if(CreateAccountGui.vo2Sound.sc)
            {
               CreateAccountGui.vo2Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
               _voBtn.play();
            }
         }
      }
   }
}

