package gui.itemWindows
{
   import ecard.ECard;
   import localization.LocalizationManager;
   
   public class ItemWindowECard extends ItemWindowBase
   {
      private var _currSelectedIndex:Function;
      
      private var _readFunction:Function;
      
      private var _specialTypeAppend:String;
      
      public function ItemWindowECard(param1:Function, param2:ECard, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _currSelectedIndex = param9.currSelectedIndex;
         _readFunction = param9.readFunction;
         _specialTypeAppend = param2.specialType == 1 ? "Valentine" : "";
         super("inboxMessage",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function select(param1:Boolean) : void
      {
         if(param1)
         {
            if(!_currItem.isRead && !_currItem.isReadInProcess)
            {
               _currItem.isReadInProcess = true;
               _window.gotoAndStop("new" + _specialTypeAppend);
               _window.selectedOutline.visible = true;
               _window.newIcon.mouseEnabled = false;
               _window.newIcon.mouseChildren = false;
               LocalizationManager.findAllTextfields(_window);
               _readFunction();
            }
            else if(_window.currentFrameLabel != "new" + _specialTypeAppend)
            {
               _window.gotoAndStop("selected" + _specialTypeAppend);
            }
         }
         else if(!_currItem.isRead)
         {
            _window.gotoAndStop("new" + _specialTypeAppend);
            _window.selectedOutline.visible = false;
            _window.newIcon.mouseEnabled = false;
            _window.newIcon.mouseChildren = false;
            LocalizationManager.findAllTextfields(_window);
         }
         else if(_window.currentFrameLabel == "selected" + _specialTypeAppend || _window.currentFrameLabel == "new" + _specialTypeAppend || _window.currentFrameLabel == "norm" && _specialTypeAppend != "")
         {
            _window.gotoAndStop(_specialTypeAppend == "" ? "norm" : _specialTypeAppend.toLowerCase());
         }
      }
      
      public function get currItem() : Object
      {
         return _currItem;
      }
      
      public function updateWithInput(param1:ECard) : void
      {
         _currItem = param1;
         update();
      }
      
      public function update() : void
      {
         if(_isCurrItemLoaded)
         {
            select(index == _currSelectedIndex());
            if(_window.messageTxt)
            {
               LocalizationManager.updateToFit(_window.messageTxt,_currItem.modifiedMsg,false,false,true,true);
            }
            _window.gift.visible = _currItem.isGift;
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.messageTxt.mouseEnabled = false;
         _window.nameTxt.mouseEnabled = false;
         _window.gift.visible = false;
         _window.gift.mouseEnabled = false;
         _window.gift.mouseChildren = false;
         _window.AJIcon.visible = false;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded)
         {
            addEventListeners();
            _isCurrItemLoaded = true;
            setChildrenAndInitialConditions();
            update();
            LocalizationManager.updateToFit(_window.nameTxt,_currItem.senderModeratedUserName);
         }
      }
   }
}

