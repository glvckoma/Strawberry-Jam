package game.moatMadness
{
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   
   public class MoatPathStraight extends MoatPath
   {
      private var _activeImage:Object;
      
      private var _fillAnimation:FrameAnimation;
      
      public function MoatPathStraight(param1:MoatMadness)
      {
         super();
         _theGame = param1;
         var _loc2_:Object = _theGame.getScene().getLayer("piece_straight");
         _activeImage = _theGame.getScene().cloneAsset("piece_straight");
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
         if(_fillAnimation)
         {
            _fillAnimation._container.parent.removeChild(_fillAnimation._container);
            _fillAnimation = null;
         }
         super.Remove();
      }
      
      override public function handleClick(param1:MouseEvent) : void
      {
         super.handleClick(param1);
      }
      
      override public function heartbeat(param1:Number) : void
      {
         if(_fillAnimation && !_fillAnimation.atFrameEnd())
         {
            _fillAnimation.heartbeat(param1);
            if(_filling && _fillAnimation.atNextToLastFrame(5))
            {
               setFull();
            }
         }
         super.heartbeat(param1);
      }
      
      override public function testForValidFill(param1:int, param2:int, param3:int) : Boolean
      {
         if(super.testForValidFill(param1,param2,param3))
         {
            return param3 == 1 && (_targetRotation == 0 || _targetRotation == 180) || param3 == 3 && (_targetRotation == 0 || _targetRotation == 180) || param3 == 2 && (_targetRotation == 90 || _targetRotation == 270) || param3 == 4 && (_targetRotation == 90 || _targetRotation == 270);
         }
         return false;
      }
      
      override public function getFillDirection(param1:int) : int
      {
         return param1;
      }
      
      override public function startFill(param1:int) : void
      {
         super.startFill(param1);
         _nextFillDirection = getFillDirection(param1);
         var _loc2_:Bitmap = _theGame.getScene().getLayer("fill_straight").loader.content as Bitmap;
         _fillAnimation = new FrameAnimation(_loc2_,_container.x,_container.y,100,100,0.5);
         switch(param1 - 1)
         {
            case 0:
               _fillAnimation._container.rotation = 180;
               break;
            case 1:
               _fillAnimation._container.rotation = 270;
               break;
            case 2:
               _fillAnimation._container.rotation = 0;
               break;
            case 3:
               _fillAnimation._container.rotation = 90;
         }
         _theGame._layerBackground.addChild(_fillAnimation._container);
      }
   }
}

