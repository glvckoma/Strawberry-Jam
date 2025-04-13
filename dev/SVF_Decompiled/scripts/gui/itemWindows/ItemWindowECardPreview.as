package gui.itemWindows
{
   import ecard.ECardImageBase;
   import flash.filters.ColorMatrixFilter;
   import gui.LoadingSpiral;
   
   public class ItemWindowECardPreview extends ItemWindowBase
   {
      private var _currentECardImageBase:ECardImageBase;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _currIndexFunction:Function;
      
      private var _shouldGrayOutPreviewFunction:Function;
      
      public function ItemWindowECardPreview(param1:Function, param2:int, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _currIndexFunction = param9.currIndexFunction;
         _shouldGrayOutPreviewFunction = param9.shouldGrayOutPreview;
         super(4474,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _loadingSpiral = new LoadingSpiral(_window.itemWindow,_window.itemWindow.width * 0.5,_window.itemWindow.height * 0.5);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_window && !_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
            _currentECardImageBase = new ECardImageBase();
            _currentECardImageBase.init(int(_currItem),onECardImageLoaded);
         }
      }
      
      public function update() : void
      {
         if(_currentECardImageBase && _currentECardImageBase.img)
         {
            if(_shouldGrayOutPreviewFunction())
            {
               if(_currIndexFunction() == index)
               {
                  _window.gotoAndStop("selected");
               }
               else
               {
                  _window.gotoAndStop("norm");
               }
               _currentECardImageBase.img.filters = null;
               if(_window.normCont)
               {
                  _window.normCont.activateGrayState(false);
               }
            }
            else
            {
               _window.gotoAndStop("norm");
               if(_window.normCont)
               {
                  _window.normCont.activateGrayState(true);
               }
               _currentECardImageBase.img.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
            }
         }
      }
      
      private function onECardImageLoaded() : void
      {
         _currentECardImageBase.img.scaleY = 0.255;
         _currentECardImageBase.img.scaleX = 0.255;
         if(_window)
         {
            _window.itemWindow.addChild(_currentECardImageBase.img);
            update();
         }
         _loadingSpiral.destroy();
         _loadingSpiral = null;
      }
   }
}

