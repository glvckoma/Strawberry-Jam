package avatar
{
   import flash.events.Event;
   
   public class AvatarEvent extends Event
   {
      public static const AVATAR_CHANGED:String = "OnAvatarChanged";
      
      public function AvatarEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new AvatarEvent(type);
      }
   }
}

