package quest
{
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import com.hurlant.util.Base64;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import den.DenXtCommManager;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class QuestXtCommManager
   {
      private static var _questCache:Array;
      
      private static var _questDefLookups:Array;
      
      private static var _scriptDefs:Object;
      
      private static var _wasRoomWeCameFromDen:Boolean;
      
      private static var _activePickGift:String;
      
      private static var _autoStartQuestOnNextWaitResponse:Boolean;
      
      public static const QSSAU_DIRECTION_KEY_DOWN:int = 1;
      
      public static const QSSAU_DIRECTION_KEY_LEFT:int = 2;
      
      public static const QSSAU_TYPE_JUMP_START:int = 4;
      
      public static const QSSAU_TYPE_FALL_START:int = 8;
      
      public static const QSSAU_TYPE_LANDED:int = 16;
      
      public static const RESTRICTIONS_NONE:int = 0;
      
      public static const RESTRICTIONS_AVATAR:int = 1;
      
      public function QuestXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _questCache = [];
         _questDefLookups = [];
         _autoStartQuestOnNextWaitResponse = false;
      }
      
      public static function questSideScrollAU(param1:int, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qssau",[param1,param2,param3]);
      }
      
      public static function questAskComplete(param1:String, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaskr",[param1,param2,param3]);
      }
      
      public static function questMiniGameComplete(param1:String, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qmgc",[param1,param2,param3]);
      }
      
      public static function questActorAttacked(param1:String, param2:int, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaa",[param1,param1 == "" ? 1 : 0,param2,param3,param4]);
      }
      
      public static function questPhantomAttackDestructible(param1:String, param2:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpad",[param1,param2]);
      }
      
      public static function questPlayerHeal(param1:int, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qph",[param1,param2]);
      }
      
      public static function questActorTriggered(param1:String, param2:int = 0) : void
      {
         DebugUtility.debugTrace("sending \'qat\' command with actorId: " + param1);
         gMainFrame.server.setXtObject_Str("qat",[param1,param2]);
      }
      
      public static function questPickUpItem(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpup",[param1,AvatarManager.playerSfsUserId]);
      }
      
      public static function questActorTreasureTriggered(param1:String, param2:int = 0) : void
      {
         gMainFrame.server.setXtObject_Str("qatt",[param1,param2]);
      }
      
      public static function questActorUntriggered(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("qaut",[param1]);
      }
      
      public static function questActorPositionUpdate(param1:String, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int) : void
      {
         var _loc8_:* = param1.substring(0,3) == "_l_";
         if(!_loc8_ && QuestManager.livePlayerCount() > 1)
         {
            gMainFrame.server.setXtObject_Str("qau",[param1,param2,param3,param4,param5,param6,param7]);
         }
      }
      
      public static function questActorSeek(param1:String, param2:int) : void
      {
         var _loc3_:Array = null;
         var _loc4_:* = param1.substring(0,3) == "_l_";
         if(!_loc4_)
         {
            gMainFrame.server.setXtObject_Str("qas",[param1,param2]);
         }
         else
         {
            _loc3_ = [];
            _loc3_[0] = 0;
            _loc3_[1] = 0;
            _loc3_[2] = param1;
            _loc3_[3] = param2;
            _loc3_[4] = AvatarManager.playerSfsUserId;
            QuestManager.handleQuestActorRequestSeekResponse(_loc3_);
         }
      }
      
      public static function questBeamZap(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qbzap",[param1,param2]);
      }
      
      public static function questPhantomZap(param1:String, param2:int, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qpzap",[param1,param2,param3,param4]);
      }
      
      public static function questFullRoomMinigameComplete(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qfrmgdone",[param1,param2]);
      }
      
      public static function sendQuestJoinPrivate(param1:String) : void
      {
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
         {
            DarkenManager.showLoadingSpiral(true);
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjp",[gMainFrame.server.getCurrentRoomName(),param1]);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestJoinBuddy(param1:String) : void
      {
         var _loc2_:String = null;
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            _loc2_ = gMainFrame.server.getCurrentRoomName();
            if(_loc2_.indexOf("den") != -1)
            {
               _wasRoomWeCameFromDen = true;
            }
            else
            {
               _wasRoomWeCameFromDen = false;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjf",[gMainFrame.server.getCurrentRoomName(),param1]);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestCreateJoinPublic(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         var _loc4_:String = null;
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            _loc4_ = gMainFrame.server.getCurrentRoomName();
            if(_loc4_.indexOf("den") != -1)
            {
               _wasRoomWeCameFromDen = true;
            }
            else
            {
               _wasRoomWeCameFromDen = false;
            }
            if(param3)
            {
               _autoStartQuestOnNextWaitResponse = true;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qj",[gMainFrame.server.getCurrentRoomName(),param1,param2,0]);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestCreatePrivate(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            if(param3)
            {
               _autoStartQuestOnNextWaitResponse = true;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjc",[gMainFrame.server.getCurrentRoomName(),param1,param2]);
            GuiManager.grayOutHudItemsForPrivateLobby(true);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestPrivateKick(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("qjk",[param1]);
      }
      
      public static function sendQuestJoinCancel() : void
      {
         gMainFrame.server.setXtObject_Str("qjx",[]);
      }
      
      public static function sendQuestStartRequest() : void
      {
         if(gMainFrame.server.getCurrentRoom())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestStartRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            AvatarManager.resetCustomAdventureState();
            gMainFrame.server.setXtObject_Str("qs",[gMainFrame.server.getCurrentRoomName()]);
         }
      }
      
      public static function sendQuestProjectileLaunch(param1:int, param2:int, param3:int, param4:String, param5:int, param6:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qp",[param1,param2,param3,param4,param5,param6]);
      }
      
      public static function sendQuestSwipe(param1:int, param2:int, param3:int, param4:String, param5:int, param6:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qm",[param1,param2,param3,param4,param5,param6]);
      }
      
      public static function sendQuestExit(param1:String) : void
      {
         DenXtCommManager.denChangePending = _wasRoomWeCameFromDen;
         gMainFrame.server.setXtObject_Str("qx",[param1]);
      }
      
      public static function sendAttackPlayer(param1:String, param2:int, param3:int, param4:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qap",[param1,param2,param3,param4]);
      }
      
      public static function sendQuestPlayerRequestRespawn(param1:int, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qprr",[param1,param2,param3]);
      }
      
      public static function sendPlantSeed(param1:int, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qps",[param1,param2,param3]);
      }
      
      public static function sendEatPhantom(param1:String, param2:String, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qep",[param1,param2,param3,param4]);
      }
      
      public static function sendPlantAte(param1:String, param2:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpa",[param1,param2]);
      }
      
      public static function sendPickGiftResult(param1:int, param2:Boolean, param3:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str(_activePickGift,[param1,param2 ? "1" : "0",param3 ? "1" : "0"]);
      }
      
      public static function sendPickGiftComplete() : void
      {
         gMainFrame.server.setXtObject_Str("qpgiftdone",["1"]);
      }
      
      public static function sendQuestCloneQuest() : void
      {
         gMainFrame.server.setXtObject_Str("qcq",[]);
      }
      
      public static function sendQuestDropItem(param1:int, param2:int, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("qdroppup",[param1,param2,param3,AvatarManager.playerSfsUserId]);
      }
      
      public static function sendQuestMovedItemsRequest() : void
      {
         gMainFrame.server.setXtObject_Str("qmi",[]);
      }
      
      public static function sendPlaySwfComplete() : void
      {
         gMainFrame.server.setXtObject_Str("qplayswf",[]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc9_:ByteArray = null;
         var _loc3_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:Array = null;
         var _loc7_:int = 0;
         var _loc11_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:AvatarWorldView = null;
         var _loc6_:Object;
         switch((_loc6_ = param1.obj)[0])
         {
            case "qqm":
               if(QuestManager._questActorDictionary != null)
               {
                  _loc9_ = Base64.decodeToByteArray(_loc6_[2]);
                  _loc9_.uncompress();
                  _loc3_ = _loc9_.readShort();
                  _loc10_ = 0;
                  while(_loc10_ < _loc3_)
                  {
                     _loc2_ = _loc9_.readShort();
                     _loc4_ = [];
                     _loc7_ = 0;
                     _loc4_[_loc7_++] = _loc9_.readUTF();
                     _loc2_--;
                     _loc4_[_loc7_++] = _loc6_[1];
                     _loc11_ = 0;
                     while(_loc11_ < _loc2_)
                     {
                        _loc4_[_loc7_++] = _loc9_.readUTF();
                        _loc11_++;
                     }
                     param1.obj = _loc4_;
                     handleXtReply(param1);
                     _loc10_++;
                  }
               }
               break;
            case "qssau":
               _loc5_ = int(_loc6_[2]);
               if(_loc5_ != AvatarManager.playerSfsUserId)
               {
                  _loc8_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc5_);
                  if(_loc8_ != null)
                  {
                     _loc8_.queueCommand(_loc6_);
                  }
               }
               break;
            case "qap":
               QuestManager.handleAttackPlayer(_loc6_);
               break;
            case "qau":
               QuestManager.handleQuestActorPositionUpdateResponse(_loc6_);
               break;
            case "qahs":
               QuestManager.handleActorHealthStatus(_loc6_);
               break;
            case "qas":
               QuestManager.handleQuestActorRequestSeekResponse(_loc6_);
               break;
            case "qjp":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc6_[2] != 0)
               {
                  GuiManager.setSwapBtnGray(true);
                  QuestManager.handleQuestJoinResponse(_loc6_,"custParty",_loc6_[5]);
                  break;
               }
               if(_loc6_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  break;
               }
               if(_loc6_[3] == "FULL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14817));
                  break;
               }
               if(_loc6_[3] == "NLAND")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                  break;
               }
               if(_loc6_[3] == "NOCEAN")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                  break;
               }
               if(_loc6_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                  break;
               }
               if(_loc6_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
                  break;
               }
               if(_loc6_[3] == "NB")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14819));
                  break;
               }
               if(_loc6_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc6_[4]));
                  break;
               }
               if(_loc6_[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
                  break;
               }
               if(_loc6_[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc6_[4]));
                  break;
               }
               if(_loc6_[3] == "NQ")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14822));
                  break;
               }
               if(_loc6_[3] == "NP")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  break;
               }
               if(_loc6_[3] == "NA")
               {
                  GuiManager.showBarrierPopup(1,false,false,_loc6_[4]);
                  break;
               }
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               break;
            case "qjc":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc6_[2] != 0)
               {
                  GuiManager.closeWorldMapIfOpen();
                  QuestManager.handleQuestJoinResponse(_loc6_,"custSettings");
                  GuiManager.grayOutHudItemsForPrivateLobby(true);
                  break;
               }
               if(_loc6_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(_loc6_[3] == "NLAND")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(_loc6_[3] == "NOCEAN")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
               }
               else if(_loc6_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
               }
               else if(_loc6_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
               }
               else if(_loc6_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc6_[4]));
               }
               else if(_loc6_[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(_loc6_[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc6_[4]));
               }
               else if(_loc6_[3] == "NP")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
               }
               else if(_loc6_[3] == "NA")
               {
                  GuiManager.showBarrierPopup(1,false,false,_loc6_[4]);
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               GuiManager.grayOutHudItemsForPrivateLobby(false);
               break;
            case "qj":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc6_[2] != 0)
               {
                  GuiManager.setSwapBtnGray(true);
                  QuestManager.handleQuestJoinResponse(_loc6_,"normal",_loc6_[5]);
                  break;
               }
               if(_loc6_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(_loc6_[3] == "NLAND")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(_loc6_[3] == "NOCEAN")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
               }
               else if(_loc6_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
               }
               else if(_loc6_[3] == "NLANDAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(24447));
               }
               else if(_loc6_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14823));
               }
               else if(_loc6_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc6_[4]));
               }
               else
               {
                  if(_loc6_[3] == "NAIL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
                     return;
                  }
                  if(_loc6_[3] == "NDL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc6_[4]));
                  }
                  else if(_loc6_[3] == "NDLERR")
                  {
                     new SBOkPopup(GuiManager.guiLayer,"Total user var bits exceeded - increase support for additional levels!");
                  }
                  else if(_loc6_[3] == "NP")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  }
                  else if(_loc6_[3] == "NA")
                  {
                     GuiManager.showBarrierPopup(1,false,false,_loc6_[4]);
                  }
                  else
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  }
               }
               GuiManager.setSwapBtnGray(false);
               break;
            case "qjx":
               GuiManager.setSwapBtnGray(false);
               QuestManager.handleQuestJoinCancelResponse(_loc6_);
               break;
            case "qw":
               QuestManager.handleQuestWaitResponse(_loc6_);
               if(_autoStartQuestOnNextWaitResponse)
               {
                  _autoStartQuestOnNextWaitResponse = false;
                  sendQuestStartRequest();
               }
               break;
            case "qs":
               questStartResponse(_loc6_);
               QuestManager.handleQuestStartResponse(_loc6_);
               break;
            case "qcmd":
               QuestManager.handleCommand(_loc6_,false);
               break;
            case "qcmdVT":
               QuestManager.handleCommand(_loc6_,true);
               break;
            case "qp":
               QuestManager.handleLaunchProjectile(_loc6_);
               break;
            case "qm":
               QuestManager.handleSwipe(_loc6_);
               break;
            case "quxp":
               QuestManager.handleXpUpdate(_loc6_);
               break;
            case "quhp":
               QuestManager.handleHealthUpdate(_loc6_,false);
               break;
            case "qrspn":
               QuestManager.handleHealthUpdate(_loc6_,true);
               break;
            case "qad":
               QuestManager.handleActorDeath(_loc6_);
               break;
            case "qx":
               break;
            case "qxt":
               QuestManager.handleExitByType(_loc6_);
               break;
            case "qspn":
               QuestManager.handleSpawn(_loc6_);
               break;
            case "qatt":
               QuestManager.handleQuestActorTriggerTreasure(_loc6_);
               break;
            case "qusu":
               QuestManager.handleStatsUpdate(_loc6_);
               break;
            case "qulu":
               QuestManager.handleLevelUp(_loc6_);
               break;
            case "qporbs":
               QuestManager.handleOrbsUpdate(_loc6_);
               break;
            case "qpup":
               QuestManager.handlePickUpItem(_loc6_);
               break;
            case "qsnd":
               QuestManager.playSound(_loc6_[2],null,false,null);
               break;
            case "qsndVO":
               QuestManager.playSound(_loc6_[2],null,true,_loc6_[3]);
               break;
            case "qmusic":
               QuestManager.playMusic(_loc6_[2]);
               break;
            case "qswfs":
               QuestManager.handleSetSwfState(_loc6_);
               break;
            case "qmlib":
               QuestManager.handleLoadMediaLib(_loc6_);
               break;
            case "qprr":
               QuestManager.handleQuestPlayerRequestRespawn(_loc6_);
               break;
            case "qpd":
               QuestManager.handleQuestPlayerDead(_loc6_);
               break;
            case "qsp":
               QuestManager.handleQuestSetPath(_loc6_);
               break;
            case "qps":
               QuestManager.handlePlantSeed(_loc6_);
               break;
            case "qpa":
               QuestManager.handlePlantAte(_loc6_[2],_loc6_[3]);
               break;
            case "qbzap":
               QuestManager.handleBeamZap(_loc6_);
               break;
            case "qpzap":
               QuestManager.handlePhantomZap(_loc6_);
               break;
            case "qpgift":
               _activePickGift = "qpgift";
               QuestManager.handlePickGift(_loc6_,false);
               break;
            case "qpgiftplr":
               _activePickGift = "qpgiftplr";
               QuestManager.handlePickGift(_loc6_,false);
               break;
            case "qplq":
               QuestManager.handlePlayerLeftQuest(_loc6_);
               break;
            case "qrc":
               QuestManager.handleQuestRoomChange(_loc6_);
               break;
            case "qviu":
               QuestManager.handleQuestVolumeInteractionUpdate(_loc6_);
               break;
            case "qtorch":
               QuestManager.handleQuestTorch(_loc6_);
               break;
            case "qgi":
               questPickUpItem(_loc6_[2]);
               break;
            case "qsndpk":
               QuestManager.loadQuestSfx(_loc6_[2]);
               break;
            case "qicon":
               QuestManager.handleActorIcon(_loc6_[2],_loc6_[3]);
               break;
            case "qseed":
               QuestManager.handleGiveSeed(_loc6_[2],_loc6_[3],_loc6_[4]);
               break;
            case "qmi":
               QuestManager.handleMovedItemList(_loc6_ as Array);
               break;
            case "qepr":
               QuestManager.handlePlantEatRecoil(_loc6_[2]);
               break;
            case "qplayswf":
               QuestManager.handlePlaySwf(_loc6_[2]);
               break;
            case "qshake":
               QuestManager.handleShake(_loc6_[2]);
               break;
            case "qaward":
               QuestManager.handleAward(_loc6_[2],_loc6_[3]);
               break;
            case "qposturi":
               QuestManager.handlePostUri(_loc6_[2]);
               break;
            case "qpreloadswf":
               QuestManager.handlPreloadSwf(_loc6_[2]);
               break;
            case "qfade":
               QuestManager.handleFade(_loc6_[2] == 1);
               break;
            case "qavsw":
               QuestManager.handleAvSwitch(_loc6_);
               break;
            case "qrestore":
               QuestManager.handleRestore(_loc6_);
         }
      }
      
      private static function questStartResponse(param1:Object) : void
      {
         var _loc10_:String = null;
         var _loc13_:Dictionary = null;
         var _loc15_:Object = null;
         var _loc12_:String = null;
         var _loc2_:int = 0;
         var _loc14_:int = 0;
         var _loc5_:String = null;
         var _loc8_:int = 0;
         var _loc16_:* = false;
         var _loc17_:* = false;
         var _loc11_:String = null;
         var _loc9_:String = null;
         var _loc6_:int = 2;
         var _loc3_:int = int(param1[_loc6_++]);
         var _loc4_:int = int(param1[_loc6_++]);
         var _loc7_:int = int(param1[_loc6_++]);
         if(_loc7_ >= 0)
         {
            QuestManager.onStartQuestInit();
            _loc10_ = param1[_loc6_++];
            _loc13_ = new Dictionary();
            while(_loc7_ > 0)
            {
               _loc15_ = {};
               _loc12_ = param1[_loc6_++];
               _loc2_ = int(param1[_loc6_++]);
               _loc14_ = 0;
               _loc5_ = null;
               if(_loc2_ == 16)
               {
                  _loc5_ = param1[_loc6_++];
               }
               else
               {
                  _loc14_ = int(param1[_loc6_++]);
               }
               _loc8_ = int(param1[_loc6_++]);
               _loc16_ = param1[_loc6_++] == 1;
               _loc17_ = param1[_loc6_++] == 1;
               _loc11_ = param1[_loc6_++];
               _loc9_ = param1[_loc6_++];
               _loc15_.visible = _loc16_;
               _loc15_.requireClick = _loc17_;
               _loc15_.defId = _loc14_;
               _loc15_.defName = _loc5_;
               _loc15_.type = _loc2_;
               _loc15_.state = _loc8_;
               _loc15_.pathName = _loc11_ != "" ? _loc11_ : null;
               QuestManager.initInitialActorStatus(_loc15_,null);
               if(_loc9_ != null && _loc9_ != "")
               {
                  _loc15_.pendingSwfStateName = [];
                  _loc15_.pendingSwfStateName.push(_loc9_);
               }
               else
               {
                  _loc15_.pendingSwfStateName = null;
               }
               _loc13_[_loc12_] = _loc15_;
               _loc7_--;
            }
            QuestManager.setActorDictionary(_loc13_,_loc10_);
            QuestManager.hasJustJoinedQuest = true;
         }
         else
         {
            AvatarManager.joiningNewRoom = false;
            RoomXtCommManager._loadingNewRoom = false;
            GuiManager.setSwapBtnGray(false);
         }
      }
      
      public static function questNPCDefResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1025] = null;
         var _loc2_:Object = {};
         for each(var _loc3_ in param1.def)
         {
            _loc2_[int(_loc3_.id)] = {
               "avatarRefId":int(_loc3_.avatarRefId),
               "backColor":uint(_loc3_.backColor),
               "backItemRefId":int(_loc3_.backItemRefId),
               "eyesColor":uint(_loc3_.eyesColor),
               "eyesItemRefId":int(_loc3_.eyesItemRefId),
               "legColor":uint(_loc3_.legColor),
               "legItemRefId":int(_loc3_.legItemRefId),
               "headColor":uint(_loc3_.headColor),
               "headMediaRefId":uint(_loc3_.headMediaRefId),
               "headItemRefId":int(_loc3_.headItemRefId),
               "defId":int(_loc3_.id),
               "mediaRefId":int(_loc3_.mediaRefId),
               "neckColor":uint(_loc3_.neckColor),
               "neckItemRefId":int(_loc3_.neckItemRefId),
               "patternColor":uint(_loc3_.patternColor),
               "patternItemRefId":int(_loc3_.patternItemRefId),
               "tailColor":uint(_loc3_.tailColor),
               "tailItemRefId":int(_loc3_.tailItemRefId),
               "titleStrId":int(_loc3_.titleStrId),
               "type":int(_loc3_.type),
               "baseColor":uint(_loc3_.baseColor),
               "hps":int(_loc3_.hps),
               "defense":int(_loc3_.defense),
               "xpValue":int(_loc3_.xpValue),
               "iconMediaRefId":int(_loc3_.iconMediaRefId),
               "level":int(_loc3_.level),
               "attackable":int(_loc3_.attackable),
               "damageTouch":int(_loc3_.damageTouch)
            };
         }
         QuestManager.npcDefs = _loc2_;
      }
      
      public static function scriptResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1052] = null;
         var _loc2_:Object = {};
         for each(var _loc3_ in _loc4_)
         {
            _loc2_[int(_loc3_.id)] = {
               "defId":int(_loc3_.id),
               "avatarLimit":int(_loc3_.avatarLimit),
               "avatarMin":int(_loc3_.avatarMin),
               "avatarType":int(_loc3_.avatarType),
               "descStrId":int(_loc3_.descStrId),
               "difficulty":int(_loc3_.difficulty),
               "levelMin":int(_loc3_.levelMin),
               "mediaRefId":int(_loc3_.mediaRefId),
               "time":int(_loc3_.time),
               "titleStrId":int(_loc3_.titleStrId),
               "hudType":int(_loc3_.hudType),
               "bannerMediaRefId":int(_loc3_.bannerMediaRefId),
               "membersOnly":(_loc3_.membersOnly == "1" ? true : false),
               "playAsPet":(_loc3_.playAsPet == "1" ? true : false),
               "restrictions":int(_loc3_.restrictions),
               "avatarDefFlags":Number(_loc3_.avatarDefFlags),
               "isPlatformer":(_loc3_.isPlatformer == "1" ? true : false)
            };
         }
         _scriptDefs = _loc2_;
      }
      
      public static function roomJoined(param1:String) : void
      {
         QuestManager.questRoomJoined(param1.indexOf("quest_") == 0);
      }
      
      public static function getScriptDef(param1:int) : Object
      {
         return _scriptDefs[param1];
      }
      
      private static function searchQuestCache(param1:int) : Object
      {
         return _questCache[param1];
      }
   }
}

