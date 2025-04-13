package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import quest.QuestXtCommManager;
   
   public class ItemWindowCustPlayers extends ItemWindowBase
   {
      private var _onBxBtn:Function;
      
      private var _currUserName:String;
      
      private var _ai:AvatarInfo;
      
      private var _scriptDefId:int;
      
      public function ItemWindowCustPlayers(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _onBxBtn = param9.onBxBtn;
         _scriptDefId = param9.scriptDefId;
         super(2301,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.bx.visible = false;
         super.setChildrenAndInitialConditions();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:Avatar = null;
         var _loc4_:AvatarInfo = null;
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            while(_window.char.charLayer.numChildren > 0)
            {
               _window.char.charLayer.removeChildAt(0);
            }
            _window.char.gotoAndPlay("waiting");
            LocalizationManager.translateId(_window.nameBar.firstName_txt,11101);
            _window.nameBar.lastName_txt.text = "";
            _window.char.gotoAndPlay("up");
            _loc3_ = AvatarManager.getAvatarBySfsUserId(int(_currItem));
            if(_loc3_)
            {
               _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc3_.userName);
            }
            if(_loc3_ == null || _loc4_ == null)
            {
               AvatarXtCommManager.requestAvatarGetBySfsId(int(_currItem),onAvatarGetReceived);
            }
            else
            {
               setupAvatar(_loc3_,_loc4_.currPet);
            }
            _isCurrItemLoaded = true;
         }
      }
      
      override protected function addEventListeners() : void
      {
         _window.bx.addEventListener("mouseDown",_onBxBtn,false,0,true);
         super.addEventListeners();
      }
      
      override protected function removeEventListeners() : void
      {
         _window.bx.removeEventListener("mouseDown",_onBxBtn);
         super.removeEventListeners();
      }
      
      public function showXBtn(param1:Boolean) : void
      {
         _window.bx.visible = param1;
      }
      
      public function get userName() : String
      {
         return _currUserName;
      }
      
      public function get char() : MovieClip
      {
         return _window.char;
      }
      
      private function setupAvatar(param1:Avatar, param2:Object) : void
      {
         var _loc9_:GuiPet = null;
         var _loc7_:AvatarView = null;
         var _loc5_:Point = null;
         var _loc8_:String = null;
         var _loc10_:int = 0;
         var _loc3_:* = null;
         var _loc4_:String = null;
         var _loc11_:Object = QuestXtCommManager.getScriptDef(_scriptDefId);
         if(_loc11_.playAsPet)
         {
            _loc9_ = new GuiPet(param2.createdAt,0,param2.lBits,param2.uBits,param2.eBits,param2.type,param2.name,param2.personalityDefId,param2.favoriteToyDefId,param2.favoriteFoodDefId,onBigPetLoaded);
            _window.char.charLayer.addChild(_loc9_);
            _window.nameBar.firstName_txt.text = _loc9_.petName;
         }
         else
         {
            _loc7_ = new AvatarView();
            _loc7_.init(param1);
            _loc7_.playAnim(15,false,0,null,true);
            _loc7_.scaleX = 0.7;
            _loc7_.scaleY = 0.7;
            _loc5_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc7_.avTypeId);
            _loc7_.x = _loc5_.x;
            _loc7_.y = _loc5_.y + 5;
            _window.char.charLayer.addChild(_loc7_);
            _loc8_ = param1.avName;
            _loc10_ = int(_loc8_.indexOf(" "));
            if(_loc10_ != -1)
            {
               _loc3_ = _loc8_.substr(0,_loc10_);
               _loc4_ = _loc8_.substr(_loc10_ + 1,_loc8_.length);
            }
            else
            {
               _loc3_ = _loc8_;
            }
            _window.nameBar.firstName_txt.text = _loc3_;
            if(_loc4_)
            {
               _window.nameBar.lastName_txt.text = _loc4_;
            }
         }
         _currUserName = param1.userName;
         _ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param1.userName,param1.perUserAvId);
         var _loc6_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.userName);
         if(_ai && _loc6_ && _ai.questLevel > 0)
         {
            loadQuestShape(_loc6_.nameBarData);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         if(param2)
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
            setupAvatar(_loc7_,_loc5_.currPet);
         }
      }
      
      private function onBigPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         param2.scaleY = 1.5;
         param2.scaleX = 1.5;
         param2.y += 30;
      }
      
      private function loadQuestShape(param1:int) : void
      {
         var _loc2_:String = _window.xpShape.currentLabels[Utility.getColorId(param1) - 1].name;
         _window.xpShape.visible = true;
         if(_loc2_ == "black")
         {
            _window.xpShape.gotoAndStop(2);
            _window.xpShape.gotoAndStop(_loc2_);
         }
         if(_window.xpShape.currentFrameLabel != _loc2_)
         {
            _window.xpShape.gotoAndStop(_loc2_);
         }
         Utility.createXpShape(_ai.questLevel,true,_window.xpShape[_loc2_].mouse.up.icon,null,param1);
      }
   }
}

