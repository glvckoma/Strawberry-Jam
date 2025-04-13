package gui.itemWindows
{
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gui.WindowAndScrollbarGenerator;
   import gui.WindowGenerator;
   
   public class ItemWindowOriginalImages extends ItemWindowOriginal
   {
      private var _images:Array;
      
      private var _giftNames:Array;
      
      private var _eCards:Array;
      
      public function ItemWindowOriginalImages(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _images = param9.images as Array;
         _giftNames = param9.giftNames as Array;
         _eCards = param9.eCards as Array;
         param2 = _images[param4];
         super(param1,param2,param3,param4,param5,param6,param7,param8,null);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         resetVisibility();
         if(_spiral)
         {
            _spiral.destroy();
         }
      }
      
      override public function updateWithInput(param1:*) : void
      {
         _images = param1.images as Array;
         _giftNames = param1.giftNames as Array;
         _eCards = param1.eCards as Array;
         _currItem = _images[index];
         _isCurrItemLoaded = false;
         setChildrenAndInitialConditions();
         loadCurrItem();
         addEventListeners();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:Point = null;
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded && _currItem)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
            _loc4_ = _window.iconLayer.width / Math.max(_currItem.width,_currItem.height);
            _currItem.scaleX = _currItem.scaleY = _loc4_;
            _loc3_ = getAnchorPoint(_currItem as DisplayObject);
            _currItem.x = -_currItem.width * 0.5 + _loc3_.x;
            _currItem.y = -_currItem.height * 0.5 + _loc3_.y;
            if(_iconLayerName != "" && Boolean(_currItem.hasOwnProperty(_iconLayerName)))
            {
               _window.iconLayer.addChild(_currItem[_iconLayerName]);
            }
            else
            {
               _window.iconLayer.addChild(DisplayObject(_currItem));
            }
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_window && _currItem)
         {
            addEventListener("rollOver",onWindowRollOver,false,0,true);
            addEventListener("rollOut",onWindowRollOut,false,0,true);
         }
      }
      
      override protected function onWindowRollOver(param1:MouseEvent) : void
      {
         if(_useToolTip && this.parent != null)
         {
            if(_windowGenerator == null)
            {
               if(this.parent.parent is WindowGenerator)
               {
                  _windowGenerator = WindowGenerator(this.parent.parent);
               }
               else
               {
                  _windowGenerator = WindowAndScrollbarGenerator(this.parent.parent);
               }
            }
            if(_currItem && _windowGenerator.isIndexInView(_visibilityIndex))
            {
               _windowGenerator.toolTip.init(_windowGenerator.parent.parent,_giftNames[index],this.x + _windowGenerator.boxWidth * 0.5 - _itemXLocation + _windowGenerator.parent.x,this.y + _windowGenerator.boxHeight - _itemYLocation + _windowGenerator.parent.y - 5);
               _windowGenerator.toolTip.startTimer(param1);
            }
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
         super.onWindowRollOut(null);
      }
      
      private function getAnchorPoint(param1:DisplayObject) : Point
      {
         var _loc2_:Point = new Point();
         var _loc3_:Rectangle = param1.getRect(param1);
         _loc2_.x = -1 * _loc3_.x;
         _loc2_.y = -1 * _loc3_.y;
         return _loc2_;
      }
   }
}

