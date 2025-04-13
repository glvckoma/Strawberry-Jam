package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.display.MovieClip;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class LoadAvatarCarouselResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      private static var _mediaHelper:MediaHelper;
      
      public function LoadAvatarCarouselResourceStackable()
      {
         super();
      }
      
      public static function loadVOSounds(param1:Function, param2:Object = null) : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(getVoMediaIdToLoad(),param1,param2);
      }
      
      private static function getVoMediaIdToLoad() : int
      {
         var _loc1_:int = 2696;
         switch(LocalizationManager.currentLanguage)
         {
            case LocalizationManager.LANG_ENG:
               _loc1_ = 2696;
               break;
            case LocalizationManager.LANG_FRE:
               _loc1_ = 2695;
               break;
            case LocalizationManager.LANG_POR:
               _loc1_ = 2737;
               break;
            case LocalizationManager.LANG_DE:
               _loc1_ = 2757;
               break;
            case LocalizationManager.LANG_SPA:
               _loc1_ = 2912;
               break;
            default:
               _loc1_ = 2696;
         }
         return _loc1_;
      }
      
      override public function init(param1:Function) : void
      {
         super.init(param1);
         _mediaHelper = new MediaHelper();
         if(gMainFrame.clientInfo.sessionId == undefined)
         {
            if(gMainFrame.clientInfo.sbTrackerModulator == undefined)
            {
               gMainFrame.clientInfo.sbTrackerModulator = 32;
            }
            gMainFrame.clientInfo.sessionId = Math.floor(Math.random() * (2147483647 + 1));
         }
         _mediaHelper.init(1808,onAvatarCarouselLoaded);
      }
      
      private function onAvatarCarouselLoaded(param1:MovieClip) : void
      {
         MainFrame.avatarCreationLogin = MovieClip(param1.getChildAt(0));
         loadVOSounds(onCreationVOLoaded);
      }
      
      private function onCreationVOLoaded(param1:MovieClip) : void
      {
         MainFrame.avatarCreationVO = param1;
         _mediaHelper.destroy();
         _mediaHelper = null;
         super._resourceDoneLoadingCallback(this);
      }
   }
}

