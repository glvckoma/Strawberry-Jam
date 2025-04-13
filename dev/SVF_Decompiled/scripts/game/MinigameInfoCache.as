package game
{
   public class MinigameInfoCache
   {
      public var currMinigameId:int;
      
      private var minigameInfo:Object;
      
      public function MinigameInfoCache()
      {
         super();
      }
      
      public function init() : void
      {
         minigameInfo = {};
         currMinigameId = -1;
      }
      
      public function destroy() : void
      {
         minigameInfo = null;
      }
      
      public function get playerMinigameInfo() : MinigameInfo
      {
         return minigameInfo[currMinigameId];
      }
      
      public function set playerMinigameInfo(param1:MinigameInfo) : void
      {
         currMinigameId = param1.gameDefId;
         minigameInfo[currMinigameId] = param1;
      }
      
      public function getMinigameInfo(param1:int) : MinigameInfo
      {
         return minigameInfo[param1];
      }
      
      public function getMinigameInfoByExtName(param1:String) : MinigameInfo
      {
         for each(var _loc2_ in minigameInfo)
         {
            if(_loc2_.extName == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getMinigameInfoBySwfName(param1:String) : MinigameInfo
      {
         for each(var _loc2_ in minigameInfo)
         {
            if(_loc2_.swfName == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getAllReadyForPvpGameDefs() : Array
      {
         var _loc1_:Array = null;
         if(minigameInfo)
         {
            _loc1_ = [];
            for each(var _loc2_ in minigameInfo)
            {
               if(_loc2_.readyForPVP)
               {
                  _loc1_.push(_loc2_);
               }
            }
            _loc1_.sortOn(["gameDefId"],2 | 0x10);
            return _loc1_;
         }
         return null;
      }
      
      public function setMinigameInfo(param1:int, param2:MinigameInfo) : void
      {
         minigameInfo[param1] = param2;
      }
   }
}

