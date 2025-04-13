package gui
{
   import den.DenItem;
   import den.DenStateItem;
   import den.DenXtCommManager;
   import den.EcoStateResponse;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import shop.ShopManager;
   
   public class EcoPointsPopup
   {
      private static const POPUP_ID:int = 8344;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _bx:MovieClip;
      
      private var _infoPopupCont:MovieClip;
      
      private var _generatorBtn:MovieClip;
      
      private var _meterCircleCont:MovieClip;
      
      private var _totalConsumedPointsTxt:TextField;
      
      private var _viewEcoScoreBtn:MovieClip;
      
      private var _ecoPointsTxt:TextField;
      
      private var _toggleBtn:MovieClip;
      
      private var _itemBlock:MovieClip;
      
      private var _burst:MovieClip;
      
      private var _arrowCont:MovieClip;
      
      private var _ecoItem:DenItem;
      
      private var _ecoItemState:DenStateItem;
      
      private var _titleTxt:TextField;
      
      private var _infoBtn:MovieClip;
      
      private var _infoPopupCloseBtn:MovieClip;
      
      private var _infoPopupEcoShopBtn:MovieClip;
      
      private var _ecoScorePopup:EcoScorePopup;
      
      private var _offlineRedTxt:TextField;
      
      private var _numActiveWindTurbines:int;
      
      private var _numActiveSolarPanels:int;
      
      private var _ecoScore:int;
      
      private var _nextRewardBitIndex:int;
      
      private var _unredeemedEcoCredits:int;
      
      private var _ecoPointConsumed:int;
      
      public function EcoPointsPopup(param1:DenStateItem, param2:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _ecoItemState = param1;
         _closeCallback = param2;
         DenXtCommManager.requestDenEcoCreditRefresh(onEcoCreditReceived);
      }
      
      public function destroy() : void
      {
         if(_popup)
         {
            DarkenManager.unDarken(_popup);
            GuiManager.guiLayer.removeChild(_popup);
         }
         _closeCallback = null;
         _mediaHelper.destroy();
         _mediaHelper = null;
         removeEventListeners();
         _popup = null;
      }
      
      private function onEcoCreditReceived(param1:EcoStateResponse) : void
      {
         setEcoCreditDataFromServer(param1);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(8344,onMediaLoaded);
      }
      
      private function setEcoCreditDataFromServer(param1:EcoStateResponse) : void
      {
         _numActiveWindTurbines = param1.numActiveWindTurbines;
         _numActiveSolarPanels = param1.numActiveSolarPanels;
         _ecoPointConsumed = param1.ecoPowerConsumption;
         _ecoScore = param1.ecoPowerGeneration;
         _nextRewardBitIndex = param1.nextRewardBitIndex;
         _unredeemedEcoCredits = param1.unredeemedEcoCredits;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _popup = param1.getChildAt(0) as MovieClip;
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _bx = _popup.bx;
         _infoPopupCont = _popup.infoPopupCont;
         _infoPopupCont.visible = false;
         _infoPopupCloseBtn = _infoPopupCont.bx;
         _infoPopupEcoShopBtn = _infoPopupCont.ecoShopBtn;
         _generatorBtn = _popup.generatorBtn;
         _meterCircleCont = _popup.meterCircleCont;
         _totalConsumedPointsTxt = _popup.totalConsumerPointsCont.totalConsumedPoints;
         _viewEcoScoreBtn = _popup.getCreditBtn;
         _ecoPointsTxt = _popup.ecoPoints;
         _toggleBtn = _popup.toggleBtn;
         _itemBlock = _popup.itemBlockOne;
         _burst = _popup.burst;
         _arrowCont = _popup.arrowCont;
         _titleTxt = _popup.titleTxt;
         _infoBtn = _popup.infoBtn;
         _offlineRedTxt = _popup.offlineRedTxt;
         _offlineRedTxt.visible = false;
         _ecoItem = new DenItem();
         _ecoItem.init(_ecoItemState.defId);
         _ecoItem.imageLoadedCallback = onEcoItemLoaded;
         _itemBlock.addChild(_ecoItem.icon);
      }
      
      private function onEcoItemLoaded() : void
      {
         _titleTxt.text = _ecoItem.name;
         if(_ecoItemState.ecoConsumerStateId == 2)
         {
            _toggleBtn.gotoAndStop("offline");
            _toggleBtn.toggleBtn.gotoAndStop("startingOn");
            _toggleBtn.toggleBtn.toggleKnobRed.visible = true;
            _toggleBtn.toggleBtn.toggleKnob.visible = false;
            _burst.visible = false;
         }
         else
         {
            _toggleBtn.gotoAndStop("single");
            _toggleBtn.toggleBtn.toggleKnobRed.visible = false;
            _toggleBtn.toggleBtn.toggleKnob.visible = true;
            if(_ecoItemState.ecoConsumerStateId == 1)
            {
               _burst.visible = true;
               sendMouseEventToItem();
               _toggleBtn.toggleBtn.gotoAndStop("startingOn");
            }
            else if(_ecoItemState.ecoConsumerStateId == 0)
            {
               _burst.visible = false;
               _toggleBtn.toggleBtn.gotoAndStop("startingOff");
            }
         }
         setupEcoScores();
         GuiManager.guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
         addEventListeners();
      }
      
      private function setupEcoScores() : void
      {
         _totalConsumedPointsTxt.text = _ecoPointConsumed + "/" + _ecoScore;
         if(_toggleBtn.currentFrameLabel == "offline" || _ecoPointConsumed > _ecoScore)
         {
            _meterCircleCont.gotoAndStop("redMeter");
            _arrowCont.gotoAndStop(1);
         }
         else
         {
            _meterCircleCont.gotoAndStop(_ecoScore > 0 ? Math.ceil(_ecoPointConsumed / _ecoScore * 100) : 100);
            if(_toggleBtn.toggleBtn.currentFrameLabel == "startingOn" || _toggleBtn.toggleBtn.currentFrameLabel == "on")
            {
               _arrowCont.gotoAndPlay(1);
            }
            else
            {
               _arrowCont.gotoAndStop(1);
            }
         }
         _ecoPointsTxt.text = String(_ecoPointConsumed);
         LocalizationManager.findAllTextfields(_popup);
      }
      
      private function sendMouseEventToItem() : void
      {
         var _loc2_:Loader = null;
         var _loc1_:MovieClip = null;
         if(_ecoItem.icon.parent)
         {
            _loc2_ = Loader(Sprite(_ecoItem.icon.getChildAt(0)).getChildAt(0));
            if(_loc2_)
            {
               _loc1_ = MovieClip(_loc2_.content);
               if(_loc1_)
               {
                  if(_loc1_.hasOwnProperty("handleMouse"))
                  {
                     _loc1_.handleMouse("mouseDown");
                  }
                  else
                  {
                     _loc1_.listenToMouse = true;
                     MovieClip(_loc1_.item1).dispatchEvent(new MouseEvent("mouseDown"));
                     _loc1_.listenToMouse = false;
                  }
               }
            }
         }
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _bx.addEventListener("mouseDown",onClose,false,0,true);
         _toggleBtn.addEventListener("mouseDown",onToggleBtn,false,0,true);
         _infoBtn.addEventListener("mouseDown",onInfoBtn,false,0,true);
         _infoPopupCloseBtn.addEventListener("mouseDown",onInfoBtn,false,0,true);
         _infoPopupEcoShopBtn.addEventListener("mouseDown",onShopBtn,false,0,true);
         _viewEcoScoreBtn.addEventListener("mouseDown",onEcoScoreBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _bx.removeEventListener("mouseDown",onClose);
         _toggleBtn.removeEventListener("mouseDown",onToggleBtn);
         _infoBtn.removeEventListener("mouseDown",onInfoBtn);
         _infoPopupCloseBtn.removeEventListener("mouseDown",onInfoBtn);
         _infoPopupEcoShopBtn.removeEventListener("mouseDown",onShopBtn);
         _viewEcoScoreBtn.removeEventListener("mouseDown",onEcoScoreBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onToggleBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = 1;
         if(param1.currentTarget.toggleBtn.currentFrameLabel == "on" || param1.currentTarget.toggleBtn.currentFrameLabel == "startingOn")
         {
            _loc2_ = 0;
         }
         DarkenManager.showLoadingSpiral(true);
         DenXtCommManager.requestDenEcoConsumer(_ecoItemState.invIdx,_loc2_,ecoConsumerCallback);
      }
      
      private function ecoConsumerCallback(param1:int, param2:int, param3:Dictionary) : void
      {
         var _loc4_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         _ecoPointConsumed = param1;
         _ecoScore = param2;
         if(param3[_ecoItemState.invIdx] !== undefined)
         {
            _loc4_ = int(param3[_ecoItemState.invIdx]);
            if(_loc4_ == 0)
            {
               if(_toggleBtn.currentFrameLabel != "offline")
               {
                  sendMouseEventToItem();
               }
               _toggleBtn.gotoAndStop("single");
               _toggleBtn.toggleBtn.gotoAndPlay("off");
               _burst.visible = false;
               _offlineRedTxt.visible = false;
               _toggleBtn.toggleBtn.toggleKnob.visible = true;
            }
            else if(_loc4_ == 1)
            {
               _toggleBtn.gotoAndStop("single");
               _toggleBtn.toggleBtn.gotoAndPlay("on");
               _burst.visible = true;
               _offlineRedTxt.visible = false;
               _toggleBtn.toggleBtn.toggleKnob.visible = true;
               sendMouseEventToItem();
            }
            else if(_loc4_ == 2)
            {
               _toggleBtn.gotoAndStop("offline");
               _toggleBtn.toggleBtn.gotoAndPlay("on");
               _burst.visible = false;
               _offlineRedTxt.visible = true;
               _toggleBtn.toggleBtn.toggleKnob.visible = false;
            }
            _ecoItemState.ecoConsumerStateId = _loc4_;
         }
         setupEcoScores();
      }
      
      private function setConsumerState(param1:int) : void
      {
         _ecoItemState.ecoConsumerStateId = param1;
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _infoPopupCont.visible = !_infoPopupCont.visible;
      }
      
      private function onShopBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         ShopManager.launchStore(778,1030);
      }
      
      private function onEcoScoreBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _ecoScorePopup = new EcoScorePopup(onEcoScorePopupClose);
      }
      
      private function onEcoScorePopupClose() : void
      {
         _ecoScorePopup.destroy();
         _ecoScorePopup = null;
      }
   }
}

