package gui
{
   import avatar.UserInfo;
   import collection.DenRoomItemCollection;
   import collection.IntItemCollection;
   import den.DenXtCommManager;
   
   public class DenSwitch
   {
      public static const RECYCLE_DEN_ROOM:int = 99;
      
      public static var activeDenIdx:int;
      
      public static var playerUserInfo:UserInfo;
      
      public static var playerUsername:String;
      
      public static var playerSfsUserId:int;
      
      private static var _denList:DenRoomItemCollection;
      
      private static var _addDenCallback:Function;
      
      private static var _removeCallback:Function;
      
      private static var _switchIdx:int;
      
      private static var _switchDensCallback:Function;
      
      private static var _removeIdx:int;
      
      private static var _maxSlots:int;
      
      private static var _numSlots:int;
      
      public function DenSwitch()
      {
         super();
      }
      
      public static function init(param1:int) : void
      {
         setActiveDenIdx(param1);
      }
      
      public static function destroy() : void
      {
      }
      
      public static function setActiveDenIdx(param1:int) : void
      {
         activeDenIdx = param1;
      }
      
      public static function denInfoSet() : void
      {
      }
      
      private static function updateDens() : void
      {
      }
      
      public static function get numSlots() : int
      {
         return _numSlots;
      }
      
      public static function get numDens() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _denList.length)
         {
            if(_denList.getDenRoomItem(_loc2_))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function addNewDen(param1:int, param2:String, param3:Function) : void
      {
         _addDenCallback = param3;
      }
      
      public static function addDenResponse(param1:Boolean, param2:int) : void
      {
         if(param1)
         {
         }
         if(_addDenCallback != null)
         {
            _addDenCallback(param1);
         }
      }
      
      public static function switchDens(param1:int, param2:Function = null) : void
      {
         if(param1 < 0 || param1 >= _denList.length)
         {
            throw new Error("Invalid switchIdx:" + param1);
         }
         _switchIdx = param1;
         _switchDensCallback = param2;
         activeDenIdx = _denList.getDenRoomItem(_switchIdx).invIdx;
         DenXtCommManager.requestDenChange(param1,param2);
      }
      
      public static function reTrySwitchDensAfterAddingAvatar() : void
      {
         DenXtCommManager.requestDenChange(_switchIdx,_switchDensCallback);
      }
      
      public static function denListResponse(param1:DenRoomItemCollection) : void
      {
         _denList = param1;
      }
      
      public static function removeDen(param1:int, param2:Function) : void
      {
         var _loc3_:IntItemCollection = null;
         if(param1 < 0 || param1 >= _denList.length)
         {
            throw new Error("Invalid removeIdx:" + param1);
         }
         _removeCallback = param2;
         _removeIdx = param1;
         if(_denList.getDenRoomItem(param1).invIdx != activeDenIdx && _denList.getDenRoomItem(param1).invIdx > 0)
         {
            _loc3_ = new IntItemCollection();
            _loc3_.pushIntItem(_denList.getDenRoomItem(param1).invIdx);
            DenXtCommManager.requestRecycle(false,_loc3_,denRecycleResponse);
         }
         else
         {
            denRecycleResponse(new Vector.<int>());
         }
      }
      
      public static function denRecycleResponse(param1:Vector.<int>) : void
      {
         if(param1.length > 0)
         {
            _denList.setDenRoomItem(_removeIdx,null);
         }
         if(_removeCallback != null)
         {
            _removeCallback(param1.length > 0,_removeIdx);
         }
         _removeIdx = -1;
      }
      
      public static function get denList() : DenRoomItemCollection
      {
         return _denList;
      }
      
      public static function get nextFreeSlotIdx() : int
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 200)
         {
            if(!_denList.getDenRoomItem(_loc1_))
            {
               return _loc1_;
            }
            _loc1_++;
         }
         return -1;
      }
      
      public static function haveOceanDen() : Boolean
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _denList.length)
         {
            if(_denList.getDenRoomItem(_loc1_) && _denList.getDenRoomItem(_loc1_).enviroType == 1)
            {
               return true;
            }
            _loc1_++;
         }
         return false;
      }
   }
}

