package gui.itemWindows
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class ItemWindowGame extends ItemWindowBase
   {
      public function ItemWindowGame(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("gameBtnCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get itemLayer() : MovieClip
      {
         return _window.itemLayer;
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
            if(_currItem)
            {
               if(_iconLayerName != "" && Boolean(_currItem.hasOwnProperty(_iconLayerName)))
               {
                  _window.itemLayer.addChild(_currItem[_iconLayerName]);
               }
               else
               {
                  _window.itemLayer.addChild(DisplayObject(_currItem));
               }
            }
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null)
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
            if(_memberOnlyDown != null)
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
      }
   }
}

