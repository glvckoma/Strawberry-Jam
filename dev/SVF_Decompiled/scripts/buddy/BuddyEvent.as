package buddy
{
   import flash.events.Event;
   
   public class BuddyEvent extends Event
   {
      public static const BUDDY_LIST:String = "OnBuddyList";
      
      public static const BUDDY_CHANGED:String = "OnBuddyChanged";
      
      public var userName:String;
      
      public function BuddyEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new BuddyEvent(type);
      }
   }
}

