package gui
{
   public class JBManager
   {
      private static const JB_FACT_LIST_ID:int = 54;
      
      private static const JB_PAGE_BIT_IDX:int = 29;
      
      private static const JB_KEEP_GIFT:int = 31;
      
      private static const JB_DISCARD_GIFT:int = 30;
      
      private static var _defPages:Array;
      
      private static var _unseenPagesIds:Array;
      
      private static var _currRoomJBItems:Array;
      
      private static var _numUnclaimedGifts:int;
      
      private static var _hasLoadedDefs:Boolean;
      
      private static var _numUnseenPages:int;
      
      public function JBManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _defPages = [];
         _unseenPagesIds = [];
         GenericListXtCommManager.requestGenericList(54,onFactListReceived);
      }
      
      public static function get numUnseenPages() : int
      {
         return _numUnseenPages;
      }
      
      public static function get numUnclaimedGifts() : int
      {
         return _numUnclaimedGifts;
      }
      
      public static function set numUnclaimedGifts(param1:int) : void
      {
         _numUnclaimedGifts = param1;
      }
      
      public static function removeUnseenPage(param1:int) : void
      {
         _numUnseenPages--;
         delete _unseenPagesIds[param1];
      }
      
      public static function checkUnseenPage(param1:Array) : void
      {
         if(param1 && param1.length > 0)
         {
            if(_hasLoadedDefs)
            {
               if(_unseenPagesIds.length > 0)
               {
                  _currRoomJBItems = null;
                  for each(var _loc3_ in param1)
                  {
                     for each(var _loc2_ in _unseenPagesIds)
                     {
                        if(_loc2_ == _loc3_.refId)
                        {
                           GuiManager.showJBGlow(true);
                           break;
                        }
                     }
                  }
               }
            }
            else
            {
               _currRoomJBItems = param1;
            }
         }
      }
      
      private static function onFactListReceived(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         var _loc3_:int = 0;
         _hasLoadedDefs = true;
         var _loc2_:int = int(param1.length);
         var _loc6_:Boolean = false;
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc4_ = param1[_loc5_];
            if(!_defPages[_loc4_.userVarId])
            {
               _defPages[_loc4_.userVarId] = [];
               if(!gMainFrame.userInfo.userVarCache.isBitSet(_loc4_.userVarId,29))
               {
                  _numUnseenPages++;
                  _unseenPagesIds[_loc4_.userVarId] = _loc4_.id;
               }
               else
               {
                  _loc6_ = true;
               }
            }
            _defPages[_loc4_.userVarId].push(_loc4_);
            NGFactManager.updateFactDefCache(_loc4_);
            _loc5_++;
         }
         for each(var _loc7_ in _defPages)
         {
            _loc3_ = 0;
            _loc5_ = 0;
            while(_loc5_ < _loc7_.length)
            {
               if(gMainFrame.userInfo.userVarCache.isBitSet(_loc7_[_loc5_].userVarId,_loc7_[_loc5_].bitIdx))
               {
                  _loc3_++;
                  _loc6_ = true;
               }
               _loc5_++;
            }
            if(_loc3_ == _loc7_.length)
            {
               if(!(gMainFrame.userInfo.userVarCache.isBitSet(_loc7_[_loc5_ - 1].userVarId,31) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(_loc7_[_loc5_ - 1].userVarId,30))))
               {
                  _numUnclaimedGifts++;
               }
            }
         }
         if(_currRoomJBItems)
         {
            checkUnseenPage(_currRoomJBItems);
         }
         GuiManager.updateJBIcon(_loc6_);
      }
   }
}

