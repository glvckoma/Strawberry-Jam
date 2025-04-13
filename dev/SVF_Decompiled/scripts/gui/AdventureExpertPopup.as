package gui
{
   import avatar.AvatarInfo;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestXtCommManager;
   
   public class AdventureExpertPopup
   {
      private static const ADVENTURE_EXPERT_ID:int = 2288;
      
      private static var _difficultyPopup:MovieClip;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _autoStart:Boolean;
      
      private static var _scriptDef:Object;
      
      private static var _isTryingToJoin:Boolean;
      
      public function AdventureExpertPopup()
      {
         super();
      }
      
      public static function init(param1:int, param2:Boolean = false) : void
      {
         _scriptDef = QuestXtCommManager.getScriptDef(param1);
         _guiLayer = GuiManager.guiLayer;
         _autoStart = param2;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2288,onExpertLoaded);
      }
      
      public static function destroy() : void
      {
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         if(_difficultyPopup)
         {
            DarkenManager.unDarken(_difficultyPopup);
            _guiLayer.removeChild(_difficultyPopup);
            _difficultyPopup = null;
         }
      }
      
      private static function onExpertLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _difficultyPopup = MovieClip(param1.getChildAt(0));
         _difficultyPopup.x = 900 * 0.5;
         _difficultyPopup.y = 550 * 0.5;
         _difficultyPopup.nonMemLock.visible = !gMainFrame.userInfo.isMember;
         _difficultyPopup.dModeCont.visible = false;
         _difficultyPopup.scrim.visible = false;
         addEventListeners();
         _guiLayer.addChild(_difficultyPopup);
         DarkenManager.darken(_difficultyPopup);
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private static function onDifficulty(param1:MouseEvent) : void
      {
         var _loc3_:AvatarInfo = null;
         param1.stopPropagation();
         var _loc2_:int = 0;
         if(Utility.canQuest())
         {
            if(param1.currentTarget.name == _difficultyPopup.dModeCont.hardBtn.name)
            {
               _loc3_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
               if(_loc3_ && _loc3_.questLevel < _scriptDef.levelMin + 1)
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_scriptDef.levelMin + 1));
                  return;
               }
               _loc2_ = 1;
            }
            if(_isTryingToJoin)
            {
               QuestXtCommManager.sendQuestCreateJoinPublic(_scriptDef.defId,_loc2_,_autoStart);
               destroy();
               DarkenManager.showLoadingSpiral(true);
               return;
            }
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("diamondShop","customAdventure/");
               destroy();
               return;
            }
            QuestXtCommManager.sendQuestCreatePrivate(_scriptDef.defId,_loc2_,false);
            destroy();
            DarkenManager.showLoadingSpiral(true);
            return;
         }
         destroy();
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(20142));
      }
      
      private static function onJoinTypeBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(_loc2_ && _loc2_.questLevel < _scriptDef.levelMin)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_scriptDef.levelMin));
            return;
         }
         if(!gMainFrame.userInfo.isMember && param1.currentTarget.name == _difficultyPopup.hostBtn.name)
         {
            UpsellManager.displayPopup("diamondShop","customAdventure/");
         }
         else if(_scriptDef.difficulty != 0)
         {
            _difficultyPopup.dModeCont.visible = true;
            _difficultyPopup.scrim.visible = true;
            _isTryingToJoin = param1.currentTarget.name == _difficultyPopup.joinBtn.name;
         }
         else
         {
            if(param1.currentTarget.name == _difficultyPopup.joinBtn.name)
            {
               QuestXtCommManager.sendQuestCreateJoinPublic(_scriptDef.defId,0,_autoStart);
            }
            else
            {
               QuestXtCommManager.sendQuestCreatePrivate(_scriptDef.defId,0,false);
            }
            destroy();
         }
      }
      
      private static function onCloseModeCont(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _difficultyPopup.dModeCont.visible = false;
         _difficultyPopup.scrim.visible = false;
      }
      
      private static function addEventListeners() : void
      {
         if(_difficultyPopup)
         {
            _difficultyPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _difficultyPopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
            _difficultyPopup.dModeCont.normalBtn.addEventListener("mouseDown",onDifficulty,false,0,true);
            _difficultyPopup.dModeCont.hardBtn.addEventListener("mouseDown",onDifficulty,false,0,true);
            _difficultyPopup.dModeCont.bx.addEventListener("mouseDown",onCloseModeCont,false,0,true);
            _difficultyPopup.joinBtn.addEventListener("mouseDown",onJoinTypeBtn,false,0,true);
            _difficultyPopup.hostBtn.addEventListener("mouseDown",onJoinTypeBtn,false,0,true);
         }
      }
      
      private static function removeEventListeners() : void
      {
         if(_difficultyPopup)
         {
            _difficultyPopup.removeEventListener("mouseDown",onPopup);
            _difficultyPopup.bx.removeEventListener("mouseDown",onCloseBtn);
            _difficultyPopup.dModeCont.normalBtn.removeEventListener("mouseDown",onDifficulty);
            _difficultyPopup.dModeCont.hardBtn.removeEventListener("mouseDown",onDifficulty);
            _difficultyPopup.dModeCont.bx.removeEventListener("mouseDown",onCloseModeCont);
            _difficultyPopup.joinBtn.removeEventListener("mouseDown",onJoinTypeBtn);
            _difficultyPopup.hostBtn.removeEventListener("mouseDown",onJoinTypeBtn);
         }
      }
   }
}

