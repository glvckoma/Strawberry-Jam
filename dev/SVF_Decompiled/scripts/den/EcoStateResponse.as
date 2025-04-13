package den
{
   public class EcoStateResponse
   {
      public var numActiveWindTurbines:int;
      
      public var numActiveSolarPanels:int;
      
      public var numConsumerItems:int;
      
      public var ecoPowerGeneration:int;
      
      public var ecoPowerConsumption:int;
      
      public var ecoScoreRequired:int;
      
      public var nextRewardBitIndex:int;
      
      public var unredeemedEcoCredits:int;
      
      public var secondsUntilNextEcoCredit:int;
      
      public function EcoStateResponse(param1:Object)
      {
         super();
         var _loc2_:int = 2;
         numActiveWindTurbines = param1[_loc2_++];
         numActiveSolarPanels = param1[_loc2_++];
         numConsumerItems = param1[_loc2_++];
         ecoPowerGeneration = param1[_loc2_++];
         ecoPowerConsumption = param1[_loc2_++];
         ecoScoreRequired = param1[_loc2_++];
         nextRewardBitIndex = param1[_loc2_++];
         unredeemedEcoCredits = param1[_loc2_++];
         secondsUntilNextEcoCredit = param1[_loc2_++];
      }
   }
}

