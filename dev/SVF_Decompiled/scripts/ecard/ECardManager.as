package ecard
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.ECardCreation;
   import gui.ECardInbox;
   import gui.PredictiveTextMessageValidation;
   import gui.SafeChatManager;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   
   public class ECardManager
   {
      private static const ECARD_INBOX_CREATION_MEDIA_ID:int = 1353;
      
      private static var _inbox:Array;
      
      private static var _cardMediaIds:Array;
      
      private static var _stampMediaIds:Array;
      
      private static var _cardIdObjects:Array;
      
      private static var _eCardInbox:ECardInbox;
      
      private static var _eCardCreation:ECardCreation;
      
      private static var _glowTimer:Timer;
      
      private static var _hudECardBtn:MovieClip;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _eCardInboxAndCreation:MovieClip;
      
      private static var _unreadCount:int;
      
      private static var _isFirstTime:Boolean;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _predictiveTextMessageValidation:PredictiveTextMessageValidation;
      
      public function ECardManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:MovieClip, param3:Boolean = false) : void
      {
         _guiLayer = param1;
         _hudECardBtn = param2;
         _hudECardBtn.glow.visible = false;
         _hudECardBtn.addEventListener("mouseDown",eCardBtnDownHandler,false,0,true);
         _predictiveTextMessageValidation = new PredictiveTextMessageValidation(1);
         if(!param3)
         {
            _glowTimer = new Timer(5000);
            _glowTimer.addEventListener("timer",glowTimerHandler,false,0,true);
            _inbox = [];
            _isFirstTime = true;
            _unreadCount = 0;
            _hudECardBtn.newEcardCount.visible = false;
            _hudECardBtn.newEcardCount.eCardCountTxt.text = "";
            ECardXtCommManager._deleteResponseCallback = onDeleteResponse;
         }
         else
         {
            _hudECardBtn.newEcardCount.visible = _unreadCount > 0;
            _hudECardBtn.newEcardCount.eCardCountTxt.text = _unreadCount;
         }
      }
      
      public static function destroy() : void
      {
         ECardXtCommManager._deleteResponseCallback = null;
      }
      
      public static function isECardTextValid(param1:String) : Boolean
      {
         return SafeChatManager.containsInTreeArray(param1,1) || _predictiveTextMessageValidation.isTextValid(param1);
      }
      
      public static function processECardList(param1:Array, param2:int) : void
      {
         _inbox = param1.concat();
         unreadCount = param2;
         if(_eCardInbox)
         {
            _eCardInbox.processECardList(_inbox);
         }
      }
      
      public static function processECardPush(param1:ECard) : void
      {
         if(!isFirstTime)
         {
            _inbox.unshift(param1);
            if(_eCardInbox)
            {
               _eCardInbox.processECardPush(param1);
            }
         }
         if(!param1.isRead)
         {
            unreadCount++;
         }
      }
      
      public static function processECardUpdate(param1:int, param2:String) : void
      {
         var _loc3_:ECard = null;
         var _loc4_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _inbox.length)
         {
            _loc3_ = _inbox[_loc4_];
            if(_loc3_ != null && _loc3_.msgId == param1)
            {
               _loc3_.msg = param2;
               if(_eCardInbox)
               {
                  _eCardInbox.updateECard(_loc3_);
               }
               break;
            }
            _loc4_++;
         }
      }
      
      public static function get inbox() : Array
      {
         return _inbox;
      }
      
      public static function set setInboxAfterDelete(param1:Array) : void
      {
         if(_eCardInbox)
         {
            _inbox = param1.concat();
         }
      }
      
      public static function onCardsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _cardMediaIds = param2;
      }
      
      public static function onStampsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _stampMediaIds = param2;
      }
      
      private static function eCardBtnDownHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            RoomManagerWorld.instance.forceStopMovement();
            _eCardInbox = new ECardInbox();
            _eCardInbox.init(_guiLayer,_inbox.concat(),openCreateCard,onClose);
         }
      }
      
      private static function onClose() : void
      {
         _hudECardBtn.downToUpState();
         if(_eCardCreation)
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
         }
         if(_eCardInbox)
         {
            _eCardInbox.destroy();
            _eCardInbox = null;
         }
      }
      
      public static function closeECard() : void
      {
         onClose();
      }
      
      public static function onECardLoaded(param1:ECard) : void
      {
         if(_eCardInbox)
         {
            _eCardInbox.onECardLoaded(param1);
         }
      }
      
      public static function openCreateCard(param1:String, param2:String, param3:int, param4:Boolean = true) : void
      {
         _eCardCreation = new ECardCreation();
         if(param4)
         {
            _eCardCreation.init(_guiLayer,param1,param2,param3,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onClose);
         }
         else
         {
            _eCardCreation.init(_guiLayer,param1,param2,param3,_cardMediaIds,_stampMediaIds,onCreateCardBackBtn,onClose,true);
         }
      }
      
      private static function onCreateCardBackBtn(param1:Boolean) : void
      {
         if(_eCardCreation)
         {
            _eCardCreation.destroy();
            _eCardCreation = null;
            if(_eCardInbox)
            {
               if(param1)
               {
                  _hudECardBtn.downToUpState();
                  _eCardInbox.destroy();
                  _eCardInbox = null;
               }
            }
         }
      }
      
      public static function onDeleteResponse(param1:Array, param2:Boolean) : void
      {
         var _loc5_:ECard = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(_eCardInbox)
         {
            _eCardInbox.onDeleteResponse(param1,param2);
         }
         else if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc6_ = 0;
               while(_loc6_ < _inbox.length)
               {
                  _loc5_ = _inbox[_loc6_];
                  if(_loc5_ != null && _loc5_.msgId == param1[_loc3_])
                  {
                     _inbox.splice(_loc6_,1);
                     break;
                  }
                  _loc6_++;
               }
               _loc3_++;
            }
         }
         if(param2)
         {
            _loc7_ = 0;
            while(_loc7_ < _inbox.length)
            {
               _loc5_ = _inbox[_loc7_];
               if(_loc5_ && !_loc5_.isRead)
               {
                  _loc4_++;
               }
               _loc7_++;
            }
            _unreadCount = _loc4_;
            if(_unreadCount > 0)
            {
               _hudECardBtn.newEcardCount.eCardCountTxt.text = _unreadCount;
               _hudECardBtn.newEcardCount.visible = true;
            }
            else
            {
               _hudECardBtn.newEcardCount.visible = false;
               _hudECardBtn.newEcardCount.eCardCountTxt.text = "";
            }
         }
      }
      
      private static function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         if(_hudECardBtn)
         {
            _hudECardBtn.glow.visible = false;
         }
      }
      
      public static function get unreadCount() : int
      {
         return _unreadCount;
      }
      
      public static function set unreadCount(param1:int) : void
      {
         if(param1 > _unreadCount)
         {
            if(_glowTimer.running)
            {
               _glowTimer.stop();
            }
            if(!_eCardCreation)
            {
               _glowTimer.start();
               if(_hudECardBtn)
               {
                  _hudECardBtn.glow.visible = true;
               }
               AJAudio.playMailReceivedSound();
            }
         }
         _unreadCount = param1;
         if(_eCardInbox)
         {
            _eCardInbox.updateUnreadCount();
         }
         if(_hudECardBtn)
         {
            if(_unreadCount > 0)
            {
               _hudECardBtn.newEcardCount.eCardCountTxt.text = param1;
               _hudECardBtn.newEcardCount.visible = true;
            }
            else
            {
               _hudECardBtn.newEcardCount.visible = false;
               _hudECardBtn.newEcardCount.eCardCountTxt.text = "";
            }
         }
      }
      
      public static function get eCardInboxAndCreation() : MovieClip
      {
         return _eCardInboxAndCreation;
      }
      
      public static function get isFirstTime() : Boolean
      {
         return _isFirstTime;
      }
      
      public static function set isFirstTime(param1:Boolean) : void
      {
         _isFirstTime = param1;
      }
      
      public static function isECardCreationOpen() : Boolean
      {
         return _eCardCreation != null;
      }
   }
}

