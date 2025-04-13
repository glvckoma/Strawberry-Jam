package game.horseRace
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   
   public class HorseRaceLaneTexture
   {
      public var _active:Array;
      
      public var _inactive:Array;
      
      public var _minSpacing:int;
      
      public var _varSpacing:int;
      
      public var _currentX:int;
      
      public var _fixedWidth:int;
      
      public var _theGame:HorseRace;
      
      public function HorseRaceLaneTexture(param1:HorseRace, param2:String, param3:int, param4:int, param5:int, param6:int, param7:int = 0)
      {
         var _loc9_:int = 0;
         var _loc8_:MovieClip = null;
         _active = [];
         _inactive = [];
         super();
         _theGame = param1;
         _minSpacing = param5;
         _varSpacing = param6;
         _fixedWidth = param7;
         _loc9_ = 0;
         while(_loc9_ < param4)
         {
            _loc8_ = GETDEFINITIONBYNAME(param2);
            _loc8_.y = param3;
            _inactive.push(_loc8_);
            _loc9_++;
         }
      }
      
      public function reset() : void
      {
         var _loc1_:MovieClip = null;
         _currentX = Math.random() * _varSpacing;
         while(_active.length > 0)
         {
            _loc1_ = _active[0];
            if(_loc1_.parent != null)
            {
               _loc1_.parent.removeChild(_loc1_);
            }
            _active.splice(0,1);
            _inactive.push(_loc1_);
         }
      }
      
      public function heartbeat(param1:Number, param2:Sprite) : void
      {
         var _loc4_:int = 0;
         var _loc3_:MovieClip = null;
         _loc4_ = _active.length - 1;
         while(_loc4_ >= 0)
         {
            _loc3_ = _active[_loc4_];
            if(_loc3_.x + param2.x < -_loc3_.width)
            {
               if(_loc3_.parent != null)
               {
                  _loc3_.parent.removeChild(_loc3_);
               }
               _active.splice(0,1);
               _inactive.push(_loc3_);
            }
            _loc4_--;
         }
         while(_inactive.length > 0 && _currentX + param2.x < 1100)
         {
            _loc3_ = _inactive[0];
            _inactive.splice(0,1);
            _active.push(_loc3_);
            _loc3_.x = _currentX;
            if(_currentX == 0)
            {
               _loc3_.setStart();
            }
            else if(_theGame._trackLength != 0 && _currentX >= _theGame._trackLength - _fixedWidth / 2)
            {
               _loc3_.setEnd();
            }
            else
            {
               _loc3_.randomize();
            }
            param2.addChildAt(_loc3_,0);
            if(_fixedWidth > 0)
            {
               _currentX += _fixedWidth + _minSpacing + Math.random() * _varSpacing;
            }
            else
            {
               _currentX += _loc3_.width + _minSpacing + Math.random() * _varSpacing;
            }
         }
      }
   }
}

