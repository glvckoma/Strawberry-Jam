package game.moatMadness
{
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   
   public class MoatPathCurve extends MoatPath
   {
      private var _activeImage:Object;
      
      private var _fillAnimation:FrameAnimation;
      
      public function MoatPathCurve(param1:MoatMadness)
      {
         super();
         _theGame = param1;
         var _loc2_:Object = _theGame.getScene().getLayer("piece_curve");
         _activeImage = _theGame.getScene().cloneAsset("piece_curve");
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
            return param3 == 1 && (_targetRotation == 180 || _targetRotation == 270) || param3 == 3 && (_targetRotation == 0 || _targetRotation == 90) || param3 == 2 && (_targetRotation == 0 || _targetRotation == 270) || param3 == 4 && (_targetRotation == 90 || _targetRotation == 180);
         }
         return false;
      }
      
      override public function getFillDirection(param1:int) : int
      {
         switch(param1 - 1)
         {
            case 0:
               if(_targetRotation == 180)
               {
                  return 2;
               }
               return 4;
               break;
            case 1:
               if(_targetRotation == 0)
               {
                  return 1;
               }
               return 3;
               break;
            case 2:
               if(_targetRotation == 0)
               {
                  return 4;
               }
               return 2;
               break;
            case 3:
               if(_targetRotation == 90)
               {
                  return 1;
               }
               return 3;
               break;
            default:
               return param1;
         }
      }
      
      override public function startFill(param1:int) : void
      {
         super.startFill(param1);
         _nextFillDirection = getFillDirection(param1);
         var _loc2_:Object = _theGame.getScene().getLayer("fill_curve_1").loader;
         var _loc4_:Object = _theGame.getScene().getLayer("fill_curve_2").loader;
         var _loc3_:Bitmap = _loc2_.content as Bitmap;
         var _loc5_:Bitmap = _loc4_.content as Bitmap;
         switch(param1 - 1)
         {
            case 0:
               if(_targetRotation == 180)
               {
                  _fillAnimation = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
                  break;
               }
               _fillAnimation = new FrameAnimation(_loc5_,_container.x,_container.y,100,100,0.5);
               break;
            case 1:
               if(_targetRotation == 0)
               {
                  _fillAnimation = new FrameAnimation(_loc5_,_container.x,_container.y,100,100,0.5);
                  break;
               }
               _fillAnimation = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
               break;
            case 2:
               if(_targetRotation == 0)
               {
                  _fillAnimation = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
                  break;
               }
               _fillAnimation = new FrameAnimation(_loc5_,_container.x,_container.y,100,100,0.5);
               break;
            case 3:
               if(_targetRotation == 90)
               {
                  _fillAnimation = new FrameAnimation(_loc3_,_container.x,_container.y,100,100,0.5);
                  break;
               }
               _fillAnimation = new FrameAnimation(_loc5_,_container.x,_container.y,100,100,0.5);
               break;
         }
         _fillAnimation._container.rotation = _targetRotation;
         _theGame._layerBackground.addChild(_fillAnimation._container);
      }
   }
}

