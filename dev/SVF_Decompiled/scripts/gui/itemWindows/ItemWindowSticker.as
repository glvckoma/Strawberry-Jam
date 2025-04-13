package gui.itemWindows
{
   import den.DenItem;
   import flash.display.MovieClip;
   import gui.LoadingSpiral;
   import playerWall.StickerItem;
   
   public class ItemWindowSticker extends ItemWindowMasterpiece
   {
      private var _stickerItem:StickerItem;
      
      public function ItemWindowSticker(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override public function get currItem() : DenItem
      {
         throw new Error("This is not applicable to stickers");
      }
      
      public function get stickerMediaId() : int
      {
         return _currItem as int;
      }
      
      override public function cloneItem(param1:Function = null) : MovieClip
      {
         return _stickerItem.clone(param1);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded && _currItem != null)
         {
            _isCurrItemLoaded = true;
            for each(var _loc3_ in _selectedItems)
            {
               if(_loc3_.id == _currItem)
               {
                  inUse = true;
               }
            }
            _spiral = new LoadingSpiral(_window.iconLayer);
            _stickerItem = new StickerItem(int(_currItem),onStickerLoaded);
         }
      }
      
      private function onStickerLoaded() : void
      {
         var _loc1_:Number = NaN;
         if(_window)
         {
            _loc1_ = _window.iconLayer.width / Math.max(_stickerItem.width,_stickerItem.height);
            _stickerItem.scaleX = _stickerItem.scaleY = _loc1_;
            _window.iconLayer.addChild(_stickerItem);
            _spiral.destroy();
         }
      }
      
      override public function destroy() : void
      {
         if(_stickerItem != null)
         {
            _stickerItem.destroy();
            _stickerItem = null;
         }
         super.destroy();
      }
   }
}

