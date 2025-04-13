package
{
   import avatar.AvatarManager;
   import gui.GuiManager;
   import loadProgress.LoadProgress;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import room.RoomXtCommManager;
   
   public class LocalizationXtCommManager
   {
      public function LocalizationXtCommManager()
      {
         super();
      }
      
      public static function onLocalizationShardResponse(param1:String) : void
      {
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:Array = param1.split(",");
         var _loc8_:int = 0;
         var _loc7_:* = _loc5_;
         for each(var _loc3_ in _loc7_)
         {
            _loc2_ = _loc3_.split(":");
            _loc4_ = int(_loc2_[0]);
            _loc6_ = int(_loc2_[1]);
            requestLocalizationPack(_loc6_);
         }
      }
      
      public static function requestLocalizationPack(param1:int) : void
      {
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         LocalizationManager.currentLanguage = param1;
         LocalizationManager.hasLocalizations = false;
         RoomXtCommManager.waitForLangPack = true;
         AvatarManager.waitForLangPack = true;
         _loc2_.init(uint("1023" + param1),onLocalizationListResponse,RoomXtCommManager.startRoomLoadIfReady,2);
         DefPacksDefHelper.mediaArray["1023" + param1] = _loc2_;
      }
      
      public static function onLocalizationListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray["1023" + LocalizationManager.currentLanguage] = null;
         LocalizationManager.setLocalizations(param1.def,GuiManager.mainHud != null ? GuiManager.rebuildMainHud : null);
         LoadProgress.onLocalizationsReceived();
         if(param1.passback)
         {
            param1.passback();
         }
      }
      
      public static function onPreferredLocalizationListResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray["1055." + LocalizationManager.accountLanguage] = null;
         LocalizationManager.setPreferredLocalizations(param1.def);
      }
   }
}

