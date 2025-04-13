package gui.itemWindows
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import newspaper.NewspaperData;
   import newspaper.NewspaperDef;
   import newspaper.NewspaperManager;
   
   public class ItemWindowToggleImage extends ItemWindowBase
   {
      private const WINDOW_ID:int = 5842;
      
      private var _newspaperDef:NewspaperDef;
      
      private var _mediaHelper:MediaHelper;
      
      private var _onMouseDown:Function;
      
      public function ItemWindowToggleImage(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _newspaperDef = NewspaperDef(param2);
         _onMouseDown = param5;
         super(5842,param1,param2,param3,param4,myMouseDown,myMouseOver,myMouseOut,param8,false);
      }
      
      public function get window() : MovieClip
      {
         return _window;
      }
      
      public function myMouseOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_window.itemWindowBtn.down.visible)
         {
            _window.itemWindowBtn.mouse.gotoAndPlay(1);
            this.parent.setChildIndex(this,this.parent.numChildren - 1);
            _window.itemWindowBtn.itemWindow.scaleX = 1.25;
            _window.itemWindowBtn.itemWindow.scaleY = 1.25;
         }
      }
      
      public function myMouseOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_window.itemWindowBtn.down.visible)
         {
            this.parent.setChildIndex(this,0);
            _window.itemWindowBtn.mouse.gotoAndStop(1);
            _window.itemWindowBtn.itemWindow.scaleX = 1;
            _window.itemWindowBtn.itemWindow.scaleY = 1;
         }
      }
      
      public function myMouseDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_window.itemWindowBtn.down && !_window.itemWindowBtn.down.visible)
         {
            _window.itemWindowBtn.down.visible = true;
            _window.itemWindowBtn.mouse.visible = false;
            _onMouseDown(_index);
         }
         else
         {
            _window.itemWindowBtn.mouse.visible = true;
            _window.itemWindowBtn.mouse.gotoAndPlay(1);
            if(_window.itemWindowBtn.down)
            {
               _window.itemWindowBtn.down.visible = false;
            }
         }
      }
      
      public function downToUpdate() : void
      {
         _window.itemWindowBtn.down.visible = false;
         _window.itemWindowBtn.mouse.visible = true;
         _window.itemWindowBtn.mouse.gotoAndStop(1);
         _window.itemWindowBtn.itemWindow.scaleX = 1;
         _window.itemWindowBtn.itemWindow.scaleY = 1;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
            loadIcon();
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var _loc1_:NewspaperData = null;
         _window.giftBurst.visible = false;
         _window.newBurst.visible = false;
         if(_newspaperDef)
         {
            _loc1_ = NewspaperManager.getNewspaperData(_newspaperDef.defId);
            if(_loc1_ == null || _loc1_.timeSeen < _newspaperDef.availabilityStartTime)
            {
               _window.newBurst.visible = true;
            }
         }
         _window.itemWindowBtn.mouse.gotoAndStop(1);
         if(_index == 0)
         {
            _window.itemWindowBtn.down.visible = true;
            _window.itemWindowBtn.mouse.visible = false;
            if(this.parent)
            {
               this.parent.setChildIndex(this,this.parent.numChildren - 1);
            }
         }
         else
         {
            _window.itemWindowBtn.down.visible = false;
            _window.itemWindowBtn.mouse.visible = true;
         }
      }
      
      private function loadIcon() : void
      {
         if(_newspaperDef)
         {
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(_newspaperDef.iconMediaId,onIconLoaded);
         }
      }
      
      private function onIconLoaded(param1:MovieClip) : void
      {
         if(_window)
         {
            _window.itemWindowBtn.itemWindow.addChild(param1);
         }
         param1.mouseChildren = false;
         param1.mouseEnabled = false;
         _mediaHelper.destroy();
         _mediaHelper = null;
      }
   }
}

