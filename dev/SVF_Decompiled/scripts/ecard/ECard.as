package ecard
{
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ECard
   {
      public static const TYPE_STANDARD:int = 0;
      
      public static const TYPE_CLOTHING:int = 1;
      
      public static const TYPE_BUDDY:int = 2;
      
      public static const TYPE_DEN_ACC:int = 3;
      
      public static const TYPE_GEMS:int = 4;
      
      public static const TYPE_DEN_ROOM:int = 5;
      
      public static const TYPE_AVT:int = 6;
      
      public static const TYPE_SUBSCRIPTION:int = 7;
      
      public static const TYPE_PET:int = 8;
      
      public static const TYPE_DIAMOND:int = 9;
      
      public static const TYPE_CUSTOM_AVT:int = 10;
      
      public static const TYPE_EMAIL_RESET:int = 11;
      
      public static const TYPE_ADOPT_A_PET:int = 12;
      
      public static const TYPE_PROMOTION:int = 13;
      
      public static const TYPE_DEN_AUDIO:int = 99;
      
      public static const CARD_ID_REDEMPTION:int = 0;
      
      public static const CARD_ID_BULK:int = -1;
      
      public static const ECARD_REDEMPTION_STAMP_NORMAL:int = 0;
      
      public static const ECARD_REDEMPTION_STAMP_AJJUMP:int = 1;
      
      public static const ECARD_REDEMPTION_STAMP_DIAMOND_REFUND:int = 2;
      
      public static const ECARD_REDEMPTION_STAMP_REFERRAL:int = 3;
      
      public static const MESSAGE_TYPE_BUBBLECHAT:int = 1;
      
      public static const MESSAGE_TYPE_LIMITEDCHAT:int = 2;
      
      public static const SENDER_USER:int = 0;
      
      public static const SENDER_VOICE:int = 1;
      
      public static const SENDER_REDEM:int = 2;
      
      public static const SPECIAL_TYPE_NORMAL:int = 0;
      
      public static const SPECIAL_TYPE_VALENTINES:int = 1;
      
      private var _msgId:int;
      
      private var _senderUserName:String;
      
      private var _cardMediaId:int;
      
      private var _stampMediaId:int;
      
      private var _isRead:Boolean;
      
      private var _msg:String;
      
      private var _type:int;
      
      private var _secondaryType:int;
      
      private var _giftId:int;
      
      private var _giftColor:uint;
      
      private var _giftName:String;
      
      private var _senderType:int;
      
      private var _senderSGAccountType:int;
      
      private var _senderNameBarData:int;
      
      private var _userNameModerationFlag:int;
      
      private var _messageTxt:TextField;
      
      private var _stampCont:MovieClip;
      
      private var _isReadInProcess:Boolean;
      
      private var _additionalGiftData:String;
      
      private var _specialType:int;
      
      private var _cardImg:MovieClip;
      
      private var _cardImgHelper:MediaHelper;
      
      private var _stampImg:MovieClip;
      
      private var _stampImgHelper:MediaHelper;
      
      private var _acceptBtn:MovieClip;
      
      private var _rejectBtn:MovieClip;
      
      private var _memberNameBar:MovieClip;
      
      private var _nonMemberNameBar:MovieClip;
      
      private var _nonMemberUserName:TextField;
      
      private var _charBox:MovieClip;
      
      private var _linkToBtn:MovieClip;
      
      private var _changeEmailBtn:MovieClip;
      
      private var _cancelEmailBtn:MovieClip;
      
      private var _buttonsLoadedCallback:Function;
      
      public function ECard()
      {
         super();
      }
      
      public function init(param1:int, param2:String, param3:int, param4:int, param5:Boolean, param6:String, param7:int, param8:int, param9:uint, param10:String, param11:int, param12:int, param13:int, param14:int, param15:int, param16:String, param17:int) : void
      {
         _msgId = param1;
         _senderUserName = param2;
         _cardMediaId = param3;
         _stampMediaId = param4;
         _isRead = param5;
         _msg = param6;
         _type = param7;
         _giftId = param8;
         _giftColor = param9;
         _giftName = param10;
         _senderSGAccountType = param11;
         _senderNameBarData = param12;
         _secondaryType = param13;
         _senderType = param14;
         _userNameModerationFlag = param15;
         _additionalGiftData = param16;
         _specialType = param17;
         if(param7 == 3 && DenXtCommManager.getDenItemDef(_giftId) != null)
         {
            if(DenXtCommManager.getDenItemDef(_giftId).sortCat == 4)
            {
               _type = 99;
            }
         }
         else if(param7 == 0 && _giftId > 0)
         {
            _giftId = 0;
         }
         if(param17 == 1)
         {
            _senderUserName = LocalizationManager.translateIdOnly(32191);
         }
         else if(isFromVoice)
         {
            _senderUserName = LocalizationManager.translateIdOnly(int(_senderUserName));
         }
         _stampImg = new MovieClip();
         _cardImg = new MovieClip();
      }
      
      public function get msgId() : int
      {
         return _msgId;
      }
      
      public function get senderUserName() : String
      {
         return _senderUserName;
      }
      
      public function get senderModeratedUserName() : String
      {
         if(_specialType == 1 || _userNameModerationFlag > 0)
         {
            return _senderUserName;
         }
         return LocalizationManager.translateIdOnly(11098);
      }
      
      public function get cardMediaId() : int
      {
         return _cardMediaId;
      }
      
      public function get stampMediaId() : int
      {
         return _stampMediaId;
      }
      
      public function get isRead() : Boolean
      {
         return _isRead;
      }
      
      public function set isRead(param1:Boolean) : void
      {
         _isRead = param1;
      }
      
      public function get msg() : String
      {
         return _msg;
      }
      
      public function set msg(param1:String) : void
      {
         _msg = param1;
      }
      
      public function get modifiedMsg() : String
      {
         var _loc1_:String = null;
         if(_msg == "")
         {
            if(_cardImg.numChildren == 0)
            {
               cardImg;
            }
            return "";
         }
         if(isFromVoice)
         {
            if(_type == 11)
            {
               return LocalizationManager.translateIdOnly(24440);
            }
            if(isNaN(parseInt(_msg)))
            {
               return _msg;
            }
            _loc1_ = LocalizationManager.translateIdOnly(parseInt(_msg));
            if(_loc1_.indexOf("%s") == -1)
            {
               return _loc1_;
            }
            return LocalizationManager.translateIdAndInsertOnly(parseInt(_msg),_additionalGiftData);
         }
         if(!ECardManager.isECardTextValid(_msg))
         {
            _msg = LocalizationManager.translateIdOnly(28985);
         }
         return _msg;
      }
      
      public function get isBuddy() : Boolean
      {
         return _type == 2;
      }
      
      public function get isGift() : Boolean
      {
         return (_type == 1 || _type >= 3) && _type != 11;
      }
      
      public function get isEmailReset() : Boolean
      {
         return _type == 11;
      }
      
      public function get giftId() : int
      {
         return _giftId;
      }
      
      public function get giftColor() : uint
      {
         return _giftColor;
      }
      
      public function get giftName() : String
      {
         return _giftName;
      }
      
      public function set giftName(param1:String) : void
      {
         _giftName = param1;
      }
      
      public function get isSenderMember() : Boolean
      {
         return _senderSGAccountType >= 2;
      }
      
      public function get isSenderArchived() : Boolean
      {
         return _senderSGAccountType == -2;
      }
      
      public function get senderSGAccountType() : int
      {
         return _senderSGAccountType;
      }
      
      public function get isFromUser() : Boolean
      {
         return _senderType == 0;
      }
      
      public function get isFromVoice() : Boolean
      {
         return _senderType == 1;
      }
      
      public function get isStartupJAG() : Boolean
      {
         return _senderType == 2 || !gMainFrame.userInfo.isMember && isAJHQGift || _cardMediaId == -1;
      }
      
      public function get isRedemptionJAG() : Boolean
      {
         if(isStartupJAG && (giftId > 0 || type == 4 || type == 7 || type == 13 || type == 9))
         {
            return true;
         }
         return false;
      }
      
      public function get isAJHQGift() : Boolean
      {
         return isFromVoice && _giftId > 0;
      }
      
      public function get isBulkItem() : Boolean
      {
         return _cardMediaId == -1;
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function set type(param1:int) : void
      {
         _type = param1;
      }
      
      public function get secondaryType() : int
      {
         return _secondaryType;
      }
      
      public function get nameBarData() : int
      {
         return _senderNameBarData;
      }
      
      public function set nameBarData(param1:int) : void
      {
         _senderNameBarData = param1;
      }
      
      public function get cardImg() : MovieClip
      {
         if(_cardImg.numChildren == 0)
         {
            if(_cardImgHelper == null)
            {
               _cardImgHelper = new MediaHelper();
               _cardImgHelper.init(_cardMediaId,cardImgReceived);
            }
         }
         else
         {
            ECardManager.onECardLoaded(this);
         }
         return _cardImg;
      }
      
      public function get stampImg() : MovieClip
      {
         if(_type != 2 && !isFromVoice)
         {
            if(_stampImg.numChildren == 0)
            {
               _stampImgHelper = new MediaHelper();
               _stampImgHelper.init(_stampMediaId,stampImgReceived);
            }
         }
         return _stampImg;
      }
      
      public function get acceptBtn() : MovieClip
      {
         return _acceptBtn;
      }
      
      public function get rejectBtn() : MovieClip
      {
         return _rejectBtn;
      }
      
      public function get memberNameBar() : MovieClip
      {
         return _memberNameBar;
      }
      
      public function get nonMemberNameBar() : MovieClip
      {
         return _nonMemberNameBar;
      }
      
      public function get nonMemberUserName() : TextField
      {
         return _nonMemberUserName;
      }
      
      public function get charBox() : MovieClip
      {
         return _charBox;
      }
      
      public function get changeEmailBtn() : MovieClip
      {
         return _changeEmailBtn;
      }
      
      public function get cancelEmailBtn() : MovieClip
      {
         return _cancelEmailBtn;
      }
      
      public function get messageTxt() : TextField
      {
         return _messageTxt;
      }
      
      public function get stampCont() : MovieClip
      {
         return _stampCont;
      }
      
      public function get isReadInProcess() : Boolean
      {
         return _isReadInProcess;
      }
      
      public function set isReadInProcess(param1:Boolean) : void
      {
         _isReadInProcess = param1;
      }
      
      public function get additionalGiftData() : String
      {
         return _additionalGiftData;
      }
      
      public function get linkToBtn() : MovieClip
      {
         return _linkToBtn;
      }
      
      public function get specialType() : int
      {
         return _specialType;
      }
      
      private function cardImgReceived(param1:MovieClip) : void
      {
         var _loc3_:TextFormat = null;
         var _loc2_:MovieClip = param1.getChildAt(0) as MovieClip;
         if(_loc2_)
         {
            param1 = _loc2_;
         }
         _cardImg.addChild(param1);
         if(param1.userNameTxt)
         {
            param1.userNameTxt.text = _senderUserName;
         }
         if(param1.msgTxt)
         {
            _messageTxt = param1.msgTxt;
            if(modifiedMsg == "")
            {
               _msg = _messageTxt.text;
            }
            if(isFromUser)
            {
               if(modifiedMsg != "")
               {
                  _messageTxt.text = modifiedMsg;
               }
               _loc3_ = _messageTxt.getTextFormat();
               _loc3_.size = 50;
               _messageTxt.setTextFormat(_loc3_);
               if(_messageTxt.textHeight / Number(_messageTxt.getTextFormat().size) > 1 || _messageTxt.textHeight / 50 > 1)
               {
                  _loc3_.size = 30;
                  _messageTxt.setTextFormat(_loc3_);
                  if(_messageTxt.textHeight / Number(_messageTxt.getTextFormat().size) < 1)
                  {
                     _messageTxt.y += 13;
                  }
               }
               else
               {
                  _messageTxt.setTextFormat(_loc3_);
               }
            }
            else if(modifiedMsg != "" && _type != 11)
            {
               LocalizationManager.updateToFit(_messageTxt,modifiedMsg);
            }
         }
         else if(isFromUser)
         {
            _msg = LocalizationManager.translateIdOnly(28985);
         }
         else
         {
            _msg = LocalizationManager.translateIdOnly(24440);
         }
         if(param1.stamp)
         {
            _stampCont = param1.stamp;
            _stampCont.addChild(stampImg);
         }
         if(_type == 2)
         {
            if(param1.okBtn)
            {
               _acceptBtn = param1.okBtn;
            }
            if(param1.cancelBtn)
            {
               _rejectBtn = param1.cancelBtn;
            }
            if(param1.member)
            {
               _memberNameBar = param1.member;
            }
            if(param1.nonmember)
            {
               _nonMemberNameBar = param1.nonmember;
            }
            if(param1.userName_txt)
            {
               _nonMemberUserName = param1.userName_txt;
            }
            if(param1.charBox)
            {
               _charBox = param1.charBox;
            }
         }
         else if(_type == 11)
         {
            if(param1.changeEmailBtn)
            {
               _changeEmailBtn = param1.changeEmailBtn;
            }
            if(param1.cancelBtn)
            {
               _cancelEmailBtn = param1.cancelBtn;
            }
         }
         if((_cardMediaId == 1194 || _cardMediaId == 1630) && _msg != "")
         {
            if(param1.hasOwnProperty("txt"))
            {
               param1.txt.text = "";
            }
         }
         if(param1.linkTo)
         {
            _linkToBtn = param1.linkTo;
         }
         ECardManager.onECardLoaded(this);
         _cardImgHelper.destroy();
         _cardImgHelper = null;
      }
      
      private function stampImgReceived(param1:MovieClip) : void
      {
         _stampImg.addChild(param1);
      }
   }
}

