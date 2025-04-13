package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_SocialTrigger extends RoomObject
   {
      private var _currentStage:int;
      
      private var _stages:Array;
      
      private var _totalCount:int;
      
      public function RoomObject_SocialTrigger(param1:MovieClip)
      {
         super(param1);
         _stages = param1.stages;
         clearCount();
         update();
      }
      
      public function clearCount() : void
      {
         _totalCount = 0;
      }
      
      public function incCount() : void
      {
         _totalCount++;
      }
      
      public function update() : void
      {
         var _loc2_:int = 0;
         var _loc1_:* = 0;
         while(_loc2_ < _stages.length)
         {
            if(_totalCount < _stages[_loc2_].total)
            {
               break;
            }
            _loc1_ = _loc2_;
            _loc2_++;
         }
         if(_currentStage != _loc1_)
         {
            _currentStage = _loc1_;
            _mc.gotoAndPlay(_stages[_currentStage].label);
         }
      }
   }
}

