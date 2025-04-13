package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBStandardTitlePopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.utils.ByteArray;
   import loader.FeedbackDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class FeedbackManager
   {
      public static const TYPE_ASK_BRADY:int = 1;
      
      public static const TYPE_ITEMS:int = 2;
      
      public static const TYPE_HOWL:int = 3;
      
      public static const TYPE_WORK:int = 4;
      
      public static const TYPE_GENERIC:int = 5;
      
      public static const TYPE_FLAGS:int = 6;
      
      public static const TYPE_PETS:int = 7;
      
      public static const TYPE_PARTIES:int = 8;
      
      public static const TYPE_EPIC_ITEMS:int = 9;
      
      public static const TYPE_ARCADE:int = 10;
      
      public static const TYPE_ASK_TIERNEY:int = 11;
      
      public static const TYPE_DONATION:int = 12;
      
      public static const TYPE_CARNIVAL:int = 13;
      
      public static const TYPE_ARTSTUDIO:int = 14;
      
      public static const TYPE_JAMSESSION:int = 15;
      
      public static const TYPE_DIAMOND:int = 16;
      
      public static const TYPE_ADVENTURE:int = 17;
      
      public static const TYPE_DICTIONARY:int = 18;
      
      public static const TYPE_CHAT_EXPERIENCE:int = 19;
      
      public static const TYPE_MASTERPIECES:int = 20;
      
      public static const TYPE_ASK_CAMI:int = 21;
      
      public static const TYPE_ASK_GABBY:int = 22;
      
      private static const TAB_MEDIA_ID:int = 153;
      
      private static const POPUP_MEDIA_ID:int = 457;
      
      private static const TAB_FRAME_LABEL:String = "answer";
      
      private static var _feedbackDefCache:Array;
      
      private static var _feedbackLocs:Array;
      
      private static var _feedbackDefHelpers:Array;
      
      private static var _tabMediaHelper:MediaHelper;
      
      private static var _tabTemplate:MovieClip;
      
      private static var _popupMediaHelper:MediaHelper;
      
      private static var _popup:MovieClip;
      
      private static var _imageUploader:UserImageUpload;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _worldLayer:DisplayLayer;
      
      private static var _secondaryType:int;
      
      public function FeedbackManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:DisplayLayer) : void
      {
         _feedbackDefCache = [];
         _guiLayer = param1;
         _worldLayer = param2;
         _popupMediaHelper = new MediaHelper();
         _tabMediaHelper = new MediaHelper();
         _tabMediaHelper.init(153,mediaHelperCallback,true);
         _imageUploader = new UserImageUpload();
         _imageUploader.init();
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("openFeedback",handleOpenDefaultFeedback);
         }
      }
      
      public static function setUpOrbs(param1:Array, param2:Array) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc5_:FeedbackDefHelper = null;
         _feedbackLocs = param2;
         _feedbackDefHelpers = [];
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            if(param1[_loc4_] == 0)
            {
               DarkenManager.showLoadingSpiral(false);
               throw new Error("Id == 0");
            }
            _loc3_ = _feedbackDefCache[param1[_loc4_]];
            if(!_loc3_)
            {
               _loc5_ = new FeedbackDefHelper();
               _loc5_.init(param1[_loc4_],onDefReceived);
               _feedbackDefHelpers[param1[_loc4_]] = _loc5_;
            }
            else
            {
               setUpOrb(_loc3_);
            }
            _loc4_++;
         }
      }
      
      public static function openFeedbackPopup(param1:int) : void
      {
         var _loc3_:FeedbackDefHelper = null;
         if(param1 == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            throw new Error("Id == 0");
         }
         DarkenManager.showLoadingSpiral(true);
         if(!_feedbackDefHelpers)
         {
            _feedbackDefHelpers = [];
         }
         var _loc2_:Object = _feedbackDefCache[param1];
         if(!_loc2_)
         {
            _loc3_ = new FeedbackDefHelper();
            _loc3_.init(param1,onDefReceived);
            _feedbackDefHelpers[param1] = _loc3_;
         }
         else
         {
            displayFeedbackPopup(_loc2_);
         }
      }
      
      private static function handleOpenDefaultFeedback() : void
      {
         openFeedbackPopup(5);
      }
      
      private static function onDefReceived(param1:FeedbackDefHelper) : void
      {
         var _loc5_:Object = param1.def;
         var _loc4_:String = LocalizationManager.translateIdOnly(int(_loc5_.defaultStrRef));
         var _loc3_:RegExp = /\r\n/g;
         _loc4_ = _loc4_.replace(_loc3_,"\n");
         _loc3_ = /\r/g;
         _loc4_ = _loc4_.replace(_loc3_,"\n");
         var _loc2_:Object = {
            "id":int(_loc5_.id),
            "titleTxt":LocalizationManager.translateIdOnly(int(_loc5_.titleStrRef)),
            "defaultTxt":_loc4_,
            "thanksTxt":LocalizationManager.translateIdOnly(int(_loc5_.thankStrRef)),
            "allowImg":Boolean(int(_loc5_.bAcceptImage)),
            "userVarId":int(_loc5_.userVarRef),
            "bitIdx":int(_loc5_.bitIndex)
         };
         _feedbackDefCache[_loc2_.id] = _loc2_;
         _feedbackDefHelpers[_loc2_.id] = null;
         _loc2_.seen = gMainFrame.userInfo.userVarCache.isBitSet(_loc2_.userVarId,_loc2_.bitIdx);
         if(_loc2_.id == 1 || _loc2_.id == 11 || _loc2_.id == 3 || _loc2_.id == 4 || _loc2_.id == 5 || _loc2_.id == 18 || _loc2_.id == 19 || _loc2_.id == 21 || _loc2_.id == 22)
         {
            displayFeedbackPopup(_loc2_);
         }
         else
         {
            setUpOrb(_loc2_);
         }
      }
      
      private static function setUpOrb(param1:Object) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         if(_tabTemplate)
         {
            _loc3_ = new _tabTemplate.constructor();
            _loc3_.def = param1;
            _loc2_ = _loc3_.id = int(param1.id);
            _loc3_.x = _feedbackLocs[_loc2_].x;
            _loc3_.y = _feedbackLocs[_loc2_].y;
            if(param1.seen)
            {
               _loc3_.gotoAndPlay("answerDim");
            }
            else
            {
               _loc3_.gotoAndPlay("answer");
            }
            _loc3_.addEventListener("mouseDown",onTabMouseDown,false,0,true);
            _worldLayer.addChild(_loc3_);
         }
      }
      
      private static function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(param1.mediaHelper.id == 153)
            {
               _loc2_ = int(param1.mediaHelper.id);
               _tabTemplate = MovieClip(param1.getChildAt(0));
               _tabMediaHelper.destroy();
               _tabMediaHelper = null;
            }
            else if(param1.mediaHelper.id == 457)
            {
               _popup = param1;
               _popupMediaHelper.destroy();
               _popupMediaHelper = null;
               _popup.x = 900 * 0.5;
               _popup.y = 550 * 0.5;
               _popup.parent.x = _popup.x;
               _popup.parent.y = _popup.y;
               displayFeedbackPopup(param1.passback);
            }
         }
      }
      
      private static function onTabMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:MovieClip = MovieClip(param1.currentTarget);
         var _loc3_:Object = _loc2_.def;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/feedback/" + _loc3_.id);
         DarkenManager.showLoadingSpiral(true);
         if(!_loc3_.seen)
         {
            _loc2_.gotoAndPlay("answerDim");
         }
         displayFeedbackPopup(_loc3_);
      }
      
      public static function displayFeedbackPopup(param1:Object) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = int(param1.id);
         if(!_popup)
         {
            _popupMediaHelper.init(457,mediaHelperCallback,param1);
            return;
         }
         if(!param1.seen)
         {
            param1.seen = true;
            AchievementXtCommManager.requestSetUserVar(param1.userVarId,param1.bitIdx);
         }
         removePopup();
         _popup.gotoAndStop(frameLabelForType(_loc2_));
         _popup.submitBtn.addEventListener("mouseDown",onMouseDown,false,0,true);
         _popup.bx.addEventListener("mouseDown",onMouseDown,false,0,true);
         _popup.addEventListener("mouseDown",onMouseDown,false,0,true);
         _popup.txt.addEventListener("mouseDown",onMouseDown,false,0,true);
         _popup.def = param1;
         if(_popup["descTxt"])
         {
            _loc3_ = param1.defaultTxt.split("|");
            LocalizationManager.updateToFit(_popup.descTxt,_loc3_[0]);
            LocalizationManager.updateToFit(_popup.txt,_loc3_[1]);
         }
         else
         {
            LocalizationManager.updateToFit(_popup.txt,param1.defaultTxt);
         }
         _popup.defaultTxt = _popup.txt.text;
         _popup.titleTxt.text = param1.titleTxt;
         if(param1.allowImg)
         {
            _popup.addFileBtn.visible = true;
            _imageUploader.setUploadBtn(_popup.addFileBtn);
            _popup.removeFileBtn.addEventListener("mouseDown",onRemoveFileBtn,false,0,true);
         }
         else
         {
            if(_popup.addFileBtn)
            {
               _popup.addFileBtn.visible = false;
            }
            if(_popup.removeFileBtn)
            {
               _popup.removeFileBtn.visible = false;
            }
         }
         _popup.txt.maxChars = maxCharsForType(_loc2_);
         if(_loc2_ == 18)
         {
            _popup.txt.restrict = "^ ";
         }
         else
         {
            _popup.txt.restrict = null;
         }
         _popup.visible = true;
         _popup.clickedTextBox = false;
         KeepAlive.startKATimer(_popup);
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(DisplayObjectContainer(_popup));
         _guiLayer.addChild(DisplayObjectContainer(_popup));
      }
      
      private static function frameLabelForType(param1:int) : int
      {
         switch(param1)
         {
            case 1:
               return 1;
            case 3:
            case 19:
               return 2;
            case 4:
            case 2:
            case 5:
            case 6:
            case 7:
            case 8:
            case 9:
            case 10:
            case 13:
            case 15:
            case 16:
            case 17:
               break;
            case 11:
               return 4;
            case 18:
               return 6;
            case 21:
               return 7;
            case 22:
               return 8;
            default:
               return 1;
         }
         return 3;
      }
      
      private static function maxCharsForType(param1:int) : int
      {
         switch(param1)
         {
            case 1:
            case 11:
            case 21:
            case 22:
               return 150;
            case 3:
               return 50;
            case 4:
               return 3000;
            case 2:
            case 9:
            case 16:
            case 10:
            case 17:
            case 5:
               return 300;
            case 12:
            case 8:
            case 7:
            case 15:
            case 6:
            case 13:
            case 14:
               break;
            case 19:
               return 200;
            case 18:
               return 25;
            default:
               return 1;
         }
         return 100;
      }
      
      private static function onRemoveFileBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _imageUploader.resetUploader();
         _popup.addFileBtn.visible = true;
      }
      
      private static function onMouseDown(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:RegExp = null;
         param1.stopPropagation();
         if(param1.currentTarget == _popup)
         {
            return;
         }
         if(param1.currentTarget == _popup.txt)
         {
            if(!_popup.clickedTextBox)
            {
               _popup.txt.text = "";
               _popup.clickedTextBox = true;
               gMainFrame.stage.focus = _popup.txt;
               _popup.txt.setSelection(0,0);
            }
            return;
         }
         if(param1.currentTarget.name == "submitBtn")
         {
            _loc3_ = _popup.txt.text;
            _loc2_ = /\r\n/g;
            _loc3_ = _loc3_.replace(_loc2_,"\n");
            _loc2_ = /\r/g;
            _loc3_ = _loc3_.replace(_loc2_,"\n");
            if(_loc3_.length > 0 && _loc3_ != _popup.defaultTxt || _imageUploader.fileName != "")
            {
               if(_loc3_ == _popup.def.defaultTxt)
               {
                  _popup.txt.text = "";
                  _loc3_ = "";
               }
               setupRequest(_imageUploader,_loc3_,_popup.def.id,_secondaryType,onSendComplete,onSendError);
            }
         }
         removePopup(param1.currentTarget.name == "bx");
      }
      
      private static function removePopup(param1:Boolean = true) : void
      {
         if(_popup)
         {
            _popup.removeEventListener("mouseDown",onMouseDown);
            _popup.bx.removeEventListener("mouseDown",onMouseDown);
            _popup.submitBtn.removeEventListener("mouseDown",onMouseDown);
            _popup.txt.removeEventListener("mouseDown",onMouseDown);
            if(_popup.def && _popup.def.allowImg)
            {
               _imageUploader.resetUploader();
               _popup.addFileBtn.visible = true;
               _popup.removeFileBtn.removeEventListener("mouseDown",onRemoveFileBtn);
            }
            DarkenManager.unDarken(_popup);
            _popup.visible = false;
            SBTracker.pop();
            if(!param1)
            {
               new SBStandardTitlePopup(_guiLayer,_popup.def.thanksTxt);
            }
            KeepAlive.stopKATimer(_popup);
         }
      }
      
      public static function setupRequest(param1:UserImageUpload, param2:String, param3:int, param4:int, param5:Function, param6:Function) : void
      {
         var _loc7_:String = "---------------------------" + Math.floor(Math.random() * 100000000000000);
         var _loc10_:Object = {
            "userName":gMainFrame.userInfo.myUserName,
            "avatarName":gMainFrame.userInfo.playerAvatarInfo.unlocalizedAvName,
            "type":param3,
            "message":param2,
            "secondaryType":param4,
            "languageId":LocalizationManager.currentLanguage
         };
         var _loc8_:URLRequest = new URLRequest(gMainFrame.clientInfo.mdUrl + "fb");
         _loc8_.contentType = "multipart/form-data; boundary=" + _loc7_;
         _loc8_.requestHeaders.push(new URLRequestHeader("Cache-Control","no-cache"));
         _loc8_.method = "POST";
         _loc8_.data = createPostData(param1.fileName,param1.uploadedImage,_loc7_,_loc10_);
         var _loc9_:URLLoader = new URLLoader();
         _loc9_.dataFormat = "binary";
         _loc9_.addEventListener("complete",param5);
         _loc9_.addEventListener("ioError",param6);
         _loc9_.load(_loc8_);
      }
      
      public static function createPostData(param1:String, param2:ByteArray, param3:String, param4:Object = null) : ByteArray
      {
         var _loc5_:String = null;
         var _loc7_:int = 0;
         var _loc8_:ByteArray = new ByteArray();
         _loc8_.endian = "bigEndian";
         if(param4 == null)
         {
            param4 = {};
         }
         for(var _loc6_ in param4)
         {
            writeBoundary(_loc8_,param3);
            writeLineBreak(_loc8_);
            _loc5_ = "Content-Disposition: form-data; name=\"" + _loc6_ + "\"";
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               _loc8_.writeByte(_loc5_.charCodeAt(_loc7_));
               _loc7_++;
            }
            writeLineBreak(_loc8_);
            writeLineBreak(_loc8_);
            _loc8_.writeUTFBytes(param4[_loc6_]);
            writeLineBreak(_loc8_);
         }
         if(param2)
         {
            writeBoundary(_loc8_,param3);
            writeLineBreak(_loc8_);
            _loc5_ = "Content-Disposition: form-data; name=\"image\"; filename=\"" + param1 + "\"";
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               _loc8_.writeByte(_loc5_.charCodeAt(_loc7_));
               _loc7_++;
            }
            writeLineBreak(_loc8_);
            _loc5_ = "Content-Type: image/jpeg";
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               _loc8_.writeByte(_loc5_.charCodeAt(_loc7_));
               _loc7_++;
            }
            writeLineBreak(_loc8_);
            writeLineBreak(_loc8_);
            _loc8_.writeBytes(param2,0,param2.length);
            writeLineBreak(_loc8_);
         }
         writeBoundary(_loc8_,param3);
         writeDoubleDash(_loc8_);
         writeLineBreak(_loc8_);
         return _loc8_;
      }
      
      private static function writeLineBreak(param1:ByteArray) : void
      {
         param1.writeShort(3338);
      }
      
      private static function writeDoubleDash(param1:ByteArray) : void
      {
         param1.writeShort(11565);
      }
      
      private static function writeBoundary(param1:ByteArray, param2:String) : void
      {
         var _loc3_:int = 0;
         writeDoubleDash(param1);
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            param1.writeByte(param2.charCodeAt(_loc3_));
            _loc3_++;
         }
      }
      
      private static function onSendComplete(param1:Event) : void
      {
         trace("w00t!");
      }
      
      private static function onSendError(param1:Event) : void
      {
         trace("Argh! Error sending....");
      }
   }
}

