package
{
   import com.sbi.corelib.Utils;
   import com.sbi.corelib.audio.SBAudio;
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   
   public class AJAudio
   {
      private static var _hasLoadedDailySpinSfx:Boolean;
      
      private static var _hasLoadedGiftUnwrapSfx:Boolean;
      
      private static var _hasLoadedJourneyBookWorldSfx:Boolean;
      
      private static var _hasLoadedJourneyBookBookSfx:Boolean;
      
      private static var _hasLoadedTradeSfx:Boolean;
      
      private static var _hasLoadedPetCreateSfx:Boolean;
      
      private static var _defaultVolumes:Dictionary;
      
      public function AJAudio()
      {
         super();
      }
      
      public static function init(param1:Function = null, param2:Object = null) : void
      {
         var _loc3_:Object = null;
         if(!SBAudio.isInitialized)
         {
            _loc3_ = {};
            _loc3_["HudBtnRollover"] = {
               "className":Utils.getDefByName("HudBtnRollover") as Class,
               "volume":0.2
            };
            _loc3_["HudBtnClick"] = {
               "className":Utils.getDefByName("HudBtnClick") as Class,
               "volume":0.2
            };
            _loc3_["SubMenuBtnRollover"] = {
               "className":Utils.getDefByName("SubMenuBtnRollover") as Class,
               "volume":0.2
            };
            _loc3_["SubMenuBtnClick"] = {
               "className":Utils.getDefByName("SubMenuBtnClick") as Class,
               "volume":0.2
            };
            _loc3_["ExitBtnRollover"] = {
               "className":Utils.getDefByName("ExitBtnRollover") as Class,
               "volume":0.2
            };
            _loc3_["ExitBtnClick"] = {
               "className":Utils.getDefByName("ExitBtnClick") as Class,
               "volume":0.2
            };
            _loc3_["ScrollUpDown"] = {
               "className":Utils.getDefByName("ScrollUpDown") as Class,
               "volume":0.2
            };
            _loc3_["ScrollLeftRight"] = {
               "className":Utils.getDefByName("ScrollLeftRight") as Class,
               "volume":0.2
            };
            _loc3_["TextType"] = {
               "className":Utils.getDefByName("TextType") as Class,
               "volume":0.2
            };
            _loc3_["TextEnter"] = {
               "className":Utils.getDefByName("TextEnter") as Class,
               "volume":0.2
            };
            _loc3_["IdleWarningSound"] = {
               "className":Utils.getDefByName("IdleWarningSound") as Class,
               "volume":0.2
            };
            _loc3_["ShopCachingSound"] = {
               "className":Utils.getDefByName("ShopCachingSound") as Class,
               "volume":0.2
            };
            _loc3_["GemsEarnedSound"] = {
               "className":Utils.getDefByName("GemsEarnedSound") as Class,
               "volume":0.2
            };
            _loc3_["ItemRecycledSound"] = {
               "className":Utils.getDefByName("ItemRecycledSound") as Class,
               "volume":0.2
            };
            _loc3_["MailReceivedSound"] = {
               "className":Utils.getDefByName("MailReceivedSound") as Class,
               "volume":0.2
            };
            _loc3_["BuddyOnlineOfflineSound"] = {
               "className":Utils.getDefByName("BuddyOnlineOfflineSound") as Class,
               "volume":0.2
            };
            _loc3_["NewspaperSound"] = {
               "className":Utils.getDefByName("NewspaperSound") as Class,
               "volume":0.2
            };
            _loc3_["MailSentSound"] = {
               "className":Utils.getDefByName("MailSentSound") as Class,
               "volume":0.2
            };
            _loc3_["AchievementSound"] = {
               "className":Utils.getDefByName("AchievementSound") as Class,
               "volume":0.2
            };
            _loc3_["BuddyCardOpen"] = {
               "className":Utils.getDefByName("BuddyCardOpen") as Class,
               "volume":0.2
            };
            _loc3_["BuddyCardClose"] = {
               "className":Utils.getDefByName("BuddyCardClose") as Class,
               "volume":0.2
            };
            _loc3_["LimitedChatErrorSound"] = {
               "className":Utils.getDefByName("LimitedChatErrorSound") as Class,
               "volume":0.2
            };
            _loc3_["ChatOpenSound"] = {
               "className":Utils.getDefByName("ChatOpenSound") as Class,
               "volume":0.2
            };
            _loc3_["ChatCloseSound"] = {
               "className":Utils.getDefByName("ChatCloseSound") as Class,
               "volume":0.2
            };
            _loc3_["RandomLever"] = {
               "className":Utils.getDefByName("RandomLever") as Class,
               "volume":0.2
            };
            _loc3_["NameGenRotationSound"] = {
               "className":Utils.getDefByName("NameGenRotationSound") as Class,
               "volume":1
            };
            _loc3_["NameGenStopSound"] = {
               "className":Utils.getDefByName("NameGenStopSound") as Class,
               "volume":1
            };
            _loc3_["DoorBellSound"] = {
               "className":Utils.getDefByName("DoorBellSound") as Class,
               "volume":1
            };
            SBAudio.init(_loc3_,param1,param2);
            _defaultVolumes = new Dictionary();
            _defaultVolumes["FW_TRAIL_1"] = 0.2;
            _defaultVolumes["FW_TRAIL_2"] = 0.2;
            _defaultVolumes["FW_TRAIL_3"] = 0.2;
            _defaultVolumes["FW_LAUNCH_1"] = 0.3;
            _defaultVolumes["FW_LAUNCH_2"] = 0.3;
            _defaultVolumes["FW_LAUNCH_3"] = 0.3;
            _defaultVolumes["FW_EXPLOSION_1"] = 0.3;
            _defaultVolumes["FW_EXPLOSION_2"] = 0.3;
            _defaultVolumes["FW_EXPLOSION_3"] = 0.3;
            _defaultVolumes["DOOR_WOOD_OPEN"] = 0.3;
            _defaultVolumes["DOOR_WOOD_CLOSE"] = 0.3;
            _defaultVolumes["DOOR_SLIDE"] = 0.3;
            _defaultVolumes["DOOR_STONE_SLIDE"] = 0.3;
            _defaultVolumes["aj_water_fs1"] = 0;
            _defaultVolumes["aj_water_fs2"] = 0;
            _defaultVolumes["aj_water_fs3"] = 0;
            _defaultVolumes["BOUNCE"] = 0.4;
            _defaultVolumes["aj_slideBounce1"] = 0.28;
            _defaultVolumes["aj_slideBounce2"] = 0.28;
            _defaultVolumes["aj_JBCameraHide"] = 0.3;
            _defaultVolumes["aj_JBCameraReveal"] = 0.3;
            _defaultVolumes["aj_JBcarrotBounce"] = 0.3;
            _defaultVolumes["aj_JBcarrotsPop"] = 0.3;
            _defaultVolumes["aj_JBcarrotsRing"] = 0.3;
            _defaultVolumes["aj_JBcosmoHatAppear"] = 0.3;
            _defaultVolumes["aj_JBcosmoHatBoomSeedAppear"] = 0.3;
            _defaultVolumes["aj_JBcosmoHatBoomSeedFall"] = 0.3;
            _defaultVolumes["aj_JBcosmoHatFall"] = 0.3;
            _defaultVolumes["aj_JBgilbertArmorClose"] = 0.3;
            _defaultVolumes["aj_JBgilbertArmorOpen"] = 0.3;
            _defaultVolumes["aj_JBgrahamGearLP"] = 0.3;
            _defaultVolumes["aj_JBgreelyCapeEnter"] = 0.3;
            _defaultVolumes["aj_JBgreelyCapeExit"] = 0.3;
            _defaultVolumes["aj_JBlizaCompassHide"] = 0.3;
            _defaultVolumes["aj_JBlizaCompassReveal"] = 0.3;
         }
      }
      
      public static function loadSfx(param1:String, param2:Class, param3:Number = 0.3) : void
      {
         if(_defaultVolumes[param1])
         {
            param3 = Number(_defaultVolumes[param1]);
         }
         SBAudio.addCachedSound(param1,param2,param3);
      }
      
      public static function setupSharedObject(param1:SharedObject) : void
      {
         SBAudio.setupSharedObject(param1);
      }
      
      public static function playSfx(param1:String, param2:int = 1) : void
      {
         SBAudio.playCachedSound(param1,param2);
      }
      
      public static function stopSfx(param1:String) : void
      {
         SBAudio.stopCachedSound(param1);
      }
      
      public static function playHudBtnRollover() : void
      {
         playSfx("HudBtnRollover");
      }
      
      public static function playHudBtnClick() : void
      {
         playSfx("HudBtnClick");
      }
      
      public static function playSubMenuBtnRollover() : void
      {
         playSfx("SubMenuBtnRollover");
      }
      
      public static function playSubMenuBtnClick() : void
      {
         playSfx("SubMenuBtnClick");
      }
      
      public static function playExitBtnRollover() : void
      {
         playSfx("ExitBtnRollover");
      }
      
      public static function playExitBtnClick() : void
      {
         playSfx("ExitBtnClick");
      }
      
      public static function playScrollUpDown() : void
      {
         playSfx("ScrollUpDown");
      }
      
      public static function playScrollLeftRight() : void
      {
         playSfx("ScrollLeftRight");
      }
      
      public static function playTextType() : void
      {
         playSfx("TextType");
      }
      
      public static function playTextEnter() : void
      {
         playSfx("TextEnter");
      }
      
      public static function playIdleWarningSound() : void
      {
         playSfx("IdleWarningSound");
      }
      
      public static function playShopCachingSound() : void
      {
         playSfx("ShopCachingSound");
      }
      
      public static function playGemsEarnedSound() : void
      {
         playSfx("GemsEarnedSound");
      }
      
      public static function playItemRecycledSound() : void
      {
         playSfx("ItemRecycledSound");
      }
      
      public static function playMailReceivedSound() : void
      {
         playSfx("MailReceivedSound");
      }
      
      public static function playMailSentSound() : void
      {
         playSfx("MailSentSound");
      }
      
      public static function playBuddyOnlineOfflineSound() : void
      {
         playSfx("BuddyOnlineOfflineSound");
      }
      
      public static function playNewspaperSound() : void
      {
         playSfx("NewspaperSound");
      }
      
      public static function playAchievementSound() : void
      {
         playSfx("AchievementSound");
      }
      
      public static function playBuddyCardOpen() : void
      {
         playSfx("BuddyCardOpen");
      }
      
      public static function playBuddyCardClose() : void
      {
         playSfx("BuddyCardClose");
      }
      
      public static function playLimitedChatErrorSound() : void
      {
         playSfx("LimitedChatErrorSound");
      }
      
      public static function playChatOpenSound() : void
      {
         playSfx("ChatOpenSound");
      }
      
      public static function playChatCloseSound() : void
      {
         playSfx("ChatCloseSound");
      }
      
      public static function playRandomLever() : void
      {
         playSfx("RandomLever");
      }
      
      public static function playNameGenRotationSound(param1:int = 1) : void
      {
         playSfx("NameGenRotationSound",param1);
      }
      
      public static function playNameGenStopSound() : void
      {
         playSfx("NameGenStopSound");
      }
      
      public static function playDoorBellSound() : void
      {
         playSfx("DoorBellSound");
      }
      
      public static function stopNameGenRotationSound() : void
      {
         stopSfx("NameGenRotationSound");
      }
      
      public static function stopRandomLever() : void
      {
         stopSfx("RandomLever");
      }
      
      public static function get hasLoadedDailySpinSfx() : Boolean
      {
         return _hasLoadedDailySpinSfx;
      }
      
      public static function set hasLoadedDailySpinSfx(param1:Boolean) : void
      {
         _hasLoadedDailySpinSfx = param1;
      }
      
      public static function playDailySpinSpin() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinSpin");
      }
      
      public static function playDailySpinBub1() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinBub1");
      }
      
      public static function playDailySpinBub2() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinBub2");
      }
      
      public static function playDailySpinBub3() : void
      {
         if(!_hasLoadedDailySpinSfx)
         {
            return;
         }
         playSfx("DailySpinBub3");
      }
      
      public static function get hasLoadedGiftUnwrapSfx() : Boolean
      {
         return _hasLoadedGiftUnwrapSfx;
      }
      
      public static function set hasLoadedGiftUnwrapSfx(param1:Boolean) : void
      {
         _hasLoadedGiftUnwrapSfx = param1;
      }
      
      public static function playGiftUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("GiftUnwrap");
      }
      
      public static function playTreasureUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("TreasureUnwrap");
      }
      
      public static function playTreasureBagUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("TreasureBagUnwrap");
      }
      
      public static function playTreasureLuckyUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("EpicLuckyTreasureUnwrap");
      }
      
      public static function playTreasureLucky2Unwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("potOgoldPopUp");
      }
      
      public static function playTreasureEggUnwrap() : void
      {
         if(!_hasLoadedGiftUnwrapSfx)
         {
            return;
         }
         playSfx("TreasureGoldenEgg");
      }
      
      public static function get hasLoadedJourneyBookWorldSfx() : Boolean
      {
         return _hasLoadedJourneyBookWorldSfx;
      }
      
      public static function set hasLoadedJourneyBookWorldSfx(param1:Boolean) : void
      {
         _hasLoadedJourneyBookWorldSfx = param1;
      }
      
      public static function playJBPrizeEarned() : void
      {
         if(!_hasLoadedJourneyBookWorldSfx)
         {
            return;
         }
         playSfx("JBPrizeEarned");
      }
      
      public static function playJBWorldFactClose() : void
      {
         if(!_hasLoadedJourneyBookWorldSfx)
         {
            return;
         }
         playSfx("JBWorldFactClose");
      }
      
      public static function playJBWorldFactOpen() : void
      {
         if(!_hasLoadedJourneyBookWorldSfx)
         {
            return;
         }
         playSfx("JBWorldFactOpen");
      }
      
      public static function get hasLoadedJourneyBookBookSfx() : Boolean
      {
         return _hasLoadedJourneyBookBookSfx;
      }
      
      public static function set hasLoadedJourneyBookBookSfx(param1:Boolean) : void
      {
         _hasLoadedJourneyBookBookSfx = param1;
      }
      
      public static function playJBBookFactClose() : void
      {
         if(!_hasLoadedJourneyBookBookSfx)
         {
            return;
         }
         playSfx("JBBookFactClose");
      }
      
      public static function playJBBookFactOpen() : void
      {
         if(!_hasLoadedJourneyBookBookSfx)
         {
            return;
         }
         playSfx("JBBookFactOpen");
      }
      
      public static function get hasLoadedTradeSfx() : Boolean
      {
         return _hasLoadedTradeSfx;
      }
      
      public static function set hasLoadedTradeSfx(param1:Boolean) : void
      {
         _hasLoadedTradeSfx = param1;
      }
      
      public static function playTradeSuccessSound() : void
      {
         if(!_hasLoadedTradeSfx)
         {
            return;
         }
         playSfx("TradeSuccessSound");
      }
      
      public static function playTradeFailedSound() : void
      {
         if(!_hasLoadedTradeSfx)
         {
            return;
         }
         playSfx("TradeFailedSound");
      }
      
      public static function playTradeRequestSound() : void
      {
         if(!_hasLoadedTradeSfx)
         {
            return;
         }
         playSfx("TradeRequestSound");
      }
      
      public static function get hasLoadedPetCreateSfx() : Boolean
      {
         return _hasLoadedPetCreateSfx;
      }
      
      public static function set hasLoadedPetCreatefx(param1:Boolean) : void
      {
         _hasLoadedPetCreateSfx = param1;
      }
      
      public static function playPetCreateRandomSound1() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         playSfx("petRandomization1");
      }
      
      public static function stopPetCreateRandomSound1() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         stopSfx("petRandomization1");
      }
      
      public static function playPetCreateRandomSound2() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         playSfx("petRandomization2");
      }
      
      public static function stopPetCreateRandomSound2() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         stopSfx("petRandomization2");
      }
      
      public static function playPetCreateRandomSound3() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         playSfx("petRandomization3");
      }
      
      public static function stopPetCreateRandomSound3() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         stopSfx("petRandomization3");
      }
      
      public static function playPetCreateRandomSound4() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         playSfx("petRandomization4");
      }
      
      public static function stopPetCreateRandomSound4() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         stopSfx("petRandomization4");
      }
      
      public static function playPetCreateRandomSoundFinish() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         playSfx("petRandomizationFinish");
      }
      
      public static function stopPetCreateRandomSoundFinish() : void
      {
         if(!_hasLoadedPetCreateSfx)
         {
            return;
         }
         stopSfx("petRandomizationFinish");
      }
   }
}

