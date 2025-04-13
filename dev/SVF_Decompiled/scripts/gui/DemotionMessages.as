package gui
{
   import avatar.AvatarSwitch;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DemotionMessages
   {
      private var _demotionMessage:MediaHelper;
      
      private var _newMemberPopup:MovieClip;
      
      private var _content:MovieClip;
      
      private var _idx:int;
      
      private var _gaIdx:int;
      
      private var _choose:SwitchManager;
      
      private var _currSound:Sound;
      
      private var _currSoundChannel:SoundChannel;
      
      private var _closeCallBack:Function;
      
      private var _roomVolume:Number;
      
      private var _hasChosen:Boolean;
      
      private var _wasMusicMuted:Boolean;
      
      private var _startingIndex:int;
      
      public function DemotionMessages()
      {
         super();
      }
      
      public function init(param1:Function = null) : void
      {
         _demotionMessage = new MediaHelper();
         _demotionMessage.init(156,demotionCallback);
         _closeCallBack = param1;
      }
      
      public function destroy() : void
      {
         removeListeners();
         DarkenManager.unDarken(_newMemberPopup);
         if(_demotionMessage)
         {
            _demotionMessage.destroy();
         }
         _newMemberPopup.visible = false;
         _newMemberPopup = null;
         _content.visible = false;
         _content = null;
         if(_closeCallBack != null)
         {
            _closeCallBack();
         }
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = null;
         }
         _closeCallBack = null;
      }
      
      public function goToNextPage() : void
      {
         nextBtnHandler(null);
      }
      
      public function set hasChosen(param1:Boolean) : void
      {
         _hasChosen = param1;
      }
      
      private function demotionCallback(param1:MovieClip) : void
      {
         _newMemberPopup = MovieClip(param1.getChildAt(0));
         _newMemberPopup.x = 900 * 0.5;
         _newMemberPopup.y = 550 * 0.5;
         _newMemberPopup.addEventListener("mouseDown",demotionMouseDownHandler,false,0,true);
         GuiManager.guiLayer.addChild(_newMemberPopup);
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_newMemberPopup);
         _content = _newMemberPopup.c;
         _content.soundBtn.addEventListener("mouseDown",soundBtnHandler,false,0,true);
         _content.chooseBtn.addEventListener("mouseDown",chooseBtnHandler,false,0,true);
         _content.renewBtn.addEventListener("mouseDown",joinBtnHandler,false,0,true);
         _content.nextBtn.addEventListener("mouseDown",nextBtnHandler,false,0,true);
         _content.noThanksBtn.addEventListener("mouseDown",demotionCloseHandler,false,0,true);
         _content.chooseBtn.visible = false;
         _content.noThanksBtn.visible = false;
         switch(LocalizationManager.currentLanguage)
         {
            case LocalizationManager.LANG_ENG:
               _startingIndex = 67;
               break;
            case LocalizationManager.LANG_SPA:
               _startingIndex = 675;
               break;
            case LocalizationManager.LANG_POR:
               _startingIndex = 630;
               break;
            case LocalizationManager.LANG_FRE:
               _startingIndex = 625;
               break;
            case LocalizationManager.LANG_DE:
               _startingIndex = 620;
               break;
            default:
               _startingIndex = 67;
         }
         _idx = 1;
         _gaIdx = 2;
         _currSound = new Sound();
         _currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (_startingIndex + _idx) + ".mp3"));
         playSoundCallback();
      }
      
      private function playSoundCallback() : void
      {
         _wasMusicMuted = SBAudio.isMusicMuted;
         if(!_wasMusicMuted)
         {
            SBAudio.muteMusic();
         }
         _currSoundChannel = _currSound.play();
      }
      
      private function nextBtnHandler(param1:MouseEvent) : void
      {
         var _loc9_:Array = null;
         var _loc4_:Array = null;
         var _loc3_:* = 0;
         var _loc2_:* = 0;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/#page" + _gaIdx);
         var _loc8_:Boolean = AvatarSwitch.shouldChoose();
         _gaIdx++;
         _idx++;
         if(!_hasChosen && !_loc8_ && _idx > 2)
         {
            _idx++;
            _loc9_ = AvatarSwitch.avatars;
            _loc4_ = [];
            _loc7_ = AvatarSwitch.numNonMemberAvatars;
            _loc5_ = 0;
            while(_loc5_ < _loc9_.length)
            {
               if(_loc9_[_loc5_])
               {
                  if(!AvatarSwitch.isMemberOnlyAvatar(_loc5_))
                  {
                     _loc6_ = true;
                  }
               }
               else if(_loc5_ >= _loc7_ - 1)
               {
                  _loc6_ = true;
               }
               if(_loc6_)
               {
                  _loc6_ = false;
                  if(_loc4_[0] == null && _loc9_[_loc5_])
                  {
                     _loc4_[0] = _loc3_ = _loc5_;
                  }
                  else
                  {
                     _loc4_[1] = _loc2_ = _loc5_;
                  }
                  if(_loc4_[0] != null && _loc4_[1] != null)
                  {
                     break;
                  }
               }
               _loc5_++;
            }
            if(_loc4_[1] != null && _loc9_[_loc2_])
            {
               AvatarSwitch.adjustAvailSlotFlags(_loc9_[_loc3_].avInvId,true);
               AvatarSwitch.adjustAvailSlotFlags(_loc9_[_loc2_].avInvId,true);
            }
            else
            {
               AvatarSwitch.adjustAvailSlotFlags(_loc9_[_loc3_].avInvId,true);
            }
            DarkenManager.showLoadingSpiral(true);
            _content.nextBtn.visible = false;
            AvatarSwitch.chooseTwo(_loc4_,onAvatarChooseCallback);
            return;
         }
         if(_idx == 3)
         {
            _content.renewBtn.visible = false;
            _content.nextBtn.visible = false;
            _content.chooseBtn.visible = true;
         }
         if(_idx == 4 && _loc8_)
         {
            _content.chooseBtn.visible = false;
            _content.nextBtn.visible = false;
            _content.noThanksBtn.visible = true;
         }
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
         }
         _currSound = new Sound();
         _currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (_startingIndex + _idx) + ".mp3"));
         _currSoundChannel = _currSound.play();
         _content.gotoAndStop("p" + _idx);
      }
      
      private function onAvatarChooseCallback(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
         }
         if(param1)
         {
            _content.chooseBtn.visible = false;
            _content.nextBtn.visible = false;
            _content.noThanksBtn.visible = true;
            _currSound = new Sound();
            _currSound.load(LoaderCache.fetchCDNURLRequest("streams/" + (_startingIndex + _idx) + ".mp3"));
            _currSoundChannel = _currSound.play();
            _content.gotoAndStop("p" + _idx);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(11233));
            _content.nextBtn.removeEventListener("mouseDown",nextBtnHandler);
            _content.nextBtn.visible = true;
         }
      }
      
      private function joinBtnHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/renew");
         param1.stopPropagation();
         var _loc3_:String = gMainFrame.clientInfo.websiteURL + "membership";
         var _loc2_:URLRequest = new URLRequest(_loc3_);
         try
         {
            navigateToURL(_loc2_,"_blank");
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error with loading URL");
         }
      }
      
      private function chooseBtnHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/avatarChoose");
         param1.stopPropagation();
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
         }
         GuiManager.openAvatarChoose();
         _content.chooseBtn.visible = false;
         _content.renewBtn.visible = true;
         _content.noThanksBtn.visible = true;
      }
      
      private function soundBtnHandler(param1:MouseEvent) : void
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
      
      private function demotionMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function demotionCloseHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/demotion/page4_noThanks");
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = _currSound.play();
         }
         else
         {
            _currSoundChannel = _currSound.play();
         }
         if(!_wasMusicMuted)
         {
            SBAudio.unmuteMusic();
         }
         param1.stopPropagation();
         destroy();
      }
      
      private function removeListeners() : void
      {
         _content.chooseBtn.removeEventListener("mouseDown",chooseBtnHandler);
         _content.renewBtn.removeEventListener("mouseDown",joinBtnHandler);
         _content.nextBtn.removeEventListener("mouseDown",nextBtnHandler);
         _content.noThanksBtn.removeEventListener("mouseDown",demotionCloseHandler);
         _newMemberPopup.removeEventListener("mouseDown",demotionMouseDownHandler);
      }
   }
}

