package game.moatMadness
{
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   
   public class MoatPathCross extends MoatPath
   {
      private var _activeImage:Object;
      
      private var _fillAnimationTop:FrameAnimation;
      
      private var _fillAnimationBottom:FrameAnimation;
      
      public function MoatPathCross(param1:MoatMadness)
      {
         super();
         _theGame = param1;
         var _loc2_:Object = _theGame.getScene().getLayer("piece_cross");
         _activeImage = _theGame.getScene().cloneAsset("piece_cross");
         _width = _loc2_.loader.width;
         _height = _loc2_.loader.height;
         _activeImage.loader.x = -_width / 2;
         _activeImage.loader.y = -_height / 2;
      }
      
      override public function init(param1:MoatMadness, param2:int, param3:int, param4:int) : void
      {
         _container.addChild(_activeImage.loader);
         super.init(param1,param2,param3,param4);
      }
      
      override public function Remove() : void
      {
         _container.removeChild(_activeImage.loader);
         if(_fillAnimationTop)
         {
            _fillAnimationTop._container.parent.removeChild(_fillAnimationTop._container);
            _fillAnimationTop = null;
         }
         if(_fillAnimationBottom)
         {
            _fillAnimationBottom._container.parent.removeChild(_fillAnimationBottom._container);
            _fillAnimationBottom = null;
         }
         super.Remove();
      }
      
      override public function handleClick(param1:MouseEvent) : void
      {
         super.handleClick(param1);
      }
      
      override public function heartbeat(param1:Number) : void
      {
         if(_fillAnimationTop && !_fillAnimationTop.atFrameEnd())
         {
            _fillAnimationTop.heartbeat(param1);
            if(_filling && _fillAnimationTop.atNextToLastFrame(5))
            {
               setFull();
            }
         }
         if(_fillAnimationBottom && !_fillAnimationBottom.atFrameEnd())
         {
            _fillAnimationBottom.heartbeat(param1);
            if(_filling && _fillAnimationBottom.atNextToLastFrame(5))
            {
               setFull();
            }
         }
         super.heartbeat(param1);
      }
      
      override public function testForValidFill(param1:int, param2:int, param3:int) : Boolean
      {
         return super.testForValidFill(param1,param2,param3);
      }
      
      override public function getFillDirection(param1:int) : int
      {
         return param1;
      }
      
      override public function startFill(param1:int) : void
      {
         super.startFill(param1);
         _nextFillDirection = getFillDirection(param1);
         var _loc3_:Bitmap = _theGame.getScene().getLayer("fill_cross_top").loader.content as Bitmap;
         var _loc2_:Bitmap = _theGame.getScene().getLayer("fill_cross_bottom").loader.content as Bitmap;
         switch(param1 - 1)
         {
            case 0:
               if(_targetRotation == 0 || _targetRotation == 180)
               {
                  _fillAnimationBottom = new FrameAnimation(_loc2_,_container.x,_container.y,100,100,0.5);
                  _fillAnimationBottom._container.rotation = 180;
                  _theGame._layerBackground.addChild(_fillAnimationBottom._container);
                  break;
               }
               _fillAnimationTop = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
               _fillAnimationTop._container.rotation = 90;
               _theGame._layerBackground.addChild(_fillAnimationTop._container);
               break;
            case 1:
               if(_targetRotation == 90 || _targetRotation == 270)
               {
                  _fillAnimationBottom = new FrameAnimation(_loc2_,_container.x,_container.y,100,100,0.5);
                  _fillAnimationBottom._container.rotation = 270;
                  _theGame._layerBackground.addChild(_fillAnimationBottom._container);
                  break;
               }
               _fillAnimationTop = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
               _fillAnimationTop._container.rotation = 180;
               _theGame._layerBackground.addChild(_fillAnimationTop._container);
               break;
            case 2:
               if(_targetRotation == 0 || _targetRotation == 180)
               {
                  _fillAnimationBottom = new FrameAnimation(_loc2_,_container.x,_container.y,100,100,0.5);
                  _theGame._layerBackground.addChild(_fillAnimationBottom._container);
                  break;
               }
               _fillAnimationTop = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
               _fillAnimationTop._container.rotation = 270;
               _theGame._layerBackground.addChild(_fillAnimationTop._container);
               break;
            case 3:
               if(_targetRotation == 90 || _targetRotation == 270)
               {
                  _fillAnimationBottom = new FrameAnimation(_loc2_,_container.x,_container.y,100,100,0.5);
                  _fillAnimationBottom._container.rotation = 90;
                  _theGame._layerBackground.addChild(_fillAnimationBottom._container);
                  break;
               }
               _fillAnimationTop = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
               _fillAnimationTop._container.rotation = 0;
               _theGame._layerBackground.addChild(_fillAnimationTop._container);
               break;
         }
      }
   }
}

