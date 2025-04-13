package gui
{
   import avatar.Avatar;
   import avatar.AvatarEditorView;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.graphics.JPEGAsyncCompleteEvent;
   import com.sbi.graphics.JpegAsynchEncoder;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class PhotoBooth
   {
      private static var _nameSaveIndex:int = 1;
      
      private const IMAGE_WIDTH:int = 626;
      
      private const IMAGE_HEIGHT:int = 470;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currAvtView:AvatarEditorView;
      
      private var _booth:MovieClip;
      
      private var _myPet:GuiPet;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _numBackgroundFrames:int;
      
      private var _currBackgroundFrame:int;
      
      private var _jpgEncoder:JpegAsynchEncoder;
      
      private var _hudAvtView:AvatarView;
      
      private var _startingFrame:int;
      
      private var _petPosIndex:int;
      
      private var _debugAvtIndex:int;
      
      private var _loadingSpiralAvt:LoadingSpiral;
      
      private var _flip:Boolean;
      
      private var _forPlayerWallImage:Boolean;
      
      public function PhotoBooth()
      {
         super();
      }
      
      public function init(param1:Function = null, param2:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _forPlayerWallImage = param2;
         _guiLayer = GuiManager.guiLayer;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2017,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/exit");
         KeepAlive.stopKATimer(_booth);
         SafeChatManager.destroy(_booth.chatTree);
         removeEventListeners();
         DarkenManager.unDarken(_booth);
         _guiLayer.removeChild(_booth);
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            SBTracker.trackPageview("/game/play/popup/photobooth/enter");
            _booth = MovieClip(param1.getChildAt(0));
            KeepAlive.startKATimer(_booth);
            initializeNeededItems();
            positionAndDrawAvatarView(true);
            showHudAvt();
            loadPetView();
            addEventListeners();
            _booth.x = 900 * 0.5;
            _booth.y = 550 * 0.5;
            DarkenManager.showLoadingSpiral(false);
            _guiLayer.addChild(_booth);
            DarkenManager.darken(_booth);
         }
      }
      
      private function initializeNeededItems() : void
      {
         _numBackgroundFrames = _booth.imageCont.backgroundCont.totalFrames;
         _currBackgroundFrame = 1;
         _petPosIndex = -1;
         _booth.imageCont.msgTxt.filters = [new GlowFilter(16777215)];
         _booth.imageCont.petLShadow.visible = false;
         _booth.imageCont.petRShadow.visible = false;
         _booth.posBtn.activateGrayState(true);
         _booth.avtBtn.visible = false;
         _booth.textBtn.currTxt.text = "";
         _booth.imageCont.msgTxt.text = "";
         SafeChatManager.buildSafeChatTree(_booth.chatTree,"ECardTextTreeNode",3,onTextClose,null,onChatTreeLoaded);
         SafeChatManager.closeSafeChat(_booth.chatTree);
         _booth.imageCont.chatBalloon.visible = false;
         _booth.imageCont.chatBalloon.closeChatBtn.visible = false;
         _booth.bubbleLockToggle.toggleBtn.gotoAndStop("startingOff");
         _booth.bubbleLockToggle.toggleBtn.toggleKnob.gotoAndStop("up");
         _booth.bubbleLockToggle.toggleBtn.toggleBG.gotoAndStop("up");
         _loadingSpiralAvt = new LoadingSpiral(_booth.imageCont.charBox);
      }
      
      private function onChatTreeLoaded() : void
      {
         _booth.textBtn.currTxt.text = SafeChatManager.photoBoothNodes[0];
         _booth.imageCont.msgTxt.text = SafeChatManager.photoBoothNodes[0];
      }
      
      private function positionAndDrawAvatarView(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(_currAvtView)
            {
               _startingFrame = _currAvtView.frame;
               if(_currAvtView.parent)
               {
                  _booth.imageCont.charBox.removeChild(_currAvtView);
               }
            }
            _loadingSpiralAvt.setNewParent(_booth.imageCont.charBox);
            _loadingSpiralAvt.visible = true;
            _currAvtView = new AvatarEditorView();
            _currAvtView.init(AvatarManager.playerAvatar);
         }
         var _loc2_:Point = AvatarUtility.getAvatarPhotoOffset(_currAvtView.avTypeId);
         _currAvtView.x = _loc2_.x;
         _currAvtView.y = _loc2_.y;
         _currAvtView.visible = false;
         _currAvtView.playAnim(42,false,0,onAvatarLoaded);
         _currAvtView.scaleX = 626 / 1024;
         _currAvtView.scaleY = 470 / 768;
         _booth.imageCont.charBox.addChild(_currAvtView);
      }
      
      private function loadPetView() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc1_:Array = PetManager.myPetList;
         _myPet = null;
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_[_loc2_].idx == PetManager.myActivePetInvId)
            {
               _loc3_ = _loc1_[_loc2_];
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc3_.currPetDef,_loc3_.createdTs))
               {
                  _booth.posBtn.activateGrayState(false);
                  _myPet = new GuiPet(_loc3_.createdTs,_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,_loc3_.personalityDefId,_loc3_.favoriteToyDefId,_loc3_.favoriteFoodDefId,onPetLoaded);
               }
               break;
            }
            _loc2_++;
         }
         if(_myPet == null)
         {
            _booth.posBtn.activateGrayState(true);
            while(_booth.imageCont.itemWindowPet2R.numChildren > 0)
            {
               _booth.imageCont.itemWindowPet2R.removeChildAt(0);
            }
            while(_booth.imageCont.itemWindowPet1R.numChildren > 0)
            {
               _booth.imageCont.itemWindowPet1R.removeChildAt(0);
            }
            while(_booth.imageCont.itemWindowPet2L.numChildren > 0)
            {
               _booth.imageCont.itemWindowPet2L.removeChildAt(0);
            }
            while(_booth.imageCont.itemWindowPet1L.numChildren > 0)
            {
               _booth.imageCont.itemWindowPet1L.removeChildAt(0);
            }
         }
      }
      
      private function addEventListeners() : void
      {
         with(_booth)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
            leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn,false,0,true);
            rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn,false,0,true);
            actionPose.addEventListener(MouseEvent.MOUSE_DOWN,onActionPoseBtn,false,0,true);
            actionPose.addEventListener(MouseEvent.ROLL_OVER,onActionPoseOverHandler,false,0,true);
            actionPose.addEventListener(MouseEvent.ROLL_OUT,onOutHandler,false,0,true);
            posBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPetPosBtn,false,0,true);
            posBtn.addEventListener(MouseEvent.ROLL_OVER,onPetPosOverHandler,false,0,true);
            posBtn.addEventListener(MouseEvent.ROLL_OUT,onOutHandler,false,0,true);
            addTextBtn.addEventListener(MouseEvent.MOUSE_DOWN,onTextBtn,false,0,true);
            camBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSaveBtn,false,0,true);
            camBtn.addEventListener(MouseEvent.ROLL_OVER,onSaveOverHandler,false,0,true);
            camBtn.addEventListener(MouseEvent.ROLL_OUT,onOutHandler,false,0,true);
            char.addEventListener(MouseEvent.MOUSE_DOWN,onCustomize,false,0,true);
            char.addEventListener(MouseEvent.ROLL_OVER,charWindowOverHandler,false,0,true);
            char.addEventListener(MouseEvent.ROLL_OUT,charWindowOutHandler,false,0,true);
            bubbleLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,onToggleBtn,false,0,true);
            bubbleLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,onToggleOver,false,0,true);
            bubbleLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,onToggleOut,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         with(_booth)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
            leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn);
            rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onLeftRightBtn);
            actionPose.removeEventListener(MouseEvent.MOUSE_DOWN,onActionPoseBtn);
            actionPose.removeEventListener(MouseEvent.ROLL_OVER,onActionPoseOverHandler);
            actionPose.removeEventListener(MouseEvent.ROLL_OUT,onOutHandler);
            posBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onPetPosBtn);
            posBtn.removeEventListener(MouseEvent.ROLL_OVER,onPetPosOverHandler);
            posBtn.removeEventListener(MouseEvent.ROLL_OUT,onOutHandler);
            addTextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onTextBtn);
            camBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSaveBtn);
            camBtn.removeEventListener(MouseEvent.ROLL_OVER,onSaveOverHandler);
            camBtn.removeEventListener(MouseEvent.ROLL_OUT,onOutHandler);
            char.removeEventListener(MouseEvent.MOUSE_DOWN,onCustomize);
            bubbleLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onToggleBtn);
            bubbleLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,onToggleOver);
            bubbleLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,onToggleOut);
         }
      }
      
      private function onTextClose(param1:String, param2:String) : void
      {
         _booth.textBtn.currTxt.text = param1;
         _booth.imageCont.msgTxt.text = param1;
         setTextVisibility();
         SafeChatManager.closeSafeChat(_booth.chatTree);
      }
      
      private function completeSaveAction() : void
      {
         DarkenManager.showLoadingSpiral(true,true);
         var _loc1_:BitmapData = new BitmapData(1024,768);
         var _loc2_:Matrix = new Matrix(1024 / 626,0,0,768 / 470,0,0);
         _loc1_.draw(_booth.imageCont,_loc2_,null,null,null,true);
         _jpgEncoder = new JpegAsynchEncoder();
         _jpgEncoder.addEventListener("JPEGAsyncComplete",asyncEncodingComplete,false,0,true);
         _jpgEncoder.addEventListener("progress",onEncodingProgress,false,0,true);
         _jpgEncoder.PixelsPerIteration = 128;
         _jpgEncoder.JPEGAsyncEncoder(100);
         _jpgEncoder.encode(_loc1_);
      }
      
      private function showHudAvt() : void
      {
         var _loc2_:Avatar = AvatarManager.playerAvatar;
         if(_hudAvtView)
         {
            if(_hudAvtView.parent == _booth.char.charLayer)
            {
               _booth.char.charLayer.removeChild(_hudAvtView);
            }
            _hudAvtView.destroy();
         }
         _hudAvtView = new AvatarView();
         _hudAvtView.init(_loc2_,null,onHudViewChanged);
         _hudAvtView.playAnim(15,false,1,null,true);
         var _loc1_:Point = AvatarUtility.getAvatarHudPosition(_hudAvtView.avTypeId);
         _hudAvtView.x = _loc1_.x;
         _hudAvtView.y = _loc1_.y;
         _booth.char.charLayer.addChild(_hudAvtView);
      }
      
      private function onHudViewChanged(param1:AvatarView) : void
      {
         if(_hudAvtView)
         {
            _hudAvtView.playAnim(15,false,1,null,true);
         }
      }
      
      private function setTextVisibility() : void
      {
         if(_booth.bubbleLockToggle.toggleBtn.currentFrameLabel == "on" || _booth.bubbleLockToggle.toggleBtn.currentFrameLabel == "startingOn")
         {
            _booth.imageCont.msgTxt.visible = false;
         }
         else
         {
            _booth.imageCont.msgTxt.visible = true;
         }
      }
      
      private function addPetToCorrectSpot(param1:int, param2:Boolean = false) : void
      {
         var _loc4_:Matrix = null;
         if(param1 > 3)
         {
            param1 = 0;
         }
         var _loc3_:* = param1;
         if(param2)
         {
            if(param1 % 2 != 0)
            {
               _loc3_ = param1 - 1;
            }
         }
         switch(_loc3_)
         {
            case 0:
               while(_booth.imageCont.itemWindowPet2R.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet2R.removeChildAt(0);
               }
               while(_booth.imageCont.itemWindowPet1R.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet1R.removeChildAt(0);
               }
               while(_booth.imageCont.itemWindowPet2L.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet2L.removeChildAt(0);
               }
               while(_booth.imageCont.itemWindowPet1L.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet1L.removeChildAt(0);
               }
               if(_myPet.isGround())
               {
                  _booth.imageCont.itemWindowPet2L.addChild(_myPet);
               }
               else
               {
                  _booth.imageCont.itemWindowPet1L.addChild(_myPet);
               }
               if(_loc3_ != param1)
               {
               }
               break;
            case 1:
               _loc4_ = _myPet.transform.matrix;
               _loc4_.scale(-1,1);
               _myPet.transform.matrix = _loc4_;
               break;
            case 2:
               while(_booth.imageCont.itemWindowPet2L.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet2L.removeChildAt(0);
               }
               while(_booth.imageCont.itemWindowPet1L.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet1L.removeChildAt(0);
               }
               while(_booth.imageCont.itemWindowPet2R.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet2R.removeChildAt(0);
               }
               while(_booth.imageCont.itemWindowPet1R.numChildren > 0)
               {
                  _booth.imageCont.itemWindowPet1R.removeChildAt(0);
               }
               if(_myPet.isGround())
               {
                  _booth.imageCont.itemWindowPet2R.addChild(_myPet);
               }
               else
               {
                  _booth.imageCont.itemWindowPet1R.addChild(_myPet);
               }
               if(_loc3_ != param1)
               {
               }
               break;
            case 3:
               _loc4_ = _myPet.transform.matrix;
               _loc4_.scale(-1,1);
               _myPet.transform.matrix = _loc4_;
         }
         _petPosIndex = param1;
      }
      
      private function loadDebugAvatar(param1:Avatar) : void
      {
         if(_currAvtView)
         {
            _startingFrame = _currAvtView.frame;
            if(_currAvtView.parent)
            {
               _booth.imageCont.charBox.removeChild(_currAvtView);
            }
         }
         _loadingSpiralAvt.setNewParent(_booth.imageCont.charBox);
         _loadingSpiralAvt.visible = true;
         _currAvtView = new AvatarEditorView();
         _currAvtView.init(param1);
         var _loc2_:Point = AvatarUtility.getAvatarPhotoOffset(_currAvtView.avTypeId);
         _currAvtView.x = _loc2_.x;
         _currAvtView.y = _loc2_.y;
         _currAvtView.visible = false;
         _currAvtView.playAnim(42,false,0,onAvatarLoaded);
         _currAvtView.scaleX = 626 / 1024;
         _currAvtView.scaleY = 470 / 768;
         _booth.imageCont.charBox.addChild(_currAvtView);
      }
      
      private function onAvatarLoaded(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Matrix = null;
         _currAvtView.visible = true;
         _currAvtView.pauseAnim(true);
         _currAvtView.frame = _startingFrame;
         _loadingSpiralAvt.visible = false;
         if(_flip)
         {
            _loc3_ = _currAvtView.transform.matrix;
            _loc3_.scale(-1,1);
            _currAvtView.transform.matrix = _loc3_;
         }
         else if(_booth.imageCont.avtShadow.scaleX < 0)
         {
            _booth.imageCont.avtShadow.scaleX *= -1;
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc3_:Matrix = null;
         _myPet.scaleY = 2;
         _myPet.scaleX = 2;
         if(_petPosIndex < 2)
         {
            _loc3_ = _myPet.transform.matrix;
            _loc3_.scale(-1,1);
            _myPet.transform.matrix = _loc3_;
         }
         addPetToCorrectSpot(_petPosIndex == -1 ? 0 : _petPosIndex,true);
      }
      
      private function onAvatarEditorClose() : void
      {
         positionAndDrawAvatarView(true);
         showHudAvt();
         loadPetView();
      }
      
      private function flashComplete() : void
      {
         completeSaveAction();
      }
      
      private function onSaveImage(param1:Object) : void
      {
         if(param1.status)
         {
            SBTracker.trackPageview("/game/play/popup/photobooth/imageSaved");
            DarkenManager.showLoadingSpiral(true);
            AvatarXtCommManager.sendAvatarPhotoTake(onPhotoGemsSpent);
            _nameSaveIndex++;
         }
      }
      
      private function onPhotoGemsSpent(param1:Object) : void
      {
         UserCurrency.setCurrency(int(param1[2]),0);
         DarkenManager.showLoadingSpiral(false);
         AJAudio.playShopCachingSound();
      }
      
      private function onSaveForGems(param1:Object) : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/saveForGems");
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            AvatarXtCommManager.sendAvatarPhotoTakeCheck(onGemsSpent);
         }
      }
      
      private function onGemsSpent(param1:Object) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1[2] >= 0)
         {
            _booth.flash.playFlash(flashComplete);
         }
         else
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14788));
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
         else
         {
            destroy();
         }
      }
      
      private function onLeftRightBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/leftRight");
         if(param1.currentTarget.name == "leftBtn")
         {
            if(_currBackgroundFrame - 1 < 1)
            {
               _currBackgroundFrame = _numBackgroundFrames;
            }
            else
            {
               _currBackgroundFrame--;
            }
         }
         else if(param1.currentTarget.name == "rightBtn")
         {
            if(_currBackgroundFrame + 1 > _numBackgroundFrames)
            {
               _currBackgroundFrame = 1;
            }
            else
            {
               _currBackgroundFrame++;
            }
         }
         if(_booth.imageCont.backgroundCont.currentLabels[_currBackgroundFrame - 1].name.indexOf("ocean") >= 0)
         {
            if(!Utility.isOcean(AvatarManager.playerAvatar.enviroTypeFlag))
            {
               onLeftRightBtn(param1);
               return;
            }
         }
         else if(!Utility.isLand(AvatarManager.playerAvatar.enviroTypeFlag))
         {
            onLeftRightBtn(param1);
            return;
         }
         _booth.imageCont.backgroundCont.gotoAndStop(_currBackgroundFrame);
      }
      
      private function onActionPoseBtn(param1:MouseEvent) : void
      {
         var _loc2_:Matrix = null;
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/poseBtn");
         if(_currAvtView)
         {
            _loc2_ = _currAvtView.transform.matrix;
            _loc2_.scale(-1,1);
            _currAvtView.transform.matrix = _loc2_;
            _flip = !_flip;
            _booth.imageCont.avtShadow.scaleX *= -1;
         }
      }
      
      private function onActionPoseOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14675),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 27);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPetPosBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         KeepAlive.inputReceivedHandler(null);
         SBTracker.trackPageview("/game/play/popup/photobooth/petPose");
         if(_myPet)
         {
            addPetToCorrectSpot(_petPosIndex + 1);
         }
      }
      
      private function onPetPosOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14676),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 27);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onTextBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_booth.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,_booth.chatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(_booth.chatTree);
         }
      }
      
      private function onSaveBtn(param1:MouseEvent) : void
      {
         SBTracker.trackPageview("/game/play/popup/photobooth/save");
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         KeepAlive.inputReceivedHandler(null);
         if(_forPlayerWallImage)
         {
            if(_closeCallback != null)
            {
               _closeCallback(_flip ? 1 : 0,_petPosIndex,_currBackgroundFrame);
            }
         }
         else
         {
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14789,50),true,onSaveForGems);
         }
      }
      
      private function onSaveOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14677),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 41);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onEncodingProgress(param1:ProgressEvent) : void
      {
         DarkenManager.updateLoadingSpiralPercentage(Math.round(param1.bytesLoaded / param1.bytesTotal * 100) + "%");
      }
      
      private function asyncEncodingComplete(param1:JPEGAsyncCompleteEvent) : void
      {
         _jpgEncoder.removeEventListener("JPEGAsyncComplete",asyncEncodingComplete);
         _jpgEncoder.removeEventListener("progress",onEncodingProgress);
         DarkenManager.showLoadingSpiral(false);
         new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14790),true,onSaveImage,{
            "FileReference":true,
            "ImageData":_jpgEncoder.ImageData,
            "SaveName":"AnimalJam_" + _nameSaveIndex + ".jpg"
         });
      }
      
      private function onCustomize(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openAvatarEditor(onAvatarEditorClose);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function charWindowOverHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14673),param1.currentTarget.x + param1.currentTarget.parent.x,param1.currentTarget.y + param1.currentTarget.parent.y - 55);
         GuiManager.toolTip.startTimer(param1);
         param1.currentTarget.gotoAndStop("over");
         AJAudio.playHudBtnRollover();
      }
      
      private function charWindowOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         param1.currentTarget.gotoAndStop("up");
      }
      
      private function onChatBalloonOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _booth.imageCont.chatBalloon.closeChatBtn.visible = true;
      }
      
      private function onChatBalloonOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _booth.imageCont.chatBalloon.closeChatBtn.visible = false;
      }
      
      private function onCloseBalloon(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _booth.imageCont.chatBalloon.visible = false;
      }
      
      private function onToggleBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/photobooth/toggleText");
         if(param1.currentTarget.currentFrameLabel == "on" || param1.currentTarget.currentFrameLabel == "startingOn")
         {
            param1.currentTarget.gotoAndPlay("off");
            _booth.imageCont.msgTxt.visible = true;
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
            _booth.imageCont.msgTxt.visible = false;
         }
      }
      
      private function onToggleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onToggleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
   }
}

