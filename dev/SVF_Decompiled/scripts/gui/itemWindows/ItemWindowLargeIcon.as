package gui.itemWindows
{
   import Enums.AdoptAPetDef;
   import adoptAPet.AdoptAPetData;
   import adoptAPet.AdoptAPetManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   
   public class ItemWindowLargeIcon extends ItemWindowBase
   {
      private var _newIcon:MovieClip;
      
      private var _itemWindow:MovieClip;
      
      private var _icons:MovieClip;
      
      private var _currAdoptAPetDef:AdoptAPetDef;
      
      private var _currAdoptAPetData:AdoptAPetData;
      
      private var _mediaHelper:MediaHelper;
      
      private var _hasLoaded:Boolean;
      
      private var _currAdoptAPetIcon:Sprite;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _isForMyself:Boolean;
      
      private var _defIdSeenUpdated:int;
      
      public function ItemWindowLargeIcon(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         if(param2 is AdoptAPetData)
         {
            _currAdoptAPetData = param2 as AdoptAPetData;
            _currAdoptAPetDef = AdoptAPetManager.getAdoptAPetDef(_currAdoptAPetData.defId);
            param2 = _currAdoptAPetDef;
         }
         else if(param2 is AdoptAPetDef)
         {
            _currAdoptAPetDef = param2 as AdoptAPetDef;
         }
         _isForMyself = param9.isForMyself;
         super("iconWindowJazwares",param1,param2,param3,param4,param5,param6,param7,param8,true);
      }
      
      public function get currAdoptAPetDef() : AdoptAPetDef
      {
         return _currAdoptAPetDef;
      }
      
      public function get defIdSeenUpdated() : int
      {
         return _defIdSeenUpdated;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _newIcon = _window.newIcon;
         _newIcon.visible = false;
         _itemWindow = _window.itemWindow;
         _icons = _window.icons;
         _window.gray.visible = false;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_hasLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _loadingSpiral = new LoadingSpiral(_itemWindow,_itemWindow.width * 0.5,_itemWindow.height * 0.5);
            _hasLoaded = true;
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_currAdoptAPetDef.mediaRefId,onCurrItemLoaded);
         }
      }
      
      override protected function addEventListeners() : void
      {
         addEventListener("rollOver",onWindowRollOver,false,0,true);
         addEventListener("rollOut",onWindowRollOut,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         removeEventListener("rollOver",onWindowRollOver);
         removeEventListener("rollOut",onWindowRollOut);
      }
      
      private function onCurrItemLoaded(param1:MovieClip) : void
      {
         if(_window)
         {
            _currAdoptAPetIcon = param1.getChildAt(0) as Sprite;
            _currAdoptAPetIcon.x = _itemWindow.width * 0.5;
            _currAdoptAPetIcon.y = _itemWindow.height * 0.5;
            _itemWindow.addChild(_currAdoptAPetIcon);
            _icons.gotoAndStop(_currAdoptAPetDef.type + 1);
            if(_currAdoptAPetData == null)
            {
               _currAdoptAPetIcon.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
               _icons.filters = _currAdoptAPetIcon.filters;
               _window.gray.visible = true;
            }
            else
            {
               _newIcon.visible = !_currAdoptAPetData.hasBeenSeen;
            }
            if(_isForMyself && _newIcon.visible)
            {
               AdoptAPetManager.setUsableAdoptAPetDefAsSeen(currAdoptAPetDef.defId);
               _defIdSeenUpdated = currAdoptAPetDef.defId;
            }
         }
         _loadingSpiral.destroy();
         _loadingSpiral = null;
         _mediaHelper.destroy();
         _mediaHelper = null;
      }
   }
}

