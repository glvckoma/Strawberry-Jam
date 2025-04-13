package gui.itemWindows
{
   import Party.PartyManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.WindowAndScrollbarGenerator;
   import gui.WindowGenerator;
   import localization.LocalizationManager;
   
   public class ItemWindowParty extends ItemWindowBase
   {
      private var _defId:int;
      
      private var _isGame:Boolean;
      
      private var _additionalIndex:int;
      
      private var _partyDef:Object;
      
      private var _printTimeFunc:Function;
      
      private var _creatorName:String;
      
      private var _customPartyName:String;
      
      private var _customPartyTimeLeft:Number;
      
      private var _isCustom:Boolean;
      
      public function ItemWindowParty(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         var _loc10_:int = 0;
         _additionalIndex = param9.additionalIndex;
         _printTimeFunc = param9.printTimeFunc;
         _customPartyName = "";
         _customPartyTimeLeft = 0;
         if(param2 != null && !(param2 is int))
         {
            _creatorName = param2.creator;
            _customPartyName = param2.name;
            _customPartyTimeLeft = param2.timeLeft;
            _partyDef = PartyManager.getPartyDef(param2.defId);
            _loc10_ = int(_partyDef.mediaRefId);
            param2 = param2.defId;
            _useToolTip = true;
         }
         else
         {
            _loc10_ = int(param9.mediaRefId[param4]);
         }
         super(_loc10_,param1,param2,param3,param4,param5,param6,param7,param8,_useToolTip);
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.anims.mouseEnabled = false;
         _window.anims.mouseChildren = false;
         _window.txt.mouseEnabled = false;
         _window.txt.mouseChildren = false;
         if(_currItem || _partyDef != null)
         {
            if(_partyDef == null)
            {
               _partyDef = PartyManager.getPartyDef(_currItem as int);
            }
            _defId = int(_partyDef.id);
            _isGame = _partyDef.isGame == "1";
            _isCustom = _partyDef.isCustom == "1";
            setupTextAndAnims(_printTimeFunc != null ? _printTimeFunc(_isCustom ? _customPartyTimeLeft : index) : "");
            if(_customPartyName != "")
            {
               titleTextWithString = _customPartyName;
            }
            else if(int(_partyDef.titleStrId) != 0)
            {
               titleText = _partyDef.titleStrId;
            }
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
            if(_useToolTip)
            {
               addEventListener("rollOver",onWindowRollOver,false,0,true);
               addEventListener("rollOut",onWindowRollOut,false,0,true);
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
      
      override protected function onWindowRollOver(param1:MouseEvent) : void
      {
         if(_windowGenerator == null)
         {
            if(this.parent.parent is WindowGenerator)
            {
               _windowGenerator = WindowGenerator(this.parent.parent);
            }
            else
            {
               _windowGenerator = WindowAndScrollbarGenerator(this.parent.parent);
            }
         }
         if(_windowGenerator.isIndexInView(_visibilityIndex))
         {
            _windowGenerator.toolTip.init(_windowGenerator.parent.parent,_printTimeFunc != null ? _printTimeFunc(_isCustom ? _customPartyTimeLeft : index) : "",this.x + _windowGenerator.boxWidth * 0.5 - _itemXLocation + _windowGenerator.parent.x,this.y + _windowGenerator.boxHeight - _itemYLocation + _windowGenerator.parent.y);
            _windowGenerator.toolTip.startTimer(param1);
         }
      }
      
      override protected function onWindowRollOut(param1:MouseEvent) : void
      {
         _windowGenerator.toolTip.resetTimerAndSetVisibility();
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
      }
      
      public function setupTextAndAnims(param1:String) : void
      {
         if(_window)
         {
            if(_customPartyName != "")
            {
               _window.goBtn.visible = true;
            }
            else if(param1 != "")
            {
               _window.goBtn.visible = false;
               if(_window.txt.timeTxt)
               {
                  LocalizationManager.updateToFit(_window.txt.timeTxt,param1);
               }
            }
            else
            {
               _window.goBtn.visible = true;
               if(_window.txt.timeTxt)
               {
                  _window.txt.timeTxt.visible = false;
               }
               _window.anims.animate();
            }
         }
      }
      
      public function get additionalIndex() : int
      {
         return _additionalIndex;
      }
      
      public function get txt() : MovieClip
      {
         return _window.txt;
      }
      
      public function set titleText(param1:int) : void
      {
         if(_window.txt.titleTxtCont && _window.txt.titleTxtCont.hasOwnProperty("titleTxt"))
         {
            LocalizationManager.translateId(_window.txt.titleTxtCont.titleTxt,param1);
         }
      }
      
      public function set titleTextWithString(param1:String) : void
      {
         if(_window.txt.titleTxtCont && _window.txt.titleTxtCont.hasOwnProperty("titleTxt"))
         {
            LocalizationManager.updateToFit(_window.txt.titleTxtCont.titleTxt,param1);
         }
      }
      
      public function set defId(param1:int) : void
      {
         _defId = param1;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function set isGame(param1:Boolean) : void
      {
         _isGame = param1;
      }
      
      public function get isGame() : Boolean
      {
         return _isGame;
      }
      
      public function get timeLeft() : int
      {
         return _customPartyTimeLeft;
      }
      
      public function get sizeCont() : MovieClip
      {
         return _window.sizeCont;
      }
   }
}

