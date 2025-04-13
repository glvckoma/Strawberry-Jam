package newspaper
{
   import collection.NewspaperDataCollection;
   import collection.NewspaperDefCollection;
   import loader.DefPacksDefHelper;
   
   public class NewspaperManager
   {
      public static const LIST_ID:int = 627;
      
      private static var _hasSeenFirstPage:Boolean;
      
      private static var _hasUnseenPages:Boolean;
      
      private static var _newspaperDefs:NewspaperDefCollection;
      
      private static var _newspaperData:NewspaperDataCollection;
      
      private static var _newspaperPopup:NewspaperPopup;
      
      private static var _newspaperCloseCallback:Function;
      
      public function NewspaperManager()
      {
         super();
      }
      
      public static function loadNewspaperDefs(param1:Function) : void
      {
         var _loc2_:DefPacksDefHelper = null;
         _hasSeenFirstPage = true;
         if(_newspaperDefs != null)
         {
            param1(_newspaperDefs);
         }
         else
         {
            _loc2_ = new DefPacksDefHelper();
            _loc2_.init(1065,onDefsLoaded,param1,2);
            DefPacksDefHelper.mediaArray[1065] = _loc2_;
         }
      }
      
      public static function setNewspaperData(param1:NewspaperDataCollection) : void
      {
         _newspaperData = param1;
         checkIfNewPagesExist();
      }
      
      private static function onDefsLoaded(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1065] = null;
         _newspaperDefs = new NewspaperDefCollection();
         for each(var _loc2_ in param1.def)
         {
            _newspaperDefs.setNewspaperDefItem(_loc2_.id,new NewspaperDef(_loc2_.id,_loc2_.name,_loc2_.pageMediaRefId,_loc2_.iconMediaRefId,_loc2_.giftType,_loc2_.giftRefId,_loc2_.amount,_loc2_.country,uint(_loc2_.availabilityStartTime),uint(_loc2_.availabilityEndTime),int(_loc2_.membersOnly)));
         }
         if(param1.passback && param1.passback != null)
         {
            param1.passback(_newspaperDefs);
         }
      }
      
      public static function get hasUnseenPages() : Boolean
      {
         return _hasUnseenPages;
      }
      
      public static function set hasUnseenPages(param1:Boolean) : void
      {
         _hasUnseenPages = param1;
      }
      
      public static function get hasSeenFirstPage() : Boolean
      {
         return _hasSeenFirstPage;
      }
      
      public static function set hasSeenFirstPage(param1:Boolean) : void
      {
         _hasSeenFirstPage = param1;
      }
      
      public static function getNewspaperDef(param1:int) : NewspaperDef
      {
         return _newspaperDefs.getNewspaperDefItem(param1);
      }
      
      public static function getNewspaperData(param1:int) : NewspaperData
      {
         return _newspaperData.getNewspaperDataItem(param1);
      }
      
      public static function updateNewspaperData(param1:int, param2:int) : void
      {
         var _loc3_:NewspaperData = null;
         if(param2 != -1)
         {
            _loc3_ = _newspaperData.getNewspaperDataItem(param1);
            if(_loc3_)
            {
               _loc3_.timeSeen = param2;
            }
            else
            {
               _loc3_ = new NewspaperData({
                  "defId":param1,
                  "ts":param2
               });
            }
            _newspaperData.setNewspaperDataItem(param1,_loc3_);
         }
      }
      
      public static function openNewspaperPopup(param1:Function) : void
      {
         _newspaperCloseCallback = param1;
         _newspaperPopup = new NewspaperPopup(onNewspaperClose);
      }
      
      private static function onNewspaperClose() : void
      {
         _newspaperPopup = null;
         if(_newspaperCloseCallback != null)
         {
            _newspaperCloseCallback();
            _newspaperCloseCallback = null;
         }
      }
      
      private static function checkIfNewPagesExist() : void
      {
         loadNewspaperDefs(onNewspaperDefsLoaded);
      }
      
      private static function onNewspaperDefsLoaded(param1:NewspaperDefCollection) : void
      {
         GenericListXtCommManager.requestGenericList(627,onListLoaded);
      }
      
      private static function onListLoaded(param1:int, param2:Array, param3:Object) : void
      {
         onItemListFiltered(param2);
      }
      
      private static function onItemListFiltered(param1:Array) : void
      {
         var _loc2_:NewspaperDef = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:NewspaperDefCollection = new NewspaperDefCollection();
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = getNewspaperDef(param1[_loc4_]);
            if(_loc2_ && (_loc2_.country == "" || _loc2_.country.indexOf(gMainFrame.clientInfo.countryCode) != -1) && _loc2_.getIsViewable(gMainFrame.userInfo.isMember))
            {
               _loc6_.pushNewspaperDefItem(_loc2_);
            }
            _loc4_++;
         }
         GenericListXtCommManager.filterTypedItems(_loc6_);
         hasSeenFirstPage = true;
         var _loc7_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(455));
         if(_loc7_ == -1)
         {
            hasSeenFirstPage = false;
            hasUnseenPages = true;
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < _loc6_.length)
            {
               if(_loc7_ < _loc6_.getNewspaperDefItem(_loc5_).availabilityStartTime)
               {
                  if(_loc5_ == 0)
                  {
                     hasSeenFirstPage = false;
                  }
                  hasUnseenPages = true;
                  break;
               }
               _loc5_++;
            }
         }
      }
   }
}

