package gui.itemWindows
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class ItemWindowNameBarIcon extends ItemWindowBase
   {
      private var _currColorId:int;
      
      private var _loadIcons:Boolean;
      
      private var _icon1:MovieClip;
      
      private var _icon2:MovieClip;
      
      private var _iconsMediaHelper:MediaHelper;
      
      private var _callbackFunction:Function;
      
      private var _triedToLoadCurrItem:Boolean;
      
      private var _isLoadingIcon:Boolean;
      
      public function ItemWindowNameBarIcon(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _currColorId = param9.currColorId;
         _loadIcons = param9.loadIcons;
         _callbackFunction = param9.callbackFunction;
         super("selNub",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get mouse() : MovieClip
      {
         return _window.nub.mouse;
      }
      
      public function update(param1:int) : void
      {
         _currColorId = param1;
         setChildrenAndInitialConditions();
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded && !_loadIcons && _window.nub.hasOwnProperty("mouse"))
         {
            _isCurrItemLoaded = true;
            _window.nub.mouse.gotoAndStop(1);
            _window.nub.mouse.mouse.light.addChild(_currItem.iconMouse);
            _window.nub.mouse.up.light.addChild(_currItem.iconUp);
         }
         else
         {
            _triedToLoadCurrItem = true;
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_currItem)
         {
            _window["updateColor"](_currColorId);
            _window.scaleX = 1.5;
            _window.scaleY = 1.5;
            if(_loadIcons && !_isLoadingIcon)
            {
               _window.y += _window.height * 0.5;
               while(_window.nub.mouse.mouse.light.numChildren > 0)
               {
                  _window.nub.mouse.mouse.light.removeChildAt(0);
               }
               while(_window.nub.mouse.up.light.numChildren > 0)
               {
                  _window.nub.mouse.up.light.removeChildAt(0);
               }
               _window.nub.mouse.gotoAndStop(1);
               loadIcon();
            }
         }
         else
         {
            _window.visible = false;
         }
      }
      
      private function loadIcon() : void
      {
         _isLoadingIcon = true;
         _iconsMediaHelper = new MediaHelper();
         _iconsMediaHelper.init(int(_currItem),onIconsLoaded);
      }
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         if(param1 && _window)
         {
            if(_icon1 == null)
            {
               _icon1 = param1;
               _iconsMediaHelper = new MediaHelper();
               _iconsMediaHelper.init(int(_currItem),onIconsLoaded);
            }
            else
            {
               _loadIcons = false;
               _icon2 = param1;
               _currItem = {
                  "iconMouse":_icon1,
                  "iconUp":_icon2
               };
               _callbackFunction(_icon1,_icon2,_index);
               _icon1 = null;
               _icon2 = null;
               _callbackFunction = null;
               _iconsMediaHelper.destroy();
               _iconsMediaHelper = null;
               if(_triedToLoadCurrItem)
               {
                  loadCurrItem();
               }
            }
         }
      }
   }
}

