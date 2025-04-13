package gui
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public dynamic class ChatBalloon extends MovieClip
   {
      private const CHAT_TIMEOUT_MS:int = 8000;
      
      private const BALLOON_BEGIN_FADEOUT:Number = 1000;
      
      private const BALLOON_MAX_ALPHA:Number = 0.75;
      
      private const TEXT_COLOR_NORMAL:uint = 4477529;
      
      private const TEXT_COLOR_BAD_TEXT:uint = 13369344;
      
      private var _maxAlpha:Number;
      
      private var _timeout:int = 0;
      
      private var _avType:int = 0;
      
      private var _originalFrameId:int = 0;
      
      private var _originalCustomMsgText:String;
      
      private var _emoteBG:MovieClip = null;
      
      private var _emote:Sprite = null;
      
      private var _permEmoteMediaId:int = -1;
      
      private var _permEmoteMediaHelper:MediaHelper;
      
      private var _hasSbTextfield:Boolean;
      
      private var _msgTxt:Object;
      
      private var _balloonBG:MovieClip;
      
      private var _btnBallonBG:MovieClip;
      
      private var _btnBalloonMouseBG:MovieClip;
      
      private var _btnBalloonUpBG:MovieClip;
      
      private var _btnBalloonDownBg:MovieClip;
      
      private var _btnBalloonGrayBG:MovieClip;
      
      private var _onCustomAdventureBtn:Function;
      
      private var _onCustomPVPBtn:Function;
      
      private var _emoteBGOffsetFunc:Function;
      
      public function ChatBalloon()
      {
         super();
      }
      
      public function init(param1:int, param2:Function, param3:Boolean = false, param4:int = 1, param5:Number = 1, param6:Class = null, param7:Function = null, param8:Function = null) : void
      {
         if(param5 < 0.75)
         {
            this.scaleX = this.scaleY = 1 + (0.75 - param5);
         }
         _originalFrameId = param4;
         this.gotoAndStop(param4);
         _balloonBG = this["balloon_bg"];
         _msgTxt = this["message_txt"];
         _onCustomAdventureBtn = param7;
         _onCustomPVPBtn = param8;
         _emoteBGOffsetFunc = param2;
         _avType = param1;
         visible = false;
         _msgTxt.autoSize = "center";
         if(param3)
         {
            _maxAlpha = 1;
         }
         else
         {
            _maxAlpha = 0.75;
         }
         _emoteBG = GETDEFINITIONBYNAME("emo_bubble");
         setEmoteBgOffsets();
      }
      
      public function setText(param1:String, param2:Boolean = false, param3:Boolean = true) : void
      {
         if(_emote)
         {
            _permEmoteMediaId = -1;
            _emoteBG.itemWindow.removeChild(_emote);
            _emote = null;
         }
         if(contains(_emoteBG))
         {
            removeChild(_emoteBG);
         }
         if(param1 != _msgTxt.text && _hasSbTextfield)
         {
            _balloonBG.visible = false;
            setAlpha(_maxAlpha);
            this.visible = false;
         }
         else
         {
            _balloonBG.visible = true;
            setAlpha(_maxAlpha);
            this.visible = true;
         }
         _msgTxt.text = param1;
         _msgTxt.height;
         if(!_hasSbTextfield)
         {
            if(param3)
            {
               _balloonBG.m.height = Math.ceil(_msgTxt.height);
               _balloonBG.m.y = _balloonBG.b.y - _balloonBG.m.height;
               _balloonBG.t.y = _balloonBG.m.y - _balloonBG.t.height;
               _msgTxt.y = -_balloonBG.b.height - _balloonBG.m.height;
            }
            else
            {
               _balloonBG.m.height = Math.ceil(_msgTxt.height);
               _balloonBG.b.y = _balloonBG.m.y + _balloonBG.m.height;
               _msgTxt.y = _balloonBG.t.height + 3;
            }
            if(this.currentFrameLabel == "advBtn")
            {
               _btnBallonBG.y = _balloonBG.y + _balloonBG.t.y - _btnBallonBG.height + _balloonBG.t.height;
            }
         }
         if(param2)
         {
            _msgTxt.textColor = 13369344;
         }
         else
         {
            _msgTxt.textColor = 4477529;
         }
         _timeout = 8000;
         if(param3 && this.parent)
         {
            this.parent.addChild(this);
         }
      }
      
      public function setCustomAdventureMessage(param1:String, param2:String, param3:int, param4:Boolean = false, param5:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = param2.split("|");
         if(param5)
         {
            param2 = _loc8_[0];
            _loc6_ = int(_loc8_[1]);
         }
         else
         {
            param2 = _loc8_[0];
            _loc7_ = int(_loc8_[1]);
         }
         if(param2 == "on")
         {
            if(_emote && _emoteBG)
            {
               _emoteBG.itemWindow.removeChild(_emote);
               _emote = null;
               if(contains(_emoteBG))
               {
                  removeChild(_emoteBG);
               }
            }
            if(this.currentFrameLabel != "advBtn")
            {
               this.gotoAndStop("advBtn");
            }
            _balloonBG = this["balloon_bg"];
            _btnBallonBG = this["btnBalloon_bg"];
            _btnBalloonMouseBG = _btnBallonBG.mouse.mouse;
            _btnBalloonUpBG = _btnBallonBG.mouse.up;
            _btnBalloonDownBg = _btnBallonBG.down;
            _btnBalloonGrayBG = _btnBallonBG.gray;
            _btnBallonBG.isForPVP = param5;
            _btnBallonBG.PVPGameId = _loc6_;
            _btnBallonBG.scriptDefId = _loc7_;
            _btnBallonBG.addEventListener("mouseDown",onBtnBG,false,0,true);
            _msgTxt = this["message_txt"];
            _msgTxt.autoSize = "center";
            LocalizationManager.translateId(_btnBalloonMouseBG.message_txt,11259);
            LocalizationManager.translateId(_btnBalloonUpBG.message_txt,11259);
            LocalizationManager.translateId(_btnBalloonDownBg.message_txt,11259);
            LocalizationManager.translateId(_btnBalloonGrayBG.message_txt,11259);
            if(param3 > 0)
            {
               _btnBalloonMouseBG.message_txt.x = 3;
               _btnBalloonUpBG.message_txt.x = 3;
               _btnBalloonDownBg.message_txt.x = 3;
               _btnBalloonGrayBG.message_txt.x = 3;
               _btnBallonBG["redDot"].visible = true;
            }
            else
            {
               _btnBalloonMouseBG.message_txt.x = 17;
               _btnBalloonUpBG.message_txt.x = 17;
               _btnBalloonDownBg.message_txt.x = 17;
               _btnBalloonGrayBG.message_txt.x = 17;
               _btnBallonBG["redDot"].visible = false;
            }
            _msgTxt.text = param1;
            _originalCustomMsgText = param1;
            _balloonBG.m.height = _msgTxt.height;
            _balloonBG.m.y = _balloonBG.b.y - _msgTxt.height;
            _balloonBG.t.y = _balloonBG.m.y - _balloonBG.t.height;
            _msgTxt.y = -_balloonBG.b.height - _msgTxt.height;
            _btnBallonBG.y = _balloonBG.y + _balloonBG.t.y - _btnBallonBG.height + _balloonBG.t.height;
            if(this.itemWindow)
            {
               this.itemWindow.y = _btnBallonBG.y;
            }
            _balloonBG.t.alpha = 0;
            setAlpha(_maxAlpha);
            this.visible = true;
            _timeout = 8000;
            if(this.parent)
            {
               this.parent.addChild(this);
            }
         }
         else
         {
            if(_btnBallonBG)
            {
               if(_btnBallonBG.isForPVP != param5)
               {
                  return;
               }
               _btnBallonBG.removeEventListener("mouseDown",onBtnBG);
            }
            if(this.currentFrameLabel == "advBtn")
            {
               this.gotoAndStop(_originalFrameId);
            }
            _balloonBG = this["balloon_bg"];
            _msgTxt = this["message_txt"];
            _msgTxt.autoSize = "center";
            this.visible = false;
         }
      }
      
      public function get msgTxt() : Object
      {
         return _msgTxt;
      }
      
      public function get isPvpCustom() : Boolean
      {
         if(_btnBallonBG)
         {
            return _btnBallonBG.isForPVP;
         }
         return false;
      }
      
      public function get pvpGameId() : int
      {
         if(_btnBallonBG)
         {
            return _btnBallonBG.PVPGameId;
         }
         return 0;
      }
      
      public function setCustomPVPImage(param1:MovieClip) : void
      {
         var _loc2_:Number = NaN;
         if(this.currentFrameLabel == "advBtn")
         {
            while(this.itemWindow.numChildren > 0)
            {
               this.itemWindow.removeChildAt(0);
            }
            param1 = param1.getChildAt(0) as MovieClip;
            param1.gotoAndStop("icon");
            _loc2_ = 32.5 / Math.max(param1.sizeCont.width,param1.sizeCont.height);
            param1.scaleX = param1.scaleY = _loc2_;
            param1.sizeCont.scaleX = param1.sizeCont.scaleY = _loc2_;
            param1.x += param1.sizeCont.width * 0.5;
            param1.y += param1.sizeCont.height * 0.5;
            this.itemWindow.addChild(param1);
         }
      }
      
      private function onBtnBG(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isForPVP)
         {
            _onCustomPVPBtn(param1.currentTarget.PVPGameId);
         }
         else
         {
            _onCustomAdventureBtn(param1.currentTarget.scriptDefId);
         }
      }
      
      private function updateCustAdventureBGSize(param1:MovieClip, param2:Object) : void
      {
         _balloonBG.m.height = _msgTxt.height;
         _balloonBG.m.y = _balloonBG.b.y - _msgTxt.height;
         _balloonBG.t.y = _balloonBG.m.y - _balloonBG.t.height;
         _msgTxt.y = -_balloonBG.b.height - _msgTxt.height;
         _btnBallonBG.y = _balloonBG.y + _balloonBG.t.y - _btnBallonBG.height + _balloonBG.t.height;
         if(this.itemWindow)
         {
            this.itemWindow.y = _btnBallonBG.y;
         }
      }
      
      public function setEmote(param1:Sprite, param2:int = -1) : void
      {
         if(this.currentFrameLabel != "advBtn")
         {
            _permEmoteMediaId = param2;
            if(_emote)
            {
               _emoteBG.itemWindow.removeChild(_emote);
               _emote = null;
            }
            if(_permEmoteMediaId >= 0)
            {
               param1 = new Sprite();
               _permEmoteMediaHelper = new MediaHelper();
               _permEmoteMediaHelper.init(_permEmoteMediaId,permEmoteMediaCallback);
            }
            if(param1)
            {
               _msgTxt.text = "";
               addChild(_emoteBG);
               _emote = param1;
               _emote.y = -5;
               _emoteBG.itemWindow.addChild(_emote);
               if(_emote is MovieClip)
               {
                  MovieClip(_emote).gotoAndPlay(1);
               }
               if(this.currentFrameLabel != "advBtn")
               {
                  _timeout = 8000;
               }
               _balloonBG.visible = false;
               setAlpha(1);
               _emoteBG.bubble.alpha = _maxAlpha;
               _emoteBG.itemWindow.alpha = 1;
               this.visible = true;
            }
         }
      }
      
      public function setReadyForClear() : void
      {
         if(this.visible && _timeout > 1000)
         {
            _timeout = 1000;
         }
         _permEmoteMediaId = -1;
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function heartbeat(param1:int) : void
      {
         if(_timeout && _permEmoteMediaId < 0)
         {
            if(param1 >= _timeout)
            {
               _timeout = 0;
               if(_emote)
               {
                  _emoteBG.itemWindow.removeChild(_emote);
                  _emote = null;
               }
               if(this.currentFrameLabel != "advBtn")
               {
                  this.visible = false;
               }
               else
               {
                  _msgTxt.text = _originalCustomMsgText;
                  updateCustAdventureBGSize(_balloonBG,_msgTxt);
               }
            }
            else
            {
               _timeout -= param1;
               if(this.currentFrameLabel != "advBtn" && _timeout < 1000)
               {
                  setAlpha(_timeout / 1000 * _maxAlpha);
               }
            }
         }
      }
      
      public function set avType(param1:int) : void
      {
         if(param1 != _avType)
         {
            _avType = param1;
            setEmoteBgOffsets();
         }
      }
      
      public function updateEmoteBgOffsets() : void
      {
         setEmoteBgOffsets();
      }
      
      private function setAlpha(param1:Number) : void
      {
         this.alpha = param1;
         _msgTxt.alpha = 1;
      }
      
      private function permEmoteMediaCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Point = null;
         var _loc3_:Number = NaN;
         if(param1 && _emote && _permEmoteMediaId >= 0)
         {
            param1 = param1.getChildAt(0) as MovieClip;
            _loc2_ = 0;
            while(_loc2_ < param1.currentLabels.length)
            {
               if(param1.currentLabels[_loc2_].name == "icon")
               {
                  param1.gotoAndStop("icon");
                  break;
               }
               _loc2_++;
            }
            if("sizeCont" in param1)
            {
               _loc4_ = new Point(param1.sizeCont.width,param1.sizeCont.height);
            }
            else
            {
               _loc4_ = new Point(param1.width,param1.height);
            }
            _loc3_ = 30 / Math.max(_loc4_.x,_loc4_.y);
            param1.scaleX = param1.scaleY = _loc3_;
            if("sizeCont" in param1)
            {
               param1.sizeCont.scaleX = param1.sizeCont.scaleY = _loc3_;
            }
            else
            {
               param1.x -= param1.width * 0.5;
               param1.y -= param1.height * 0.5;
            }
            _emote.addChild(param1);
         }
      }
      
      private function setEmoteBgOffsets() : void
      {
         var _loc1_:Point = _emoteBGOffsetFunc(_avType);
         _emoteBG.x = _loc1_.x;
         _emoteBG.y = _loc1_.y;
      }
   }
}

