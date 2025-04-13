package game.horseRace
{
   public class HorseRaceAIProfile
   {
      public var _jumpDetectionProbability:int;
      
      public var _jumpDetectionDelay:Number;
      
      public var _jumpDetectionDistance:Number;
      
      public function HorseRaceAIProfile(param1:int, param2:Number, param3:int)
      {
         super();
         _jumpDetectionProbability = param1;
         _jumpDetectionDelay = param2;
         _jumpDetectionDistance = param3;
      }
   }
}

