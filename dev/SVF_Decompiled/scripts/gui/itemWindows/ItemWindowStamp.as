package gui.itemWindows
{
   import ecard.ECardImageBase;
   
   public class ItemWindowStamp extends ItemWindowBase
   {
      private var stampImageBase:ECardImageBase;
      
      public function ItemWindowStamp(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("StampBtn",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            setChildrenAndInitialConditions();
            addEventListeners();
            stampImageBase = new ECardImageBase();
            stampImageBase.init(int(_currItem),onImageLoaded);
         }
      }
      
      private function onImageLoaded() : void
      {
         if(_iconLayerName != "" && Boolean(stampImageBase.hasOwnProperty(_iconLayerName)))
         {
            _window.imgLayer.addChild(stampImageBase[_iconLayerName]);
         }
         stampImageBase[_iconLayerName].scaleX = 0.6;
         stampImageBase[_iconLayerName].scaleY = 0.6;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
      }
   }
}

