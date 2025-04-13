package gui.itemWindows
{
   import den.DenItem;
   import flash.display.MovieClip;
   import gui.LoadingSpiral;
   import masterpiece.MasterpieceDisplayItem;
   
   public class ItemWindowMasterpiece extends ItemWindowBase
   {
      private var _masterpieceDisplayItem:MasterpieceDisplayItem;
      
      protected var _selectedItems:Array;
      
      public function ItemWindowMasterpiece(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _selectedItems = param9 as Array;
         super("itemWindow",param1,param2,param3,param4,param5,param6,param7,param8,true);
      }
      
      public function get inUse() : Boolean
      {
         return _window.cir.currentFrameLabel == "down";
      }
      
      public function set inUse(param1:Boolean) : void
      {
         if(param1)
         {
            _window.cir.gotoAndStop("down");
         }
         else
         {
            _window.cir.gotoAndStop("up");
         }
      }
      
      public function get currItem() : DenItem
      {
         return _currItem as DenItem;
      }
      
      public function cloneItem(param1:Function = null) : MovieClip
      {
         return _masterpieceDisplayItem.clone(param1);
      }
      
      public function update(param1:Boolean) : void
      {
         inUse = param1;
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
         if(!_isCurrItemLoaded && _currItem)
         {
            for each(var _loc3_ in _selectedItems)
            {
               if(_loc3_.iid == currItem.invIdx)
               {
                  inUse = true;
               }
            }
            _spiral = new LoadingSpiral(_window.iconLayer);
            _isCurrItemLoaded = true;
            _masterpieceDisplayItem = new MasterpieceDisplayItem();
            _masterpieceDisplayItem.init(currItem,onMasterpieceItemLoaded);
         }
      }
      
      override public function destroy() : void
      {
         if(_masterpieceDisplayItem)
         {
            _masterpieceDisplayItem.destroy();
            _masterpieceDisplayItem = null;
         }
         super.destroy();
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         resetVisibility();
         _window.scaleX = _window.scaleY = 1.5;
         _window.sizeCont.scaleX = _window.sizeCont.scaleY = 1.5;
      }
      
      private function onMasterpieceItemLoaded(param1:MasterpieceDisplayItem, param2:MovieClip) : void
      {
         var _loc3_:Number = NaN;
         if(_window)
         {
            _loc3_ = _window.iconLayer.width / Math.max(_masterpieceDisplayItem.width,_masterpieceDisplayItem.height);
            _masterpieceDisplayItem.scaleX = _masterpieceDisplayItem.scaleY = _loc3_;
            _window.iconLayer.addChild(_masterpieceDisplayItem);
            _spiral.destroy();
         }
      }
      
      private function resetVisibility() : void
      {
         _window.lock.visible = false;
         _window.lockOpen.visible = false;
         _window.gray.visible = false;
         _window.gift.visible = false;
         _window.addBtn.visible = false;
         _window.removeBtn.visible = false;
         _window.ocean.visible = false;
         _window.rare.visible = false;
         _window.avtSpecific.visible = false;
         _window.avtSpecificIcon.visible = false;
         _window.avtSpecificHighlight.visible = false;
         _window.rareDiamondTag.visible = false;
         _window.diamond.visible = false;
         _window.customDiamond.visible = false;
         _window.previewBtn.visible = false;
         _window.certBtn.visible = false;
         _window.shopItem.visible = false;
         super.onWindowRollOut(null);
      }
   }
}

