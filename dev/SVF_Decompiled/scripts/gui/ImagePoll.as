package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ImagePoll
   {
      public static const TSHIRT_VAR_ID:int = 312;
      
      public static const DEN_ITEM_VOTING_VAR_ID:int = 374;
      
      public static const TSHIRT_IMAGES_MEDIA_ID:int = 76;
      
      public static const POLL_MEDIA_ID:int = 1355;
      
      public static const DEN_POLL_MEDIA_ID:int = 2926;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _imgPopup:MovieClip;
      
      private static var _pollTab:MovieClip;
      
      private static var _closeCallback:Function;
      
      private static var _spirals:Array;
      
      private static var _mediaIds:Array;
      
      private static var _randOptionLookup:Array;
      
      private static var _locStrings:Array;
      
      private static var _mediaHolder:Array;
      
      private static var _checkedItems:Array;
      
      private static var _itemImages:Array;
      
      private static var _numAllowedVotes:int;
      
      private static var _pollUserVardId:int;
      
      private static var _numImageWindow:int;
      
      private static var _pollPopupMediaId:int;
      
      private static var _pollUserVarIndex:int;
      
      public function ImagePoll()
      {
         super();
      }
      
      public static function displayPoll(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:MovieClip = null, param8:Function = null) : void
      {
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(param1) != param2)
         {
            DarkenManager.showLoadingSpiral(true);
            _spirals = [];
            _checkedItems = [];
            _guiLayer = GuiManager.guiLayer;
            _pollPopupMediaId = param3;
            _numImageWindow = param5;
            _numAllowedVotes = param6;
            _pollUserVardId = param1;
            _pollTab = param7;
            _closeCallback = param8;
            _pollUserVarIndex = param2;
            if(param4 != 0)
            {
               GenericListXtCommManager.requestGenericList(param4,onMediaListReceived);
            }
            else
            {
               onMediaListReceived(0,null,null);
            }
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18821));
         }
      }
      
      public static function destroy(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _mediaHolder.length)
         {
            if(_mediaHolder[_loc2_])
            {
               _mediaHolder[_loc2_].destroy();
            }
            if(_spirals[_loc2_])
            {
               _spirals[_loc2_].destroy();
            }
            _loc2_++;
         }
         removeListeners();
         DarkenManager.unDarken(_imgPopup);
         _guiLayer.removeChild(_imgPopup);
         if(param1)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18821));
         }
      }
      
      private static function onMediaListReceived(param1:int, param2:Array, param3:Array) : void
      {
         if(_mediaIds)
         {
            _mediaIds = param2;
            _randOptionLookup = [0,1,2,3,4,5,6,7,8,9];
            _locStrings = param3;
            _mediaIds = shuffleArray(_mediaIds);
         }
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_pollPopupMediaId,onMediaReceived,true);
      }
      
      private static function onMediaReceived(param1:MovieClip) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         var _loc4_:Object = null;
         if(param1)
         {
            if(param1.mediaHelper.id == _pollPopupMediaId)
            {
               DarkenManager.showLoadingSpiral(false);
               _imgPopup = MovieClip(param1.getChildAt(0));
               _imgPopup.x = 900 * 0.5;
               _imgPopup.y = 550 * 0.5;
               _imgPopup.imageViewerPopup.visible = false;
               _imgPopup.scrim.visible = false;
               if(_imgPopup.doneBtn.hasGrayState)
               {
                  _imgPopup.doneBtn.activateGrayState(true);
               }
               _mediaHelper.destroy();
               _mediaHelper = null;
               _mediaHolder = [];
               _itemImages = [];
               _loc2_ = 0;
               while(_loc2_ < _numImageWindow)
               {
                  _loc3_ = _imgPopup["pollItem" + _loc2_];
                  _loc3_.index = _loc2_;
                  _loc3_.ItemHL.itemSelectedHL.visible = false;
                  _loc3_.ItemHL.mouseOverHL.gotoAndStop("out");
                  _loc3_.checkbox.checkmark.visible = false;
                  _loc3_.checkbox.mouse.visible = false;
                  if(_mediaIds)
                  {
                     _spirals[_loc2_] = new LoadingSpiral(_loc3_.itemBlock);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_mediaIds[_loc2_],onMediaReceived,_loc2_);
                     _mediaHolder.push(_mediaHelper);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_mediaIds[_loc2_],onMediaReceived,_loc2_ + 10);
                     _mediaHolder.push(_mediaHelper);
                  }
                  _loc2_++;
               }
               _guiLayer.addChild(_imgPopup);
               DarkenManager.darken(_imgPopup);
               addListeners();
            }
            else
            {
               _loc4_ = param1.getChildAt(0);
               _itemImages[param1.passback] = _loc4_;
               if(param1.passback < _numImageWindow)
               {
                  _spirals[param1.passback].destroy();
                  _imgPopup["pollItem" + param1.passback].itemBlock.addChild(_loc4_);
               }
            }
         }
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         var _loc3_:* = 0;
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == "doneBtn")
            {
               _loc2_ = 0;
               while(_loc2_ < _checkedItems.length)
               {
                  if(_checkedItems[_loc2_] != null)
                  {
                     if(_randOptionLookup)
                     {
                        _loc3_ |= 1 << _randOptionLookup[_checkedItems[_loc2_]];
                     }
                     else
                     {
                        _loc3_ |= 1 << _checkedItems[_loc2_];
                     }
                  }
                  _loc2_++;
               }
               SBTracker.trackPageview("/game/play/imageVote/#" + _loc3_);
               AchievementXtCommManager.requestSetUserVar(_pollUserVardId,_pollUserVarIndex);
               if(_closeCallback != null)
               {
                  _closeCallback(_pollTab);
                  _closeCallback = null;
               }
            }
            else if(_closeCallback != null)
            {
               SBTracker.pop();
            }
            destroy(param1.currentTarget.name == "doneBtn");
         }
      }
      
      private static function onItemOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.ItemHL.mouseOverHL.currentFrameLabel != "out")
         {
            param1.currentTarget.ItemHL.mouseOverHL.gotoAndStop("out");
         }
      }
      
      private static function onItemOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.ItemHL.mouseOverHL.currentFrameLabel != "over")
         {
            param1.currentTarget.ItemHL.mouseOverHL.gotoAndStop("over");
         }
      }
      
      private static function onCheckOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.mouse.visible = !param1.currentTarget.mouse.visible;
      }
      
      private static function onCheckOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.mouse.visible = !param1.currentTarget.mouse.visible;
      }
      
      private static function onCheckOrVote(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Boolean = false;
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == "checkbox")
         {
            param1.currentTarget.checkmark.visible = _loc4_ = !param1.currentTarget.checkmark.visible;
            _loc2_ = int(param1.currentTarget.parent.index);
         }
         else
         {
            _loc2_ = int(param1.currentTarget.parent.currPollIndex);
            _imgPopup["pollItem" + _loc2_].checkbox.checkmark.visible = _loc4_ = !_imgPopup["pollItem" + _loc2_].checkbox.checkmark.visible;
         }
         if(_loc4_)
         {
            _checkedItems.push(_loc2_);
            if(_checkedItems.length > _numAllowedVotes)
            {
               _loc3_ = int(_checkedItems[0]);
               _checkedItems.shift();
               _imgPopup["pollItem" + _loc3_].checkbox.checkmark.visible = false;
               _imgPopup["pollItem" + _loc3_].ItemHL.itemSelectedHL.visible = false;
            }
            if(_checkedItems.length > 0)
            {
               if(_imgPopup.doneBtn.hasGrayState && _imgPopup.doneBtn.isGray)
               {
                  _imgPopup.doneBtn.activateGrayState(false);
               }
            }
         }
         else
         {
            _checkedItems.splice(_checkedItems.indexOf(_loc2_),1);
            if(_imgPopup.doneBtn.hasGrayState && !_imgPopup.doneBtn.isGray && _checkedItems.length == 0)
            {
               _imgPopup.doneBtn.activateGrayState(true);
            }
         }
         _imgPopup["pollItem" + _loc2_].ItemHL.itemSelectedHL.visible = _loc4_;
         if(param1.currentTarget.name != "checkbox")
         {
            _imgPopup.imageViewerPopup.visible = false;
            _imgPopup.scrim.visible = false;
         }
      }
      
      private static function onItemZoom(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         param1.stopPropagation();
         _imgPopup.imageViewerPopup.visible = true;
         _imgPopup.scrim.visible = true;
         if(_imgPopup.imageViewerPopup.currentLabels.length < 1)
         {
            while(_imgPopup.imageViewerPopup.itemBlock.numChildren > 0)
            {
               _imgPopup.imageViewerPopup.itemBlock.removeChildAt(0);
            }
         }
         var _loc2_:int = int(param1.currentTarget.name == "zoomBtn" ? param1.currentTarget.parent.index : param1.currentTarget.index);
         if(_itemImages)
         {
            _loc3_ = _itemImages[_loc2_ + 10];
            if(_loc3_ != null)
            {
               _loc3_.gotoAndStop("large");
               _imgPopup.imageViewerPopup.itemBlock.addChild(_loc3_);
            }
         }
         if(_locStrings)
         {
            _imgPopup.imageViewerPopup.titleTxt.text = _locStrings[_randOptionLookup[_loc2_]];
         }
         if(_imgPopup.imageViewerPopup.currentLabels.length > 1)
         {
            _imgPopup.imageViewerPopup.gotoAndStop("pollItem" + _loc2_);
            _imgPopup.imageViewerPopup.titleTxt.text = _imgPopup["pollItem" + _loc2_].titleTxt.text;
         }
         _imgPopup.imageViewerPopup.currPollIndex = _loc2_;
      }
      
      private static function onCloseViewer(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _imgPopup.imageViewerPopup.visible = false;
         _imgPopup.scrim.visible = false;
      }
      
      private static function shuffleArray(param1:Array) : Array
      {
         var _loc7_:String = null;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = int(param1.length);
         var _loc4_:Array = param1.slice();
         while(_loc6_ < _loc3_)
         {
            _loc7_ = _loc4_[_loc6_];
            _loc2_ = Math.floor(Math.random() * _loc3_);
            if(_loc6_ != _loc2_)
            {
               _loc4_[_loc6_] = _loc4_[_loc2_];
               _loc4_[_loc2_] = _loc7_;
               _loc5_ = int(_randOptionLookup[_loc6_]);
               _randOptionLookup[_loc6_] = _randOptionLookup[_loc2_];
               _randOptionLookup[_loc2_] = _loc5_;
            }
            _loc6_++;
         }
         return _loc4_;
      }
      
      private static function addListeners() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         _imgPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _imgPopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _imgPopup.doneBtn.addEventListener("mouseDown",onClose,false,0,true);
         _loc1_ = 0;
         while(_loc1_ < _numImageWindow)
         {
            _loc2_ = _imgPopup["pollItem" + _loc1_];
            _loc2_.addEventListener("mouseOut",onItemOut,false,0,true);
            _loc2_.addEventListener("mouseOver",onItemOver,false,0,true);
            _loc2_.addEventListener("mouseDown",onItemZoom,false,0,true);
            _loc2_.zoomBtn.addEventListener("mouseDown",onItemZoom,false,0,true);
            _loc2_.checkbox.addEventListener("rollOver",onCheckOver,false,0,true);
            _loc2_.checkbox.addEventListener("rollOut",onCheckOut,false,0,true);
            _loc2_.checkbox.addEventListener("mouseDown",onCheckOrVote,false,0,true);
            _loc1_++;
         }
         _imgPopup.imageViewerPopup.bx.addEventListener("mouseDown",onCloseViewer,false,0,true);
         _imgPopup.imageViewerPopup.voteBtn.addEventListener("mouseDown",onCheckOrVote,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = 0;
         _imgPopup.removeEventListener("mouseDown",onPopup);
         _imgPopup.bx.removeEventListener("mouseDown",onClose);
         _imgPopup.doneBtn.removeEventListener("mouseDown",onClose);
         _loc1_ = 0;
         while(_loc1_ < _numImageWindow)
         {
            _loc2_ = _imgPopup["pollItem" + _loc1_];
            _loc2_.removeEventListener("mouseOut",onItemOut);
            _loc2_.removeEventListener("mouseOver",onItemOver);
            _loc2_.removeEventListener("mouseDown",onItemZoom);
            _loc2_.zoomBtn.removeEventListener("mouseDown",onItemZoom);
            _loc2_.checkbox.removeEventListener("rollOver",onCheckOver);
            _loc2_.checkbox.removeEventListener("rollOut",onCheckOut);
            _loc2_.checkbox.removeEventListener("mouseDown",onCheckOrVote);
            _loc1_++;
         }
         _imgPopup.imageViewerPopup.bx.removeEventListener("mouseDown",onCloseViewer);
         _imgPopup.imageViewerPopup.voteBtn.removeEventListener("mouseDown",onCheckOrVote);
      }
   }
}

