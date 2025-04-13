package
{
   import com.sbi.client.SFEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class XtReplyDemuxer
   {
      private static var MSG_DELAY_MS:int = 0;
      
      private static var _delayList:Array;
      
      private static var _delayTimer:Timer;
      
      private static var _xtReplyCallbacks:Vector.<Function>;
      
      private static var _xtReplyCommands:Vector.<String>;
      
      public function XtReplyDemuxer()
      {
         super();
      }
      
      public static function init() : void
      {
         if(MSG_DELAY_MS > 0)
         {
            _delayList = [];
            _delayTimer = new Timer(10);
            _delayTimer.addEventListener("timer",delayTimerHandler,false,0,true);
            _delayTimer.start();
         }
         _xtReplyCallbacks = new Vector.<Function>();
         _xtReplyCommands = new Vector.<String>();
         gMainFrame.server.addEventListener("OnXtReply",xtReplyHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         _delayList = null;
         if(_delayTimer)
         {
            if(_delayTimer.running)
            {
               _delayTimer.stop();
            }
            _delayTimer = null;
         }
         _xtReplyCallbacks = null;
         _xtReplyCommands = null;
         gMainFrame.server.removeEventListener("OnXtReply",xtReplyHandler);
      }
      
      public static function addModule(param1:Function, param2:String) : void
      {
         _xtReplyCallbacks.push(param1);
         _xtReplyCommands.push(param2);
      }
      
      public static function removeModule(param1:Function) : void
      {
         var _loc2_:int = int(_xtReplyCallbacks.indexOf(param1));
         if(_loc2_ >= 0)
         {
            _xtReplyCallbacks.splice(_loc2_,1);
            _xtReplyCommands.splice(_loc2_,1);
            return;
         }
         throw new Error("module not found! callback:" + param1);
      }
      
      public static function xtReplyHandler(param1:SFEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc2_:Function = null;
         _loc4_ = 0;
         while(_loc4_ < _xtReplyCommands.length)
         {
            _loc3_ = _xtReplyCommands[_loc4_];
            if(_loc3_.charAt(0) == param1.obj[0].charAt(0))
            {
               if(_loc3_.length == 1)
               {
                  _loc2_ = _xtReplyCallbacks[_loc4_];
                  break;
               }
               if(param1.obj[0].indexOf(_loc3_) != -1)
               {
                  _loc2_ = _xtReplyCallbacks[_loc4_];
                  break;
               }
            }
            _loc4_++;
         }
         if(_loc2_ == null)
         {
            throw new Error("ERROR: undefined module command:" + param1.obj[0]);
         }
         if(MSG_DELAY_MS == 0)
         {
            _loc2_(param1);
         }
         else
         {
            _delayList.push({
               "f":_loc2_,
               "e":param1,
               "ts":getTimer() + MSG_DELAY_MS
            });
         }
      }
      
      private static function delayTimerHandler(param1:TimerEvent) : void
      {
         var _loc4_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:uint = uint(getTimer());
         _loc2_ = 0;
         while(_loc2_ < _delayList.length)
         {
            _loc4_ = _delayList[_loc2_];
            if(_loc4_.ts >= _loc3_)
            {
               break;
            }
            _loc4_.f(_loc4_.e);
            _delayList.splice(0,1);
            _loc2_--;
            _loc2_++;
         }
      }
   }
}

