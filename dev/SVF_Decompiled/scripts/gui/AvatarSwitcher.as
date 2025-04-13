package gui
{
   import Party.PartyManager;
   import avatar.Avatar;
   import avatar.AvatarDef;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import gui.itemWindows.ItemWindowAnimal;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomXtCommManager;
   
   public class AvatarSwitcher
   {
      private const SLOTS_PER_NONMEMBER:int = 2;
      
      private const MIN_NUM_AVATARS:int = 1;
      
      private const COST_OF_NEW_ANIMAL:int = 1000;
      
      private const AVSWITCH_MEDIA_ID:int = 1168;
      
      private const AVSWITCH_CHOOSING_MEDIA_ID:int = 1169;
      
      private var _numTotalSlots:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _activeIdx:int;
      
      private var _idx:int;
      
      private var _purchaseIdx:int;
      
      private var _myGemCount:int;
      
      private var _recycling:Boolean;
      
      private var _hasDeletedAnAvatar:Boolean;
      
      private var _isChoosing:Boolean;
      
      private var _isChoosingOceanAnimal:Boolean;
      
      private var _joinRoomAfterSwitch:Boolean;
      
      private var _switchDensAfterAdd:Boolean;
      
      private var _avatarsChosen:Array;
      
      private var _currSound:Sound;
      
      private var _currSoundChannel:SoundChannel;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _switchContent:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _choosingContent:MovieClip;
      
      private var _hasAddedListeners:Boolean;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      public function AvatarSwitcher()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Function = null, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true, param6:Boolean = false) : void
      {
         var _loc7_:int = 0;
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _closeCallback = param2;
         _isChoosing = param3;
         _isChoosingOceanAnimal = param4;
         _joinRoomAfterSwitch = param5;
         _switchDensAfterAdd = param6;
         AvatarSwitch.isChoosing = _isChoosing;
         _myGemCount = UserCurrency.getCurrency(0);
         _numTotalSlots = 40;
         _mediaHelpers = [];
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1168,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
         if(_isChoosing)
         {
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(1169,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
            _avatarsChosen = [];
            AvatarSwitch.availSlotFlags = 4294967295;
            switch(LocalizationManager.currentLanguage)
            {
               case LocalizationManager.LANG_ENG:
                  _loc7_ = 72;
                  break;
               case LocalizationManager.LANG_SPA:
                  _loc7_ = 680;
                  break;
               case LocalizationManager.LANG_POR:
                  _loc7_ = 635;
                  break;
               case LocalizationManager.LANG_FRE:
                  _loc7_ = 630;
                  break;
               case LocalizationManager.LANG_DE:
                  _loc7_ = 625;
                  break;
               default:
                  _loc7_ = 72;
            }
            _currSound = new Sound();
            _currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + _loc7_ + ".mp3"));
         }
      }
      
      public function destroy() : void
      {
         removeListeners();
         KeepAlive.stopKATimer(_switchContent);
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = null;
         }
         if(_switchContent)
         {
            if(_switchContent.root.parent == _guiLayer)
            {
               _guiLayer.removeChild(_switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(_switchContent.root));
            _switchContent.root.removeEventListener("mouseDown",onPopup);
            _switchContent = null;
            if(_closeBtn)
            {
               _closeBtn = null;
            }
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _closeCallback = null;
      }
      
      public function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      public function get isChoosing() : Boolean
      {
         return _isChoosing;
      }
      
      private function isRecycling() : Boolean
      {
         return _recycling;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(param1.mediaHelper.id == 1168)
            {
               _closeBtn = MovieClip(param1.getChildAt(0)).bx;
               _switchContent = MovieClip(param1.getChildAt(0)).c;
               KeepAlive.startKATimer(_switchContent);
               _guiLayer.addChild(param1);
               param1.addEventListener("mouseDown",onPopup,false,0,true);
               param1.x = 900 * 0.5;
               param1.y = 550 * 0.5;
               DarkenManager.showLoadingSpiral(false);
               DarkenManager.darken(param1);
               if(_isChoosing)
               {
                  if(_choosingContent)
                  {
                     addListeners();
                  }
               }
               else
               {
                  addListeners();
               }
               initializePopupStates();
               buildWindows();
            }
            else if(param1.mediaHelper.id == 1169)
            {
               _choosingContent = new MovieClip();
               _choosingContent.oneAmlPopup = param1.OneAmlPopup;
               _choosingContent.amlsPopup = param1.AmlsPopup;
               _guiLayer.addChild(_choosingContent.amlsPopup);
               _guiLayer.addChild(_choosingContent.oneAmlPopup);
               _choosingContent.oneAmlPopup.x = 900 * 0.5;
               _choosingContent.oneAmlPopup.y = 550 * 0.5;
               _choosingContent.amlsPopup.x = 900 * 0.5;
               _choosingContent.amlsPopup.y = 550 * 0.5;
               _choosingContent.oneAmlPopup.visible = false;
               _choosingContent.amlsPopup.visible = false;
               if(!_hasAddedListeners && _switchContent)
               {
                  addListeners();
               }
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function initializePopupStates() : void
      {
         _activeIdx = AvatarSwitch.activeAvatarIdx;
         LocalizationManager.translateId(_switchContent.buyPopup.item_name_txt,11218);
         _switchContent.buyPopup.tag.txt.text = "";
         _switchContent.oopsPopup.body_txt.text = "";
         _switchContent.buyPopup.newTag.visible = false;
         _switchContent.buyPopup.saleTag.visible = false;
         _switchContent.buyPopup.clearanceTag.visible = false;
         _switchContent.buyPopup.paw.gray.visible = false;
         _switchContent.buyPopup.banner.visible = false;
         _switchContent.buyPopup.lock.visible = false;
         _switchContent.buyPopup.lockOpen.visible = false;
         _switchContent.buyPopup.colorChange_btn.visible = false;
         _switchContent.buyPopup.paw.visible = true;
         _switchContent.buyPopup.visible = false;
         _switchContent.buyPopup.ocean.visible = false;
         if(AvatarManager.roomEnviroType == 0)
         {
            _switchContent.buyPopup.buyGreenBG.visible = true;
         }
         else
         {
            _switchContent.buyPopup.buyGreenBG.visible = false;
         }
         _switchContent.oopsPopup.visible = false;
         _switchContent.oopsCostPopup.visible = false;
         _switchContent.denShopTag.visible = false;
         _switchContent.saveAmlTag.visible = false;
      }
      
      private function buildWindows() : void
      {
         var _loc1_:int = 0;
         DarkenManager.showLoadingSpiral(true);
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _numTotalSlots = 40;
         if(AvatarSwitch.avatars.length >= 40)
         {
            _loc1_ = AvatarSwitch.avatars.length % 4;
            _numTotalSlots = Math.min(1000,AvatarSwitch.avatars.length + (4 - _loc1_));
         }
         if(AvatarSwitch.avatars.length > 0 && _isChoosing)
         {
            _avatarsChosen = [];
         }
         AvatarSwitch.numOpenNonMemberSlots = 0;
         _switchContent.newAmlTag.newAmlBtn.activateGrayState(true);
         _switchContent.itemCounter.counterTxt.text = AvatarSwitch.avatars.length + "/" + 1000;
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(gMainFrame.userInfo.myUserName);
         var _loc4_:int = _numTotalSlots;
         var _loc5_:int = Math.min(_loc4_,4);
         var _loc3_:int = Math.ceil(_loc5_ / 2);
         _itemWindows = new WindowAndScrollbarGenerator();
         _itemWindows.init(_switchContent.itemBlock.width,_switchContent.itemBlock.height,-4,0,_loc5_,_loc3_,_loc4_,0,0,0,0,ItemWindowAnimal,AvatarSwitch.avatars,"",_loc4_,{
            "mouseDown":onItemWindowDown,
            "mouseOver":onItemWindowOver,
            "mouseOut":onItemWindowOut
         },{
            "isAnimal":true,
            "isChoosing":_isChoosing,
            "isChoosingOcean":_isChoosingOceanAnimal,
            "nameBarData":_loc2_.nameBarData,
            "numNonMemberAvatars":AvatarSwitch.numNonMemberAvatars,
            "numNonMemberOceanOnlyAvatars":AvatarSwitch.numNonMemberOceanOnlyAvatars,
            "isRecycling":isRecycling,
            "ignoreEnviroType":true
         },onWindowsLoaded,true,false,false,false,false,false);
         _switchContent.itemBlock.addChild(_itemWindows);
      }
      
      private function onWindowsLoaded() : void
      {
         var _loc7_:Boolean = false;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:Boolean = false;
         var _loc1_:* = false;
         _activeIdx = AvatarSwitch.activeAvatarIdx;
         var _loc5_:int = AvatarSwitch.numNonMemberAvatars;
         var _loc4_:int = AvatarSwitch.numNonMemberOceanOnlyAvatars;
         var _loc6_:* = -1;
         _loc3_ = 0;
         while(_loc3_ < _numTotalSlots)
         {
            if(AvatarSwitch.avatars[_loc3_] != null)
            {
               if(!_isChoosing && AvatarSwitch.numNonMemberAvatars < 2 && _loc6_ == -1)
               {
                  _loc6_ = _loc3_;
               }
            }
            else
            {
               _loc7_ = true;
            }
            _loc3_++;
         }
         if(_isChoosingOceanAnimal)
         {
            _loc2_ = AvatarSwitch.numTotalAvatars;
            if(_loc2_ == _numTotalSlots)
            {
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11219);
               _switchContent.oopsPopup.visible = true;
               onRecycleDown(null);
            }
            else
            {
               if(_loc6_ != -1)
               {
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11220);
               }
               else if(gMainFrame.userInfo.isMember && _loc2_ > 1)
               {
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11222);
               }
               else if(!gMainFrame.userInfo.isMember)
               {
                  if(_loc2_ == 1)
                  {
                     LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11222);
                  }
                  else
                  {
                     LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11219);
                  }
               }
               else
               {
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11222);
               }
               _switchContent.oopsPopup.visible = true;
            }
         }
         if(_isChoosing)
         {
            if(AvatarSwitch.numMemberAvatars == _numTotalSlots || (_loc5_ == 0 || _loc5_ - _loc4_ == 0) && !_loc7_ || !_loc7_ && _loc5_ - _loc4_ < 1)
            {
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11223);
               _switchContent.oopsPopup.visible = true;
               onRecycleDown(null);
            }
            else if(_loc7_ && (_loc5_ - _loc4_ < 1 || _loc5_ == 0))
            {
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11224);
               _switchContent.oopsPopup.visible = true;
            }
         }
         if(gMainFrame.userInfo.isMember)
         {
            if(AvatarSwitch.numAvailAvatars <= 1)
            {
               _loc8_ = true;
            }
         }
         else if(_isChoosing && (_loc5_ > 0 && _loc5_ - _loc4_ != 0 || _loc7_))
         {
            _loc8_ = true;
         }
         else if(_loc5_ < 2 && AvatarSwitch.numMemberAvatars == 0)
         {
            _loc8_ = true;
         }
         if(_loc8_)
         {
            _switchContent.recycleBtn.gray.visible = true;
            _switchContent.recycleBtn.mouse.visible = false;
            _switchContent.recycleBtn.down.visible = false;
         }
         else
         {
            _switchContent.recycleBtn.gray.visible = false;
            _switchContent.recycleBtn.mouse.visible = true;
            _switchContent.recycleBtn.down.visible = true;
         }
         if(gMainFrame.userInfo.isMember)
         {
            _loc1_ = AvatarSwitch.avatars.length >= 1000;
         }
         else if(_isChoosing)
         {
            if(_loc5_ - _loc4_ >= 1)
            {
               _loc1_ = true;
            }
         }
         else
         {
            _loc1_ = _loc5_ >= 2;
         }
         _switchContent.newAmlTag.newAmlBtn.activateGrayState(_loc1_);
         if(!_isChoosing)
         {
            _itemWindows.mediaWindows[_activeIdx].aml.sel.visible = true;
         }
         else
         {
            _closeBtn.visible = false;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function setupAvatarViews(param1:int) : AvatarView
      {
         var _loc2_:Point = null;
         var _loc3_:AvatarView = new AvatarView();
         var _loc4_:Avatar = AvatarSwitch.avatars[param1];
         if(_loc4_)
         {
            _loc4_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc4_.userName).getFullItemList(true),true);
            _loc3_.init(_loc4_);
            _loc3_.playAnim(13,false,1,null);
            _loc2_ = AvatarUtility.getAnimalItemWindowOffset(_loc3_.avTypeId);
            _loc3_.x = _loc2_.x;
            _loc3_.y = _loc2_.y;
         }
         return _loc3_;
      }
      
      public function resetSlots() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numTotalSlots)
         {
            while(_itemWindows.mediaWindows[_loc1_].gray.amlMask.amlBox.numChildren > 0)
            {
               _itemWindows.mediaWindows[_loc1_].gray.amlMask.amlBox.removeChildAt(0);
            }
            while(_itemWindows.mediaWindows[_loc1_].aml.amlMask.amlBox.numChildren > 0)
            {
               _itemWindows.mediaWindows[_loc1_].aml.amlMask.amlBox.removeChildAt(0);
            }
            _loc1_++;
         }
      }
      
      public function addAvatarCallback(param1:int) : void
      {
         if(param1 == 1)
         {
            if(!_isChoosing)
            {
               _myGemCount -= 1000;
               close();
               if(_isChoosingOceanAnimal)
               {
                  if(_joinRoomAfterSwitch)
                  {
                     RoomXtCommManager.sendRoomJoinRequest(RoomXtCommManager._joinRoomName);
                  }
                  else if(_switchDensAfterAdd)
                  {
                     DenSwitch.reTrySwitchDensAfterAddingAvatar();
                  }
               }
            }
            else
            {
               buildWindows();
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11225);
            _switchContent.oopsPopup.visible = true;
         }
      }
      
      public function isChoosingAddCallback(param1:Boolean) : void
      {
         if(param1)
         {
            resetSlots();
            initializePopupStates();
            buildWindows();
         }
      }
      
      public function switchAvatarCallback(param1:Boolean, param2:Boolean = false) : void
      {
         if(param2)
         {
            if(_switchContent && param1)
            {
               _switchContent.root.visible = false;
               return;
            }
         }
         if(param1)
         {
            close();
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11226);
            _switchContent.oopsPopup.visible = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function recycleAvatarCallback(param1:Boolean, param2:int, param3:int, param4:int, param5:Boolean) : void
      {
         var _loc6_:int = 0;
         if(param1)
         {
            _hasDeletedAnAvatar = true;
            _recycling = false;
            _loc6_ = 0;
            while(_loc6_ < _numTotalSlots)
            {
               if(_itemWindows.mediaWindows[_loc6_])
               {
                  _itemWindows.mediaWindows[_loc6_].recycle.visible = false;
               }
               _loc6_++;
            }
            _itemWindows.deleteItem(param2,AvatarSwitch.avatars,false);
            if(AvatarSwitch.numTotalAvatars <= 1)
            {
               _switchContent.recycleBtn.gray.visible = true;
               _switchContent.recycleBtn.mouse.visible = false;
               _switchContent.recycleBtn.down.visible = false;
            }
            _switchContent.newAmlTag.newAmlBtn.activateGrayState(AvatarSwitch.avatars.length >= 1000);
            _switchContent.itemCounter.counterTxt.text = AvatarSwitch.avatars.length + "/" + 1000;
            if(_isChoosing)
            {
               buildWindows();
            }
            _myGemCount = param4;
            UserCurrency.setCurrency(param4,0);
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11227);
            _switchContent.oopsPopup.visible = true;
            _recycling = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         if(param1.status)
         {
            AvatarSwitch.removeAvatar(_idx,recycleAvatarCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc5_:Object = null;
         var _loc6_:Avatar = null;
         var _loc2_:int = 0;
         var _loc7_:AvatarDef = null;
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         var _loc3_:ItemWindowAnimal = ItemWindowAnimal(param1.currentTarget);
         if(_loc3_.makeNew.visible)
         {
            if(!_loc3_.makeNew.newAmlBtn.gray.visible)
            {
               if(_myGemCount >= 1000)
               {
                  SBTracker.push();
                  SBTracker.trackPageview("/game/play/popup/avatarSwitch/chooseAvatar");
               }
               setupNextOpenIndex();
               AvatarSwitch.addAvatar(_idx,false,addAvatarCallback,_isChoosing,_isChoosingOceanAnimal,_switchDensAfterAdd);
            }
            else if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("animalSlots","chooseAvatar");
            }
         }
         else if(_recycling)
         {
            if(_loc3_.recycle.visible)
            {
               if(_idx != _activeIdx || _isChoosing)
               {
                  if(AvatarSwitch.getNumUsableLandAvatars(_isChoosing,gMainFrame.userInfo.isMember) == 1 && AvatarSwitch.isSlotAvailable(_idx) && Utility.isLand(AvatarSwitch.avatars[_idx].enviroTypeFlag))
                  {
                     DarkenManager.darken(_switchContent.oopsPopup);
                     LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11228);
                     _switchContent.oopsPopup.visible = true;
                  }
                  else
                  {
                     _loc4_ = _loc3_.level > 0 ? LocalizationManager.translateIdAndInsertOnly(11229,_loc3_.level) : "";
                     _loc5_ = AvatarUtility.findAvDefByType(AvatarSwitch.avatars[_idx].avTypeId,AvatarSwitch.avatars[_idx].customAvId);
                     if(_loc5_)
                     {
                        new SBYesNoPopup(_guiLayer,_loc4_ + LocalizationManager.translateIdAndInsertOnly(11230,Utility.convertNumberToString(_loc5_.recycleValue)),true,confirmRecycleHandler);
                     }
                  }
               }
               else
               {
                  DarkenManager.darken(_switchContent.oopsPopup);
                  LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11231);
                  _switchContent.oopsPopup.visible = true;
               }
            }
         }
         else if(_loc3_.aml.visible == true || _loc3_.denWindow.visible == true)
         {
            if(_isChoosing)
            {
               if(!AvatarSwitch.isMemberOnlyAvatar(_idx))
               {
                  _loc3_.checkbox.check.visible = !_loc3_.checkbox.check.visible;
                  if(_loc3_.checkbox.check.visible)
                  {
                     if(_avatarsChosen.length < 2)
                     {
                        if(_avatarsChosen.length > 0)
                        {
                           _loc6_ = AvatarSwitch.avatars[_idx];
                           if(!Utility.isLand(_loc6_.enviroTypeFlag) && Utility.isOcean(_loc6_.enviroTypeFlag))
                           {
                              _loc6_ = AvatarSwitch.avatars[_avatarsChosen[0]];
                              if(!Utility.isLand(_loc6_.enviroTypeFlag) && Utility.isOcean(_loc6_.enviroTypeFlag))
                              {
                                 LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11232);
                                 _switchContent.oopsPopup.visible = true;
                                 _loc3_.checkbox.check.visible = !_loc3_.checkbox.check.visible;
                                 return;
                              }
                           }
                        }
                        _avatarsChosen.push(_idx);
                        if(AvatarSwitch.numNonMemberAvatars == 1 || _avatarsChosen.length > 1)
                        {
                           _switchContent.saveAmlTag.visible = true;
                        }
                        else
                        {
                           _switchContent.saveAmlTag.visible = false;
                        }
                     }
                     else
                     {
                        _loc6_ = AvatarSwitch.avatars[_idx];
                        if(!Utility.isLand(_loc6_.enviroTypeFlag) && Utility.isOcean(_loc6_.enviroTypeFlag))
                        {
                           _loc6_ = AvatarSwitch.avatars[_avatarsChosen[1]];
                           if(!Utility.isLand(_loc6_.enviroTypeFlag) && Utility.isOcean(_loc6_.enviroTypeFlag))
                           {
                              LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11232);
                              _switchContent.oopsPopup.visible = true;
                              _loc3_.checkbox.check.visible = !_loc3_.checkbox.check.visible;
                              return;
                           }
                        }
                        _loc2_ = int(_avatarsChosen[0]);
                        _avatarsChosen.shift();
                        _avatarsChosen.push(_idx);
                        _itemWindows.mediaWindows[_loc2_].checkbox.check.visible = false;
                        _itemWindows.mediaWindows[_loc2_].aml.bg.visible = false;
                        _itemWindows.mediaWindows[_loc2_].aml.sel.visible = false;
                     }
                     _loc3_.aml.bg.visible = true;
                     _loc3_.aml.sel.visible = true;
                  }
                  else
                  {
                     _avatarsChosen.splice(_avatarsChosen.indexOf(_idx),1);
                     _switchContent.saveAmlTag.visible = false;
                     _loc3_.aml.bg.visible = false;
                     _loc3_.aml.sel.visible = false;
                  }
               }
            }
            else if(PartyManager.canSwitchToAvatar(AvatarSwitch.avatars[_idx],true))
            {
               if(_idx != _activeIdx)
               {
                  AvatarSwitch.switchAvatars(_idx,switchAvatarCallback);
               }
               else if(_idx == _activeIdx)
               {
                  close();
               }
            }
         }
         else if(_loc3_.lock.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("animalSlots","buyThirdAvatar");
            }
            else
            {
               DebugUtility.debugTrace("WARNING: Slot is locked but user is a member. Why?!");
            }
         }
         else if(_loc3_.gray.visible == true)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               _loc7_ = gMainFrame.userInfo.getAvatarDefByAvatar(AvatarSwitch.avatars[_idx]);
               if(_loc7_)
               {
                  UpsellManager.displayPopup("animalSlots","useLockedAvatar/" + LocalizationManager.translateIdOnly(_loc7_.titleStrRef));
               }
               else
               {
                  UpsellManager.displayPopup("animalSlots","useLockedAvatar");
               }
            }
         }
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(ItemWindowAnimal(param1.currentTarget).aml.currentFrameLabel != "mouse")
         {
            ItemWindowAnimal(param1.currentTarget).aml.gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(ItemWindowAnimal(param1.currentTarget).aml.currentFrameLabel != "out")
         {
            ItemWindowAnimal(param1.currentTarget).aml.gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_switchContent.oopsPopup);
         _switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private function setupNextOpenIndex() : void
      {
         var _loc2_:int = 0;
         var _loc1_:* = -1;
         _loc2_ = 0;
         while(_loc2_ < _numTotalSlots)
         {
            if(!ItemWindowAnimal(_itemWindows.mediaWindows[_loc2_]))
            {
               _loc1_ = _loc2_;
               break;
            }
            if(ItemWindowAnimal(_itemWindows.mediaWindows[_loc2_]).isUsable())
            {
               _loc1_ = _loc2_;
               break;
            }
            _loc2_++;
         }
         _idx = _loc1_;
      }
      
      private function onNewAmlTag(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            setupNextOpenIndex();
            if(_myGemCount >= 1000)
            {
               SBTracker.push();
               SBTracker.trackPageview("/game/play/popup/avatarSwitch/chooseAvatar");
            }
            AvatarSwitch.addAvatar(_idx,false,addAvatarCallback,_isChoosing,_isChoosingOceanAnimal,_switchDensAfterAdd);
         }
      }
      
      private function onRecycleDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_recycling)
         {
            _loc2_ = 0;
            while(_loc2_ < _numTotalSlots)
            {
               if(_itemWindows.mediaWindows[_loc2_])
               {
                  _itemWindows.mediaWindows[_loc2_].recycle.visible = false;
               }
               _loc2_++;
            }
            _recycling = false;
         }
         else if(!_switchContent.recycleBtn.gray.visible)
         {
            _recycling = true;
            _loc3_ = 0;
            while(_loc3_ < _numTotalSlots)
            {
               if(AvatarSwitch.avatars[_loc3_] && _itemWindows.mediaWindows[_loc3_])
               {
                  _itemWindows.mediaWindows[_loc3_].recycle.visible = true;
               }
               _loc3_++;
            }
         }
         else
         {
            _switchContent.recycleBtn.mouse.visible = false;
         }
      }
      
      private function onRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14626),25,490);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSaveAnimalsDown(param1:MouseEvent) : void
      {
         var _loc2_:AvatarView = null;
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/avatarConfirm");
         if(_avatarsChosen.length > 1)
         {
            while(_choosingContent.amlsPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               _choosingContent.amlsPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = setupAvatarViews(_avatarsChosen[0]);
            _choosingContent.amlsPopup._slot0.amlMask.amlBox.addChild(_loc2_);
            _choosingContent.amlsPopup._slot0.nameTxt.text = _loc2_.avName;
            while(_choosingContent.amlsPopup._slot1.amlMask.amlBox.numChildren > 0)
            {
               _choosingContent.amlsPopup._slot1.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = setupAvatarViews(_avatarsChosen[1]);
            _choosingContent.amlsPopup._slot1.amlMask.amlBox.addChild(_loc2_);
            _choosingContent.amlsPopup._slot1.nameTxt.text = _loc2_.avName;
            DarkenManager.darken(_choosingContent.amlsPopup);
            if(_currSoundChannel)
            {
               _currSoundChannel.stop();
               _currSoundChannel = _currSound.play();
            }
            else
            {
               _currSoundChannel = _currSound.play();
            }
            _choosingContent.amlsPopup.visible = true;
            _choosingContent.amlsPopup.parent.setChildIndex(_choosingContent.amlsPopup,_choosingContent.amlsPopup.parent.numChildren - 1);
         }
         else
         {
            while(_choosingContent.oneAmlPopup._slot0.amlMask.amlBox.numChildren > 0)
            {
               _choosingContent.oneAmlPopup._slot0.amlMask.amlBox.removeChildAt(0);
            }
            _loc2_ = setupAvatarViews(_avatarsChosen[0]);
            _choosingContent.oneAmlPopup._slot0.amlMask.amlBox.addChild(_loc2_);
            _choosingContent.oneAmlPopup._slot0.nameTxt.text = _loc2_.avName;
            DarkenManager.darken(_choosingContent.oneAmlPopup);
            _choosingContent.oneAmlPopup.soundBtn.visible = false;
            _choosingContent.oneAmlPopup.visible = true;
            _choosingContent.oneAmlPopup.parent.setChildIndex(_choosingContent.oneAmlPopup,_choosingContent.oneAmlPopup.parent.numChildren - 1);
         }
      }
      
      private function onChooseOkNoDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         SBTracker.pop();
         param1.stopPropagation();
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
         }
         DarkenManager.unDarken(param1.currentTarget.parent);
         param1.currentTarget.parent.visible = false;
         if(param1.currentTarget == _choosingContent.amlsPopup.okBtn || param1.currentTarget == _choosingContent.oneAmlPopup.okBtn)
         {
            if(_avatarsChosen.length == 1)
            {
               checkForAdditionalSpots();
            }
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = int(AvatarSwitch.orderingOfAvatars[AvatarSwitch.avatars[_avatarsChosen[0]].avInvId] != null ? AvatarSwitch.orderingOfAvatars[AvatarSwitch.avatars[_avatarsChosen[0]].avInvId] : -1);
            if(AvatarSwitch.activeAvatarIdx != _loc2_)
            {
               AvatarSwitch.setAvatarSwitchCallback(onSwitchComplete);
            }
            AvatarSwitch.chooseTwo(_avatarsChosen,onChooseCallback);
         }
      }
      
      private function onChooseCallback(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _loc2_ = AvatarSwitch.avatars;
            AvatarSwitch.availSlotFlags = 0;
            if(_avatarsChosen.length > 1 && _loc2_[_avatarsChosen[1]])
            {
               AvatarSwitch.adjustAvailSlotFlags(_loc2_[_avatarsChosen[0]].avInvId,true);
               AvatarSwitch.adjustAvailSlotFlags(_loc2_[_avatarsChosen[1]].avInvId,true);
            }
            else
            {
               AvatarSwitch.adjustAvailSlotFlags(_loc2_[_avatarsChosen[0]].avInvId,true);
            }
            close();
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11233);
            _switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onSwitchComplete(param1:Boolean, param2:Boolean = false) : void
      {
         if(!param1)
         {
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11233);
            _switchContent.oopsPopup.visible = true;
         }
      }
      
      private function onChooseSoundBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = _currSound.play();
         }
         else
         {
            _currSoundChannel = _currSound.play();
         }
      }
      
      private function checkForAdditionalSpots() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numTotalSlots)
         {
            if(_avatarsChosen[0] != _loc1_)
            {
               if(AvatarSwitch.avatars[_loc1_] == null)
               {
                  _avatarsChosen.push(_loc1_);
                  break;
               }
               if(!AvatarSwitch.isMemberOnlyAvatar(_loc1_))
               {
                  _avatarsChosen.push(_loc1_);
                  break;
               }
            }
            _loc1_++;
         }
      }
      
      private function addListeners() : void
      {
         if(_closeBtn)
         {
            _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         }
         if(_switchContent)
         {
            _hasAddedListeners = true;
            _switchContent.recycleBtn.addEventListener("mouseDown",onRecycleDown,false,0,true);
            _switchContent.recycleBtn.addEventListener("mouseOver",onRecycleOver,false,0,true);
            _switchContent.recycleBtn.addEventListener("mouseOut",onRecycleOut,false,0,true);
            _switchContent.oopsPopup.closeBtn.addEventListener("mouseDown",onOopsClose,false,0,true);
            _switchContent.newAmlTag.newAmlBtn.addEventListener("mouseDown",onNewAmlTag,false,0,true);
            if(_isChoosing && _choosingContent)
            {
               _switchContent.saveAmlTag.saveAmlBtn.addEventListener("mouseDown",onSaveAnimalsDown,false,0,true);
               _choosingContent.amlsPopup.okBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.amlsPopup.noBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.oneAmlPopup.okBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.oneAmlPopup.noBtn.addEventListener("mouseDown",onChooseOkNoDown,false,0,true);
               _choosingContent.amlsPopup.soundBtn.addEventListener("mouseDown",onChooseSoundBtn,false,0,true);
            }
         }
      }
      
      private function removeListeners() : void
      {
         if(_closeBtn)
         {
            _closeBtn.removeEventListener("mouseDown",onClose);
         }
         if(_switchContent)
         {
            _switchContent.recycleBtn.removeEventListener("mouseDown",onRecycleDown);
            _switchContent.recycleBtn.removeEventListener("mouseOver",onRecycleOver);
            _switchContent.recycleBtn.removeEventListener("mouseOut",onRecycleOut);
            _switchContent.oopsPopup.closeBtn.removeEventListener("mouseDown",onOopsClose);
            _switchContent.newAmlTag.newAmlBtn.removeEventListener("mouseDown",onNewAmlTag);
            if(_isChoosing)
            {
               _switchContent.saveAmlTag.saveAmlBtn.removeEventListener("mouseDown",onSaveAnimalsDown);
               _choosingContent.amlsPopup.okBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.amlsPopup.noBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.oneAmlPopup.okBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.oneAmlPopup.noBtn.removeEventListener("mouseDown",onChooseOkNoDown);
               _choosingContent.amlsPopup.soundBtn.removeEventListener("mouseDown",onChooseSoundBtn);
            }
         }
      }
   }
}

