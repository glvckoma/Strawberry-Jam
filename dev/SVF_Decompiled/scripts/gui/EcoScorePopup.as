package gui
{
   import Enums.DenItemDef;
   import achievement.AchievementXtCommManager;
   import avatar.AvatarManager;
   import collection.DenItemCollection;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenXtCommManager;
   import den.EcoStateResponse;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import shop.ShopManager;
   
   public class EcoScorePopup
   {
      private static const POPUP_ID:int = 8313;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _closeCallback:Function;
      
      private var _bx:MovieClip;
      
      private var _creditCount:TextField;
      
      private var _ecoSystemCont:MovieClip;
      
      private var _infoCont:MovieClip;
      
      private var _itemDetailCont:MovieClip;
      
      private var _shopCreditBtn:GuiSoundButton;
      
      private var _generatorBtn:GuiSoundButton;
      
      private var _consumerDetailCont:MovieClip;
      
      private var _creditProgressMeter:MovieClip;
      
      private var _scoreProgressMeter:MovieClip;
      
      private var _scoreProgressTxt:TextField;
      
      private var _consumerItemBtn:GuiSoundButton;
      
      private var _consumerItemsMeter:MovieClip;
      
      private var _consumerItemTxt:TextField;
      
      private var _getCreditBtn:GuiSoundButton;
      
      private var _giftBtn:MovieClip;
      
      private var _infoBtn:MovieClip;
      
      private var _itemBlockOne:MovieClip;
      
      private var _itemBlockTwo:MovieClip;
      
      private var _itemScoreTxt:TextField;
      
      private var _itemScoreTxtTwo:TextField;
      
      private var _quantityTxt:TextField;
      
      private var _quantityTxtTwo:TextField;
      
      private var _detailDenQuantityTxt:TextField;
      
      private var _detailRateTxt:TextField;
      
      private var _detailNameTxt:TextField;
      
      private var _detailBlock:MovieClip;
      
      private var _detailTotalPointTxt:TextField;
      
      private var _factTxt:TextField;
      
      private var _consumerDetailDenQuantityTxt:TextField;
      
      private var _consumerDetailTotalPointTxt:TextField;
      
      private var _consumerDetailItemNameTxt:TextField;
      
      private var _arrowATop:MovieClip;
      
      private var _arrowBTop:MovieClip;
      
      private var _arrowABot:MovieClip;
      
      private var _arrowBBot:MovieClip;
      
      private var _numActiveWindTurbines:int;
      
      private var _numActiveSolarPanels:int;
      
      private var _numConsumerItems:int;
      
      private var _ecoScore:int;
      
      private var _ecoPowerGeneration:int;
      
      private var _ecoPowerConsumption:int;
      
      private var _unredeemedEcoCredits:int;
      
      private var _ecoScoreRequired:int;
      
      private var _nextRewardBitIndex:int;
      
      private var _turbineCount:int;
      
      private var _solarPanelCount:int;
      
      private var _numConsumersPlaced:int;
      
      private var _turbineItem:DenItem;
      
      private var _turbineDef:DenItemDef;
      
      private var _solarPanelItem:DenItem;
      
      private var _solarPanelDef:DenItemDef;
      
      private var _currDetailItem:DenItem;
      
      private var _currDetailDef:DenItemDef;
      
      private var _currDetail:MovieClip;
      
      private var _factsLocStrings:Array;
      
      private var _doRewardPopup:Boolean;
      
      private var _refreshTimer:Timer;
      
      public function EcoScorePopup(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _factsLocStrings = new Array(35720,35721,35722,35723,35724,35725);
         _refreshTimer = new Timer(0);
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
         _refreshTimer.reset();
         removeEventListeners();
         _popup = null;
      }
      
      private function onEcoCreditReceived(param1:EcoStateResponse) : void
      {
         setEcoCreditDataFromServer(param1);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(8313,onMediaLoaded);
      }
      
      private function refreshFromServer(param1:EcoStateResponse) : void
      {
         setEcoCreditDataFromServer(param1);
         resetPopupDataAfterRefresh();
         if(_doRewardPopup)
         {
            _doRewardPopup = false;
            GuiManager.initMessagePopups(true);
         }
      }
      
      private function setEcoCreditDataFromServer(param1:EcoStateResponse) : void
      {
         _numActiveWindTurbines = param1.numActiveWindTurbines;
         _numActiveSolarPanels = param1.numActiveSolarPanels;
         _numConsumerItems = param1.numConsumerItems;
         _ecoPowerGeneration = param1.ecoPowerGeneration;
         _ecoPowerConsumption = param1.ecoPowerConsumption;
         _ecoScore = _ecoPowerGeneration - _ecoPowerConsumption;
         _ecoScoreRequired = param1.ecoScoreRequired;
         _nextRewardBitIndex = param1.nextRewardBitIndex;
         _unredeemedEcoCredits = param1.unredeemedEcoCredits;
         resetTimer(param1.secondsUntilNextEcoCredit);
      }
      
      private function resetTimer(param1:int) : void
      {
         _refreshTimer.reset();
         if(param1 > 0)
         {
            _refreshTimer.delay = param1 * 1000;
            _refreshTimer.start();
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var _loc2_:DenItemCollection = null;
         DarkenManager.showLoadingSpiral(false);
         _popup = param1.getChildAt(0) as MovieClip;
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _bx = _popup.bx;
         _creditCount = _popup.creditCount;
         _creditCount.text = UserCurrency.getCurrency(11).toString();
         _shopCreditBtn = _popup.shopCreditBtn;
         if(AvatarManager.playerAvatar && AvatarManager.playerAvatar.inventoryDenFull && AvatarManager.playerAvatar.inventoryDenFull.denItemCollection.length > 0)
         {
            _loc2_ = new DenItemCollection(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection.concatCollection(null));
         }
         else if(gMainFrame.userInfo.playerUserInfo.denItemsFull)
         {
            _loc2_ = new DenItemCollection(gMainFrame.userInfo.playerUserInfo.denItemsFull.concatCollection(null));
         }
         for each(var _loc3_ in _loc2_.getCoreArray())
         {
            if(_loc3_.categoryId == 1)
            {
               if(_loc3_.defId == 4541)
               {
                  _turbineCount++;
               }
               else if(_loc3_.defId == 4540)
               {
                  _solarPanelCount++;
               }
               else if(_loc3_.specialType == 7)
               {
                  _numConsumersPlaced++;
               }
            }
         }
         _ecoSystemCont = _popup.ecoSystemCont;
         _itemScoreTxt = _ecoSystemCont.itemScoreTxt;
         _turbineDef = DenXtCommManager.getDenItemDef(4541);
         _itemScoreTxt.text = (_turbineDef.ecoPower * _turbineCount).toString();
         _itemScoreTxtTwo = _ecoSystemCont.itemScoreTxtTwo;
         _solarPanelDef = DenXtCommManager.getDenItemDef(4540);
         _itemScoreTxtTwo.text = (_solarPanelDef.ecoPower * _solarPanelCount).toString();
         _quantityTxt = _ecoSystemCont.quantityTxt;
         _quantityTxt.text = _turbineCount.toString();
         _quantityTxtTwo = _ecoSystemCont.quantityTxtTwo;
         _quantityTxtTwo.text = _solarPanelCount.toString();
         _itemBlockOne = _ecoSystemCont.itemBlockOne;
         _turbineItem = new DenItem();
         _turbineItem.init(4541);
         _itemBlockOne.addChild(_turbineItem.icon);
         _itemBlockTwo = _ecoSystemCont.itemBlockTwo;
         _solarPanelItem = new DenItem();
         _solarPanelItem.init(4540);
         _itemBlockTwo.addChild(_solarPanelItem.icon);
         _generatorBtn = _ecoSystemCont.generatorBtn;
         _getCreditBtn = _ecoSystemCont.ecoCreditsBtn;
         _getCreditBtn.activateGrayState(_unredeemedEcoCredits <= 0);
         _creditProgressMeter = _ecoSystemCont.ecoCreditsMeter;
         updateCreditProgressMeter();
         _scoreProgressMeter = _ecoSystemCont.ecoScoreProgressMeter;
         _scoreProgressTxt = _ecoSystemCont.ecoScoreProgressTxt;
         updateScore();
         _consumerItemsMeter = _ecoSystemCont.consumerItemsMeter;
         _consumerItemTxt = _ecoSystemCont.consumerItemTxt;
         _consumerItemBtn = _ecoSystemCont.consumerItemBtn;
         updateConsumerUsage();
         _giftBtn = _ecoSystemCont.giftCont;
         _giftBtn.gotoAndStop(isGiftAvailable() ? "on" : "off");
         _consumerDetailCont = _popup.consumerDetailCont;
         _consumerDetailCont.visible = false;
         _consumerDetailDenQuantityTxt = _consumerDetailCont.denQuantityTxt;
         _consumerDetailDenQuantityTxt.text = String(_numConsumersPlaced);
         _consumerDetailTotalPointTxt = _consumerDetailCont.totalPointTxt;
         _consumerDetailTotalPointTxt.text = _ecoPowerConsumption + "/" + _ecoPowerGeneration;
         _infoCont = _popup.infoCont;
         _infoCont.visible = false;
         _infoBtn = _ecoSystemCont.infoBtn;
         _factTxt = _popup.factTxt;
         LocalizationManager.translateId(_factTxt,_factsLocStrings[Math.floor(Math.random() * (_factsLocStrings.length - 1 + 1))]);
         _itemDetailCont = _popup.itemDetailCont;
         _detailDenQuantityTxt = _itemDetailCont.denQuantityTxt;
         _detailBlock = _itemDetailCont.itemBlockOne;
         _detailNameTxt = _itemDetailCont.itemNameTxt;
         _detailRateTxt = _itemDetailCont.rateTxt;
         _detailTotalPointTxt = _itemDetailCont.totalPointTxt;
         _itemDetailCont.visible = false;
         _arrowATop = _popup.ecoSystemCont.arrowACont;
         _arrowBTop = _popup.ecoSystemCont.arrowBCont;
         _arrowABot = _popup.ecoSystemCont.arrowCCont;
         _arrowBBot = _popup.ecoSystemCont.arrowDCont;
         if(_turbineCount == 0)
         {
            _arrowATop.gotoAndStop(1);
            _arrowABot.gotoAndStop(1);
         }
         if(_solarPanelCount == 0)
         {
            _arrowBTop.gotoAndStop(1);
            _arrowBBot.gotoAndStop(1);
         }
         GuiManager.guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
         addEventListeners();
      }
      
      private function resetPopupDataAfterRefresh() : void
      {
         _creditCount.text = UserCurrency.getCurrency(11).toString();
         _giftBtn.gotoAndStop(isGiftAvailable() ? "on" : "off");
         updateScore();
         updateCreditProgressMeter();
         _getCreditBtn.activateGrayState(_unredeemedEcoCredits <= 0);
      }
      
      private function updateScore() : void
      {
         if(_ecoScore >= _ecoScoreRequired)
         {
            _scoreProgressTxt.text = _ecoScore.toString();
            _scoreProgressMeter.normalBar.width = 0;
         }
         else
         {
            _scoreProgressTxt.text = _ecoScore + "/" + _ecoScoreRequired;
            _scoreProgressMeter.normalBar.width = _scoreProgressMeter.blueBar.width * (1 - _ecoScore / _ecoScoreRequired);
         }
      }
      
      private function updateConsumerUsage() : void
      {
         var _loc1_:String = null;
         if(_ecoPowerConsumption > _ecoScore)
         {
            _consumerItemsMeter.gotoAndStop("redMeter");
         }
         else
         {
            _loc1_ = (_ecoScore > 0 ? Math.ceil(_ecoPowerConsumption / _ecoScore * 100) : 100).toString();
            _consumerItemsMeter.gotoAndStop(_loc1_);
         }
      }
      
      private function isGiftAvailable() : Boolean
      {
         return _ecoScore >= _ecoScoreRequired;
      }
      
      private function updateCreditProgressMeter() : void
      {
         var _loc1_:String = Math.ceil(_unredeemedEcoCredits / 240 * 100).toString();
         _creditProgressMeter.gotoAndStop(_loc1_);
         _getCreditBtn.setTextInLayer(_loc1_,"ecoCreditsTxt");
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _bx.addEventListener("mouseDown",onClose,false,0,true);
         _giftBtn.addEventListener("mouseDown",onGiftBtn,false,0,true);
         _infoBtn.addEventListener("mouseDown",onInfoBtn,false,0,true);
         _shopCreditBtn.addEventListener("mouseDown",onShopBtn,false,0,true);
         _getCreditBtn.addEventListener("mouseDown",onGetCreditBtn,false,0,true);
         _itemBlockOne.addEventListener("mouseDown",onItemBlock,false,0,true);
         _itemBlockTwo.addEventListener("mouseDown",onItemBlock,false,0,true);
         _consumerItemBtn.addEventListener("mouseDown",onConsumerDetailBtn,false,0,true);
         _refreshTimer.addEventListener("timer",onRefreshTimerComplete,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _bx.removeEventListener("mouseDown",onClose);
         _giftBtn.removeEventListener("mouseDown",onGiftBtn);
         _infoBtn.removeEventListener("mouseDown",onInfoBtn);
         _shopCreditBtn.removeEventListener("mouseDown",onShopBtn);
         _getCreditBtn.removeEventListener("mouseDown",onGetCreditBtn);
         _itemBlockOne.removeEventListener("mouseDown",onItemBlock);
         _itemBlockTwo.removeEventListener("mouseDown",onItemBlock);
         _consumerItemBtn.removeEventListener("mouseDown",onConsumerDetailBtn);
         _refreshTimer.removeEventListener("timerComplete",onRefreshTimerComplete);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_infoCont.visible || _itemDetailCont.visible || _consumerDetailCont.visible)
         {
            if(_itemDetailCont.visible)
            {
               _detailBlock.removeChild(_currDetail == _itemBlockOne ? _turbineItem.icon : _solarPanelItem.icon);
               _currDetail.addChild(_currDetail == _itemBlockOne ? _turbineItem.icon : _solarPanelItem.icon);
               _itemDetailCont.visible = false;
            }
            else if(_consumerDetailCont.visible)
            {
            }
            _infoCont.visible = false;
            _consumerDetailCont.visible = false;
            _ecoSystemCont.visible = true;
            return;
         }
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onGiftBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_giftBtn.currentFrameLabel == "on")
         {
            if(_nextRewardBitIndex >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               AchievementXtCommManager.requestSetUserVar(465,_nextRewardBitIndex,onGiftCallback);
            }
            else
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(35713));
            }
         }
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _infoCont.visible = !_infoCont.visible;
         _ecoSystemCont.visible = !_infoCont.visible;
      }
      
      private function onInfoClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _infoCont.visible = !_infoCont.visible;
         _ecoSystemCont.visible = !_infoCont.visible;
      }
      
      private function onConsumerDetailBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _consumerDetailCont.visible = !_consumerDetailCont.visible;
         _ecoSystemCont.visible = !_ecoSystemCont.visible;
      }
      
      private function onGetCreditBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_getCreditBtn.isGray)
         {
            DarkenManager.showLoadingSpiral(true);
            DenXtCommManager.requestDenEcoCreditRedeem(ecoCreditReemdCallback);
         }
      }
      
      private function onShopBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         ShopManager.launchStore(778,1030);
      }
      
      private function onItemBlock(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _itemDetailCont.visible = !_itemDetailCont.visible;
         _ecoSystemCont.visible = !_itemDetailCont.visible;
         if(_itemDetailCont.visible)
         {
            _currDetail = param1.currentTarget as MovieClip;
            _currDetailItem = _currDetail == _itemBlockOne ? _turbineItem : _solarPanelItem;
            _currDetailDef = _currDetail == _itemBlockOne ? _turbineDef : _solarPanelDef;
            _detailDenQuantityTxt.text = _currDetail == _itemBlockOne ? _turbineCount.toString() : _solarPanelCount.toString();
            _currDetail.removeChild(_currDetailItem.icon);
            _detailBlock.addChild(_currDetailItem.icon);
            _detailNameTxt.text = _currDetailItem.name;
            _detailRateTxt.text = _currDetailDef.ecoPower.toString();
            _detailTotalPointTxt.text = (int(_detailDenQuantityTxt.text) * _currDetailDef.ecoPower).toString();
         }
      }
      
      private function onGiftCallback(param1:int, param2:int) : void
      {
         if(param2 > 0)
         {
            _doRewardPopup = true;
            DenXtCommManager.requestDenEcoCreditRefresh(refreshFromServer);
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function ecoCreditReemdCallback(param1:Boolean, param2:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _creditCount.text = UserCurrency.getCurrency(11).toString();
            _unredeemedEcoCredits = 0;
            updateCreditProgressMeter();
            _getCreditBtn.activateGrayState(_unredeemedEcoCredits <= 0);
            resetTimer(param2);
         }
      }
      
      private function onRefreshTimerComplete(param1:TimerEvent) : void
      {
         DenXtCommManager.requestDenEcoCreditRefresh(refreshFromServer);
      }
   }
}

