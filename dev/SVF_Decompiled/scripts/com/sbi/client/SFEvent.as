package com.sbi.client
{
   import flash.events.Event;
   
   public class SFEvent extends Event
   {
      public static const ON_CONNECT:String = "OnConnect";
      
      public static const ON_LOGIN:String = "OnLogin";
      
      public static const ON_CONNECTION_LOST:String = "OnConectionLost";
      
      public static const ON_CHAT_MESSAGE:String = "OnChatMessage";
      
      public static const ON_RECEIVED_OBJECT:String = "OnReceivedObject";
      
      public static const ON_ROOM_LIST:String = "OnRoomList";
      
      public static const ON_CREATE_ROOM:String = "OnCreateRoom";
      
      public static const ON_ROOM_CREATED:String = "onRoomCreated";
      
      public static const ON_JOIN_ROOM:String = "OnJoinRoom";
      
      public static const ON_LEFT_ROOM:String = "OnLeftRoom";
      
      public static const ON_USER_ENTERED_ROOM:String = "OnUserEnteredRoom";
      
      public static const ON_USER_LEFT_ROOM:String = "OnUserLeftRoom";
      
      public static const ON_ROOM_POPULATION_CHANGE:String = "onRoomPopulationChange";
      
      public static const ON_BUDDY_LIST:String = "onBuddyList";
      
      public static const ON_BUDDY_LIST_UPDATE:String = "onBuddyListUpdate";
      
      public static const ON_BUDDY_REQUEST:String = "onBuddyRequest";
      
      public static const ON_BUDDY_ROOM:String = "onBuddyRoom";
      
      public static const ON_XT_REPLY:String = "OnXtReply";
      
      public static const ON_ROOM_DELETED:String = "onRoomDeleted";
      
      public static const ON_ROOM_VAR:String = "OnRoomVar";
      
      public var status:Boolean;
      
      public var message:String;
      
      public var statusId:int;
      
      public var userId:int;
      
      public var roomId:int;
      
      public var userName:String;
      
      public var obj:*;
      
      public function SFEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new SFEvent(type);
      }
   }
}

