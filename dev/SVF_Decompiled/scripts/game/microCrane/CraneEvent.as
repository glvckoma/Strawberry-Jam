package game.microCrane
{
   import flash.events.Event;
   
   public class CraneEvent extends Event
   {
      public static const CRANE_DROP_COMPLETE:String = "craneDropComplete";
      
      public static const CRANE_OPEN:String = "craneOpen";
      
      public static const CRANE_CLOSE:String = "craneClose";
      
      public static const CRANE_LOWER:String = "craneLower";
      
      public static const CRANE_RETRACT:String = "craneRetract";
      
      public function CraneEvent(param1:String)
      {
         super(param1,true,false);
      }
      
      override public function clone() : Event
      {
         return new CraneEvent(type);
      }
      
      override public function toString() : String
      {
         return formatToString("CraneEvent",type);
      }
   }
}

