package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class ToolTipPopup extends MovieClip
   {
      private const NUM_EXTRA_TEXT_LINES:int = 2;
      
      public var msgTxt:TextField;
      
      public var right:MovieClip;
      
      public var middle:MovieClip;
      
      public var left:MovieClip;
      
      public var extraInfo:MovieClip;
      
      public var toolTipTimer:Timer;
      
      private var _useTimer:Boolean;
      
      private var _currEvent:MouseEvent;
      
      private var _currDisplay:DisplayObjectContainer;
      
      public function ToolTipPopup()
      {
         super();
         msgTxt = this["txt"];
         right = this["r"];
         middle = this["m"];
         left = this["l"];
         extraInfo = this["tooltipCont"];
         enabled = false;
         visible = false;
         toolTipTimer = new Timer(225);
         mouseChildren = false;
         mouseEnabled = false;
      }
      
      public function init(param1:DisplayObjectContainer, param2:String, param3:int, param4:int, param5:Boolean = true) : void
      {
         setChild(param1);
         msgTxt.autoSize = "left";
         param2 = param2.replace(/(?'firstSpace' ?)(\r\n|\r|\n)(?(firstSpace)| ?)/gim,"");
         setToolTipText(param2);
         setPos(param3,param4);
         _useTimer = param5;
      }
      
      public function setToolTipText(param1:String) : void
      {
         var _loc10_:Array = null;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc11_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:TextField = null;
         var _loc9_:TextField = null;
         var _loc7_:int = 0;
         if(param1 && param1 != "" && param1 != msgTxt.text)
         {
            _loc10_ = param1.split("|");
            msgTxt.text = _loc10_[0];
            _loc6_ = msgTxt.textWidth + 5;
            middle.width = Math.ceil(_loc6_);
            _loc3_ = -_loc6_ * 0.5;
            middle.x = Math.round(_loc3_);
            msgTxt.x = middle.x;
            left.x = middle.x - left.width;
            right.x = _loc3_ + _loc6_;
            enabled = true;
            if(_loc10_.length > 1 && extraInfo)
            {
               extraInfo.visible = true;
               _loc10_.shift();
               _loc4_ = _loc10_.length * 0.5;
               _loc7_ = 0;
               while(_loc7_ < 2)
               {
                  _loc2_ = extraInfo["att" + (_loc7_ + 1)];
                  _loc9_ = extraInfo["value" + (_loc7_ + 1)];
                  if(_loc7_ < _loc4_)
                  {
                     _loc2_.visible = true;
                     _loc9_.visible = true;
                     _loc2_.autoSize = "left";
                     _loc9_.autoSize = "left";
                     _loc2_.text = _loc10_[_loc8_++];
                     _loc9_.text = _loc10_[_loc8_++];
                     _loc11_ += _loc2_.textHeight;
                     _loc5_ = Math.max(_loc5_,_loc2_.width + _loc9_.width + 5);
                  }
                  else
                  {
                     _loc2_.visible = false;
                     _loc9_.visible = false;
                  }
                  _loc7_++;
               }
               extraInfo.m.height = _loc11_;
               extraInfo.b.y = extraInfo.m.y + extraInfo.m.height;
               extraInfo.t.width = extraInfo.b.width = extraInfo.m.width = _loc5_;
               extraInfo.t.x = extraInfo.b.x = extraInfo.m.x = middle.x + middle.width * 0.5 - extraInfo.m.width * 0.5;
               _loc7_ = 0;
               while(_loc7_ < _loc4_)
               {
                  _loc2_ = extraInfo["att" + (_loc7_ + 1)];
                  _loc9_ = extraInfo["value" + (_loc7_ + 1)];
                  _loc2_.x = extraInfo.b.x + 2;
                  _loc9_.x = extraInfo.b.x + extraInfo.b.width - _loc9_.width - 2;
                  _loc2_.y = _loc9_.y = extraInfo.m.y + 2 + _loc7_ * _loc2_.textHeight;
                  _loc7_++;
               }
            }
            else if(extraInfo)
            {
               extraInfo.visible = false;
            }
         }
         else
         {
            if(param1 == null || param1 == "")
            {
               visible = false;
               enabled = false;
            }
            if(extraInfo)
            {
               extraInfo.visible = false;
            }
         }
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         var _loc5_:Point = this.parent.localToGlobal(new Point(param1,param2));
         var _loc4_:int = Math.round(this.width * 0.5);
         var _loc3_:int = Math.round(this.height * 0.5);
         if(_loc5_.x - _loc4_ < 0)
         {
            _loc5_.x += _loc4_ - _loc5_.x;
         }
         else if(_loc5_.x + _loc4_ > 900)
         {
            _loc5_.x -= _loc5_.x + _loc4_ - 900;
         }
         if(_loc5_.y - _loc3_ < 0)
         {
            _loc5_.y += _loc3_ - _loc5_.y;
         }
         else if(_loc5_.y + _loc3_ > 550)
         {
            _loc5_.y -= _loc5_.y + _loc3_ - 550;
         }
         _loc5_ = this.parent.globalToLocal(_loc5_);
         this.x = _loc5_.x;
         this.y = _loc5_.y;
      }
      
      public function bringToolToFront() : void
      {
         if(parent)
         {
            parent.setChildIndex(this,parent.numChildren - 1);
         }
         else
         {
            _currDisplay.addChild(this);
         }
      }
      
      public function startTimer(param1:MouseEvent = null) : void
      {
         if(enabled)
         {
            if(_useTimer)
            {
               bringToolToFront();
               toolTipTimer.start();
               toolTipTimer.addEventListener("timer",toolTipTimerHandler,false,0,true);
               _currEvent = param1;
            }
            else
            {
               visible = true;
            }
         }
      }
      
      public function isTimerRunning() : Boolean
      {
         return toolTipTimer.running;
      }
      
      public function resetTimerAndSetVisibility() : void
      {
         toolTipTimer.reset();
         toolTipTimer.removeEventListener("timer",toolTipTimerHandler);
         visible = false;
         _currEvent = null;
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function toolTipTimerHandler(param1:TimerEvent) : void
      {
         toolTipTimer.stop();
         if(_currEvent && _currEvent.currentTarget.hitTestPoint(_currEvent.stageX,_currEvent.stageY))
         {
            visible = true;
         }
         else
         {
            resetTimerAndSetVisibility();
         }
      }
      
      public function setChild(param1:DisplayObjectContainer) : void
      {
         _currDisplay = param1;
         param1.addChild(this);
      }
   }
}

