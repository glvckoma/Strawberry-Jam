package room
{
   public class RoomJoinType
   {
      public static const AUTO:RoomJoinType = new RoomJoinType(0);
      
      public static const DIRECT_JOIN_AND_HALT_ON_FAILURE:RoomJoinType = new RoomJoinType(1);
      
      public static const DIRECT_JOIN_AND_SEARCH_ON_FAILURE:RoomJoinType = new RoomJoinType(2);
      
      private var _id:int;
      
      public function RoomJoinType(param1:int)
      {
         super();
         _id = param1;
      }
      
      public function getInt() : int
      {
         return _id;
      }
      
      public function toString() : String
      {
         return String(_id);
      }
   }
}

