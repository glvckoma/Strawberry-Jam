package trade
{
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.loader.LoaderCache;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import flash.utils.Timer;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class TutorialPopups
   {
      private static var _tutorialMediaHelper:MediaHelper;
      
      private static var _talkingTutorialPopup:MovieClip;
      
      private static var _tutorialTextPopup:MovieClip;
      
      private static var _talkingLoadingSpiral:LoadingSpiral;
      
      private static var _talkingTutorialTimer:Timer;
      
      private static var _soundIds:Array;
      
      public function TutorialPopups()
      {
         super();
      }
      
      public static function openTutorialTextPopup(param1:int, param2:int, param3:int) : void
      {
         if(_tutorialTextPopup)
         {
            _tutorialTextPopup.x = param2;
            _tutorialTextPopup.y = param3;
            _tutorialTextPopup.message_txt.text = LocalizationManager.translateIdOnly(param1);
            _tutorialTextPopup.balloon_bg.m.height = Math.floor(_tutorialTextPopup.message_txt.height + 10);
            _tutorialTextPopup.balloon_bg.b.y = Math.round(_tutorialTextPopup.balloon_bg.m.y + _tutorialTextPopup.balloon_bg.m.height);
            tutorialTextVoSetup(param1);
         }
         else
         {
            _tutorialMediaHelper = new MediaHelper();
            _tutorialMediaHelper.init(2875,onTutorialLoaded,{
               "message":param1,
               "x":param2,
               "y":param3
            });
         }
      }
      
      private static function tutorialTextVoSetup(param1:int) : void
      {
         if(_soundIds == null)
         {
            setupSoundIds();
         }
         var _loc2_:Sound = new Sound();
         switch(param1 - 18659)
         {
            case 0:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][5] + ".mp3"));
               break;
            case 1:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][6] + ".mp3"));
         }
         _tutorialTextPopup.sound = _loc2_;
         if(_tutorialTextPopup.currSoundChannel)
         {
            _tutorialTextPopup.currSoundChannel.stop();
            _tutorialTextPopup.currSoundChannel = null;
         }
         _tutorialTextPopup.currSoundChannel = _loc2_.play(0,0,new SoundTransform(SBAudio.isMusicMuted ? 0 : volumeLevel()));
      }
      
      private static function onTutorialLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _tutorialTextPopup = MovieClip(param1.getChildAt(0));
            _tutorialTextPopup.x = param1.passback.x;
            _tutorialTextPopup.y = param1.passback.y;
            _tutorialTextPopup.message_txt.autoSize = "center";
            _tutorialTextPopup.message_txt.text = LocalizationManager.translateIdOnly(param1.passback.message);
            _tutorialTextPopup.balloon_bg.m.height = Math.floor(_tutorialTextPopup.message_txt.height + 10);
            _tutorialTextPopup.balloon_bg.b.y = Math.round(_tutorialTextPopup.balloon_bg.m.y + _tutorialTextPopup.balloon_bg.m.height);
            tutorialTextVoSetup(param1.passback.message);
            GuiManager.guiLayer.addChild(_tutorialTextPopup);
            _tutorialMediaHelper.destroy();
            _tutorialMediaHelper = null;
         }
      }
      
      public static function openTalkingTutorial(param1:int, param2:int, param3:int, param4:int, param5:MovieClip, param6:MovieClip = null) : void
      {
         if(_talkingTutorialPopup)
         {
            if(param3 != -1)
            {
               _talkingTutorialPopup.x = param3;
            }
            if(param4 != -1)
            {
               _talkingTutorialPopup.y = param4;
            }
            _talkingTutorialPopup.cont.popupCont.txt.text = LocalizationManager.translateIdOnly(param1);
            _talkingTutorialPopup.cont.popupCont.bg.m.height = Math.floor(_talkingTutorialPopup.cont.popupCont.txt.textHeight + 6);
            _talkingTutorialPopup.cont.popupCont.bg.b.y = Math.floor(_talkingTutorialPopup.cont.popupCont.bg.m.y + _talkingTutorialPopup.cont.popupCont.bg.m.height);
            _talkingTutorialPopup.buttonToTurnOn = param5;
            _talkingTutorialPopup.layerToTurnOn = param6;
            if(_talkingTutorialPopup.currSoundChannel != null)
            {
               _talkingTutorialPopup.currSoundChannel.stop();
               _talkingTutorialPopup.currSoundChannel = null;
            }
            if(param2 != 0)
            {
               LocalizationManager.translateId(_talkingTutorialPopup.cont.popupCont.talkingHeadTitleTxt,21401);
            }
            setupTalkingTutorialSound(param1);
            if(_talkingTutorialPopup.cont.currentFrameLabel != "closed")
            {
               _talkingTutorialPopup.cont.gotoAndStop("closed");
            }
            if(_talkingTutorialTimer == null)
            {
               _talkingTutorialTimer = new Timer(1000);
               _talkingTutorialTimer.addEventListener("timer",onTalkingTutorialTimerComplete,false,0,true);
            }
            if(_talkingTutorialPopup.talkingHead)
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(1);
            }
            _talkingTutorialTimer.reset();
            _talkingTutorialTimer.start();
         }
         else
         {
            _tutorialMediaHelper = new MediaHelper();
            _tutorialMediaHelper.init(2872,onTalkingTutorialLoaded,{
               "message":param1,
               "titleTxt":param2,
               "x":param3,
               "y":param4,
               "buttonToTurnOn":param5,
               "layerToTurnOn":param6
            });
         }
      }
      
      private static function setupTalkingTutorialSound(param1:int) : void
      {
         if(_soundIds == null)
         {
            setupSoundIds();
         }
         var _loc2_:Sound = new Sound();
         switch(param1)
         {
            case 18654:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][0] + ".mp3"));
               break;
            case 18655:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][1] + ".mp3"));
               break;
            case 18656:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][2] + ".mp3"));
               break;
            case 21388:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][3] + ".mp3"));
               break;
            case 18658:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][4] + ".mp3"));
               break;
            case 18661:
               _loc2_.load(LoaderCache.fetchCDNURLRequest("streams/" + _soundIds[LocalizationManager.currentLanguage][7] + ".mp3"));
         }
         _talkingTutorialPopup.sound = _loc2_;
      }
      
      private static function onTalkingTutorialTimerComplete(param1:TimerEvent) : void
      {
         if(_talkingTutorialPopup)
         {
            if(_talkingTutorialPopup.cont.currentFrameLabel == "closed")
            {
               _talkingTutorialPopup.cont.gotoAndPlay("opening");
               if(_talkingTutorialPopup.talkingHead)
               {
                  _talkingTutorialPopup.talkingHead.NPC.gotoAndPlay(1);
               }
               _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = false;
            }
            if(_talkingTutorialPopup.buttonToTurnOn)
            {
               _talkingTutorialPopup.buttonToTurnOn.gotoAndStop("new");
               _talkingTutorialPopup.buttonToTurnOn.setButtonState(2);
            }
            if(_talkingTutorialPopup.layerToTurnOn && _talkingTutorialPopup.layerToTurnOn.parent)
            {
               _talkingTutorialPopup.layerToTurnOn.parent.gotoAndStop("new");
               _talkingTutorialPopup.layerToTurnOn.visible = true;
            }
            _talkingTutorialTimer.reset();
            if(_talkingTutorialPopup.sound && _talkingTutorialPopup.sound.bytesLoaded != 0 && _talkingTutorialPopup.sound.bytesLoaded == _talkingTutorialPopup.sound.bytesTotal)
            {
               _talkingTutorialPopup.currSoundChannel = (_talkingTutorialPopup.sound as Sound).play(0,0,new SoundTransform(SBAudio.isMusicMuted ? 0 : volumeLevel()));
               if(_talkingTutorialPopup.currSoundChannel)
               {
                  _talkingTutorialPopup.currSoundChannel.addEventListener("soundComplete",onPlaybackComplete);
               }
               else
               {
                  onPlaybackComplete(null);
               }
            }
            else
            {
               _talkingTutorialTimer.start();
            }
         }
      }
      
      private static function onPlaybackComplete(param1:Event) : void
      {
         if(_talkingTutorialPopup)
         {
            if(_talkingTutorialPopup.talkingHead)
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(1);
            }
            if(_talkingTutorialPopup.currSoundChannel)
            {
               _talkingTutorialPopup.currSoundChannel = null;
            }
         }
      }
      
      private static function onTalkingTutorialLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _talkingTutorialPopup = MovieClip(param1.getChildAt(0));
            _talkingTutorialPopup.scaleX = 0.7;
            _talkingTutorialPopup.scaleY = 0.7;
            _talkingTutorialPopup.x = param1.passback.x;
            _talkingTutorialPopup.y = param1.passback.y;
            _talkingTutorialPopup.addEventListener("mouseDown",onTutorialPopup,false,0,true);
            _talkingTutorialPopup.cont.popupCont.bx.addEventListener("mouseDown",onTutorialPopup,false,0,true);
            _talkingTutorialPopup.cont.popupCont.voBtn.addEventListener("mouseDown",onTutorialVoBtn,false,0,true);
            _talkingTutorialPopup.cont.popupCont.txt.autoSize = "center";
            _talkingTutorialPopup.cont.popupCont.txt.text = LocalizationManager.translateIdOnly(param1.passback.message);
            _talkingTutorialPopup.cont.popupCont.bg.m.height = Math.floor(_talkingTutorialPopup.cont.popupCont.txt.textHeight + 6);
            _talkingTutorialPopup.cont.popupCont.bg.b.y = Math.floor(_talkingTutorialPopup.cont.popupCont.bg.m.y + _talkingTutorialPopup.cont.popupCont.bg.m.height);
            LocalizationManager.translateId(_talkingTutorialPopup.cont.popupCont.talkingHeadTitleTxt,21401);
            _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = false;
            _talkingTutorialPopup.buttonToTurnOn = param1.passback.buttonToTurnOn;
            _talkingTutorialPopup.layerToTurnOn = param1.passback.layerToTurnOn;
            _talkingLoadingSpiral = new LoadingSpiral(_talkingTutorialPopup.itemRenderPlaceholder.itemWindow,_talkingTutorialPopup.itemRenderPlaceholder.itemWindow.width * 0.5,_talkingTutorialPopup.itemRenderPlaceholder.itemWindow.height * 0.5);
            _tutorialMediaHelper = new MediaHelper();
            _tutorialMediaHelper.init(2052,onTalkingHeadMediaLoaded);
            _talkingTutorialPopup.cont.gotoAndPlay("opening");
            GuiManager.guiLayer.addChild(_talkingTutorialPopup);
            setupTalkingTutorialSound(param1.passback.message);
            if(_talkingTutorialPopup.cont.currentFrameLabel != "closed")
            {
               _talkingTutorialPopup.cont.gotoAndStop("closed");
            }
            if(_talkingTutorialTimer == null)
            {
               _talkingTutorialTimer = new Timer(1000);
               _talkingTutorialTimer.addEventListener("timer",onTalkingTutorialTimerComplete,false,0,true);
            }
            _talkingTutorialTimer.reset();
            _talkingTutorialTimer.start();
         }
      }
      
      private static function onTalkingHeadMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_talkingTutorialPopup != null)
            {
               _talkingTutorialPopup.talkingHead = param1.getChildAt(0);
               _talkingTutorialPopup.itemRenderPlaceholder.itemWindow.addChild(param1);
               _talkingLoadingSpiral.visible = false;
               if(_tutorialMediaHelper)
               {
                  _tutorialMediaHelper.destroy();
                  _tutorialMediaHelper = null;
               }
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(0);
            }
         }
      }
      
      private static function onTutorialVoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_talkingTutorialPopup.currSoundChannel)
         {
            _talkingTutorialPopup.currSoundChannel.stop();
            _talkingTutorialPopup.currSoundChannel = null;
            if(_talkingTutorialPopup.talkingHead)
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(1);
            }
         }
         else if(_talkingTutorialPopup.sound)
         {
            _talkingTutorialPopup.currSoundChannel = _talkingTutorialPopup.sound.play(0,0,new SoundTransform(SBAudio.isMusicMuted ? 0 : volumeLevel()));
            _talkingTutorialPopup.currSoundChannel.addEventListener("soundComplete",onPlaybackComplete);
            if(_talkingTutorialPopup.talkingHead)
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndPlay(1);
            }
         }
      }
      
      private static function onTutorialPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_talkingTutorialPopup.cont.currentFrameLabel == "closed")
         {
            _talkingTutorialPopup.cont.gotoAndPlay("opening");
            if(_talkingTutorialPopup.talkingHead)
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndPlay(1);
            }
            _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = false;
            if(_talkingTutorialPopup.buttonToTurnOn)
            {
               _talkingTutorialPopup.buttonToTurnOn.gotoAndStop("new");
               _talkingTutorialPopup.buttonToTurnOn.setButtonState(2);
            }
            if(_talkingTutorialPopup.layerToTurnOn)
            {
               _talkingTutorialPopup.layerToTurnOn.parent.gotoAndStop("new");
               _talkingTutorialPopup.layerToTurnOn.visible = true;
            }
            if(_talkingTutorialPopup.sound)
            {
               _talkingTutorialPopup.currSoundChannel = _talkingTutorialPopup.sound.play(0,0,new SoundTransform(SBAudio.isMusicMuted ? 0 : volumeLevel()));
               _talkingTutorialPopup.currSoundChannel.addEventListener("soundComplete",onPlaybackComplete);
            }
         }
         else
         {
            _talkingTutorialPopup.cont.gotoAndPlay("closing");
            if(_talkingTutorialPopup.talkingHead)
            {
               _talkingTutorialPopup.talkingHead.NPC.gotoAndStop(1);
            }
            _talkingTutorialPopup.lizaHeadFrameHolder.glow.visible = true;
            if(_talkingTutorialPopup.buttonToTurnOn)
            {
               _talkingTutorialPopup.buttonToTurnOn.setButtonState(1);
            }
            if(_talkingTutorialPopup.layerToTurnOn)
            {
               _talkingTutorialPopup.layerToTurnOn.visible = false;
            }
            if(_talkingTutorialPopup.currSoundChannel)
            {
               _talkingTutorialPopup.currSoundChannel.stop();
               _talkingTutorialPopup.currSoundChannel = null;
            }
         }
      }
      
      private static function setupSoundIds() : void
      {
         _soundIds = new Array(8);
         _soundIds[LocalizationManager.LANG_ENG] = [789,790,791,792,793,794,795,796];
         _soundIds[LocalizationManager.LANG_FRE] = [812,813,814,815,816,817,818,819];
         _soundIds[LocalizationManager.LANG_DE] = [820,821,822,823,824,825,826,827];
         _soundIds[LocalizationManager.LANG_POR] = [828,829,830,831,832,833,834,835];
         _soundIds[LocalizationManager.LANG_SPA] = [836,837,838,839,840,841,842,843];
      }
      
      private static function volumeLevel() : Number
      {
         switch(LocalizationManager.currentLanguage)
         {
            case LocalizationManager.LANG_FRE:
               return 0.57;
            case LocalizationManager.LANG_POR:
               return 0.85;
            case LocalizationManager.LANG_SPA:
               return 0.7;
            default:
               return 1;
         }
      }
      
      public static function handleSoundBtnClick() : void
      {
         if(_tutorialTextPopup && _tutorialTextPopup.currSoundChannel)
         {
            _tutorialTextPopup.currSoundChannel.soundTransform = new SoundTransform(SBAudio.isMusicMuted ? 0 : volumeLevel());
         }
         if(_talkingTutorialPopup && _talkingTutorialPopup.currSoundChannel)
         {
            _talkingTutorialPopup.currSoundChannel.soundTransform = new SoundTransform(SBAudio.isMusicMuted ? 0 : volumeLevel());
         }
      }
      
      public static function closeTutorialTextPopup() : void
      {
         if(_tutorialTextPopup)
         {
            GuiManager.guiLayer.removeChild(_tutorialTextPopup);
            if(_tutorialTextPopup.currSoundChannel)
            {
               _tutorialTextPopup.currSoundChannel.stop();
               _tutorialTextPopup.currSoundChannel = null;
            }
            _tutorialTextPopup = null;
         }
      }
      
      public static function closeTalkingTutorialPopup() : void
      {
         if(_talkingTutorialPopup)
         {
            if(_tutorialMediaHelper)
            {
               _tutorialMediaHelper.destroy();
               _tutorialMediaHelper = null;
            }
            if(_talkingTutorialPopup.currSoundChannel)
            {
               _talkingTutorialPopup.currSoundChannel.stop();
               _talkingTutorialPopup.currSoundChannel = null;
            }
            GuiManager.guiLayer.removeChild(_talkingTutorialPopup);
            _talkingTutorialPopup.removeEventListener("mouseDown",onTutorialPopup);
            _talkingTutorialPopup.cont.popupCont.bx.removeEventListener("mouseDown",onTutorialPopup);
            _talkingTutorialPopup = null;
            if(_talkingTutorialTimer)
            {
               _talkingTutorialTimer.reset();
               _talkingTutorialTimer = null;
            }
         }
      }
   }
}

