package game.miniGame_Memory
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import gskinner.motion.GTween;
   
   public class MemoryCard
   {
      public var _cardType:int;
      
      public var _slot:int;
      
      private var _theGame:MiniGame_Memory;
      
      private var _selected:Boolean;
      
      private var _card:Object;
      
      private var _disabledImage:Sprite;
      
      private var _imageMask:Sprite;
      
      private var _matched:Boolean;
      
      private var _state:int;
      
      private var _cardPath:MovieClip;
      
      public const STATE_IDLE:int = 1;
      
      public const STATE_SELECTING:int = 2;
      
      public const STATE_DISABLED:int = 3;
      
      public function MemoryCard()
      {
         super();
      }
      
      public function getCardType() : int
      {
         return _cardType;
      }
      
      public function initCard(param1:MiniGame_Memory, param2:Object, param3:int, param4:int) : void
      {
         _card = param2;
         _cardType = param4;
         _slot = param3;
         _theGame = param1;
         _matched = false;
         _selected = false;
         _state = 1;
         _cardPath = _theGame.getScene().getLayer("animalPaths").loader.content.createPath();
         _cardPath.addEventListener("MemoryPathInComplete",memoryPathInComplete);
         _cardPath.addEventListener("MemoryPathOutComplete",memoryPathOutComplete);
      }
      
      public function remove() : void
      {
         _cardPath.removeEventListener("MemoryPathInComplete",memoryPathInComplete);
         _cardPath.removeEventListener("MemoryPathOutComplete",memoryPathOutComplete);
         _card.loader.mask = null;
         if(_disabledImage && _disabledImage.parent)
         {
            _disabledImage.parent.removeChild(_disabledImage);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         if(!_imageMask)
         {
            _imageMask = new Sprite();
            _imageMask.mouseEnabled = false;
            _imageMask.graphics.beginFill(16711680);
            _imageMask.graphics.drawRect(0,0,125,125);
            _imageMask.x = _theGame._cardSelect.x + 125 * (_slot % 4);
            _imageMask.y = _theGame._cardSelect.y + 125 * Math.floor(_slot / 4);
            _card.loader.mask = _imageMask;
            _card.loader.alpha = 1;
            _cardPath.x = _imageMask.x;
            _cardPath.y = _imageMask.y;
         }
         else
         {
            _card.loader.x = _cardPath.x + _cardPath.animal_null1.x;
            _card.loader.y = _cardPath.y + _cardPath.animal_null1.y;
         }
      }
      
      public function isMouseOverHighlightable() : Boolean
      {
         return _state == 1 && !isMatched() && !isSelected();
      }
      
      public function isSelected() : Boolean
      {
         return _state != 3 && !_matched && _selected;
      }
      
      public function isSelectable() : Boolean
      {
         return _state != 3 && !_matched;
      }
      
      public function getState() : int
      {
         return _state;
      }
      
      public function select(param1:Boolean = false) : void
      {
         if(_imageMask && _state != 3)
         {
            if(!_matched && !_selected)
            {
               _selected = true;
               _state = 2;
               if(!param1)
               {
                  _theGame._soundMan.playByName(_theGame._soundNameEnter);
               }
               switch(_theGame.getSlotDirection(_cardType) - 1)
               {
                  case 0:
                     _cardPath.gotoAndPlay("top_in");
                     break;
                  case 1:
                     _cardPath.gotoAndPlay("bottom_in");
                     break;
                  case 2:
                     _cardPath.gotoAndPlay("left_in");
                     break;
                  case 3:
                     _cardPath.gotoAndPlay("right_in");
               }
            }
         }
      }
      
      private function memoryPathInComplete(param1:MemoryEvent) : void
      {
         _state = 1;
      }
      
      private function memoryPathOutComplete(param1:MemoryEvent) : void
      {
         _state = 1;
      }
      
      public function unselect(param1:Boolean = false) : void
      {
         if(_state != 3)
         {
            if(!_matched && _selected)
            {
               _state = 1;
               _selected = false;
               switch(_theGame.getSlotDirection(_cardType) - 1)
               {
                  case 0:
                     _cardPath.gotoAndPlay("top_out");
                     break;
                  case 1:
                     _cardPath.gotoAndPlay("bottom_out");
                     break;
                  case 2:
                     _cardPath.gotoAndPlay("left_out");
                     break;
                  case 3:
                     _cardPath.gotoAndPlay("right_out");
               }
               if(param1 == false)
               {
               }
            }
         }
      }
      
      public function matched() : void
      {
         if(_state != 3)
         {
            _matched = true;
         }
      }
      
      public function isMatched() : Boolean
      {
         return _matched;
      }
      
      public function disable() : void
      {
         if(_state != 3)
         {
            _state = 3;
            _disabledImage = new Sprite();
            _disabledImage.graphics.beginFill(0);
            _disabledImage.graphics.drawRect(0,0,125,125);
            _disabledImage.x = _theGame._cardSelect.x + 125 * (_slot % 4);
            _disabledImage.y = _theGame._cardSelect.y + 125 * Math.floor(_slot / 4);
            _theGame._layerBackground.addChild(_disabledImage);
            _disabledImage.alpha = 0;
            new GTween(_disabledImage,1,{"alpha":0.35});
         }
      }
      
      public function mouseOver(param1:Object) : void
      {
         if(_imageMask)
         {
            if(param1.layer.loader.x != _imageMask.x || param1.layer.loader.y != _imageMask.y || param1.layer.loader.alpha == 0)
            {
               param1.layer.loader.x = _imageMask.x;
               param1.layer.loader.y = _imageMask.y;
               param1.tween = new GTween(param1.layer.loader,0.5,{"alpha":0.6});
            }
         }
      }
   }
}

