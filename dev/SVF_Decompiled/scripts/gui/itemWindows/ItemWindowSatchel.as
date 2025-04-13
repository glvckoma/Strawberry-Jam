package gui.itemWindows
{
   import currency.UserCurrency;
   
   public class ItemWindowSatchel extends ItemWindowBase
   {
      private var _count:int;
      
      private var _scale:Number = 1;
      
      private var _frame:String = "shop";
      
      public function ItemWindowSatchel(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _count = UserCurrency.getCurrency(UserCurrency.usableCraftTypes[param4]);
         if(param9)
         {
            _scale = param9.scale;
            _frame = param9.frame;
         }
         super(param2,param1,param2,param3,param4,param5,param6,param7,param8);
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
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_window.currentFrameLabel != _frame)
         {
            _window.gotoAndStop(_frame);
         }
         if(_window.scaleX != _scale)
         {
            _window.scaleX = _window.scaleY = _scale;
         }
         _window.txt.text = Utility.convertNumberToString(_count);
      }
      
      public function update() : void
      {
         _count = UserCurrency.getCurrency(UserCurrency.usableCraftTypes[index]);
         setChildrenAndInitialConditions();
      }
   }
}

