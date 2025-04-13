package room
{
   import flash.events.Event;
   
   public class DenItemHolderEvent extends Event
   {
      public static const ITEM_REMOVED:String = "OnItemRemoved";
      
      public static const SAVE_STATE:String = "OnSaveState";
      
      public var id:uint;
      
      public var refId:int;
      
      public var array:Array;
      
      public var hasUpdates:Boolean;
      
      public function DenItemHolderEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new DenItemHolderEvent(type);
      }
   }
}

