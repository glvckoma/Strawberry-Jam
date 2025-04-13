package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import quest.QuestXtCommManager;
   
   public class AdventureJoin
   {
      public static const NORMAL_TYPE:String = "normal";
      
      public static const CUSTOM_WAITING_TYPE:String = "custParty";
      
      public static const CUSTOM_SETTINGS_TYPE:String = "custSettings";
      
      public static const NO_LOBBY:String = "noPlayers";
      
      private const MEDIA_ID:int = 2249;
      
      private var _scriptDef:Object;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _numPlayersMC:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inParamsWaiting:Object;
      
      private var _artLoadingSpiral:LoadingSpiral;
      
      private var _closeCallback:Function;
      
      private var _savedParams:Array;
      
      private var _type:String;
      
      private var _difficulty:int;
      
      private var _numPlayersText:String;
      
      private var _bigPet:GuiPet;
      
      public function AdventureJoin()
      {
         super();
      }
      
      public function init(param1:int, param2:String, param3:int, param4:Function) : void
      {
         _savedParams = [];
         _scriptDef = QuestXtCommManager.getScriptDef(param1);
         _type = param2;
         _difficulty = param3;
         _guiLayer = GuiManager.guiLayer;
         _closeCallback = param4;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2249,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.closeAll();
         TradeManager.closeAllTradingRelatedPopups();
         removeEventListeners();
         if(_bigPet)
         {
            _bigPet.destroy();
            _bigPet = null;
         }
         _mediaHelper.destroy();
         _mediaHelper = null;
         if(_popup)
         {
            DarkenManager.unDarken(_popup);
            _guiLayer.removeChild(_popup);
            _popup = null;
         }
         GuiManager.setSwapBtnGray(false);
      }
      
      public function handleWaitResponse(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Avatar = null;
         var _loc8_:AvatarInfo = null;
         if(_popup && (_type == "normal" || _type == "custParty"))
         {
            _loc4_ = int(_scriptDef.avatarLimit);
            _loc5_ = 1;
            _loc2_ = 1;
            while(_loc2_ < _loc4_ + 1)
            {
               while(_numPlayersMC["p" + _loc2_].char.charLayer.numChildren > 0)
               {
                  _numPlayersMC["p" + _loc2_].char.charLayer.removeChildAt(0);
               }
               _numPlayersMC["p" + _loc2_].char.gotoAndPlay("waiting");
               _numPlayersMC["p" + _loc2_].char.nameBar.lastName_txt.text = "";
               _loc2_++;
            }
            _loc7_ = 2;
            for(; _loc7_ < _loc4_ + 2; _loc7_++)
            {
               if(_loc7_ < param1.length)
               {
                  _loc3_ = int(param1[_loc7_]);
                  _numPlayersMC["p" + (_loc7_ - 1)].char.gotoAndPlay("up");
                  _loc6_ = AvatarManager.getAvatarBySfsUserId(_loc3_);
                  if(_loc6_)
                  {
                     _loc8_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc6_.userName);
                  }
                  if(_loc6_ == null || _loc8_ == null)
                  {
                     _savedParams[_loc3_] = _numPlayersMC["p" + (_loc7_ - 1)];
                     AvatarXtCommManager.requestAvatarGetBySfsId(_loc3_,onAvatarGetReceived);
                     continue;
                  }
                  setupAvatar(_numPlayersMC["p" + (_loc7_ - 1)],_loc6_,_loc8_.currPet);
               }
               else
               {
                  _numPlayersMC["p" + (_loc7_ - 1)].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(_numPlayersMC["p" + (_loc7_ - 1)].char.nameBar.firstName_txt,11101);
                  _numPlayersMC["p" + (_loc7_ - 1)].char.nameBar.lastName_txt.text = "";
               }
               _numPlayersMC["p" + (_loc7_ - 1)].char.nameBar.visible = false;
            }
         }
         else
         {
            _inParamsWaiting = param1;
         }
      }
      
      private function setupAvatar(param1:MovieClip, param2:Avatar, param3:Object) : void
      {
         var _loc9_:GuiPet = null;
         var _loc7_:AvatarView = null;
         var _loc6_:Point = null;
         var _loc8_:String = null;
         var _loc10_:int = 0;
         var _loc4_:* = null;
         var _loc5_:String = null;
         if(_scriptDef.playAsPet)
         {
            _loc9_ = new GuiPet(param3.createdTs,0,param3.lBits,param3.uBits,param3.eBits,param3.type,param3.name,param3.personalityDefId,param3.favoriteToyDefId,param3.favoriteFoodDefId,onBigPetLoaded);
            param1.char.charLayer.addChild(_loc9_);
            param1.char.nameBar.firstName_txt.text = _loc9_.petName;
         }
         else
         {
            _loc7_ = new AvatarView();
            _loc7_.init(param2);
            _loc7_.playAnim(15,false,0,null,true);
            _loc7_.scaleX = 0.7;
            _loc7_.scaleY = 0.7;
            _loc6_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc7_.avTypeId);
            _loc7_.x = _loc6_.x;
            _loc7_.y = _loc6_.y + 5;
            param1.char.charLayer.addChild(_loc7_);
            _loc8_ = param2.avName;
            _loc10_ = int(_loc8_.indexOf(" "));
            if(_loc10_ != -1)
            {
               _loc4_ = _loc8_.substr(0,_loc10_);
               _loc5_ = _loc8_.substr(_loc10_ + 1,_loc8_.length);
            }
            else
            {
               _loc4_ = _loc8_;
            }
            param1.char.nameBar.firstName_txt.text = _loc4_;
            if(_loc5_)
            {
               param1.char.nameBar.lastName_txt.text = _loc5_;
            }
         }
         param1.char.nameBar.visible = false;
      }
      
      private function onBigPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         param2.y += 30;
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         if(_popup && param2)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
            if(!_loc5_)
            {
               throw new Error("onAvatarSFSGetReceived and avInfo is null");
            }
            _loc6_ = _loc5_.perUserAvId;
            _loc7_ = AvatarManager.getAvatarByUserName(param1);
            if(_loc7_ == null)
            {
               _loc7_ = AvatarUtility.generateNew(_loc6_,null,param1,-1,0);
            }
            setupAvatar(_savedParams[param4],_loc7_,_loc5_.currPet);
            delete _savedParams[param4];
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var _loc4_:AvatarView = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc5_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         _popup = MovieClip(param1.getChildAt(0));
         if(_type == "noPlayers")
         {
            _popup.gotoAndStop("noPlayers");
            LocalizationManager.translateId(_popup.contTxt,_scriptDef.descStrId);
            _artLoadingSpiral = new LoadingSpiral(_popup.artWindow,_popup.artWindow.width * 0.5,_popup.artWindow.height * 0.5);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_scriptDef.mediaRefId,onArtLoaded);
         }
         else
         {
            _popup.gotoAndStop("normal");
            switch(_scriptDef.avatarLimit)
            {
               case 4:
                  _numPlayersMC = _popup.fourPlayers;
                  _popup.sixPlayers.visible = false;
                  _popup.eightPlayers.visible = false;
                  _popup.twelvePlayers.visible = false;
                  break;
               case 6:
                  _numPlayersMC = _popup.sixPlayers;
                  _popup.fourPlayers.visible = false;
                  _popup.eightPlayers.visible = false;
                  _popup.twelvePlayers.visible = false;
                  break;
               case 8:
                  _numPlayersMC = _popup.eightPlayers;
                  _popup.sixPlayers.visible = false;
                  _popup.fourPlayers.visible = false;
                  _popup.twelvePlayers.visible = false;
                  break;
               case 12:
                  _numPlayersMC = _popup.twelvePlayers;
                  _popup.sixPlayers.visible = false;
                  _popup.fourPlayers.visible = false;
                  _popup.eightPlayers.visible = false;
            }
            LocalizationManager.translateId(_numPlayersMC.contTxt,_scriptDef.descStrId);
            _artLoadingSpiral = new LoadingSpiral(_popup.artWindow,_popup.artWindow.width * 0.5,_popup.artWindow.height * 0.5);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_scriptDef.mediaRefId,onArtLoaded);
            if(_type == "normal" || _type == "custParty")
            {
               _loc4_ = new AvatarView();
               _loc4_.init(AvatarManager.playerAvatar);
               _loc4_.playAnim(15,false,0,null,true);
               _numPlayersMC.p1.char.charLayer.addChild(_loc4_);
               if(_type == "custParty")
               {
                  _popup.playBtn.visible = false;
                  _popup.playBg.visible = false;
               }
               _loc6_ = AvatarManager.playerAvatar.avName;
               _loc7_ = int(_loc6_.indexOf(" "));
               if(_loc7_ != -1)
               {
                  _loc2_ = _loc6_.substr(0,_loc7_);
                  _loc3_ = _loc6_.substr(_loc7_ + 1,_loc6_.length);
               }
               else
               {
                  _loc2_ = _loc6_;
               }
               _numPlayersMC.p1.char.nameBar.firstName_txt.text = _loc2_;
               if(_loc3_)
               {
                  _numPlayersMC.p1.char.nameBar.lastName_txt.text = _loc3_;
               }
               _numPlayersMC.p1.char.nameBar.visible = false;
               _loc5_ = 2;
               while(_loc5_ < _scriptDef.avatarLimit + 1)
               {
                  _numPlayersMC["p" + _loc5_].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(_numPlayersMC["p" + _loc5_].char.nameBar.firstName_txt,11101);
                  _numPlayersMC["p" + _loc5_].char.nameBar.lastName_txt.text = "";
                  _loc5_++;
               }
            }
         }
         if(_difficulty == 0)
         {
            _popup.hardMode.visible = false;
         }
         LocalizationManager.translateId(_popup.titleTxt,_scriptDef.titleStrId);
         addEventListeners();
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
         if(_inParamsWaiting != null)
         {
            handleWaitResponse(_inParamsWaiting);
            _inParamsWaiting = null;
         }
      }
      
      private function onArtLoaded(param1:MovieClip) : void
      {
         while(_popup.artWindow.numChildren > 0)
         {
            _popup.artWindow.removeChildAt(0);
         }
         _popup.artWindow.addChild(param1);
         if(_artLoadingSpiral != null)
         {
            _artLoadingSpiral.destroy();
            _artLoadingSpiral = null;
         }
      }
      
      private function addEventListeners() : void
      {
         var _loc1_:int = 0;
         if(_popup)
         {
            _popup.addEventListener("mouseDown",onPopup,false,0,true);
            _popup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
            if(_type == "noPlayers")
            {
               _popup.playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
            }
            else
            {
               _loc1_ = 1;
               while(_loc1_ < _scriptDef.avatarLimit + 1)
               {
                  _numPlayersMC["p" + _loc1_].char.addEventListener("rollOver",onCharRollOver,false,0,true);
                  _numPlayersMC["p" + _loc1_].char.addEventListener("rollOut",onCharRollOut,false,0,true);
                  _loc1_++;
               }
               if(_type == "normal")
               {
                  _popup.playBtn.addEventListener("mouseDown",onPlayBtn,false,0,true);
               }
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         var _loc1_:int = 0;
         if(_popup)
         {
            _popup.removeEventListener("mouseDown",onPopup);
            _popup.bx.removeEventListener("mouseDown",onCloseBtn);
            if(_type == "noPlayers")
            {
               _popup.playBtn.removeEventListener("mouseDown",onPlayBtn);
            }
            else
            {
               _loc1_ = 1;
               while(_loc1_ < _scriptDef.avatarLimit + 1)
               {
                  _numPlayersMC["p" + _loc1_].char.removeEventListener("rollOver",onCharRollOver);
                  _numPlayersMC["p" + _loc1_].char.removeEventListener("rollOut",onCharRollOut);
                  _loc1_++;
               }
               if(_type == "normal")
               {
                  _popup.playBtn.removeEventListener("mouseDown",onPlayBtn);
               }
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         QuestXtCommManager.sendQuestJoinCancel();
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
      
      private function onPlayBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(_loc2_ && _loc2_.questLevel < _scriptDef.levelMin)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_scriptDef.levelMin));
            return;
         }
         if(_type == "normal")
         {
            QuestXtCommManager.sendQuestStartRequest();
         }
         else if(_type == "noPlayers")
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(_scriptDef.defId,0);
         }
      }
      
      private function onCharRollOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("over");
         param1.currentTarget.nameBar.visible = true;
      }
      
      private function onCharRollOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("up");
         param1.currentTarget.nameBar.visible = false;
      }
   }
}

