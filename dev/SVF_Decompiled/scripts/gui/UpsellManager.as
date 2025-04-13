package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import loader.MediaHelper;
   
   public class UpsellManager
   {
      public static const EXTRA_DIAMONDS_AS_MEMBER:String = "";
      
      public static const JAG:String = "jamagram";
      
      public static const EMOTES:String = "emotes";
      
      public static const ANIMALS:String = "animals";
      
      public static const ANIMAL_SLOTS:String = "animalSlots";
      
      public static const NAMEBARS:String = "namebars";
      
      public static const DENS:String = "dens";
      
      public static const DEN_ITEMS:String = "denItems";
      
      public static const ACCESSORIES:String = "accessories";
      
      public static const PETS:String = "pets";
      
      public static const DEN_AUDIO:String = "denAudio";
      
      public static const OCEAN:String = "oceanAnimals";
      
      public static const EXTRA_DEN_ITEMS:String = "200Items";
      
      public static const DIAMONDS:String = "diamondShop";
      
      public static const ADVENTURES:String = "adventures";
      
      public static const PLAYER_WALL:String = "jammerWall";
      
      public static const DEN_ART:String = "denArt";
      
      private static const UPSELL_MEDIA_ID:int = 1114;
      
      private static const EXTRA_DIAMONDS_MEDIA_ID:int = 2216;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _closeCallBack:Function;
      
      private static var _upsellMC:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      private static var _maxPetsFunc:Function;
      
      public function UpsellManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:Function = null) : void
      {
         _guiLayer = param1;
         _maxPetsFunc = param2;
      }
      
      public static function destroy() : void
      {
         if(_closeCallBack != null)
         {
            _closeCallBack = null;
         }
      }
      
      public static function displayPopup(param1:String, param2:String, param3:Function = null, param4:String = null, param5:Boolean = false) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/upsell/#" + param2);
         _closeCallBack = param3;
         if(param1 == "")
         {
            DarkenManager.showLoadingSpiral(true);
            loadPopup(param1,param5);
         }
         else
         {
            GuiManager.openPageFlipBook(243,false,2,convertFrameLabelToPageNum(param1));
         }
      }
      
      private static function loadPopup(param1:String, param2:Boolean = false) : void
      {
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(param1 == "" ? 2216 : 1114,onUpsellLoaded,{
            "m":param1,
            "s":param2
         });
      }
      
      private static function onUpsellLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_upsellMC)
         {
            onLoadUpsellClose(null);
         }
         if(param1)
         {
            _upsellMC = MovieClip(param1.getChildAt(0));
            _upsellMC.x = 900 * 0.5;
            _upsellMC.y = 550 * 0.5;
            _upsellMC.frameName = param1.passback["m"];
            if(!param1.passback["s"])
            {
               _guiLayer.addChild(_upsellMC);
            }
            else
            {
               gMainFrame.stage.addChild(_upsellMC);
            }
            DarkenManager.darken(_upsellMC);
            if(param1.passback.m != "")
            {
               _upsellMC.gotoAndStop(_upsellMC.frameName);
               _upsellMC.lBtn.addEventListener("mouseDown",onLeftRightBtns,false,0,true);
               _upsellMC.rBtn.addEventListener("mouseDown",onLeftRightBtns,false,0,true);
               _upsellMC.joinClubBtn.addEventListener("mouseDown",onJoin,false,0,true);
            }
            _upsellMC.bx.addEventListener("mouseDown",onLoadUpsellClose,false,0,true);
            _upsellMC.addEventListener("mouseDown",onLoadPopup,false,0,true);
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
      }
      
      private static function onLoadUpsellClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         SBTracker.pop();
         if(_upsellMC.parent)
         {
            _upsellMC.parent.removeChild(_upsellMC);
         }
         DarkenManager.unDarken(_upsellMC);
         if(_upsellMC.frameName != "")
         {
            _upsellMC.lBtn.removeEventListener("mouseDown",onLeftRightBtns);
            _upsellMC.rBtn.removeEventListener("mouseDown",onLeftRightBtns);
            _upsellMC.joinClubBtn.removeEventListener("mouseDown",onJoin);
         }
         _upsellMC.bx.removeEventListener("mouseDown",onLoadUpsellClose);
         _upsellMC.removeEventListener("mouseDown",onLoadPopup);
         _upsellMC = null;
      }
      
      private static function onLeftRightBtns(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = param1.currentTarget == _upsellMC.lBtn ? -1 : 1;
         if(_upsellMC.currentFrame + _loc2_ <= 0)
         {
            _upsellMC.gotoAndStop(_upsellMC.currentLabels.length);
         }
         else if(_upsellMC.currentFrame + _loc2_ > _upsellMC.currentLabels.length)
         {
            _upsellMC.gotoAndStop(1);
         }
         else
         {
            _upsellMC.gotoAndStop(_upsellMC.currentFrame + _loc2_);
         }
      }
      
      private static function onLoadPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onJoin(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc3_:String = gMainFrame.clientInfo.websiteURL + "membership";
         var _loc2_:URLRequest = new URLRequest(_loc3_);
         try
         {
            navigateToURL(_loc2_,"_blank");
            if(_upsellMC)
            {
               onLoadUpsellClose(param1);
            }
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error with loading URL");
         }
      }
      
      private static function convertFrameLabelToPageNum(param1:String) : int
      {
         switch(param1)
         {
            case "200Items":
            case "denItems":
               break;
            case "accessories":
               return 2;
            case "animals":
               return 3;
            case "animalSlots":
               return 4;
            case "pets":
               return 5;
            case "oceanAnimals":
               return 6;
            case "denArt":
               return 7;
            case "diamondShop":
               return 8;
            case "jamagram":
               return 9;
            case "jammerWall":
               return 10;
            case "adventures":
               return 11;
            case "dens":
               return 13;
            case "denAudio":
               return 14;
            case "emotes":
               return 15;
            case "namebars":
               return 16;
            default:
               return 1;
         }
         return 1;
      }
   }
}

