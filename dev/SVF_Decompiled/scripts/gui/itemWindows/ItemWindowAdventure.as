package gui.itemWindows
{
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.UserCommXtCommManager;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import gui.AdventureExpertPopup;
   import gui.GuiManager;
   import gui.UpsellManager;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomXtCommManager;
   
   public class ItemWindowAdventure extends ItemWindowBase
   {
      private var _scriptDef:Object;
      
      public function ItemWindowAdventure(param1:Function, param2:MovieClip, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _scriptDef = QuestXtCommManager.getScriptDef(param9.scriptIds[param4]);
         super(_scriptDef.bannerMediaRefId,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:AvatarInfo = null;
         _window.txt.mouseEnabled = false;
         _window.txt.mouseChildren = false;
         LocalizationManager.translateId(_window.txt.titleTxt,_scriptDef.titleStrId);
         if(_window["memLock"])
         {
            _window["memLock"].visible = _scriptDef.membersOnly;
            _window["memLock"].mouseEnabled = false;
            _window["memLock"].mouseChildren = false;
            _loc1_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(_loc1_)
            {
               if(_loc1_.questLevel < _scriptDef.levelMin)
               {
                  _window.tag.visible = false;
               }
            }
         }
         if(_scriptDef.defId == 21)
         {
            _window.tag.visible = false;
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null && !(_memberOnlyDown != null && !gMainFrame.userInfo.isMember))
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
      }
      
      public function performContinueChecks() : Object
      {
         var _loc1_:AvatarInfo = null;
         var _loc2_:Object = null;
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(performContinueChecks);
            return null;
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(!RoomXtCommManager.isSwitching)
         {
            if(_scriptDef.membersOnly && !gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("adventures","adventure/" + _scriptDef.defId);
               return null;
            }
            _loc1_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(_loc1_)
            {
               if(_scriptDef.playAsPet)
               {
                  _loc2_ = PetManager.myActivePet;
                  if(!_loc2_)
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                     return null;
                  }
                  if(!PetManager.canPetGoInEnviroType(_loc2_.currPetDef,_loc2_.createdTs,_scriptDef.avatarType))
                  {
                     switch(_scriptDef.avatarType)
                     {
                        case 1:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19648));
                           break;
                        case 2:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19649));
                           break;
                        case 4:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19650));
                           break;
                        case 5:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19655));
                     }
                     return null;
                  }
               }
               else
               {
                  if(AvatarManager.playerAvatar && !AvatarManager.isValidEnviro(_scriptDef.avatarType))
                  {
                     switch(_scriptDef.avatarType)
                     {
                        case 1:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                           break;
                        case 2:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                           break;
                        case 4:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                           break;
                        case 5:
                     }
                     return null;
                  }
                  if(_loc1_.questLevel < _scriptDef.levelMin)
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_scriptDef.levelMin));
                     return null;
                  }
                  if(_scriptDef.avatarLimit == 1 && _window.tag.visible)
                  {
                     return {
                        "func":QuestXtCommManager.sendQuestCreateJoinPublic,
                        "defId":_scriptDef.defId
                     };
                  }
               }
               if(_window.tag.visible)
               {
                  return {
                     "func":AdventureExpertPopup.init,
                     "defId":_scriptDef.defId
                  };
               }
               return null;
            }
            return null;
         }
         return null;
      }
   }
}

