package room
{
   import flash.events.Event;
   
   public class RoomEvent extends Event
   {
      public static const LOAD_SFX:String = "RoomEventLoadSfx";
      
      public static const PLAY_SFX:String = "RoomEventPlaySfx";
      
      public static const PLAY_SWFSFX:String = "RoomEventPlaySwfSfx";
      
      public static const PLAY_SWFSFXBYCLASS:String = "RoomEventPlaySwfSfxByClass";
      
      public static const ATTACH_EMOTE:String = "RoomEventAttachEmote";
      
      private var _secondaryType:String;
      
      private var _tertiaryType:String;
      
      private var _persistent:Boolean;
      
      public function RoomEvent(param1:String, param2:String = "", param3:String = "", param4:Boolean = false)
      {
         super(param1,true,false);
         _secondaryType = param2;
         _tertiaryType = param3;
         _persistent = param4;
      }
      
      override public function clone() : Event
      {
         return new RoomEvent(type);
      }
      
      override public function toString() : String
      {
         return formatToString("RoomEvent",type,_secondaryType,_tertiaryType,_persistent);
      }
      
      public function get secondaryType() : String
      {
         return _secondaryType;
      }
      
      public function get tertiaryType() : String
      {
         return _tertiaryType;
      }
      
      public function get persistent() : Boolean
      {
         return _persistent;
      }
   }
}

