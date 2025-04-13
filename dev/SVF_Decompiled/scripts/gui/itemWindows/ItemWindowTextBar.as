package gui.itemWindows
{
   import flash.text.TextField;
   
   public class ItemWindowTextBar extends ItemWindowBase
   {
      public function ItemWindowTextBar(param1:Function, param2:String, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("userDenBtnCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded)
         {
            addEventListeners();
            _isCurrItemLoaded = true;
         }
         if(_currItem)
         {
            _window.txt.text = _currItem;
         }
      }
      
      public function get txt() : TextField
      {
         return _window.txt;
      }
      
      public function setText(param1:String) : void
      {
         _currItem = param1;
         _window.txt.text = param1;
      }
   }
}

