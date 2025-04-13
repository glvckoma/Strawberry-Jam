package game.moatMadness
{
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class MoatPath
   {
      public var _theGame:MoatMadness;
      
      public var _container:Sprite;
      
      public var _width:int;
      
      public var _height:int;
      
      public var _targetRotation:Number;
      
      public var _currentRotation:Number;
      
      public var _nextFillDirection:int;
      
      protected var _filling:Boolean;
      
      public function MoatPath()
      {
         super();
         _container = new Sprite();
         _targetRotation = 0;
         _currentRotation = 0;
         _filling = false;
      }
      
      public function init(param1:MoatMadness, param2:int, param3:int, param4:int) : void
      {
         _theGame = param1;
         _container.x = param2 + _width / 2;
         _container.y = param3 + _height / 2;
         _theGame._layerBackground.addChild(_container);
         _container.addEventListener("click",handleClick,false,0,true);
         _targetRotation = param4;
         _currentRotation = _targetRotation;
         _container.rotation = _targetRotation;
      }
      
      public function Remove() : void
      {
         _container.removeEventListener("click",handleClick);
         _container.parent.removeChild(_container);
         _container = null;
      }
      
      public function handleClick(param1:MouseEvent) : void
      {
         if(!_theGame._waterFilling && !_theGame._gameOver && !_theGame.getPaused())
         {
            if(_currentRotation == _targetRotation)
            {
               _targetRotation += 90;
               _theGame._soundMan.playByName(_theGame._soundNameRotate);
            }
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(_currentRotation != _targetRotation)
         {
            _loc2_ = 360 * param1;
            _currentRotation += _loc2_;
            if(_currentRotation >= _targetRotation)
            {
               _loc2_ -= _currentRotation - _targetRotation;
               if(_targetRotation >= 360)
               {
                  _targetRotation -= 360;
               }
               _currentRotation = _targetRotation;
            }
            _container.rotation += _loc2_;
         }
      }
      
      public function testForValidFill(param1:int, param2:int, param3:int) : Boolean
      {
         return param1 >= _container.x - _width / 2 && param1 <= _container.x + _width / 2 && param2 >= _container.y - _height / 2 && param2 <= _container.y + _height / 2;
      }
      
      public function startFill(param1:int) : void
      {
         _filling = true;
      }
      
      protected function setFull() : void
      {
         _filling = false;
         _theGame.pathFill(this,_nextFillDirection);
      }
      
      public function getFillDirection(param1:int) : int
      {
         return 0;
      }
   }
}

