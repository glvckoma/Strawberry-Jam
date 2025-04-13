package gui
{
   import Enums.TradeItem;
   import avatar.Avatar;
   import avatar.AvatarEvent;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import buddy.BuddyManager;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.DenStateItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.TradeItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import den.DenStateItem;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.setTimeout;
   import gui.itemWindows.ItemWindowOriginal;
   import inventory.Iitem;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   import playerWall.PlayerWallManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import shop.ShopManager;
   import trade.TradeConfirmPopup;
   import trade.TradeXtCommManager;
   
   public class TradeManager
   {
      private static const REQUEST_TRADE:int = 430;
      
      private static const TRADE_REQUESTED:int = 431;
      
      private static const TRADE_DONE:int = 432;
      
      private static const ITEM_WINDOW_SIZE:int = 84;
      
      private static const TRADE_REVIEW_CONFIRM:int = 4432;
      
      private static const TRADE_WAITING:int = 4456;
      
      private static const TRADING_SOUNDS_MEDIA_ID:int = 1333;
      
      private static var _isCurrentlyTrading:Boolean;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _requestTradePopup:MovieClip;
      
      private static var _requestSentPopup:MovieClip;
      
      private static var _tradeRequestedPopup:MovieClip;
      
      private static var _tradeDonePopup:MovieClip;
      
      private static var _currDownMC:MovieClip;
      
      private static var _tradeReviewConfirmPopup:MovieClip;
      
      private static var _tradeConfirmPopup:TradeConfirmPopup;
      
      private static var _tradeRequestedPopupNumItems:int;
      
      private static var _requestTradePopupCurrUsernameToTradeTo:String;
      
      private static var _mediaViews:Array;
      
      private static var _initiationTradeList:IitemCollection;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _itemWindows:WindowAndScrollbarGenerator;
      
      private static var _itemWindowTheirs:WindowAndScrollbarGenerator;
      
      private static var _itemToTradeFor:Iitem;
      
      private static var _listOfItemsBeingOffered:IitemCollection;
      
      private static var _itemBeingTaken:Iitem;
      
      private static var _isInventoryFull:Boolean;
      
      private static var _numClothingItemsInTradeList:int;
      
      private static var _numDenItemsInTradeList:int;
      
      private static var _numPetItemsInTradeList:int;
      
      private static var _numClothingItemsInInitiateTradeList:int;
      
      private static var _numDenItemsInInitiateTradeList:int;
      
      private static var _numPetItemsInInitiateTradeList:int;
      
      private static var _denClothesSelectPopup:DenAndClothesItemSelect;
      
      private static var _jammerRoomName:String;
      
      private static var _loadingSpiralAvatar:LoadingSpiral;
      
      private static var _tradeRequestedPlayerUsername:String;
      
      private static var _tradeRequestAvatar:Avatar;
      
      private static var _tradeRequestAvatarView:AvatarView;
      
      public function TradeManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer) : void
      {
         _guiLayer = param1;
         _mediaViews = [];
         _initiationTradeList = new IitemCollection();
         _loadingSpiral = new LoadingSpiral();
         _denClothesSelectPopup = new DenAndClothesItemSelect();
      }
      
      public static function destroy() : void
      {
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
      }
      
      public static function closeAllTradingRelatedPopups() : void
      {
         if(_requestTradePopup && _requestTradePopup.visible)
         {
            DarkenManager.unDarken(_requestTradePopup);
            if(_requestTradePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestTradePopup);
            }
            _requestTradePopup.visible = false;
            removeRequestTradeListeners();
         }
         if(_requestSentPopup && _requestSentPopup.visible)
         {
            DarkenManager.unDarken(_requestSentPopup);
            if(_requestSentPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestSentPopup);
            }
            _requestSentPopup.visible = false;
            removeRequestSentListeners();
         }
         if(_tradeRequestedPopup && _tradeRequestedPopup.visible)
         {
            DarkenManager.unDarken(_tradeRequestedPopup);
            if(_tradeRequestedPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeRequestedPopup);
            }
            _tradeRequestedPopup.visible = false;
            removeTradeRequestedListeners();
         }
         if(_tradeDonePopup && _tradeDonePopup.visible)
         {
            DarkenManager.unDarken(_tradeDonePopup);
            if(_tradeDonePopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeDonePopup);
            }
            _tradeDonePopup.visible = false;
            removeTradeDoneListeners();
         }
         if(_tradeReviewConfirmPopup)
         {
            DarkenManager.unDarken(_tradeReviewConfirmPopup);
            if(_tradeReviewConfirmPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeReviewConfirmPopup);
            }
            removeTradeConfirmListeners();
         }
         if(_denClothesSelectPopup)
         {
            _denClothesSelectPopup.destroy();
            _denClothesSelectPopup = null;
         }
         isCurrentlyTrading = false;
      }
      
      public static function displayRequestTrade(param1:Object, param2:MovieClip = null) : void
      {
         var _loc4_:IitemCollection = null;
         var _loc3_:String = param1.currUsernameToTradeTo;
         var _loc5_:TradeItem = param1.itemToTrade;
         if(param2 && _requestTradePopup == null)
         {
            _requestTradePopup = param2.TradeInitiatePopup;
            _requestSentPopup = param2.TradeRequestSentPopup;
            _requestTradePopup.x = 900 * 0.5;
            _requestTradePopup.y = 550 * 0.5;
            _requestSentPopup.x = 900 * 0.5;
            _requestSentPopup.y = 550 * 0.5;
            _guiLayer.addChild(_requestTradePopup);
            DarkenManager.darken(_requestTradePopup);
            addRequestTradeListeners();
            _loadingSpiral.setNewParent(_requestTradePopup.itemBlock);
            _loadingSpiral.visible = true;
            _requestTradePopupCurrUsernameToTradeTo = _loc3_;
            buildItemWindows(_requestTradePopup.itemBlock,new IitemCollection(_initiationTradeList.concatCollection(null)));
            _loc4_ = new IitemCollection();
            _loc4_.pushIitem(_itemToTradeFor);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,_loc4_,true);
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,23695,_initiationTradeList.length);
            if(_itemToTradeFor is DenItem && !(_itemToTradeFor as DenItem).isLand && !(_itemToTradeFor as DenItem).isLandAndOcean && (_itemToTradeFor as DenItem).isOcean && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else if(_requestTradePopup)
         {
            setupItemToTradeFor(_loc5_);
            _guiLayer.addChild(_requestTradePopup);
            DarkenManager.darken(_requestTradePopup);
            _requestTradePopup.visible = true;
            addRequestTradeListeners();
            _loadingSpiral.scaleX = 1;
            _loadingSpiral.scaleY = 1;
            _loadingSpiral.setNewParent(_requestTradePopup.itemBlock);
            _loadingSpiral.visible = true;
            _initiationTradeList.getCoreArray().splice(0,_initiationTradeList.length);
            _numClothingItemsInInitiateTradeList = 0;
            _numDenItemsInInitiateTradeList = 0;
            _numPetItemsInInitiateTradeList = 0;
            _requestTradePopup.gotoAndStop("four");
            _requestTradePopupCurrUsernameToTradeTo = _loc3_;
            buildItemWindows(_requestTradePopup.itemBlock,new IitemCollection(_initiationTradeList.concatCollection(null)));
            _loc4_ = new IitemCollection();
            _loc4_.pushIitem(_itemToTradeFor);
            buildItemWindows(_requestTradePopup.itemBlockTheirs,_loc4_,true);
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,23695,_initiationTradeList.length);
            if(_itemToTradeFor is DenItem && !(_itemToTradeFor as DenItem).isLand && !(_itemToTradeFor as DenItem).isLandAndOcean && (_itemToTradeFor as DenItem).isOcean && !DenSwitch.haveOceanDen())
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(430,{
               "currUsernameToTradeTo":_loc3_,
               "itemToTrade":_loc5_
            });
            setupItemToTradeFor(_loc5_);
         }
      }
      
      public static function displayRequestSent(param1:Object = null, param2:MovieClip = null) : void
      {
         if(_requestSentPopup || param2)
         {
            if(param2)
            {
               _requestSentPopup = param2.TradeRequestSentPopup;
               _requestSentPopup.x = 900 * 0.5;
               _requestSentPopup.y = 550 * 0.5;
            }
            _guiLayer.addChild(_requestSentPopup);
            DarkenManager.darken(_requestSentPopup);
            _requestSentPopup.visible = true;
            _loadingSpiral.scaleX = 0.5;
            _loadingSpiral.scaleY = 0.5;
            _loadingSpiral.setNewParent(_requestSentPopup.itemBlock,_requestSentPopup.itemBlock.width * 0.5,_requestSentPopup.itemBlock.height * 0.5);
            _loadingSpiral.visible = true;
            addRequestSentListeners();
         }
         else
         {
            loadPopup(4456);
         }
      }
      
      public static function displayTradeRequested(param1:Object, param2:MovieClip = null) : void
      {
         var _loc12_:Iitem = null;
         var _loc21_:int = 0;
         var _loc6_:int = 0;
         var _loc14_:int = 0;
         var _loc26_:int = 0;
         var _loc16_:int = 0;
         var _loc30_:int = 0;
         var _loc10_:int = 0;
         var _loc15_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc22_:int = 0;
         var _loc27_:IitemCollection = null;
         var _loc5_:int = 0;
         var _loc17_:int = 0;
         var _loc13_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc28_:int = 0;
         var _loc19_:int = 0;
         var _loc31_:int = 0;
         var _loc18_:AvatarInfo = null;
         var _loc4_:Boolean = false;
         var _loc32_:IitemCollection = null;
         var _loc20_:int = 0;
         var _loc25_:Boolean = false;
         var _loc23_:Number = NaN;
         var _loc29_:int = 0;
         var _loc11_:int = 0;
         if(param2 && _tradeRequestedPopup == null)
         {
            _tradeRequestedPopup = param2.TradeRequestedPopup;
            _tradeRequestedPopup.x = 900 * 0.5;
            _tradeRequestedPopup.y = 550 * 0.5;
         }
         if(_tradeRequestedPopup)
         {
            AJAudio.playTradeRequestSound();
            _loadingSpiralAvatar = new LoadingSpiral(_tradeRequestedPopup.charBox);
            _tradeRequestedPlayerUsername = param1[3];
            _loc21_ = 7;
            _loc6_ = int(param1[_loc21_++]);
            _loc14_ = int(param1[_loc21_++]);
            _loc26_ = int(param1[_loc21_++]);
            _loc16_ = 0;
            _loc30_ = 0;
            _loc10_ = 0;
            _loc15_ = 0;
            _loc7_ = 0;
            _loc3_ = 0;
            _loc22_ = 0;
            if(!AvatarManager.playerAvatar)
            {
               onDeclineTrade(null);
               return;
            }
            _loc5_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,0);
            _loc17_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,1);
            _loc13_ = Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,3);
            _loc9_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),0);
            _loc8_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),1);
            _loc28_ = Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),3);
            _loc19_ = int(PetManager.myPetList.length);
            if(int(param1[5]) < 3)
            {
               _loc27_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems() as IitemCollection;
               if(int(param1[5]) == 0)
               {
                  _loc9_--;
               }
               else if(int(param1[5]) == 1)
               {
                  _loc8_--;
               }
               else if(int(param1[5]) == 2)
               {
                  _loc28_--;
               }
            }
            else if(int(param1[5]) == 6)
            {
               _loc19_--;
               _loc27_ = PetManager.myPetListAsIitem;
            }
            else
            {
               if(int(param1[5]) == 3)
               {
                  _loc5_--;
               }
               else if(int(param1[5] == 4))
               {
                  _loc17_--;
               }
               else if(int(param1[5] == 5))
               {
                  _loc13_--;
               }
               _loc27_ = AvatarManager.playerAvatar.inventoryDenFull.denItemCollection as IitemCollection;
            }
            _guiLayer.addChild(_tradeRequestedPopup);
            DarkenManager.darken(_tradeRequestedPopup);
            addTradeRequestedListeners();
            _tradeRequestedPopup.yesBtn.visible = false;
            _tradeRequestedPopup.noBtn.visible = false;
            _tradeRequestedPopup.visible = true;
            _tradeRequestedPopupNumItems = _loc31_ = _loc6_ + _loc14_ + _loc26_;
            _loc18_ = gMainFrame.userInfo.getAvatarInfoByUserName(_tradeRequestedPlayerUsername);
            if(!_loc18_)
            {
               AvatarXtCommManager.requestAvatarGet(_tradeRequestedPlayerUsername,onAvatarGetReceived);
            }
            else
            {
               onAvatarGetReceived(_tradeRequestedPlayerUsername,true,0,_loc18_);
            }
            if(_itemWindows)
            {
               _itemWindows.destroy();
               _itemWindows = null;
            }
            _loc32_ = new IitemCollection();
            if(_loc31_ > 4)
            {
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock1");
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock5");
               _loc4_ = true;
            }
            else
            {
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock5");
               _tradeRequestedPopup.itemBlocks.gotoAndStop("itemBlock" + _loc31_);
               _loc4_ = false;
            }
            _loc20_ = 1;
            while(_loc20_ <= _loc6_)
            {
               _loc12_ = new Item();
               (_loc12_ as Item).init(int(param1[_loc21_++]),0,uint(param1[_loc21_++]));
               if(_loc12_.enviroType == 0)
               {
                  _loc16_++;
               }
               else if(_loc12_.enviroType == 1)
               {
                  _loc30_++;
               }
               else if(_loc12_.enviroType == 3)
               {
                  _loc10_++;
               }
               _loc32_.pushIitem(_loc12_);
               _loc20_++;
            }
            _loc20_ = 1;
            while(_loc20_ <= _loc14_)
            {
               _loc12_ = new DenItem();
               (_loc12_ as DenItem).init(param1[_loc21_++],0,0,param1[_loc21_++],0,null,param1[_loc21_++],param1[_loc21_++],"",param1[_loc21_++],param1[_loc21_++]);
               if(_loc12_.enviroType == 0)
               {
                  _loc15_++;
               }
               else if(_loc12_.enviroType == 1)
               {
                  _loc7_++;
               }
               else if(_loc12_.enviroType == 3)
               {
                  _loc3_++;
               }
               if(!_loc25_ && _loc12_.enviroType == 1 && !DenSwitch.haveOceanDen())
               {
                  _loc25_ = true;
               }
               _loc32_.pushIitem(_loc12_);
               _loc20_++;
            }
            _loc20_ = 1;
            while(_loc20_ <= _loc26_)
            {
               _loc12_ = new PetItem();
               _loc23_ = Number(param1[_loc21_++]);
               _loc29_ = int(param1[_loc21_++]);
               _loc11_ = int(param1[_loc21_++]);
               (_loc12_ as PetItem).init(_loc23_,_loc29_,[param1[_loc21_++],param1[_loc21_++],param1[_loc21_++]],param1[_loc21_++],param1[_loc21_++],param1[_loc21_++],_loc11_,param1[_loc21_++],false,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc29_,2)));
               _loc22_++;
               _loc32_.pushIitem(_loc12_);
               _loc20_++;
            }
            if(_loc5_ + _loc15_ > ShopManager.maxDenItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc17_ + _loc7_ > ShopManager.maxDenItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc13_ + _loc3_ > ShopManager.maxDenItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc9_ + _loc16_ > ShopManager.maxItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc8_ + _loc30_ > ShopManager.maxItems)
            {
               _isInventoryFull = true;
            }
            else if(_loc28_ + _loc10_ > ShopManager.maxItems * 2)
            {
               _isInventoryFull = true;
            }
            else if(_loc19_ + _loc22_ > PetManager.getPetInventoryMax())
            {
               _isInventoryFull = true;
            }
            else
            {
               _isInventoryFull = false;
            }
            _listOfItemsBeingOffered = _loc32_;
            if(_loc4_)
            {
               LocalizationManager.translateIdAndInsert(_tradeRequestedPopup.itemBlocks.txtCounter_ba.counterTxt,23695,_loc32_.length);
            }
            buildItemWindows(_tradeRequestedPopup.itemBlocks.itemBlock,new IitemCollection(_loc32_.concatCollection(null)));
            if(_loc27_ && _loc27_.length > 0)
            {
               _loc20_ = 0;
               while(_loc20_ < _loc27_.length)
               {
                  if(_loc27_.getIitem(_loc20_).invIdx == int(param1[6]))
                  {
                     _itemBeingTaken = _loc12_ = _loc27_.getIitem(_loc20_).clone();
                     break;
                  }
                  _loc20_++;
               }
            }
            buildItemWindows(_tradeRequestedPopup.itemBlockTheirs,new IitemCollection([_itemBeingTaken.clone()]),true);
            setTimeout(showTradeButtonsAfterDelay,2000);
            if(_loc25_)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14799));
            }
         }
         else
         {
            loadPopup(431,param1);
         }
      }
      
      public static function displayTradeConfirmPopup(param1:Object = null, param2:MovieClip = null) : void
      {
         var _loc3_:IitemCollection = null;
         if(param2 && _tradeReviewConfirmPopup == null)
         {
            _tradeReviewConfirmPopup = param2.tradeReviewConfirm;
            if(_tradeReviewConfirmPopup)
            {
               _tradeReviewConfirmPopup.x = 900 * 0.5;
               _tradeReviewConfirmPopup.y = 550 * 0.5;
            }
         }
         if(_tradeReviewConfirmPopup)
         {
            _tradeReviewConfirmPopup.visible = true;
            _guiLayer.addChild(_tradeReviewConfirmPopup);
            DarkenManager.darken(_tradeReviewConfirmPopup);
            addTradeConfirmListeners();
            _loc3_ = _listOfItemsBeingOffered != null ? _listOfItemsBeingOffered : _initiationTradeList;
            buildItemWindows(_tradeReviewConfirmPopup.itemBlock,new IitemCollection(_loc3_.concatCollection(null)));
            buildItemWindows(_tradeReviewConfirmPopup.itemBlockTheirs,new IitemCollection([_itemToTradeFor != null ? _itemToTradeFor : _itemBeingTaken]),true);
            LocalizationManager.translateIdAndInsert(_tradeReviewConfirmPopup.txtCounter_ba.counterTxt,_loc3_.length == 1 ? 23696 : 23695,_loc3_.length);
         }
         else
         {
            loadPopup(4432);
         }
      }
      
      public static function displayTradeDone(param1:Object, param2:MovieClip = null) : void
      {
         var _loc37_:int = 0;
         var _loc16_:Iitem = null;
         var _loc36_:UserInfo = null;
         var _loc14_:Object = null;
         var _loc19_:int = 0;
         var _loc17_:int = 0;
         var _loc32_:Avatar = null;
         var _loc23_:int = 0;
         var _loc3_:IitemCollection = null;
         var _loc8_:int = 0;
         var _loc22_:int = 0;
         var _loc25_:AccItemCollection = null;
         var _loc15_:int = 0;
         var _loc30_:int = 0;
         var _loc27_:int = 0;
         var _loc12_:* = false;
         var _loc45_:String = null;
         var _loc20_:int = 0;
         var _loc40_:String = null;
         var _loc28_:Number = NaN;
         var _loc9_:int = 0;
         var _loc42_:int = 0;
         var _loc4_:* = 0;
         var _loc7_:* = 0;
         var _loc21_:* = 0;
         var _loc33_:* = 0;
         var _loc5_:* = 0;
         var _loc10_:* = 0;
         var _loc13_:String = null;
         var _loc24_:int = 0;
         var _loc43_:int = 0;
         var _loc29_:int = 0;
         var _loc6_:DenStateItemCollection = null;
         var _loc35_:AccItemCollection = null;
         var _loc18_:AccItemCollection = null;
         var _loc26_:int = 0;
         var _loc39_:DenItemCollection = null;
         var _loc44_:IntItemCollection = null;
         var _loc41_:DenItemCollection = null;
         var _loc34_:TradeItemCollection = null;
         if(param2 && _tradeDonePopup == null)
         {
            _tradeDonePopup = param2.TradeDonePopup;
            if(_tradeDonePopup)
            {
               _tradeDonePopup.x = 900 * 0.5;
               _tradeDonePopup.y = 550 * 0.5;
            }
         }
         if(_tradeDonePopup)
         {
            AJAudio.playTradeSuccessSound();
            _loc37_ = int(param1[4]);
            _guiLayer.addChild(_tradeDonePopup);
            DarkenManager.darken(_tradeDonePopup);
            _tradeDonePopup.visible = true;
            addTradeDoneListeners();
            _tradeDonePopup.gotoAndStop(Math.min(5,_loc37_));
            _loc36_ = gMainFrame.userInfo.playerUserInfo;
            _loc14_ = gMainFrame.userInfo.playerUserInfo.avList;
            _loc19_ = int(gMainFrame.userInfo.playerAvatarInfo.type);
            _loc17_ = int(gMainFrame.userInfo.playerAvatarInfo.perUserAvId);
            _loc32_ = AvatarManager.getAvatarByUsernamePerUserAvId(_loc36_.userName,_loc17_);
            _loc23_ = 5;
            _loc3_ = new IitemCollection();
            _loc22_ = 1;
            while(_loc22_ <= _loc37_)
            {
               _loc8_ = int(param1[_loc23_++]);
               if(_loc8_ == 0)
               {
                  _loc16_ = new Item();
                  (_loc16_ as Item).init(int(param1[_loc23_++]),int(param1[_loc23_++]),uint(param1[_loc23_++]));
                  _loc25_ = _loc36_.fullItemList;
                  _loc25_.getCoreArray().unshift(_loc16_);
                  _loc36_.fullItemList = _loc25_;
                  if(AvatarManager.roomEnviroType == _loc16_.enviroType)
                  {
                     _loc32_.inventoryClothing.itemCollection.getCoreArray().unshift(_loc16_);
                  }
               }
               else if(_loc8_ == 1)
               {
                  _loc15_ = int(param1[_loc23_++]);
                  _loc30_ = int(param1[_loc23_++]);
                  _loc27_ = int(param1[_loc23_++]);
                  _loc12_ = param1[_loc23_++] == "true";
                  _loc45_ = param1[_loc23_++];
                  _loc20_ = int(param1[_loc23_++]);
                  _loc40_ = param1[_loc23_++];
                  _loc16_ = new DenItem();
                  (_loc16_ as DenItem).init(_loc30_,_loc15_,0,_loc27_,0,null,_loc12_,_loc45_,"",_loc20_,_loc40_);
                  _loc36_.denItemsFull.getCoreArray().unshift(_loc16_.clone());
               }
               else if(_loc8_ == 2)
               {
                  _loc28_ = Number(param1[_loc23_++]);
                  _loc9_ = int(param1[_loc23_++]);
                  _loc42_ = int(param1[_loc23_++]);
                  _loc16_ = new PetItem();
                  _loc4_ = uint(param1[_loc23_++]);
                  _loc7_ = uint(param1[_loc23_++]);
                  _loc21_ = uint(param1[_loc23_++]);
                  _loc33_ = uint(param1[_loc23_++]);
                  _loc5_ = uint(param1[_loc23_++]);
                  _loc10_ = uint(param1[_loc23_++]);
                  (_loc16_ as PetItem).init(_loc28_,_loc42_,[_loc4_,_loc7_,_loc21_],_loc33_,_loc5_,_loc10_,_loc9_,param1[_loc23_++],false,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc42_,2)));
                  PetManager.insertPet(_loc42_,_loc28_,_loc4_,_loc7_,_loc21_,_loc16_.name,_loc9_,_loc33_,_loc5_,_loc10_,false);
               }
               _loc3_.pushIitem(_loc16_);
               _loc22_++;
            }
            if(_loc3_.length > 4)
            {
               LocalizationManager.translateIdAndInsert(_tradeDonePopup.txtCounter_ba.counterTxt,_loc3_.length == 1 ? 23696 : 23695,_loc3_.length);
            }
            buildItemWindows(_tradeDonePopup.itemBlock,_loc3_);
            SBTracker.push();
            _loc13_ = "unknown";
            if(_loc16_ is Item)
            {
               _loc13_ = "accessory";
            }
            else if(_loc16_ is DenItem)
            {
               _loc13_ = "den item";
            }
            else if(_loc16_ is PetItem)
            {
               _loc13_ = "pet item";
            }
            if(_loc37_ == 1)
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted/#" + _loc13_ + "/#0#" + _loc16_.defId,-1,1);
            }
            else
            {
               SBTracker.trackPageview("/game/play/trading/request/accepted",-1,1);
            }
            _loc29_ = int(param1[_loc23_++]);
            _loc6_ = new DenStateItemCollection();
            _loc22_ = 0;
            while(_loc22_ < _loc29_)
            {
               _loc8_ = int(param1[_loc23_++]);
               _loc43_ = int(param1[_loc23_++]);
               if(_loc8_ == 0)
               {
                  _loc35_ = _loc36_.getFullItemList(true);
                  _loc24_ = 0;
                  while(_loc24_ < _loc35_.length)
                  {
                     if(_loc35_.getAccItem(_loc24_).invIdx == _loc43_)
                     {
                        _loc35_.getCoreArray().splice(_loc24_,1);
                        break;
                     }
                     _loc24_++;
                  }
                  _loc36_.fullItemList = _loc35_;
                  _loc18_ = _loc32_.inventoryClothing.itemCollection;
                  _loc24_ = 0;
                  while(true)
                  {
                     if(_loc24_ < _loc18_.length)
                     {
                        if(_loc18_.getAccItem(_loc24_).invIdx != _loc43_)
                        {
                           continue;
                        }
                        _loc32_.accStateHideAccessory(_loc18_.getAccItem(_loc24_),false);
                        _loc18_.getCoreArray().splice(_loc24_,1);
                     }
                     _loc24_++;
                  }
               }
               else if(_loc8_ == 2)
               {
                  PetManager.removePetInvIdx([_loc43_]);
               }
               else
               {
                  _loc39_ = _loc36_.denItemsFull;
                  _loc44_ = new IntItemCollection();
                  _loc24_ = 0;
                  while(_loc24_ < _loc39_.length)
                  {
                     if(_loc39_.getDenItem(_loc24_).invIdx == _loc43_)
                     {
                        if(_loc39_.getDenItem(_loc24_).isCustom)
                        {
                           _loc44_.pushIntItem(_loc39_.getDenItem(_loc24_).invIdx);
                        }
                        if(_loc39_.getDenItem(_loc24_).sortId == 4 && _loc39_.getDenItem(_loc24_).categoryId != 0)
                        {
                           _loc26_ = 0;
                           while(_loc26_ < _loc39_.length)
                           {
                              if(_loc39_.getDenItem(_loc26_).defId == 617)
                              {
                                 _loc39_.getDenItem(_loc26_).categoryId = 1;
                                 break;
                              }
                              _loc26_++;
                           }
                        }
                        if(_loc39_.getDenItem(_loc24_).mannequinData != null)
                        {
                           _loc39_.getDenItem(_loc24_).mannequinData.removeItems();
                        }
                        _loc6_.pushDenStateItem(new DenStateItem(0,_loc43_,0,0,0,0,0,0,0,0,_loc39_.getDenItem(_loc24_).refId,0,0,0,0,"",0,"",0,0,"","",-1,"",false,null,0,0,null,null,2));
                        _loc39_.getCoreArray().splice(_loc24_,1);
                     }
                     _loc24_++;
                  }
                  PlayerWallManager.checkAndRemoveMasterpieceItems(_loc44_);
                  _loc41_ = _loc32_.inventoryDenFull.denItemCollection;
                  _loc24_ = 0;
                  while(_loc24_ < _loc41_.length)
                  {
                     if(_loc41_.getDenItem(_loc24_).invIdx == _loc43_)
                     {
                        if(_loc41_.getDenItem(_loc24_).sortId == 4 && _loc41_.getDenItem(_loc24_).categoryId != 0)
                        {
                           _loc26_ = 0;
                           while(_loc26_ < _loc41_.length)
                           {
                              if(_loc41_.getDenItem(_loc26_).defId == 617)
                              {
                                 _loc41_.getDenItem(_loc26_).categoryId = 1;
                                 break;
                              }
                              _loc26_++;
                           }
                        }
                        if(_loc41_.getDenItem(_loc24_).mannequinData != null)
                        {
                           _loc41_.getDenItem(_loc24_).mannequinData.removeItems();
                        }
                        _loc41_.getCoreArray().splice(_loc24_,1);
                     }
                     _loc24_++;
                  }
                  _loc32_.inventoryDenPartial.denItemCollection = new DenItemCollection();
                  _loc36_.denItemsPartial = new DenItemCollection();
                  for each(var _loc38_ in _loc32_.inventoryDenFull.denItemCollection.getCoreArray())
                  {
                     if(_loc38_.enviroType == AvatarManager.roomEnviroType)
                     {
                        _loc32_.inventoryDenPartial.denItemCollection.pushDenItem(_loc38_);
                        _loc36_.denItemsPartial.pushDenItem(_loc38_);
                     }
                  }
               }
               _loc34_ = gMainFrame.userInfo.getMyTradeList();
               _loc24_ = 0;
               while(_loc24_ < _loc34_.length)
               {
                  if(_loc34_.getTradeItem(_loc24_).itemType == _loc8_ && _loc34_.getTradeItem(_loc24_).invIdx == _loc43_)
                  {
                     _loc34_.getCoreArray().splice(_loc24_,1);
                     if(_loc8_ == 0)
                     {
                        _numClothingItemsInTradeList--;
                        break;
                     }
                     if(_loc8_ == 3)
                     {
                        _numPetItemsInTradeList--;
                        break;
                     }
                     _numDenItemsInTradeList--;
                     break;
                  }
                  _loc24_++;
               }
               _loc22_++;
            }
            if(_loc6_.length > 0 && gMainFrame.server.getCurrentRoomName(false) == "den" + gMainFrame.userInfo.myUserName)
            {
               RoomManagerWorld.instance.denItemHolder.setItems(_loc6_);
            }
            if(GuiManager.denEditor)
            {
               GuiManager.denEditor.reloadDenItems();
            }
            if(_loc32_)
            {
               _loc32_.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
            }
            GuiManager.showHudAvt();
            closeRequestSentPopup();
         }
         else
         {
            loadPopup(432,param1);
         }
      }
      
      private static function popupsMediaCallback(param1:MovieClip) : void
      {
         var _loc3_:Function = null;
         var _loc2_:Object = null;
         var _loc4_:MediaHelper = null;
         if(param1)
         {
            switch(param1.mediaHelper.id)
            {
               case 430:
                  _loc3_ = displayRequestTrade;
                  _loc2_ = param1.passback;
                  break;
               case 431:
                  _loc3_ = displayTradeRequested;
                  _loc2_ = param1.passback;
                  break;
               case 432:
                  _loc3_ = displayTradeDone;
                  _loc2_ = param1.passback;
                  break;
               case 4432:
                  _loc3_ = displayTradeConfirmPopup;
                  _loc2_ = param1.passback;
                  break;
               case 4456:
                  _loc3_ = displayRequestSent;
                  _loc2_ = param1.passback;
            }
            if(!AJAudio.hasLoadedTradeSfx)
            {
               _loc4_ = new MediaHelper();
               _loc4_.init(1333,onSoundsLoaded,{
                  "funcToCall":_loc3_,
                  "data":_loc2_,
                  "img":param1
               });
               _mediaViews.push(_loc4_);
            }
            else
            {
               DarkenManager.showLoadingSpiral(false);
               _loc3_(_loc2_,param1);
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
         }
      }
      
      private static function onSoundsLoaded(param1:MovieClip) : void
      {
         var _loc2_:ApplicationDomain = null;
         if(param1)
         {
            if(!AJAudio.hasLoadedTradeSfx)
            {
               _loc2_ = param1.loaderInfo.applicationDomain;
               AJAudio.loadSfx("TradeSuccessSound",_loc2_.getDefinition("TradeSuccessSound") as Class,0.5);
               AJAudio.loadSfx("TradeFailedSound",_loc2_.getDefinition("TradeFailedSound") as Class,0.5);
               AJAudio.loadSfx("TradeRequestSound",_loc2_.getDefinition("TradeRequestSound") as Class,0.7);
               AJAudio.hasLoadedTradeSfx = true;
            }
            DarkenManager.showLoadingSpiral(false);
            param1.passback.funcToCall(param1.passback.data,param1.passback.img);
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
      }
      
      private static function showTradeButtonsAfterDelay() : void
      {
         if(_tradeRequestedPopup)
         {
            _tradeRequestedPopup.yesBtn.visible = true;
            _tradeRequestedPopup.noBtn.visible = true;
         }
      }
      
      private static function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:AvatarInfo = null) : void
      {
         var _loc5_:UserInfo = null;
         if(param2 && param1.toLowerCase() == _tradeRequestedPlayerUsername.toLowerCase())
         {
            if(!param4)
            {
               param4 = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
               if(!param4)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(_tradeRequestedPlayerUsername);
            if(param4.isMember)
            {
               _tradeRequestedPopup.nonmember.visible = false;
               _tradeRequestedPopup.userName_txt.visible = false;
               _tradeRequestedPopup.member.setNubType("buddy",false);
               _tradeRequestedPopup.member.setColorAndBadge(_loc5_.nameBarData);
               _tradeRequestedPopup.member.isBlocked = false;
               _tradeRequestedPopup.member.setAvName(_loc5_.getModeratedUserName(),Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc5_,false);
               _tradeRequestedPopup.member.mouseEnabled = false;
               _tradeRequestedPopup.member.mouseChildren = false;
            }
            else
            {
               _tradeRequestedPopup.member.visible = false;
               _tradeRequestedPopup.userName_txt.visible = true;
               LocalizationManager.updateToFit(_tradeRequestedPopup.userName_txt,_loc5_.getModeratedUserName());
            }
            _tradeRequestAvatar = AvatarManager.getAvatarByUserName(_tradeRequestedPlayerUsername);
            if(_tradeRequestAvatar == null)
            {
               _tradeRequestAvatar = AvatarUtility.generateNew(param4.perUserAvId,null,_tradeRequestedPlayerUsername,-1,0,onAvatarItemData);
            }
            LocalizationManager.updateToFit(_tradeRequestedPopup.itemTxt,LocalizationManager.translateIdAndInsertOnly(_tradeRequestedPopupNumItems == 1 ? 8334 : 8336,_loc5_.getModeratedUserName(),_tradeRequestedPopupNumItems),true);
            drawMainAvatar(_tradeRequestAvatar);
         }
         else
         {
            onDeclineTrade(null);
         }
      }
      
      public static function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _tradeRequestAvatar != null)
         {
            drawMainAvatar(_tradeRequestAvatar);
         }
         else
         {
            onDeclineTrade(null);
         }
      }
      
      private static function drawMainAvatar(param1:Avatar) : void
      {
         if(Utility.isOcean(param1.enviroTypeFlag))
         {
            if(Utility.isLand(param1.enviroTypeFlag))
            {
               _tradeRequestedPopup.charBox.gotoAndStop(3);
            }
            else
            {
               _tradeRequestedPopup.charBox.gotoAndStop(2);
            }
         }
         else
         {
            _tradeRequestedPopup.charBox.gotoAndStop(1);
         }
         _tradeRequestAvatarView = new AvatarView();
         _tradeRequestAvatarView.init(param1);
         if(param1.avTypeId >= 0)
         {
            _tradeRequestAvatarView.playAnim(13,false,1,positionAndAddMainAvatarView);
         }
      }
      
      private static function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = null;
         var _loc4_:MovieClip = null;
         if(_tradeRequestAvatarView)
         {
            _loc3_ = AvatarUtility.getAvOffsetByDefId(_tradeRequestAvatarView.avTypeId);
            _tradeRequestAvatarView.x = _loc3_.x;
            _tradeRequestAvatarView.y = _loc3_.y;
            if(_tradeRequestedPopup && _tradeRequestAvatar)
            {
               if(Utility.isOcean(_tradeRequestAvatar.enviroTypeFlag))
               {
                  if(Utility.isLand(_tradeRequestAvatar.enviroTypeFlag))
                  {
                     _loc4_ = _tradeRequestedPopup.charBox.beach;
                  }
                  else
                  {
                     _loc4_ = _tradeRequestedPopup.charBox.ocean;
                  }
               }
               else
               {
                  _loc4_ = _tradeRequestedPopup.charBox.land;
               }
               while(_loc4_.numChildren > 1)
               {
                  _loc4_.removeChildAt(_loc4_.numChildren - 1);
               }
               _loc4_.addChild(_tradeRequestAvatarView);
            }
         }
         if(_loadingSpiralAvatar)
         {
            _loadingSpiralAvatar.visible = false;
         }
      }
      
      private static function loadPopup(param1:int, param2:Object = null) : void
      {
         var _loc3_:MediaHelper = null;
         DarkenManager.showLoadingSpiral(true);
         _loc3_ = new MediaHelper();
         _loc3_.init(param1,popupsMediaCallback,!!param2 ? param2 : true);
         _mediaViews[_mediaViews.length + 1] = _loc3_;
      }
      
      public static function onTradeItemsResponse(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc5_:* = false;
         var _loc3_:String = null;
         var _loc4_:int = int(param1[2]);
         if(_loc4_ == 0)
         {
            if(isCurrentlyTrading || gMainFrame.clientInfo.extCallsActive)
            {
               TradeXtCommManager.sendTradeItemAcceptOrReject(2);
            }
            else
            {
               isCurrentlyTrading = true;
               SBTracker.push();
               SBTracker.trackPageview("/game/play/trading/request/received",-1,1);
               displayTradeRequested(param1);
            }
         }
         else if(_loc4_ == 1)
         {
            if(int(param1[3]) == 0)
            {
               displayTradeConfirmPopup();
            }
            else
            {
               displayTradeDone(param1);
            }
         }
         else
         {
            SBTracker.push();
            _loc5_ = param1[3] == gMainFrame.userInfo.myUserName;
            if(_loc4_ == 2)
            {
               if(_loc5_)
               {
                  _loc2_ = LocalizationManager.translateIdOnly(25759);
               }
               else
               {
                  _loc3_ = "unknown";
                  if(_itemToTradeFor is Item)
                  {
                     _loc3_ = "accessory";
                  }
                  else if(_itemToTradeFor is DenItem)
                  {
                     _loc3_ = "den item";
                  }
                  else if(_itemToTradeFor is PetItem)
                  {
                     _loc3_ = "pet item";
                  }
                  _loc2_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/denied/#" + _loc3_ + "/#0/#" + _itemToTradeFor.defId,-1,1);
               }
            }
            else if(_loc4_ == 3)
            {
               if(_loc5_)
               {
                  _loc2_ = LocalizationManager.translateIdOnly(25760);
               }
               else
               {
                  _loc2_ = LocalizationManager.translateIdAndInsertOnly(11387,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/itemAlreadyTraded",-1,1);
               }
            }
            else if(_loc4_ == 4)
            {
               if(_loc5_)
               {
                  _loc2_ = LocalizationManager.translateIdOnly(25761);
               }
               else
               {
                  _loc2_ = LocalizationManager.translateIdAndInsertOnly(11388,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/alreadyInTrade",-1,1);
               }
            }
            else if(_loc4_ == 5)
            {
               if(_loc5_)
               {
                  _loc2_ = LocalizationManager.translateIdOnly(14804);
               }
               else
               {
                  _loc2_ = LocalizationManager.translateIdAndInsertOnly(11389,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  SBTracker.trackPageview("/game/play/trading/request/fullInventoryReceiver",-1,1);
               }
            }
            else
            {
               if(_loc4_ == 6)
               {
                  closeConfirmTradePopup();
                  closeTradeRequestedPopup();
                  isCurrentlyTrading = false;
                  return;
               }
               if(_loc4_ == 7)
               {
                  if(QuestManager.isInPrivateAdventureState)
                  {
                     QuestManager.showLeaveQuestLobbyPopup(onTradeItemsResponse,param1);
                  }
                  else
                  {
                     new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14704),true,onConfirmServerSwitch);
                  }
                  SBTracker.trackPageview("/game/play/trading/request/diffShard",-1,1);
                  _jammerRoomName = param1[3];
                  closeConfirmTradePopup();
                  closeRequestSentPopup();
                  isCurrentlyTrading = false;
                  return;
               }
               if(_loc4_ == 8)
               {
                  if(_loc5_)
                  {
                     _loc2_ = LocalizationManager.translateIdOnly(25759);
                  }
                  else
                  {
                     _loc2_ = LocalizationManager.translateIdAndInsertOnly(11386,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  }
               }
               else
               {
                  if(_loc4_ != 9)
                  {
                     DebugUtility.debugTrace("This should never happen... flag=" + _loc4_);
                     closeConfirmTradePopup();
                     closeRequestSentPopup();
                     isCurrentlyTrading = false;
                     return;
                  }
                  if(_loc5_)
                  {
                     _loc2_ = LocalizationManager.translateIdOnly(25754);
                  }
                  else
                  {
                     _loc2_ = LocalizationManager.translateIdAndInsertOnly(25755,int(param1[4]) > 0 ? param1[3] : LocalizationManager.translateIdOnly(11098));
                  }
               }
            }
            isCurrentlyTrading = false;
            closeConfirmTradePopup();
            closeRequestSentPopup();
            new SBOkPopup(_guiLayer,_loc2_,true,onSBOkBtn);
         }
      }
      
      public static function onTradeListReceived(param1:Object) : void
      {
         var _loc20_:int = 0;
         var _loc10_:int = 0;
         var _loc27_:TradeItemCollection = null;
         var _loc19_:IitemCollection = null;
         var _loc13_:int = 0;
         var _loc3_:* = 0;
         var _loc26_:int = 0;
         var _loc14_:* = false;
         var _loc28_:String = null;
         var _loc11_:int = 0;
         var _loc12_:Item = null;
         var _loc17_:int = 0;
         var _loc25_:String = null;
         var _loc15_:DenItem = null;
         var _loc16_:int = 0;
         var _loc23_:Number = NaN;
         var _loc2_:* = 0;
         var _loc5_:* = 0;
         var _loc18_:* = 0;
         var _loc7_:String = null;
         var _loc24_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:PetItem = null;
         var _loc22_:String = param1[2];
         var _loc21_:int = 3;
         if(gMainFrame.userInfo.myUserName.toLowerCase() == _loc22_.toLowerCase())
         {
            _loc27_ = new TradeItemCollection();
            _numClothingItemsInTradeList = int(param1[_loc21_++]);
            _loc20_ = 0;
            while(_loc20_ < _numClothingItemsInTradeList)
            {
               _loc21_ += 1;
               _loc27_.pushTradeItem(new TradeItem(int(param1[_loc21_++]),0));
               _loc21_ += 1;
               _loc20_++;
            }
            _numDenItemsInTradeList = _loc10_ = int(param1[_loc21_++]);
            _loc20_ = 0;
            while(_loc20_ < _loc10_)
            {
               _loc21_ += 1;
               _loc27_.pushTradeItem(new TradeItem(int(param1[_loc21_++]),1));
               _loc21_ += 5;
               _loc20_++;
            }
            _numPetItemsInTradeList = int(param1[_loc21_++]);
            _loc20_ = 0;
            while(_loc20_ < _numPetItemsInTradeList)
            {
               _loc21_ += 1;
               _loc27_.pushTradeItem(new TradeItem(int(param1[_loc21_++]),3));
               _loc21_ += 8;
               _loc20_++;
            }
            gMainFrame.userInfo.myTradeList = _loc27_;
         }
         else
         {
            _loc19_ = new IitemCollection();
            _loc11_ = int(param1[_loc21_++]);
            _loc20_ = 0;
            while(_loc20_ < _loc11_)
            {
               _loc13_ = int(param1[_loc21_++]);
               _loc26_ = int(param1[_loc21_++]);
               _loc3_ = uint(param1[_loc21_++]);
               _loc12_ = new Item();
               _loc12_.init(_loc13_,_loc26_,_loc3_);
               _loc19_.pushIitem(_loc12_);
               _loc20_++;
            }
            _loc10_ = int(param1[_loc21_++]);
            _loc20_ = 0;
            while(_loc20_ < _loc10_)
            {
               _loc13_ = int(param1[_loc21_++]);
               _loc26_ = int(param1[_loc21_++]);
               _loc3_ = uint(int(param1[_loc21_++]));
               _loc14_ = param1[_loc21_++] == "true";
               _loc28_ = param1[_loc21_++];
               _loc17_ = int(param1[_loc21_++]);
               _loc25_ = param1[_loc21_++];
               _loc15_ = new DenItem();
               _loc15_.init(_loc13_,_loc26_,0,_loc3_,0,null,_loc14_,_loc28_,"",_loc17_,_loc25_);
               _loc19_.pushIitem(_loc15_);
               _loc20_++;
            }
            _loc16_ = int(param1[_loc21_++]);
            _loc20_ = 0;
            while(_loc20_ < _loc16_)
            {
               _loc13_ = int(param1[_loc21_++]);
               _loc26_ = int(param1[_loc21_++]);
               _loc23_ = Number(param1[_loc21_++]);
               _loc2_ = uint(param1[_loc21_++]);
               _loc5_ = uint(param1[_loc21_++]);
               _loc18_ = uint(param1[_loc21_++]);
               _loc7_ = param1[_loc21_++];
               _loc24_ = int(param1[_loc21_++]);
               _loc4_ = int(param1[_loc21_++]);
               _loc6_ = int(param1[_loc21_++]);
               _loc8_ = new PetItem();
               _loc8_.init(_loc23_,_loc13_,[_loc2_,_loc5_,_loc18_],_loc24_,_loc4_,_loc6_,_loc26_,_loc7_,false,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc13_,2)));
               _loc19_.pushIitem(_loc8_);
               _loc20_++;
            }
            BuddyManager.onTradeListReceived(_loc22_,_loc19_);
         }
      }
      
      public static function changeTradeList(param1:TradeItemCollection, param2:TradeItemCollection) : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:TradeItemCollection = gMainFrame.userInfo.getMyTradeList();
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < param2.length)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.length)
               {
                  if(param2.getTradeItem(_loc3_).isEqual(_loc4_.getTradeItem(_loc5_)))
                  {
                     _loc4_.getCoreArray().splice(_loc5_,1);
                     break;
                  }
                  _loc5_++;
               }
               _loc3_++;
            }
         }
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc4_.pushTradeItem(param1.getTradeItem(_loc3_));
               _loc3_++;
            }
         }
         gMainFrame.userInfo.myTradeList = _loc4_;
         TradeXtCommManager.sendTradeSetRequest(param1,param2);
      }
      
      public static function getTradeItemInTradeList(param1:Iitem) : TradeItem
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:TradeItemCollection = gMainFrame.userInfo.getMyTradeList();
         if(param1.itemType == 2)
         {
            _loc5_ = 0;
         }
         else if(param1.itemType == 0)
         {
            _loc5_ = 1;
         }
         else if(param1.itemType == 1)
         {
            _loc5_ = 3;
         }
         var _loc2_:TradeItem = new TradeItem(param1.invIdx,_loc5_);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc2_.isEqual(_loc3_.getTradeItem(_loc4_)))
            {
               return _loc3_.getTradeItem(_loc4_);
            }
            _loc4_++;
         }
         return null;
      }
      
      public static function get initiationTradeList() : IitemCollection
      {
         return _initiationTradeList;
      }
      
      public static function get numClothingItemsInInitiateTradeList() : int
      {
         return _numClothingItemsInInitiateTradeList;
      }
      
      public static function get numDenItemsInInitiateTradeList() : int
      {
         return _numDenItemsInInitiateTradeList;
      }
      
      public static function adjustByOnNumClothingItemsInInitiateTradeList(param1:int) : void
      {
         _numClothingItemsInInitiateTradeList += param1;
      }
      
      public static function adjustByOnNumDenItemsInInitiateTradeList(param1:int) : void
      {
         _numDenItemsInInitiateTradeList += param1;
      }
      
      public static function adjustByOnNumPetItemsInInitiateTradeList(param1:int) : void
      {
         _numPetItemsInInitiateTradeList += param1;
      }
      
      public static function get numClothingItemsInMyTradeList() : int
      {
         return _numClothingItemsInTradeList;
      }
      
      public static function get numDenItemsInMyTradeList() : int
      {
         return _numDenItemsInTradeList;
      }
      
      public static function get numPetItemsInMyTradeList() : int
      {
         return _numPetItemsInTradeList;
      }
      
      public static function adjustByOnNumClothingItemsInMyTradeList(param1:int) : void
      {
         _numClothingItemsInTradeList += param1;
      }
      
      public static function adjustByOnNumDenItemsInMyTradeList(param1:int) : void
      {
         _numDenItemsInTradeList += param1;
      }
      
      public static function adjustByOnNumPetItemsInMyTradeList(param1:int) : void
      {
         _numPetItemsInTradeList += param1;
      }
      
      public static function resetNumTradeItems(param1:int, param2:int, param3:int) : void
      {
         if(param1 != -1 && param2 != -1 && param3 != -1)
         {
            _numClothingItemsInTradeList = param2;
            _numDenItemsInTradeList = param2;
            _numPetItemsInTradeList = param3;
         }
      }
      
      public static function get isCurrentlyTrading() : Boolean
      {
         return _isCurrentlyTrading;
      }
      
      public static function set isCurrentlyTrading(param1:Boolean) : void
      {
         _isCurrentlyTrading = param1;
         if(param1 == false)
         {
            _itemToTradeFor = null;
            _itemBeingTaken = null;
            _listOfItemsBeingOffered = null;
            _isInventoryFull = false;
         }
      }
      
      private static function onConfirmServerSwitch(param1:Object) : void
      {
         if(param1.status && _jammerRoomName != "")
         {
            DarkenManager.showLoadingSpiral(true);
            RoomXtCommManager.sendRoomJoinRequest(_jammerRoomName);
         }
         _jammerRoomName = "";
      }
      
      private static function buildItemWindows(param1:MovieClip, param2:IitemCollection, param3:Boolean = false) : void
      {
         var _loc5_:int = 0;
         var _loc10_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:* = 0;
         var _loc11_:Boolean = false;
         var _loc8_:WindowAndScrollbarGenerator = param3 ? _itemWindowTheirs : _itemWindows;
         if(_loc8_)
         {
            _loc8_.destroy();
         }
         var _loc9_:int = int(param2.length);
         var _loc4_:Object = {
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         };
         if(_requestTradePopup && param1 == _requestTradePopup.itemBlock)
         {
            _loc11_ = true;
            _loc12_ = true;
            _loc5_ = 2;
            _loc9_ = 4;
            _loc10_ = true;
            _loc6_ = _loc7_ = Math.min(_loc9_,_loc5_);
            while(_requestTradePopup.itemBlock.numChildren > 2)
            {
               _requestTradePopup.itemBlock.removeChildAt(_requestTradePopup.itemBlock.numChildren - 1);
            }
            if(_requestTradePopup.doneBtn.hasGrayState)
            {
               _requestTradePopup.doneBtn.activateGrayState(true);
            }
         }
         else if(_requestTradePopup && param1 == _requestTradePopup.itemBlockTheirs)
         {
            _loc11_ = true;
            _loc5_ = 1;
            _loc10_ = true;
            _loc7_ = _loc6_ = 1;
            while(_requestTradePopup.itemBlockTheirs.numChildren > 1)
            {
               _requestTradePopup.itemBlockTheirs.removeChildAt(_requestTradePopup.itemBlockTheirs.numChildren - 1);
            }
         }
         else if(_tradeDonePopup && param1 == _tradeDonePopup.itemBlock)
         {
            _loc11_ = true;
            if(_loc9_ > 4)
            {
               _loc7_ = 2;
               _loc6_ = _loc9_ / 2;
            }
            else
            {
               _loc7_ = _loc9_;
               _loc6_ = 1;
            }
            while(_tradeDonePopup.itemBlock.numChildren > 1)
            {
               _tradeDonePopup.itemBlock.removeChildAt(_tradeDonePopup.itemBlock.numChildren - 1);
            }
         }
         else if(_tradeReviewConfirmPopup && param1 == _tradeReviewConfirmPopup.itemBlock)
         {
            if(_loc9_ > 2)
            {
               _loc7_ = 2;
               _loc6_ = _loc9_ / 2;
            }
            else
            {
               _loc7_ = _loc9_;
               _loc6_ = 1;
            }
            while(_tradeReviewConfirmPopup.itemBlock.numChildren > 1)
            {
               _tradeReviewConfirmPopup.itemBlock.removeChildAt(_tradeReviewConfirmPopup.itemBlock.numChildren - 1);
            }
         }
         else if(_tradeReviewConfirmPopup && param1 == _tradeReviewConfirmPopup.itemBlockTheirs)
         {
            _loc11_ = true;
            _loc5_ = 1;
            _loc10_ = true;
            _loc7_ = _loc6_ = 1;
            while(_tradeReviewConfirmPopup.itemBlockTheirs.numChildren > 1)
            {
               _tradeReviewConfirmPopup.itemBlockTheirs.removeChildAt(_tradeReviewConfirmPopup.itemBlockTheirs.numChildren - 1);
            }
         }
         else if(_tradeRequestedPopup && param1 == _tradeRequestedPopup.itemBlocks.itemBlock)
         {
            _loc11_ = true;
            if(_loc9_ > 4)
            {
               _loc7_ = 2;
               _loc6_ = _loc9_ / 2;
            }
            else
            {
               _loc7_ = Math.min(2,_loc9_);
               _loc6_ = 1;
            }
            while(_tradeRequestedPopup.itemBlocks.itemBlock.numChildren > 1)
            {
               _tradeRequestedPopup.itemBlocks.itemBlock.removeChildAt(_tradeRequestedPopup.itemBlocks.itemBlock.numChildren - 1);
            }
         }
         else if(_tradeRequestedPopup && param1 == _tradeRequestedPopup.itemBlockTheirs)
         {
            _loc11_ = true;
            _loc5_ = 1;
            _loc10_ = true;
            _loc7_ = _loc6_ = 1;
            while(_tradeRequestedPopup.itemBlockTheirs.numChildren > 1)
            {
               _tradeRequestedPopup.itemBlockTheirs.removeChildAt(_tradeRequestedPopup.itemBlockTheirs.numChildren - 1);
            }
         }
         _loc8_ = new WindowAndScrollbarGenerator();
         _loc8_.init("widthCont" in param1 ? param1.widthCont.width : param1.width,"widthCont" in param1 ? param1.widthCont.height : param1.height,0,0,_loc7_,_loc6_,0,2,3,1,1.5,ItemWindowOriginal,param2.getCoreArray(),"icon",0,_loc4_,{
            "isTradeManager":_loc10_,
            "loadImmediately":false,
            "showAddRemoveBtns":_loc12_
         },null,false,false,true,false,_loc11_);
         param1.addChild(_loc8_);
         if(param3)
         {
            _itemWindowTheirs = _loc8_;
         }
         else
         {
            _itemWindows = _loc8_;
         }
         _loadingSpiral.visible = false;
      }
      
      private static function addRequestTradeListeners() : void
      {
         _requestTradePopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _requestTradePopup.doneBtn.addEventListener("mouseDown",onDoneBtn,false,0,true);
         _requestTradePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeRequestTradeListeners() : void
      {
         _requestTradePopup.removeEventListener("mouseDown",onPopoup);
         _requestTradePopup.doneBtn.removeEventListener("mouseDown",onDoneBtn);
         _requestTradePopup.bx.removeEventListener("mouseDown",onClose);
      }
      
      private static function addRequestSentListeners() : void
      {
         _requestSentPopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _requestSentPopup.cancelBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeRequestSentListeners() : void
      {
         _requestSentPopup.removeEventListener("mouseDown",onPopoup);
         _requestSentPopup.cancelBtn.removeEventListener("mouseDown",onClose);
      }
      
      private static function addTradeRequestedListeners() : void
      {
         _tradeRequestedPopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _tradeRequestedPopup.bx.addEventListener("mouseDown",onDeclineTrade,false,0,true);
         _tradeRequestedPopup.yesBtn.addEventListener("mouseDown",onAcceptTrade,false,0,true);
         _tradeRequestedPopup.noBtn.addEventListener("mouseDown",onDeclineTrade,false,0,true);
      }
      
      private static function removeTradeRequestedListeners() : void
      {
         _tradeRequestedPopup.removeEventListener("mouseDown",onPopoup);
         _tradeRequestedPopup.bx.removeEventListener("mouseDown",onDeclineTrade);
         _tradeRequestedPopup.yesBtn.removeEventListener("mouseDown",onAcceptTrade);
         _tradeRequestedPopup.noBtn.removeEventListener("mouseDown",onDeclineTrade);
      }
      
      private static function addTradeDoneListeners() : void
      {
         _tradeDonePopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _tradeDonePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _tradeDonePopup.yesBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeTradeDoneListeners() : void
      {
         _tradeDonePopup.removeEventListener("mouseDown",onPopoup);
         _tradeDonePopup.bx.removeEventListener("mouseDown",onClose);
         _tradeDonePopup.yesBtn.removeEventListener("mouseDown",onClose);
      }
      
      private static function addTradeConfirmListeners() : void
      {
         _tradeReviewConfirmPopup.addEventListener("mouseDown",onPopoup,false,0,true);
         _tradeReviewConfirmPopup.noBtn.addEventListener("mouseDown",onClose,false,0,true);
         _tradeReviewConfirmPopup.yesBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private static function removeTradeConfirmListeners() : void
      {
         _tradeReviewConfirmPopup.removeEventListener("mouseDown",onPopoup);
         _tradeReviewConfirmPopup.noBtn.removeEventListener("mouseDown",onClose);
         _tradeReviewConfirmPopup.yesBtn.removeEventListener("mouseDown",onClose);
      }
      
      private static function addTradeItem(param1:Iitem) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _initiationTradeList.length)
         {
            if(param1 is DenItem)
            {
               if(_initiationTradeList.getIitem(_loc2_) is DenItem)
               {
                  if(param1.invIdx == _initiationTradeList.getIitem(_loc2_).invIdx)
                  {
                     return;
                  }
               }
            }
            else if(param1 is Item)
            {
               if(_initiationTradeList.getIitem(_loc2_) is Item)
               {
                  if(param1.invIdx == _initiationTradeList.getIitem(_loc2_).invIdx)
                  {
                     return;
                  }
               }
            }
            else if(param1 is PetItem)
            {
               if(_initiationTradeList.getIitem(_loc2_) is PetItem)
               {
                  if(param1.invIdx == _initiationTradeList.getIitem(_loc2_).invIdx)
                  {
                     return;
                  }
               }
            }
            _loc2_++;
         }
         if(param1)
         {
            _initiationTradeList.pushIitem(param1);
            if(_initiationTradeList.length >= 4)
            {
               if(_initiationTradeList.length == 4)
               {
                  _requestTradePopup.gotoAndPlay("grow");
               }
               _itemWindows.findOpenWindowAndUpdate(param1);
               if(_initiationTradeList.length < 20)
               {
                  _itemWindows.insertItem(null,true);
               }
            }
            else
            {
               _itemWindows.findOpenWindowAndUpdate(param1);
            }
         }
         if(_initiationTradeList.length < 1)
         {
            if(_requestTradePopup.doneBtn.hasGrayState)
            {
               _requestTradePopup.doneBtn.activateGrayState(true);
            }
         }
         else if(_requestTradePopup.doneBtn.hasGrayState)
         {
            _requestTradePopup.doneBtn.activateGrayState(false);
         }
         LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,_initiationTradeList.length == 1 ? 23696 : 23695,_initiationTradeList.length);
         if(_denClothesSelectPopup)
         {
            _denClothesSelectPopup.destroy();
            _denClothesSelectPopup = null;
         }
      }
      
      private static function findItem(param1:TradeItem) : Iitem
      {
         var _loc2_:int = 0;
         var _loc3_:IitemCollection = BuddyManager.getTradeListFromBuddyCard();
         if(_loc3_)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               if((param1.itemType == 0 && _loc3_.getIitem(_loc2_) is Item || param1.itemType == 1 && _loc3_.getIitem(_loc2_) is DenItem || param1.itemType == 3 && _loc3_.getIitem(_loc2_) is PetItem) && param1.invIdx == _loc3_.getIitem(_loc2_).invIdx)
               {
                  return _loc3_.getIitem(_loc2_);
               }
               _loc2_++;
            }
         }
         return null;
      }
      
      private static function setupItemToTradeFor(param1:TradeItem) : void
      {
         var _loc2_:Iitem = null;
         var _loc3_:Iitem = null;
         if(param1 != null)
         {
            _loc3_ = findItem(param1);
            if(_loc3_)
            {
               if(param1.itemType == 0)
               {
                  _loc2_ = new Item();
                  (_loc2_ as Item).init(_loc3_.defId,_loc3_.invIdx,(_loc3_ as Item).color,(_loc3_ as Item).cloneEquippedAvatars(true));
               }
               else if(param1.itemType == 3)
               {
                  _loc2_ = new PetItem();
                  (_loc2_ as PetItem).init((_loc3_ as PetItem).createdTs,_loc3_.defId,(_loc3_ as PetItem).petBits,(_loc3_ as PetItem).traitDefId,(_loc3_ as PetItem).toyDefId,(_loc3_ as PetItem).foodDefId,_loc3_.invIdx,(_loc3_ as PetItem).name,_loc3_.isShopItem,null,(_loc3_ as PetItem).diamondItem);
               }
               else
               {
                  _loc2_ = new DenItem();
                  (_loc2_ as DenItem).init(_loc3_.defId,_loc3_.invIdx,(_loc3_ as DenItem).categoryId,(_loc3_ as DenItem).version,(_loc3_ as DenItem).refId,(_loc3_ as DenItem).petItem,(_loc3_ as DenItem).isApproved,(_loc3_ as DenItem).uniqueImageId,(_loc3_ as DenItem).uniqueImageCreator,(_loc3_ as DenItem).uniqueImageCreatorDbId,(_loc3_ as DenItem).uniqueImageCreatorUUID);
               }
               _itemToTradeFor = _loc2_;
            }
            else
            {
               DebugUtility.debugTrace("cannot find that trade item!");
            }
         }
         else
         {
            DebugUtility.debugTrace("itemToTrade is null???");
         }
      }
      
      private static function winMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "down")
            {
               param1.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("over");
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private static function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.isActivePet)
            {
               param1.currentTarget.cir.gotoAndStop("green");
            }
            else if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("down");
            }
            else
            {
               param1.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private static function winMouseDown(param1:MouseEvent) : void
      {
         var _loc4_:DenItem = null;
         var _loc3_:MovieClip = null;
         var _loc2_:String = null;
         var _loc5_:PetItem = null;
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(param1.currentTarget.name == "previewBtn")
         {
            _loc4_ = param1.currentTarget.parent.parent.currItem as DenItem;
            _loc3_ = param1.currentTarget.parent.parent.parent.parent.parent;
            _loc2_ = null;
            if(_requestTradePopup && _loc3_ == _requestTradePopup.itemBlockTheirs)
            {
               _loc2_ = _requestTradePopupCurrUsernameToTradeTo;
            }
            else if(_tradeReviewConfirmPopup && _loc3_ == _tradeReviewConfirmPopup.itemBlockTheirs)
            {
               if(_requestTradePopupCurrUsernameToTradeTo != null)
               {
                  _loc2_ = _requestTradePopupCurrUsernameToTradeTo;
               }
               else
               {
                  _loc2_ = gMainFrame.userInfo.myUserName;
               }
            }
            else if(_tradeRequestedPopup && _loc3_ == _tradeRequestedPopup.itemBlocks.itemBlock)
            {
               _loc2_ = _tradeRequestedPlayerUsername;
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.myUserName;
            }
            GuiManager.openMasterpiecePreview(_loc4_.uniqueImageId,_loc4_.uniqueImageCreator,_loc4_.uniqueImageCreatorDbId,_loc4_.uniqueImageCreatorUUID,_loc4_.version,_loc2_,_loc4_);
         }
         else if(param1.currentTarget.name == "certBtn")
         {
            _loc5_ = param1.currentTarget.parent.parent.currItem as PetItem;
            if(_loc5_)
            {
               GuiManager.openPetCertificatePopup(_loc5_.largeIcon as GuiPet,null);
            }
         }
         else if(param1.currentTarget.removeBtn.visible)
         {
            _initiationTradeList.getIitem(param1.currentTarget.index) is Item ? adjustByOnNumClothingItemsInInitiateTradeList(-1) : adjustByOnNumDenItemsInInitiateTradeList(-1);
            _itemWindows.updateItem(param1.currentTarget.index,null);
            if(_initiationTradeList.length > 3)
            {
               _itemWindows.deleteItem(param1.currentTarget.index,_initiationTradeList.getCoreArray());
               if(_initiationTradeList.length == 20 - 1)
               {
                  _itemWindows.insertItem(null,true);
               }
            }
            else
            {
               _initiationTradeList.getCoreArray().splice(Math.min(_initiationTradeList.length - 1,param1.currentTarget.index),1);
            }
            if(_initiationTradeList.length <= 3 && _requestTradePopup.currentFrameLabel != "four")
            {
               _requestTradePopup.gotoAndPlay("shrink");
            }
            if(_initiationTradeList.length < 1)
            {
               if(_requestTradePopup.doneBtn.hasGrayState)
               {
                  _requestTradePopup.doneBtn.activateGrayState(true);
               }
            }
            else if(_requestTradePopup.doneBtn.hasGrayState)
            {
               _requestTradePopup.doneBtn.activateGrayState(false);
            }
            LocalizationManager.translateIdAndInsert(_requestTradePopup.txtCounter_ba.counterTxt,_initiationTradeList.length == 1 ? 23696 : 23695,_initiationTradeList.length);
         }
         else if(param1.currentTarget.addBtn.visible && _initiationTradeList.length < 20)
         {
            if(_denClothesSelectPopup)
            {
               _denClothesSelectPopup.destroy();
            }
            else
            {
               _denClothesSelectPopup = new DenAndClothesItemSelect();
            }
            _denClothesSelectPopup.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,PetManager.myPetListAsIitem,_guiLayer,null,addTradeItem,3);
         }
      }
      
      private static function onPopoup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onSBOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         SBTracker.flush(true);
      }
      
      private static function onDoneBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Iitem = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param1.stopPropagation();
         if(!_requestTradePopup.doneBtn.isGray)
         {
            _loc4_ = 0;
            while(_loc4_ < _initiationTradeList.length)
            {
               _loc7_ = _initiationTradeList.getIitem(_loc4_);
               if(_loc7_.isDiamond)
               {
                  _loc2_++;
               }
               else if(_loc7_.isRare)
               {
                  _loc3_++;
               }
               else if(_loc7_.isRareDiamond)
               {
                  _loc6_++;
               }
               _loc4_++;
            }
            _loc5_ = 0;
            if(_loc6_ == 1)
            {
               _loc5_ = 6;
            }
            else if(_loc2_ > 0 && _loc3_ > 0 || _loc6_ > 1)
            {
               _loc5_ = 5;
            }
            else if(_loc2_ == 1)
            {
               _loc5_ = 3;
            }
            else if(_loc2_ > 1)
            {
               _loc5_ = 4;
            }
            else if(_loc3_ == 1)
            {
               _loc5_ = 1;
            }
            else if(_loc3_ > 1)
            {
               _loc5_ = 2;
            }
            if(_loc5_ != 0)
            {
               _tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc5_,false,onConfirmSendTradeRequest,param1);
            }
            else
            {
               setupAndSendTradeRequest(param1);
            }
         }
      }
      
      private static function onConfirmSendTradeRequest(param1:Boolean, param2:Object) : void
      {
         _tradeConfirmPopup.destroy();
         _tradeConfirmPopup = null;
         if(param1)
         {
            setupAndSendTradeRequest(MouseEvent(param2));
         }
      }
      
      private static function setupAndSendTradeRequest(param1:MouseEvent) : void
      {
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:Array = [];
         var _loc11_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:Array = [];
         var _loc6_:Array = [];
         _loc10_ = 0;
         while(_loc10_ < 4)
         {
            _loc7_[_loc10_] = 0;
            _loc8_[_loc10_] = 0;
            _loc10_++;
         }
         var _loc2_:int = 0;
         var _loc12_:int = 0;
         _loc9_ = 0;
         while(_loc9_ < _initiationTradeList.length)
         {
            if(_initiationTradeList.getIitem(_loc9_) is Item)
            {
               _loc7_[_initiationTradeList.getIitem(_loc9_).enviroType]++;
               _loc4_.push(_initiationTradeList.getIitem(_loc9_).invIdx);
            }
            else if(_initiationTradeList.getIitem(_loc9_) is DenItem)
            {
               if((_initiationTradeList.getIitem(_loc9_) as DenItem).sortId == 4)
               {
                  _loc2_++;
               }
               else
               {
                  _loc8_[_initiationTradeList.getIitem(_loc9_).enviroType]++;
               }
               _loc11_.push(_initiationTradeList.getIitem(_loc9_).invIdx);
            }
            else if(_initiationTradeList.getIitem(_loc9_) is PetItem)
            {
               _loc12_++;
               _loc6_.push(_initiationTradeList.getIitem(_loc9_).invIdx);
            }
            _loc9_++;
         }
         _numClothingItemsInInitiateTradeList = 0;
         _numDenItemsInInitiateTradeList = 0;
         _numPetItemsInInitiateTradeList = 0;
         SBTracker.push();
         var _loc3_:Boolean = true;
         if(_itemToTradeFor is Item)
         {
            if(_itemToTradeFor.enviroType == 0)
            {
               if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),0) + 1 - _loc7_[0] > ShopManager.maxItems)
               {
                  _loc3_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == 1)
            {
               if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),1) + 1 - _loc7_[1] > ShopManager.maxItems)
               {
                  _loc3_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == 3)
            {
               if(Utility.numClothingItemsInList(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),3) + 1 - _loc7_[3] > ShopManager.maxItems)
               {
                  _loc3_ = false;
               }
            }
            _loc5_ = 0;
         }
         else if(_itemToTradeFor is PetItem)
         {
            if(PetManager.myPetList.length + 1 - _loc12_ > PetManager.getPetInventoryMax())
            {
               _loc3_ = false;
            }
            _loc5_ = 3;
         }
         else
         {
            if((_itemToTradeFor as DenItem).sortId == 4)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,-1,true) + 1 - _loc2_ > ShopManager.maxAudioItems)
               {
                  _loc3_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == 0)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,0) + 1 - _loc8_[0] > ShopManager.maxDenItems)
               {
                  _loc3_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == 1)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,1) + 1 - _loc8_[1] > ShopManager.maxDenItems)
               {
                  _loc3_ = false;
               }
            }
            else if(_itemToTradeFor.enviroType == 3)
            {
               if(Utility.numDenItemsInList(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,3) + 1 - _loc8_[3] > ShopManager.maxDenItems)
               {
                  _loc3_ = false;
               }
            }
            _loc5_ = 1;
         }
         if(gMainFrame.clientInfo.extCallsActive)
         {
            onClose(param1);
            TradeXtCommManager.sendTradeBusyRequest(false);
            isCurrentlyTrading = false;
            BuddyManager.destroyBuddyCard();
            return;
         }
         if(_loc3_)
         {
            SBTracker.trackPageview("/game/play/trading/request/initiated",-1,1);
            TradeXtCommManager.sendTradeItemsRequest(_requestTradePopupCurrUsernameToTradeTo,_itemToTradeFor.invIdx,_loc5_,_loc4_,_loc11_,_loc2_,_loc6_,_loc12_);
            onClose(param1);
            displayRequestSent();
         }
         else
         {
            onClose(param1);
            TradeXtCommManager.sendTradeBusyRequest(false);
            isCurrentlyTrading = false;
            SBTracker.trackPageview("/game/play/trading/request/fullInventorySender",-1,1);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
         }
         BuddyManager.destroyBuddyCard();
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         var _loc2_:* = false;
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(param1.currentTarget.parent);
         if(param1.currentTarget.parent.parent == _guiLayer)
         {
            _guiLayer.removeChild(param1.currentTarget.parent);
         }
         param1.currentTarget.parent.visible = false;
         switch(param1.currentTarget.parent)
         {
            case _requestTradePopup:
               removeRequestTradeListeners();
               if(param1.currentTarget.name == "bx")
               {
                  SBTracker.flush(true);
                  TradeXtCommManager.sendTradeBusyRequest(false);
                  isCurrentlyTrading = false;
               }
               break;
            case _tradeRequestedPopup:
               SBTracker.flush(true);
               removeTradeRequestedListeners();
               if(_tradeRequestAvatarView)
               {
                  _tradeRequestAvatarView.destroy();
                  _tradeRequestAvatarView = null;
               }
               break;
            case _requestSentPopup:
               SBTracker.flush(true);
               TradeXtCommManager.sendTradeItemCancel();
               TradeXtCommManager.sendTradeBusyRequest(false);
               removeRequestSentListeners();
               isCurrentlyTrading = false;
               break;
            case _tradeDonePopup:
               SBTracker.flush(true);
               removeTradeDoneListeners();
               TradeXtCommManager.sendTradeBusyRequest(false);
               isCurrentlyTrading = false;
               GuiManager.closeAnyInventoryRelatedWindows();
               break;
            case _tradeReviewConfirmPopup:
               SBTracker.flush(true);
               removeTradeConfirmListeners();
               _loc2_ = param1.currentTarget.name == "yesBtn";
               TradeXtCommManager.sendConfirmTrade(_loc2_);
               if(!_loc2_ || _isInventoryFull)
               {
                  closeRequestSentPopup();
                  TradeXtCommManager.sendTradeBusyRequest(false);
                  if(_isInventoryFull)
                  {
                     new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14804),true,onSBOkBtn);
                  }
                  isCurrentlyTrading = false;
                  break;
               }
               displayRequestSent();
               break;
         }
      }
      
      private static function closeRequestSentPopup() : void
      {
         if(_requestSentPopup && _requestSentPopup.visible)
         {
            AJAudio.playTradeFailedSound();
            DarkenManager.unDarken(_requestSentPopup);
            if(_requestSentPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_requestSentPopup);
            }
            _requestSentPopup.visible = false;
            removeRequestSentListeners();
         }
      }
      
      private static function closeConfirmTradePopup() : void
      {
         if(_tradeReviewConfirmPopup)
         {
            AJAudio.playTradeFailedSound();
            DarkenManager.unDarken(_tradeReviewConfirmPopup);
            if(_tradeReviewConfirmPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeReviewConfirmPopup);
            }
            removeTradeConfirmListeners();
         }
      }
      
      private static function closeTradeRequestedPopup() : void
      {
         if(_tradeRequestedPopup && _tradeRequestedPopup.visible)
         {
            if(_tradeConfirmPopup != null)
            {
               _tradeConfirmPopup.destroy();
               _tradeConfirmPopup = null;
            }
            DarkenManager.unDarken(_tradeRequestedPopup);
            if(_tradeRequestedPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_tradeRequestedPopup);
            }
            _tradeRequestedPopup.visible = false;
            if(_tradeRequestAvatarView)
            {
               _tradeRequestAvatarView.destroy();
               _tradeRequestAvatarView = null;
            }
            removeTradeRequestedListeners();
         }
      }
      
      private static function onAcceptTrade(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc3_:int = 0;
         var _loc2_:Iitem = (_itemWindowTheirs.mediaWindows[0] as ItemWindowOriginal).currItem as Iitem;
         if(_loc2_.isRareDiamond || _loc2_.isDiamond && _loc2_.isRare)
         {
            _loc3_ = 5;
         }
         else if(_loc2_.isDiamond)
         {
            _loc3_ = 3;
         }
         else if(_loc2_.isRare)
         {
            _loc3_ = 1;
         }
         _tradeConfirmPopup = new TradeConfirmPopup(_guiLayer,_loc3_,false,onConfirmAcceptTrade,param1);
      }
      
      private static function onConfirmAcceptTrade(param1:Boolean, param2:MouseEvent) : void
      {
         _tradeConfirmPopup.destroy();
         _tradeConfirmPopup = null;
         if(param1)
         {
            TradeXtCommManager.sendTradeItemAcceptOrReject(1);
            onClose(param2);
         }
      }
      
      private static function onDeclineTrade(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         TradeXtCommManager.sendTradeItemAcceptOrReject(0);
         if(param1)
         {
            onClose(param1);
         }
         else
         {
            closeTradeRequestedPopup();
         }
         TradeXtCommManager.sendTradeBusyRequest(false);
         isCurrentlyTrading = false;
      }
   }
}

