package game.miniGame_Memory
{
   import flash.events.Event;
   
   public class MemoryEvent extends Event
   {
      public static const MEMORY_PATH_IN_COMPLETE:String = "MemoryPathInComplete";
      
      public static const MEMORY_PATH_OUT_COMPLETE:String = "MemoryPathOutComplete";
      
      public function MemoryEvent(param1:String)
      {
         super(param1,true,false);
      }
      
      override public function clone() : Event
      {
         return new MemoryEvent(type);
      }
      
      override public function toString() : String
      {
         return formatToString("MemoryEvent",type);
      }
   }
}

