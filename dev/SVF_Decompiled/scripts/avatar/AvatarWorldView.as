package avatar
{
   import achievement.AchievementXtCommManager;
   import buddy.BuddyManager;
   import com.sbi.corelib.input.SBTextField;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.FrameLabel;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import game.MinigameInfo;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.ChatBalloon;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.MySettings;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   import pet.WorldPet;
   import quest.QuestActor;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarWorldView extends AvatarView
   {
      public static const AV_MODE_DEFAULT:int = 0;
      
      public static const AV_MODE_QUESTCOMBAT:int = 1;
      
      private static const ACTION_TIME:int = 3000;
      
      private static const SELNUB_SHOW_DIST:Number = 150;
      
      private static const AVATAR_MOVEDIR_ANGLE_OFFSET:Number = 0.20943951;
      
      private static const NAMEBAR_X_OFFSET:int = -15;
      
      private static const NAMEBAR_Y_OFFSET:int = 18;
      
      private static const ATTACHMENT_X_OFFSET:int = -310;
      
      private static const ATTACHMENT_Y_OFFSET:int = -320;
      
      private static const SLIDE_FRAME_TIME:Number = 41.666666666666664;
      
      private static const GLOW_LAND_DEFAULT_COLOR:int = 5586479;
      
      private static const GLOW_OCEAN_DEFAULT_COLOR:int = 2775381;
      
      private static const DEG_TO_RAD:Number = 57.295779513;
      
      private static const TERMINAL_SPEED:Number = 1000;
      
      public static const _platformingXSpeed:int = 32;
      
      private static const _platformingXAcc:int = 150;
      
      private static const STATE_LEAPINIT:int = 0;
      
      private static const STATE_LEAPUP:int = 1;
      
      private static const STATE_LEAPTOPSTART:int = 2;
      
      private static const STATE_LEAPTOPEND:int = 3;
      
      private static const STATE_FALL1:int = 4;
      
      private static const STATE_FALL2:int = 5;
      
      private static const STATE_LAND:int = 6;
      
      public static var _actionLookup:Array = [{
         "name":":dance:",
         "land":23,
         "water":38,
         "flip":false
      },{
         "name":":sleep:",
         "land":22,
         "water":41,
         "flip":false
      },{
         "name":":dive:",
         "land":22,
         "water":41,
         "flip":false
      },{
         "name":":hop:",
         "land":17,
         "water":33,
         "flip":false
      },{
         "name":":swirl:",
         "land":17,
         "water":33,
         "flip":false
      },{
         "name":":play:",
         "land":6,
         "water":39,
         "flip":false
      },{
         "name":":sitNW:",
         "land":2,
         "water":40,
         "flip":true
      },{
         "name":":poseLeft:",
         "land":2,
         "water":40,
         "flip":true
      },{
         "name":":sitNE:",
         "land":2,
         "water":40,
         "flip":false
      },{
         "name":":sitSE:",
         "land":4,
         "water":40,
         "flip":true
      },{
         "name":":poseRight:",
         "land":2,
         "water":40,
         "flip":false
      },{
         "name":":sitSW:",
         "land":4,
         "water":40,
         "flip":false
      }];
      
      private static const JumpLandFX:Class = §jumpLandFX_swf$ede96903de1ccedb3ebdde6fe307c7d4-94649027§;
      
      public var JUMP_SPEED:Number = 1200;
      
      public var BOUNCE_SPEED:Number = 1750;
      
      public var GRAVITY:Number = 2400;
      
      private var _platformingCurVel:Number = 0;
      
      private var _chatBalloon:ChatBalloon;
      
      private var _namebar:NameBar;
      
      private var _pos:Point;
      
      private var _scale:Point;
      
      private var _moveToX:Number;
      
      private var _moveToY:Number;
      
      private var _dirX:Number;
      
      private var _dirY:Number;
      
      private var _radius:Number = 30;
      
      private var _deleteOnMoveComplete:Boolean = false;
      
      private var _moving:int;
      
      private var _chatLayer:Object;
      
      private var _followPath:Array;
      
      private var _roomType:int;
      
      private var _secondaryEmot:MovieClip;
      
      private var _avAttMediaHelper:MediaHelper;
      
      private var _avAttachmentExtra:String;
      
      private var _avAttMediaId:int;
      
      private var _actionMgr:Object;
      
      private var _guiMgr:Object;
      
      private var _isGuide:Boolean;
      
      private var _lastMoveAngle:Number;
      
      private var _lastIdleAnim:int;
      
      private var _lastIdleFlip:Boolean;
      
      private var _glow:GlowFilter;
      
      private var _splashLiquid:String;
      
      private var _bInSplashVolume:Boolean;
      
      private var _splashVol:Object;
      
      private var _slideCurrentPosition:int;
      
      private var _slideFrameTime:int;
      
      private var _slidePositions:Array;
      
      private var _slideSpinTimer:Object;
      
      private var _slideSpinCurrentDirection:int;
      
      private var _pet:WorldPet;
      
      private var _splash:AvatarViewExt_Splash;
      
      private var _isLoadingEmoteId:int;
      
      private var _isMember:Boolean;
      
      private var _hudViewHolder:MovieClip;
      
      private var _hudAvtOrPetView:Object;
      
      private var _flashTimer:Timer;
      
      private var _frameTime:Number;
      
      private var _numFramesForOffscreen:int;
      
      private var _avOffscreenMediaHelper:MediaHelper;
      
      private var _customPVPImageLoader:MediaHelper;
      
      private var _currPetName:String;
      
      private var _shouldShowPetOnly:Boolean;
      
      private var _emitParticles:Boolean;
      
      private var _timeSinceLastParticle:Number;
      
      private var _lastParticleLoc:Point;
      
      private var _particleOffset:int;
      
      private var _particleIdling:MovieClip;
      
      private var _patternIndex:int;
      
      private var _currSpecialPatternColors:Array;
      
      private var _jumpVel:Number;
      
      private var _bJumping:Boolean;
      
      private var _bFalling:Boolean;
      
      private var _jumpTimer:Number;
      
      private var _jumpEnableTimer:Number;
      
      private var _bFallDisableCollision:Boolean;
      
      private var _bOnLadder:Boolean;
      
      private var _resolveUpResult:Object;
      
      private var _bJumpEnabled:Boolean;
      
      private var _bMouseMovement:Boolean;
      
      private var _sideScrollArrow:MovieClip;
      
      private var _sideScrollArrowLoader:MediaHelper;
      
      private var _prevXDir:Number;
      
      private var _xTarget:int;
      
      private var _xState:int;
      
      private var _isCurrentlySwitching:Boolean;
      
      public var _bArrowEnabled:Boolean;
      
      private var _commandQueue:Array;
      
      private var _currentCommand:Object;
      
      private var _timeSinceLastHostingUpdate:Number;
      
      private var _jumpLandFXPool:Vector.<MovieClip>;
      
      private var _leapState:int;
      
      private var _leapFrameCounter:int;
      
      private var _float:Boolean;
      
      private var _jumpLandType:String;
      
      private var _platformStartPos:Point;
      
      private var _platformCurrentDir:int;
      
      private var _bOnPlatform:Boolean;
      
      private var _doBounce:Boolean;
      
      private var platform:Rectangle;
      
      private var platformQA:QuestActor;
      
      private var _splashTimer:Number;
      
      private var _avSwitchedNPC:NPCView;
      
      public function AvatarWorldView()
      {
         super();
      }
      
      public static function convertToIdle(param1:Number) : Object
      {
         var _loc2_:int = 14;
         var _loc4_:Boolean = false;
         if(param1 > -2 * 1.5707963267948966 && param1 < -1.5707963267948966)
         {
            _loc2_ = 16;
            _loc4_ = true;
         }
         else if(param1 >= -1.5707963267948966 && param1 < 0)
         {
            _loc2_ = 16;
         }
         else if(param1 >= 0 && param1 < 1.5707963267948966)
         {
            _loc2_ = 14;
         }
         else
         {
            _loc2_ = 14;
            _loc4_ = true;
         }
         return {
            "anim":_loc2_,
            "flip":_loc4_
         };
      }
      
      public static function updateScreenPositionAndDirection(param1:MovieClip, param2:Rectangle, param3:Point) : void
      {
         if(param3.x > param2.width)
         {
            if(param3.x > param2.width)
            {
               param3.x = 900 - param1.mouse.width * 0.5;
            }
            param1.openChat(180,0);
         }
         else if(param3.x - param1.mouse.width * 0.5 < 0)
         {
            param1.openChat(0,0);
            if(param3.x - param1.mouse.width * 0.5 < 0)
            {
               param3.x += 0 - param3.x + param1.mouse.width * 0.5;
            }
         }
         if(param3.y > param2.height - 73.5)
         {
            param3.y = 550 - param1.mouse.height * 0.5 - 73.5;
            if(param3.x - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5) < 0)
            {
               param1.openChat(-90,param3.x + (0 - param3.x + (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5)));
            }
            else if(param3.x - (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5) > param2.width)
            {
               param1.openChat(-90,param3.x - (900 - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5)),true);
            }
            else
            {
               param1.openChat(-90,0);
            }
         }
         else if(param3.y - param1.mouse.height * 0.5 < 15)
         {
            param3.y += 15 - param3.y + param1.mouse.height * 0.5;
            if(param3.x - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5) < 0)
            {
               param1.openChat(90,param3.x + (0 - param3.x + (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5)));
            }
            else if(param3.x - (param1.mouse.width * 0.5 - param1.questChatBalloon.width * 0.5) > param2.width)
            {
               param1.openChat(90,param3.x - (900 - param1.mouse.width * 0.5 - (param1.questChatBalloon.width * 0.5 - param1.mouse.width * 0.5)),true);
            }
            else
            {
               param1.openChat(90,0);
            }
         }
      }
      
      override public function init(param1:Avatar, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:Boolean = false) : void
      {
         throw new Error("Don\'t use this!  Use initWorldView instead!  ...I miss overloading...");
      }
      
      public function initWorldView(param1:Avatar, param2:Object, param3:int, param4:Boolean, param5:Boolean = false, param6:Object = null, param7:Object = null, param8:int = 0, param9:int = 0) : void
      {
         var _loc12_:int = 0;
         _avatar = param1;
         if(!param2)
         {
            throw new Error("AvatarWorldView got invalid chatLayer:null!");
         }
         _chatLayer = param2;
         _actionMgr = param6;
         _guiMgr = param7;
         _roomType = param9;
         if(param5)
         {
            visible = false;
         }
         _jumpLandFXPool = new Vector.<MovieClip>();
         param1.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         _isGuide = param4;
         _scale = new Point(1,1);
         _pos = new Point(0,0);
         _slideCurrentPosition = -1;
         lastAnimToHappen = -1;
         if(param1.perUserAvId != 0 && gMainFrame.clientInfo.roomType == 7 && QuestManager.hasJustJoinedQuest && !QuestManager.isQuestLikeNormalRoom())
         {
            AvatarManager.setOffScreenMapBySfsId(userId,new Point(0,0),gMainFrame.server.getCurrentRoomName(false));
         }
         initNamebar(param3);
         if(param1.avName == "")
         {
            _namebar.visible = false;
         }
         if(_avatar.isShaman)
         {
            _loc12_ = 2;
         }
         else if(_isGuide)
         {
            _loc12_ = 3;
         }
         else
         {
            _loc12_ = 1;
         }
         _chatBalloon = GETDEFINITIONBYNAME("ChatBalloonAsset",false);
         _chatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,_loc12_,RoomManagerWorld.instance.layerManager.bkg.scaleX,SBTextField,onChatBallonAdventureDown,onChatBalloonPVPDown);
         _chatLayer.addChild(_chatBalloon);
         _moving = 0;
         _lastMoveAngle = 2;
         _lastIdleAnim = getBaseIdle();
         _lastIdleFlip = false;
         setNamebarListenersWithUserName(param1.userName);
         toggleNamebarSelNub(param8);
         _namebar.setColorAndBadge(param8);
         var _loc11_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(userName);
         if(_loc11_)
         {
            _namebar.isHostingCustomParty = _loc11_.isStillHosting;
         }
         _layerAnim = LayerAnim.getNew();
         _layerAnim.avDefId = param1.avTypeId;
         if(param1.colors)
         {
            _layerAnim.layers = setLayerHelper();
         }
         _layerAnim.local = userId == AvatarManager.playerSfsUserId;
         var _loc10_:LayerBitmap = _layerAnim.bitmap;
         _loc10_.x = 0;
         _loc10_.y = 0;
         _glow = new GlowFilter(0,1,4,4,4);
         _layerAnim.bitmap.filters = [_glow];
         setBlendColor();
         _splash = new AvatarViewExt_Splash(this,_loc10_);
         if(_roomType == 1)
         {
            _splash.showShadow(false);
         }
         if(userId == AvatarManager.playerSfsUserId || gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom())
         {
            _namebar.mouseChildren = false;
            _namebar.mouseEnabled = false;
            _chatBalloon.mouseChildren = false;
            _chatBalloon.mouseEnabled = false;
         }
         if(shouldShowOffscreen() && AvatarManager.getViewHudMCBySfsId(userId))
         {
            _hudViewHolder = AvatarManager.getViewHudMCBySfsId(userId);
            if(_hudViewHolder)
            {
               if(_flashTimer)
               {
                  _flashTimer.reset();
               }
               _flashTimer = new Timer(2500);
               _flashTimer.addEventListener("timer",onFlashTimer,false,0,true);
               _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
            }
         }
         _shouldShowPetOnly = GuiManager.isBeYourPetRoom();
         if(_shouldShowPetOnly)
         {
            _layerAnim.alpha = 0;
            _layerAnim.avatarEnabled = false;
         }
         else
         {
            _layerAnim.alpha = 1;
            _namebar.setAvName(param1,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),gMainFrame.userInfo.getUserInfoByUserName(param1.userName));
            _layerAnim.avatarEnabled = true;
            _timeSinceLastParticle = -1;
            _particleOffset = 1;
            setupParticles();
         }
         _bInSplashVolume = false;
         _isLoadingEmoteId = -1;
         _jumpVel = 0;
         _jumpTimer = 0;
         _jumpEnableTimer = 0;
         _splashTimer = 0;
         _resolveUpResult = {};
         _bJumpEnabled = true;
         _commandQueue = [];
         _leapState = -1;
         _bArrowEnabled = true;
      }
      
      override public function destroy(param1:Boolean = false) : void
      {
         QuestManager.removeTorch(this);
         _bArrowEnabled = false;
         if(parent)
         {
            parent.removeChild(this);
         }
         if(param1 && _avatar)
         {
            _avatar.destroy();
            _avatar = null;
         }
         if(_sideScrollArrow != null)
         {
            if(_sideScrollArrow.parent != null)
            {
               _sideScrollArrow.parent.removeChild(_sideScrollArrow);
            }
            _sideScrollArrow = null;
         }
         var _loc2_:LayerBitmap = _layerAnim.bitmap;
         removeChild(_loc2_);
         _loc2_.filters = null;
         super.destroy();
         if(_chatBalloon && _chatBalloon.parent == _chatLayer)
         {
            _chatLayer.removeChild(_chatBalloon);
         }
         removeChild(_namebar);
         if(_secondaryEmot && _chatLayer.contains(_secondaryEmot))
         {
            _chatLayer.removeChild(_secondaryEmot);
         }
         _splash.destroy();
         if(_particleIdling)
         {
            clearSpecialPattern();
         }
         removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar.removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar["selnub"].removeEventListener("mouseDown",namebarAndAvatarDownHandler);
         _namebar.removeEventListener("mouseDown",ownNamebarDownHandler);
         _chatBalloon = null;
         if(_namebar)
         {
            _namebar.destroy();
         }
         _namebar = null;
         avTypeChangedCallback = null;
         onAvatarChangedCallback = null;
         _slidePositions = null;
         _glow = null;
         if(_flashTimer)
         {
            _flashTimer.reset();
            _flashTimer.removeEventListener("timer",onFlashTimer);
            _flashTimer = null;
            if(_hudViewHolder)
            {
               _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
            }
         }
         if(_hudAvtOrPetView)
         {
            _hudAvtOrPetView.destroy();
            _hudAvtOrPetView = null;
         }
         if(_avSwitchedNPC)
         {
            _avSwitchedNPC.destroy();
            _avSwitchedNPC = null;
         }
         _hudViewHolder = null;
         _isCurrentlySwitching = false;
      }
      
      public function get radius() : Number
      {
         return _radius;
      }
      
      public function get attachmentVisible() : Boolean
      {
         return _secondaryEmot == null;
      }
      
      public function get moving() : Boolean
      {
         return _moving == 1 || _slideCurrentPosition >= 0;
      }
      
      public function get hFlip() : Boolean
      {
         return _layerAnim.hFlip;
      }
      
      public function get lastIdleAnim() : int
      {
         return _lastIdleAnim;
      }
      
      public function get lastIdleFlip() : Boolean
      {
         return _lastIdleFlip;
      }
      
      public function get splashLiquid() : String
      {
         return _splashLiquid;
      }
      
      public function get roomType() : int
      {
         return _roomType;
      }
      
      public function set roomType(param1:int) : void
      {
         _roomType = param1;
      }
      
      public function get isPhantom() : Boolean
      {
         if(_layerAnim != null && _avSwitchedNPC != null)
         {
            return _avSwitchedNPC != null && !_layerAnim.visible;
         }
         return false;
      }
      
      public function set deleteOnMoveComplete(param1:Boolean) : void
      {
         _deleteOnMoveComplete = param1;
      }
      
      public function get currentLevel() : int
      {
         if(_namebar)
         {
            return _namebar.currentLevel;
         }
         return 0;
      }
      
      public function isThisAttachmentOn(param1:int) : Boolean
      {
         if(_secondaryEmot == null)
         {
            return false;
         }
         if(_avAttMediaId == param1)
         {
            return true;
         }
         return false;
      }
      
      public function getBaseIdle() : int
      {
         return _roomType == 1 ? 32 : 14;
      }
      
      public function setPath(param1:Array) : void
      {
         _followPath = param1;
         if(_slideCurrentPosition == -1)
         {
            _moving = -1;
            followPath();
         }
      }
      
      public function get avatarPos() : Point
      {
         return _pos;
      }
      
      public function setPos(param1:Number, param2:Number, param3:Boolean, param4:Boolean = true) : void
      {
         var _loc5_:Number = NaN;
         if(param4)
         {
            _followPath = null;
         }
         if(param3)
         {
            _dirX = param1 - _pos.x;
            _dirY = param2 - _pos.y;
            _loc5_ = Math.sqrt(_dirX * _dirX + _dirY * _dirY);
            if(_loc5_)
            {
               _dirX /= _loc5_ * _scale.x;
               _dirY /= _loc5_ * _scale.y;
            }
            faceAnim(_dirX,_dirY,true);
            _moving = 1;
            _moveToX = param1;
            _moveToY = param2;
         }
         else
         {
            _dirX = 0;
            _dirY = 0;
            updatePos(param1,param2);
         }
      }
      
      public function get currAvatar() : Avatar
      {
         return _avatar;
      }
      
      public function get nameBar() : NameBar
      {
         return _namebar;
      }
      
      public function get nameBarIconIds() : Array
      {
         return _namebar.iconIds;
      }
      
      public function get xpShapeIcons() : Object
      {
         return _namebar.xpShapeIcons;
      }
      
      public function get isCurrentlySwitching() : Boolean
      {
         return _isCurrentlySwitching;
      }
      
      public function set isCurrentlySwitching(param1:Boolean) : void
      {
         _isCurrentlySwitching = param1;
      }
      
      public function setSplashVolumeVolume(param1:Object) : void
      {
         if(param1)
         {
            setSplashVolume(true,param1.message);
            _splashVol = param1;
         }
         else
         {
            setSplashVolume(false,"");
         }
      }
      
      public function setSplashVolume(param1:Boolean, param2:String) : void
      {
         switch(param2)
         {
            case "treeleaves":
            case "phntmtreeleaves":
               break;
            default:
               _bInSplashVolume = param1;
               _splashLiquid = param2;
         }
      }
      
      public function setAvatarMode(param1:int) : void
      {
         switch(param1 - 1)
         {
            case 0:
               _layerAnim.bitmap.filters = null;
               if(_splash)
               {
                  _splash.showShadow(false);
               }
               if(_namebar != null)
               {
                  _namebar.visible = false;
                  break;
               }
         }
      }
      
      public function setupParticles() : void
      {
         var _loc1_:CustomAvatarDef = _avatar.customAvId != -1 ? gMainFrame.userInfo.getAvatarDefByAvatar(_avatar) as CustomAvatarDef : null;
         if(_loc1_ == null || _loc1_.patternRefIds.length == 1)
         {
            _emitParticles = _avatar.colors && _avatar.customAvId != -1;
         }
         else
         {
            _emitParticles = false;
         }
         updateSpecialPatternColors();
         clearSpecialPattern();
      }
      
      public function clearSpecialPattern() : void
      {
         var _loc1_:Loader = null;
         if(_particleIdling)
         {
            _loc1_ = _particleIdling.getChildAt(0) as Loader;
            if(_loc1_.content)
            {
               (_loc1_.content as MovieClip).readyToUse = true;
            }
            if(_particleIdling.parent)
            {
               _particleIdling.parent.removeChild(_particleIdling);
            }
            _particleIdling = null;
         }
      }
      
      public function updateSpecialPatternColors() : void
      {
         if(_avatar && _avatar.colors)
         {
            _currSpecialPatternColors = PaletteHelper.getHexColorsFromPalette(_avatar.colors[1]);
         }
      }
      
      public function updateSpecialPatternColorsAndApply() : void
      {
         var _loc1_:Loader = null;
         if(_avatar && _avatar.colors)
         {
            _currSpecialPatternColors = PaletteHelper.getHexColorsFromPalette(_avatar.colors[1]);
            if(_particleIdling)
            {
               _loc1_ = _particleIdling.getChildAt(0) as Loader;
               setupSpecialPattern(_loc1_.content as MovieClip);
            }
         }
      }
      
      public function updateNameBarLevelShape(param1:int) : void
      {
         var _loc3_:UserInfo = null;
         var _loc2_:Boolean = false;
         if(_namebar != null)
         {
            if(_shouldShowPetOnly)
            {
               param1 = 0;
               _namebar.removeShape();
            }
            else
            {
               _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
               _loc2_ = (gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8) && !QuestManager.isQuestLikeNormalRoom();
               if(_loc3_ || _loc2_)
               {
                  _namebar.setColorBadgeAndXp(!!_loc3_ ? _loc3_.nameBarData : 0,param1,_isMember,_loc2_);
               }
            }
         }
      }
      
      public function updateNameBarHealth(param1:int) : void
      {
         if(_namebar != null)
         {
            _namebar.updateMeter(param1);
         }
      }
      
      public function getNameBarHealthPercentage() : int
      {
         if(_namebar != null)
         {
            return _namebar.getMeterValue();
         }
         return 100;
      }
      
      public function setBlendColor(param1:uint = 0, param2:uint = 4294967295, param3:Boolean = false) : void
      {
         var _loc4_:Array = null;
         if(_layerAnim == null || _layerAnim.bitmap == null)
         {
            return;
         }
         if(param2 == 4294967295)
         {
            if(param1 == 0 || param3)
            {
               param2 = uint(_roomType == 0 ? 5586479 : 2775381);
            }
            else
            {
               param2 = uint(param1 & 0xFFFFFF);
            }
         }
         if(_layerAnim.bitmap.filters != null && _layerAnim.bitmap.filters[0].color != param2)
         {
            _loc4_ = _layerAnim.bitmap.filters;
            _loc4_[0].color = param2;
            _layerAnim.bitmap.filters = _loc4_;
         }
         _layerAnim.bitmap.setBlendColor(param1);
      }
      
      public function setAlphaLevel(param1:int) : void
      {
         if(gMainFrame.clientInfo.invisMode && userId == AvatarManager.playerSfsUserId)
         {
            param1 = 50;
         }
         this.alpha = param1 / 100;
      }
      
      public function isSameMessage(param1:String) : Boolean
      {
         if(_chatBalloon)
         {
            if(_chatBalloon.visible)
            {
               return _chatBalloon.msgTxt.text == param1;
            }
         }
         return false;
      }
      
      public function setMessage(param1:String, param2:int) : void
      {
         var _loc3_:Boolean = false;
         if(param2 > 1)
         {
            if(param2 == 2)
            {
               param1 = LocalizationManager.translateIdOnly(int(param1.split("|")[0]));
            }
            _loc3_ = true;
         }
         _chatBalloon.setText(param1,_loc3_);
         updateOffScreenChat(param1,_loc3_);
      }
      
      public function setCustomAdventureMessage(param1:String, param2:String, param3:int, param4:int, param5:Boolean = false) : void
      {
         var _loc6_:Boolean = false;
         if(gMainFrame.userInfo.isModerator && param4 > 1)
         {
            _loc6_ = true;
         }
         _chatBalloon.setCustomAdventureMessage(param1,param2,param3,_loc6_,param5);
         if(_chatBalloon.visible && _chatBalloon.isPvpCustom)
         {
            loadCustomPVPImage(_chatBalloon.pvpGameId);
         }
      }
      
      public function loadSideScrollArrow() : void
      {
         if(_sideScrollArrow == null)
         {
            _sideScrollArrowLoader = new MediaHelper();
            _sideScrollArrowLoader.init(4903,onSideScrollArrowLoaded);
         }
         else
         {
            onSideScrollArrowLoaded(_sideScrollArrow);
         }
      }
      
      public function setAvatarAsPhantom(param1:Boolean) : void
      {
         if(param1)
         {
            hideAvatar();
            if(_avSwitchedNPC == null)
            {
               _avSwitchedNPC = new NPCView();
               _avSwitchedNPC.init(2,0,-1,0,false,onNpcLoaded);
            }
            _avSwitchedNPC.x = x;
            _avSwitchedNPC.y = y;
            _avSwitchedNPC.visible = true;
            this.parent.addChild(_avSwitchedNPC);
         }
         else
         {
            showAvatar();
            if(_avSwitchedNPC && _avSwitchedNPC.parent)
            {
               _avSwitchedNPC.visible = false;
               this.parent.removeChild(_avSwitchedNPC);
            }
         }
      }
      
      public function onNpcLoaded() : void
      {
         if(_avSwitchedNPC != null)
         {
            _avSwitchedNPC.x = x;
            _avSwitchedNPC.y = y;
            _avSwitchedNPC.getNpcMC().setVision(0);
            _avSwitchedNPC.setNpcState(0);
         }
      }
      
      private function onSideScrollArrowLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_sideScrollArrowLoader)
            {
               _sideScrollArrowLoader.destroy();
               _sideScrollArrowLoader = null;
            }
            _sideScrollArrow = param1;
            RoomManagerWorld.instance.layerManager.room_orbs.addChild(_sideScrollArrow);
            _sideScrollArrow.scaleY = 0.7;
            _sideScrollArrow.scaleX = 0.7;
            _sideScrollArrow.arrowDistance(100);
            _sideScrollArrow.visible = false;
            _sideScrollArrow.mouseChildren = false;
            _sideScrollArrow.mouseEnabled = false;
         }
      }
      
      private function loadCustomPVPImage(param1:int) : void
      {
         var _loc2_:MinigameInfo = null;
         if(param1 != 0)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(param1);
            _customPVPImageLoader = new MediaHelper();
            _customPVPImageLoader.init(_loc2_.gameLibraryIconMediaId,onCustomPVPImageLoaded);
         }
      }
      
      private function onCustomPVPImageLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_customPVPImageLoader)
            {
               _customPVPImageLoader.destroy();
               _customPVPImageLoader = null;
            }
            if(_chatBalloon)
            {
               _chatBalloon.setCustomPVPImage(param1);
            }
         }
      }
      
      public function setEmote(param1:Sprite, param2:int = -1) : void
      {
         if(param1 || param2 >= 0)
         {
            _chatBalloon.setEmote(param1,param2);
         }
         else
         {
            _chatBalloon.setReadyForClear();
         }
      }
      
      public function setChatBalloonReadyForClear() : void
      {
         _chatBalloon.setReadyForClear();
      }
      
      public function updateChatBallonBgOffsets() : void
      {
         _chatBalloon.updateEmoteBgOffsets();
      }
      
      public function getPermEmoteId() : int
      {
         if(_chatBalloon)
         {
            return _chatBalloon.perEmoteMediaId;
         }
         return -1;
      }
      
      public function setAction(param1:Sprite) : void
      {
         var _loc3_:int = 0;
         if(!_actionMgr)
         {
            return;
         }
         _lastIdleAnim = getBaseIdle();
         _lastIdleFlip = false;
         var _loc2_:String = _actionMgr.getActionString(param1);
         for each(var _loc4_ in _actionLookup)
         {
            if(_loc4_.name == _loc2_)
            {
               _loc3_ = int(_roomType == 0 ? _loc4_.land : _loc4_.water);
               if(_loc3_ > 0)
               {
                  _lastIdleAnim = _loc3_;
                  _lastIdleFlip = _loc4_.flip;
                  playAnim(_loc3_,_loc4_.flip);
               }
               break;
            }
         }
         if(_pet && _loc2_)
         {
            _pet.setActionByName(_loc2_);
         }
      }
      
      public function circleTest(param1:int, param2:int, param3:int) : Boolean
      {
         return Collision.circleHitCircle(new Point(param1,param2),param3,new Point(_pos.x,_pos.y),_radius);
      }
      
      public function bmpDataHitTest(param1:BitmapData, param2:Point) : Boolean
      {
         return param1.hitTest(new Point(_pos.x,_pos.y),255,param1,param2,255);
      }
      
      public function moveToFront() : void
      {
         if(!parent || !_chatLayer)
         {
            return;
         }
         parent.setChildIndex(this,parent.numChildren - 1);
         if(_chatBalloon.parent == _chatLayer)
         {
            _chatLayer.setChildIndex(_chatBalloon,_chatLayer.numChildren - 1);
         }
         if(_secondaryEmot)
         {
            if(_secondaryEmot.parent == _chatLayer)
            {
               _chatLayer.setChildIndex(_secondaryEmot,_chatLayer.numChildren - 1);
            }
            _secondaryEmot.scaleY = 1;
            _secondaryEmot.scaleX = 1;
         }
      }
      
      public function setAvAttachment(param1:int, param2:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:FrameLabel = null;
         _avAttMediaId = param1;
         if(param1 == 0)
         {
            if(_secondaryEmot && _isLoadingEmoteId == -1)
            {
               _secondaryEmot.attachment.gotoAndPlay("_hide");
               if(_secondaryEmot["getAttachedSound"] && _secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
         }
         else
         {
            if(_secondaryEmot && _isLoadingEmoteId == -1 && _secondaryEmot.id != param1)
            {
               _secondaryEmot.attachment.gotoAndPlay("_hide");
               if(_secondaryEmot["getAttachedSound"] && _secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.stopItemEmoticonSound(this);
               }
            }
            if(_secondaryEmot != null && (_secondaryEmot.id == param1 && _avAttachmentExtra == param2) || _isLoadingEmoteId == param1)
            {
               if(_secondaryEmot && _secondaryEmot.attachment)
               {
                  _loc4_ = int(_secondaryEmot.attachment.currentLabels.length);
                  _loc3_;
                  while(_loc3_ < _loc4_)
                  {
                     _loc5_ = _secondaryEmot.attachment.currentLabels[_loc3_];
                     if(_loc5_.name == "_main")
                     {
                        _secondaryEmot.attachment.gotoAndStop("_main");
                        return;
                     }
                     _loc3_++;
                  }
                  _secondaryEmot.attachment.gotoAndStop("_show");
               }
               return;
            }
            _avAttachmentExtra = param2;
            _isLoadingEmoteId = param1;
            if(!_avAttMediaHelper)
            {
               _avAttMediaHelper = new MediaHelper();
            }
            _avAttMediaHelper.init(param1,onAttachLoaded);
         }
      }
      
      private function setOffScreenAvAttachment(param1:MovieClip, param2:int) : void
      {
         var _loc3_:MovieClip = AvatarManager.getOffScreenAttachmentBySfsId(param2);
         var _loc4_:int = int(param1.attachmentId);
         if(_loc4_ == 0)
         {
            if(_loc3_)
            {
               if(_loc3_.attachment.currentFrameLabel == "_gone")
               {
                  while(param1.charLayer.numChildren > 0)
                  {
                     param1.charLayer.removeChildAt(0);
                  }
                  if(param1.avtView)
                  {
                     param1.charLayer.addChild(param1.avtView);
                  }
               }
               else
               {
                  _loc3_.attachment.gotoAndPlay("_hide");
               }
               AvatarManager.setOffScreenAttachmentBySfsId(param2,_loc3_);
            }
            else if(param1.avtView && !param1.charLayer.contains(param1.avtView))
            {
               param1.charLayer.addChild(param1.avtView);
            }
         }
         else
         {
            if(_loc3_ != null && (_loc3_.id == _loc4_ || _loc3_.isLoadingEmoteId == _loc4_))
            {
               if(!param1.charLayer.contains(_loc3_))
               {
                  while(param1.charLayer.numChildren > 0)
                  {
                     param1.charLayer.removeChildAt(0);
                  }
                  param1.charLayer.addChild(_loc3_);
               }
               return;
            }
            param1.isLoadingEmoteId = _loc4_;
            AvatarManager.setViewHudMCBySfsId(param2,param1);
            if(!_avOffscreenMediaHelper)
            {
               _avOffscreenMediaHelper = new MediaHelper();
            }
            _avOffscreenMediaHelper.init(_loc4_,onOffscreenAttachLoaded,{
               "offscreenMC":param1,
               "sfsId":param2
            });
         }
      }
      
      private function onOffscreenAttachLoaded(param1:MovieClip) : void
      {
         var _loc3_:* = null;
         var _loc2_:MovieClip = param1.passback.offscreenMC;
         if(param1 && param1.hasOwnProperty("attachment"))
         {
            while(_loc2_.charLayer.numChildren > 0)
            {
               _loc2_.charLayer.removeChildAt(0);
            }
            _loc3_ = param1;
            _loc3_.id = _loc2_.isLoadingEmoteId;
            _loc2_.charLayer.addChild(_loc3_);
            _loc3_.scaleY = 0.5;
            _loc3_.scaleX = 0.5;
            _loc3_.x = -355 * _loc3_.scaleX;
            _loc3_.y = -235 * _loc3_.scaleX;
            _loc3_.attachment.gotoAndPlay("_show");
            AvatarManager.setOffScreenAttachmentBySfsId(param1.passback.sfsId,_loc3_);
         }
      }
      
      private function onAttachLoaded(param1:MovieClip) : void
      {
         if(param1 && param1.hasOwnProperty("attachment") && _avAttMediaId)
         {
            if(_avAttachmentExtra && _avAttachmentExtra.length)
            {
               param1.setState(_avAttachmentExtra);
            }
            if(_chatLayer)
            {
               if(_secondaryEmot && _chatLayer.contains(_secondaryEmot))
               {
                  _chatLayer.removeChild(_secondaryEmot);
               }
               _secondaryEmot = param1;
               _secondaryEmot.id = _isLoadingEmoteId;
               if(isOffScreen)
               {
                  if(_hudViewHolder.charLayer.contains(_hudAvtOrPetView))
                  {
                     _hudViewHolder.charLayer.removeChild(_hudAvtOrPetView);
                  }
                  _hudViewHolder.charLayer.addChild(_secondaryEmot);
                  updateSecondaryEmoteOffScreenPosition();
                  _secondaryEmot.lastKnownX = this.x + -310;
                  _secondaryEmot.lastKnownY = this.y + -320;
               }
               else
               {
                  _secondaryEmot.x = this.x + -310;
                  _secondaryEmot.y = this.y + -320;
                  _secondaryEmot.scaleY = 1;
                  _secondaryEmot.scaleX = 1;
                  _chatLayer.addChild(_secondaryEmot);
               }
               _secondaryEmot.attachment.gotoAndPlay("_show");
               if(_secondaryEmot["getAttachedSound"] && _secondaryEmot.getAttachedSound() != null)
               {
                  QuestManager.playItemEmoticonSound(this,_secondaryEmot.getAttachedSound());
               }
            }
         }
         _isLoadingEmoteId = -1;
      }
      
      public function checkSelnub(param1:MouseEvent) : void
      {
         var _loc2_:Number = Point.distance(this.localToGlobal(new Point(0,0)),new Point(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY));
         if(_loc2_ < 150)
         {
            overHandler(param1);
         }
         else
         {
            outHandler(param1);
         }
      }
      
      public function heartbeat(param1:int, param2:int) : Boolean
      {
         var _loc13_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc11_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc9_:Loader = null;
         var _loc6_:Loader = null;
         var _loc14_:UserInfo = null;
         if(_slideCurrentPosition >= 0)
         {
            updateSlide(param1);
         }
         _frameTime = param2 / 1000;
         _timeSinceLastHostingUpdate += _frameTime;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         var _loc5_:Number = 1;
         if(QuestManager.isSideScrollQuest())
         {
            _loc5_ = 32 / 24;
         }
         _splash.heartbeat(_bInSplashVolume,isSplashAnim(),_splashLiquid,avatarData != null && Utility.isAir(avatarData.enviroTypeFlag));
         if(!_bInSplashVolume && _emitParticles)
         {
            if(_moving == 1)
            {
               if(_particleIdling)
               {
                  _particleIdling.visible = false;
               }
               _loc13_ = true;
               _loc3_ = _loc13_ ? 0.1 : 0.05;
               if(_timeSinceLastParticle < 0 || _timeSinceLastParticle > _loc3_)
               {
                  _loc11_ = AvatarManager.getFlower();
                  if(_loc13_)
                  {
                     _loc11_.x = x - 20;
                     _loc11_.y = y;
                     _loc11_.scaleX = 0.22;
                     _loc11_.scaleY = 0.13;
                     if(_lastParticleLoc)
                     {
                        _lastParticleLoc.x = _loc11_.x - _lastParticleLoc.x;
                        _lastParticleLoc.y = _loc11_.y - _lastParticleLoc.y;
                        _lastParticleLoc.normalize(1);
                        _loc4_ = 5;
                        _loc11_.x -= _loc4_ * _particleOffset * _lastParticleLoc.y;
                        _loc11_.y += _loc4_ * _particleOffset * _lastParticleLoc.x;
                        _particleOffset *= -1;
                        _lastParticleLoc.x = x - 20;
                        _lastParticleLoc.y = y;
                     }
                     else
                     {
                        _loc11_.visible = false;
                        _lastParticleLoc = new Point(_loc11_.x,_loc11_.y);
                     }
                  }
                  else
                  {
                     _loc11_.x = x - 55;
                     _loc11_.y = y - 80;
                     _loc11_.scaleX = _loc11_.scaleY = 0.5;
                  }
                  _loc9_ = _loc11_.getChildAt(0) as Loader;
                  if(_loc9_.content == null)
                  {
                     _loc9_.contentLoaderInfo.addEventListener("complete",flowerLoaderComplete);
                  }
                  else
                  {
                     resetFlower(_loc9_.content as MovieClip);
                  }
                  _timeSinceLastParticle = 0;
               }
               _timeSinceLastParticle += _frameTime;
            }
            else
            {
               if(_particleIdling)
               {
                  if(!_particleIdling.visible)
                  {
                     _particleIdling.visible = true;
                     _loc6_ = _particleIdling.getChildAt(0) as Loader;
                     switch(avTypeId)
                     {
                        case 30:
                           (_loc6_.content as MovieClip).setState(10);
                           break;
                        case 25:
                           (_loc6_.content as MovieClip).setState(9);
                           break;
                        case 44:
                           (_loc6_.content as MovieClip).setState(8);
                           break;
                        case 35:
                           (_loc6_.content as MovieClip).setState(7);
                           break;
                        case 3:
                           (_loc6_.content as MovieClip).setState(6);
                           break;
                        case 29:
                           (_loc6_.content as MovieClip).setState(5);
                           break;
                        case 42:
                           (_loc6_.content as MovieClip).setState(4);
                           break;
                        case 2:
                           (_loc6_.content as MovieClip).setState(3);
                           break;
                        case 33:
                           (_loc6_.content as MovieClip).setState(2);
                           break;
                        case 28:
                           (_loc6_.content as MovieClip).setState(1);
                           break;
                        default:
                           (_loc6_.content as MovieClip).setState(0);
                     }
                  }
               }
               else
               {
                  _particleIdling = AvatarManager.getFlower(true);
                  if(_particleIdling.parent == null || _particleIdling.parent != this)
                  {
                     this.addChildAt(_particleIdling,0);
                  }
                  _loc6_ = _particleIdling.getChildAt(0) as Loader;
                  if(_loc6_.content)
                  {
                     setupSpecialPattern(_loc6_.content as MovieClip);
                  }
                  else
                  {
                     _loc6_.contentLoaderInfo.addEventListener("complete",flowerIdleLoaderComplete);
                  }
               }
               _particleIdling.x = -30;
               _particleIdling.y = -15;
            }
         }
         if(QuestManager.isSideScrollQuest())
         {
            if(_currentCommand == null && _commandQueue.length > 0)
            {
               _currentCommand = _commandQueue.shift();
            }
            if(_currentCommand && _currentCommand[0] == "qssau")
            {
               sideScrollMovement(null,false,false,false,false);
            }
         }
         var _loc7_:Number = _pos.x;
         var _loc8_:Number = _pos.y;
         var _loc16_:Number = _dirX * 24 * _loc5_ * _frameTime / 0.07;
         var _loc15_:Number = _dirY * 24 * _loc5_ * _frameTime / 0.07;
         if(_dirX || _dirY)
         {
            checkSelnub(null);
         }
         if(_loc16_)
         {
            if(_loc16_ > 0 && _loc16_ + _pos.x >= _moveToX || _loc16_ < 0 && _loc16_ + _pos.x <= _moveToX)
            {
               _dirX = 0;
               _loc7_ = _moveToX;
            }
            else
            {
               _loc7_ += _loc16_;
            }
         }
         if(_loc15_)
         {
            if(_loc15_ > 0 && _loc15_ + _pos.y >= _moveToY || _loc15_ < 0 && _loc15_ + _pos.y <= _moveToY || QuestManager.isSideScrollQuest())
            {
               _dirY = 0;
               _loc8_ = _moveToY;
            }
            else
            {
               _loc8_ += _loc15_;
            }
         }
         if(_loc7_ != _pos.x || _loc8_ != _pos.y || shouldShowOffscreen())
         {
            _numFramesForOffscreen++;
            if(!(QuestManager.isSideScrollQuest() && userId == AvatarManager.playerSfsUserId))
            {
               updatePos(_loc7_,_loc8_);
            }
         }
         _chatBalloon.heartbeat(param1);
         offScreenChatHeartbeat(param1);
         if(_secondaryEmot && _secondaryEmot.attachment)
         {
            if(_secondaryEmot.attachment.currentFrameLabel == "_gone")
            {
               if(_secondaryEmot.parent && (_secondaryEmot.parent is MovieClip || _secondaryEmot.parent is DisplayLayer))
               {
                  _secondaryEmot.parent.removeChild(_secondaryEmot);
               }
               _secondaryEmot = null;
            }
            else if(isOffScreen && _numFramesForOffscreen >= 48)
            {
               if(_hudViewHolder.charLayer.contains(_hudAvtOrPetView))
               {
                  while(_hudViewHolder.charLayer.numChildren > 0)
                  {
                     _hudViewHolder.charLayer.removeChildAt(0);
                  }
                  updateSecondaryEmoteOffScreenPosition();
                  _hudViewHolder.charLayer.addChild(_secondaryEmot);
               }
               else if(_hudViewHolder.charLayer.contains(_secondaryEmot))
               {
                  while(_hudViewHolder.charLayer.numChildren > 0)
                  {
                     _hudViewHolder.charLayer.removeChildAt(0);
                  }
                  _hudViewHolder.charLayer.addChild(_hudAvtOrPetView);
               }
            }
         }
         else if(_hudViewHolder && _hudAvtOrPetView && !_hudViewHolder.charLayer.contains(_hudAvtOrPetView))
         {
            while(_hudViewHolder.charLayer.numChildren > 0)
            {
               _hudViewHolder.charLayer.removeChildAt(0);
            }
            _hudViewHolder.charLayer.addChild(_hudAvtOrPetView);
         }
         if(_numFramesForOffscreen >= 48)
         {
            _numFramesForOffscreen = 0;
         }
         if(!_dirX && !_dirY)
         {
            if(_deleteOnMoveComplete)
            {
               return false;
            }
            switch(_moving - -1)
            {
               case 0:
                  playAnim(_lastIdleAnim,_lastIdleFlip);
                  if(_avSwitchedNPC != null)
                  {
                     _avSwitchedNPC.setNpcState(0,!_lastIdleFlip ? 90 : 270);
                  }
                  _moving = 0;
                  if(isSelf)
                  {
                     RoomManagerWorld.instance.resetThrottle();
                  }
                  break;
               case 2:
                  if(_followPath)
                  {
                     followPath();
                  }
                  else if(_layerAnim.bounceEnabled)
                  {
                     if(isSelf)
                     {
                        RoomManagerWorld.instance.resetThrottle();
                        _moving = 0;
                     }
                  }
                  else
                  {
                     _moving = -1;
                  }
                  if(_moving && _avSwitchedNPC)
                  {
                     _avSwitchedNPC.setNpcState(1,!_lastIdleFlip ? 90 : 270);
                     break;
                  }
            }
         }
         if(_pet)
         {
            _pet.heartbeat(_layerAnim.bounceOffSet,_moving);
         }
         if(_timeSinceLastHostingUpdate >= 10)
         {
            _loc14_ = gMainFrame.userInfo.getUserInfoByUserName(userName);
            if(_loc14_)
            {
               _namebar.isHostingCustomParty = _loc14_.isStillHosting;
            }
            _timeSinceLastHostingUpdate = 0;
         }
         return true;
      }
      
      public function setMoving(param1:int) : void
      {
         _moving = param1;
      }
      
      private function setupSpecialPattern(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_currSpecialPatternColors == null)
            {
               updateSpecialPatternColors();
            }
            switch(avTypeId)
            {
               case 30:
                  param1.setState(10);
                  break;
               case 25:
                  param1.setState(9);
                  break;
               case 44:
                  param1.setState(8);
                  break;
               case 35:
                  param1.setState(7);
                  break;
               case 3:
                  param1.setState(6);
                  break;
               case 29:
                  param1.setState(5);
                  break;
               case 42:
                  param1.setState(4);
                  break;
               case 2:
                  param1.setState(3);
                  break;
               case 33:
                  param1.setState(2);
                  break;
               case 28:
                  param1.setState(1);
                  break;
               default:
                  param1.setState(0);
            }
            param1.setColors(_currSpecialPatternColors);
            param1.readyToUse = false;
         }
      }
      
      private function setupJumpLand(param1:MovieClip, param2:String) : void
      {
         if(param1)
         {
            param1.setType(param2);
            param1.readyToUse = false;
         }
      }
      
      private function jumpLandLoaderComplete(param1:Event) : void
      {
         setupJumpLand(param1.target.content,_jumpLandType);
      }
      
      private function flowerIdleLoaderComplete(param1:Event) : void
      {
         setupSpecialPattern(param1.target.content);
      }
      
      private function flowerLoaderComplete(param1:Event) : void
      {
         resetFlower(param1.target.content);
      }
      
      private function resetFlower(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_currSpecialPatternColors == null)
            {
               updateSpecialPatternColors();
            }
            switch(avTypeId)
            {
               case 30:
                  param1.setState(10);
                  break;
               case 25:
                  param1.setState(9);
                  break;
               case 44:
                  param1.setState(8);
                  break;
               case 35:
                  param1.setState(7);
                  break;
               case 3:
                  param1.setState(6);
                  break;
               case 29:
                  param1.setState(5);
                  break;
               case 42:
                  param1.setState(4);
                  break;
               case 2:
                  param1.setState(3);
                  break;
               case 33:
                  param1.setState(2);
                  break;
               case 28:
                  param1.setState(1);
                  break;
               default:
                  param1.setState(0);
            }
            param1.setColor(_currSpecialPatternColors[_patternIndex]);
            _patternIndex = _patternIndex + 1 == _currSpecialPatternColors.length ? 0 : _patternIndex + 1;
         }
      }
      
      public function playIdle() : void
      {
         _slideCurrentPosition = -1;
         playAnim(getBaseIdle(),_lastIdleFlip);
      }
      
      public function setActivePet(param1:Number, param2:uint, param3:uint, param4:uint, param5:String, param6:int, param7:int, param8:int, param9:int = 0) : void
      {
         if(_pet)
         {
            if(_pet.parent == this)
            {
               this.removeChild(_pet);
            }
            _pet = null;
         }
         if(gMainFrame.clientInfo.roomType != 7 || QuestManager.isQuestLikeNormalRoom() || _shouldShowPetOnly)
         {
            if(param2 != 0 && PetManager.canCurrAvatarUsePet(_avatar.enviroTypeFlag,PetManager.getPetDef(param2 & 0xFF),param1))
            {
               _pet = new WorldPet(this,param1,param2,param3,param4,param6,param8,param7,param9);
            }
            if(_shouldShowPetOnly)
            {
               if(!isActivePetGroundPet())
               {
                  _splash.showShadow(false);
               }
               _currPetName = LocalizationManager.translatePetName(param5);
               _namebar.setAvName(_currPetName);
            }
            else
            {
               _splash.showShadow(true);
            }
         }
      }
      
      public function getActivePet() : WorldPet
      {
         return _pet;
      }
      
      public function isActivePetGroundPet() : Boolean
      {
         if(_pet)
         {
            return _pet.isGround();
         }
         return true;
      }
      
      public function flipSplash(param1:Boolean) : void
      {
         _splash.flipSplash(param1);
      }
      
      public function isSplashAnim() : Boolean
      {
         return !(_layerAnim.animId == 14 || _layerAnim.animId == 16);
      }
      
      public function isPetMovingTest() : Boolean
      {
         return !(_layerAnim.animId == 14 || _layerAnim.animId == 16 || _layerAnim.animId == 3 || _layerAnim.animId == 2 || _layerAnim.animId == 1 || _layerAnim.animId == 4 || _layerAnim.animId == 5 || _layerAnim.animId == 6 || _layerAnim.animId == 22 || _layerAnim.animId == 32 || _layerAnim.animId == 40 || _layerAnim.animId == 33);
      }
      
      public function inSplashVolume() : Boolean
      {
         return _bInSplashVolume;
      }
      
      public function updateIsHostingCustomParty(param1:Boolean) : void
      {
         if(_namebar)
         {
            _namebar.isHostingCustomParty = param1;
         }
      }
      
      private function initNamebar(param1:int) : void
      {
         _isMember = Utility.isMember(param1);
         if(_isMember || _isGuide)
         {
            _namebar = GETDEFINITIONBYNAME("memberNameBar",false);
         }
         else
         {
            _namebar = GETDEFINITIONBYNAME("FreeNameBar",false);
         }
         LocalizationManager.findAllTextfields(_namebar.hostTagMC);
         _timeSinceLastHostingUpdate = 0;
         _namebar.x = -15;
         _namebar.y = 18;
         addChild(_namebar);
      }
      
      private function setNamebarListenersWithUserName(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(param1 != gMainFrame.server.userName || Boolean(gMainFrame.userInfo.isModerator))
         {
            _namebar.addEventListener("mouseDown",namebarAndAvatarDownHandler,false,0,true);
            _namebar["selnub"].addEventListener("mouseDown",namebarAndAvatarDownHandler,false,0,true);
         }
         else
         {
            _namebar.removeListeners();
         }
      }
      
      public function toggleNamebarSelNub(param1:int = -1) : void
      {
         var _loc2_:* = 0;
         if(_isGuide)
         {
            _namebar.setNubType(NameBar.GUIDE);
         }
         else
         {
            if(param1 == -1)
            {
               _loc2_ = _namebar.packedNameBarData;
            }
            else
            {
               _loc2_ = param1;
            }
            if(BuddyManager.isBuddy(_avatar.userName) || isSelf || _isMember && NameBar.isVIPBadge(_loc2_))
            {
               _namebar.setNubType(NameBar.BUDDY);
            }
            else
            {
               _namebar.setNubType(NameBar.NON_BUDDY);
            }
         }
         if(!isSelf)
         {
            if(BuddyManager.isBlocked(_avatar.userName))
            {
               _namebar.isBlocked = true;
            }
            else
            {
               _namebar.isBlocked = false;
            }
         }
         else
         {
            _namebar.isBlocked = false;
         }
      }
      
      private function get isSelf() : Boolean
      {
         if(userName)
         {
            return userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase();
         }
         return false;
      }
      
      private function followPath() : void
      {
         var _loc2_:Object = null;
         var _loc1_:int = int(_followPath.length);
         if(_loc1_)
         {
            _loc2_ = _followPath[0];
            if(_loc1_ > 1)
            {
               _followPath.splice(0,1);
            }
            else
            {
               _followPath = null;
            }
            setPos(_loc2_.x,_loc2_.y,true,false);
         }
      }
      
      private function updatePos(param1:Number, param2:Number) : void
      {
         _pos.x = param1;
         _pos.y = param2;
         param1 *= _scale.x;
         param2 *= _scale.y;
         this.x = param1;
         this.y = param2;
         var _loc3_:Point = AvatarUtility.getAvatarChatOffset(_avatar.avTypeId);
         _chatBalloon.x = this.x + _loc3_.x;
         _chatBalloon.y = this.y + _loc3_.y;
         if(_avSwitchedNPC)
         {
            _avSwitchedNPC.x = param1;
            _avSwitchedNPC.y = param2;
         }
         if(_secondaryEmot)
         {
            if(!isOffScreen)
            {
               _secondaryEmot.x = this.x + -310;
               _secondaryEmot.y = this.y + -320;
            }
            else
            {
               _secondaryEmot.lastKnownX = this.x + -310;
               _secondaryEmot.lastKnownY = this.y + -320;
            }
         }
         if(gMainFrame.userInfo.myUserName != _avatar.userName)
         {
            if(shouldShowOffscreen())
            {
               updateOffScreenPositions();
            }
         }
      }
      
      private function shouldShowOffscreen() : Boolean
      {
         return gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom() || gMainFrame.clientInfo.roomType == 2 && !RoomManagerWorld.instance.inPreviewMode;
      }
      
      private function offScreenDefaultMouseFrameLabel() : String
      {
         if(gMainFrame.clientInfo.roomType == 2)
         {
            return "den";
         }
         return "up";
      }
      
      public function updateOffScreenPositions() : void
      {
         var _loc7_:AvatarInfo = null;
         if(!_hudViewHolder)
         {
            _hudViewHolder = GETDEFINITIONBYNAME("offScreenIconQuest");
            _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
            _hudViewHolder.questChatBalloon.init(_avatar.avTypeId,AvatarUtility.getAvatarEmoteBgOffset,false,7,SBTextField);
            if(_flashTimer)
            {
               _flashTimer.reset();
            }
            _flashTimer = new Timer(2500);
            _flashTimer.addEventListener("timer",onFlashTimer,false,0,true);
            AvatarManager.setViewHudMCBySfsId(userId,_hudViewHolder);
         }
         var _loc3_:RoomManagerWorld = RoomManagerWorld.instance;
         var _loc1_:Number = _loc3_.layerManager.bkg.scaleX;
         var _loc2_:Number = _loc3_.layerManager.bkg.scaleY;
         var _loc6_:Point = _loc3_.convertWorldToScreen(this.x * _loc1_,this.y * _loc2_);
         var _loc5_:Number = _hudViewHolder.mouse.height * 0.5 * _loc1_;
         var _loc4_:Number = _hudViewHolder.mouse.width * 0.5 * _loc2_;
         var _loc8_:Number = 73.5 * _loc2_;
         var _loc9_:Rectangle = new Rectangle(0,0,900 - _loc4_,550 - _loc5_ - _loc8_ + _radius * 2 * _loc1_);
         var _loc10_:Boolean = gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom() ? true : (Utility.isSettingOn(MySettings.SETTINGS_DEN_PLAYER_ICON) ? true : false);
         if(!_loc9_.containsPoint(_loc6_) && _loc10_)
         {
            updateScreenPositionAndDirection(_hudViewHolder,_loc9_,_loc6_);
            if(!isOffScreen)
            {
               if(_hudViewHolder.mouse.currentFrameLabel != offScreenDefaultMouseFrameLabel())
               {
                  _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
               }
               if(GuiManager.isBeYourPetRoom())
               {
                  _loc7_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(userName,perUserAvId);
                  _hudAvtOrPetView = new GuiPet(_loc7_.currPet.createdTs,0,_loc7_.currPet.lBits,_loc7_.currPet.uBits,_loc7_.currPet.eBits,_loc7_.currPet.type,_loc7_.currPet.name,_loc7_.currPet.personalityDefId,_loc7_.currPet.favoriteToyDefId,_loc7_.currPet.favoriteFoodDefId,onHudAvtOrPetView);
               }
               else
               {
                  _hudAvtOrPetView = new AvatarView();
                  (_hudAvtOrPetView as AvatarView).init(_avatar,updateHudViewPosition,onHudViewChanged);
                  _hudAvtOrPetView.playAnim(15,false,1,onHudAvtOrPetView,true);
               }
               this.visible = false;
               isOffScreen = true;
               _hudViewHolder.visible = true;
               if(_chatBalloon.parent == _chatLayer)
               {
                  _chatLayer.removeChild(_chatBalloon);
               }
               if(_secondaryEmot && _secondaryEmot.parent == _chatLayer)
               {
                  _chatLayer.removeChild(_secondaryEmot);
               }
            }
            else
            {
               _hudViewHolder.visible = true;
            }
            if(_hudViewHolder.x != _loc6_.x || _hudViewHolder.y != _loc6_.y)
            {
               _hudViewHolder.x = _loc6_.x;
               _hudViewHolder.y = _loc6_.y;
               if("mainHudIndex" in _hudViewHolder && _hudViewHolder.parent)
               {
                  if(_hudViewHolder.y > 550 * 0.5)
                  {
                     if(GuiManager.guiLayer.numChildren > _hudViewHolder.mainHudIndex + 1)
                     {
                        GuiManager.guiLayer.setChildIndex(_hudViewHolder,_hudViewHolder.mainHudIndex + 1);
                     }
                  }
                  else if(GuiManager.guiLayer.numChildren > _hudViewHolder.mainHudIndex)
                  {
                     GuiManager.guiLayer.setChildIndex(_hudViewHolder,_hudViewHolder.mainHudIndex);
                  }
                  else
                  {
                     GuiManager.guiLayer.setChildIndex(_hudViewHolder,GuiManager.guiLayer.numChildren - 1);
                  }
               }
            }
         }
         else if(isOffScreen || _hudViewHolder.visible)
         {
            if(_hudViewHolder.mouse.currentFrameLabel != offScreenDefaultMouseFrameLabel())
            {
               _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
            }
            if(_hudViewHolder && _hudViewHolder.parent && _hudViewHolder.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_hudViewHolder);
            }
            _hudViewHolder.visible = false;
            isOffScreen = false;
            this.visible = true;
            _chatLayer.addChild(_chatBalloon);
            if(_secondaryEmot)
            {
               _chatLayer.addChild(_secondaryEmot);
               _secondaryEmot.x = _secondaryEmot.lastKnownX;
               _secondaryEmot.y = _secondaryEmot.lastKnownY;
               _secondaryEmot.scaleY = 1;
               _secondaryEmot.scaleX = 1;
            }
            if(lastAnimToHappen != -1)
            {
               playAnim(lastAnimToHappen,_lastIdleFlip);
               lastAnimToHappen = -1;
            }
            else
            {
               playAnim(_lastIdleAnim,_lastIdleFlip);
            }
         }
      }
      
      private function onHudViewChanged(param1:AvatarView) : void
      {
         if(_hudAvtOrPetView)
         {
            _hudAvtOrPetView.playAnim(15,false,1,null,true);
         }
      }
      
      private function onHudAvtOrPetView(param1:Object, param2:Object) : void
      {
         if(_hudViewHolder)
         {
            updateHudViewPosition(null);
            while(_hudViewHolder.charLayer.numChildren > 0)
            {
               _hudViewHolder.charLayer.removeChildAt(0);
            }
            if(param2 && param2 is GuiPet)
            {
               (param2 as GuiPet).animatePet(false);
            }
            if(_hudAvtOrPetView)
            {
               _hudViewHolder.charLayer.addChild(_hudAvtOrPetView);
            }
            _hudViewHolder.mainHudIndex = GuiManager.guiLayer.getChildIndex(GuiManager.mainHud);
            GuiManager.guiLayer.addChildAt(_hudViewHolder,_hudViewHolder.mainHudIndex);
         }
      }
      
      private function updateHudViewPosition(param1:AvatarView) : void
      {
         var _loc2_:Point = null;
         var _loc3_:Number = NaN;
         if(_hudAvtOrPetView)
         {
            if(GuiManager.isBeYourPetRoom())
            {
               _hudAvtOrPetView.y = 15;
            }
            else
            {
               _loc2_ = AvatarUtility.getAvatarHudPosition(_hudAvtOrPetView.avTypeId);
               _hudAvtOrPetView.scaleY = 1;
               _hudAvtOrPetView.scaleX = 1;
               _loc3_ = 41 / _hudAvtOrPetView.width;
               if(_hudAvtOrPetView.height * _loc3_ > 41)
               {
                  _loc3_ = 41 / _hudAvtOrPetView.height;
               }
               _hudAvtOrPetView.scaleX = _loc3_;
               _hudAvtOrPetView.scaleY = _loc3_;
               _hudAvtOrPetView.x = _loc2_.x * _loc3_;
               _hudAvtOrPetView.y = _loc2_.y * _loc3_;
            }
         }
      }
      
      private function updateSecondaryEmoteOffScreenPosition() : void
      {
         _secondaryEmot.scaleY = 1;
         _secondaryEmot.scaleX = 1;
         _secondaryEmot.scaleX = 0.5;
         _secondaryEmot.scaleY = 0.5;
         _secondaryEmot.x = -355 * 0.5;
         _secondaryEmot.y = -235 * 0.5;
      }
      
      private function updateOffScreenChat(param1:String, param2:Boolean) : void
      {
         if(shouldShowOffscreen() && gMainFrame.userInfo.myUserName != _avatar.userName && _hudViewHolder)
         {
            _hudViewHolder.questChatBalloon.setText(param1,param2,false);
         }
      }
      
      private function offScreenChatHeartbeat(param1:int) : void
      {
         if(shouldShowOffscreen() && gMainFrame.userInfo.myUserName != _avatar.userName && _hudViewHolder)
         {
            _hudViewHolder.questChatBalloon.heartbeat(param1);
         }
      }
      
      public function faceAnim(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         if(QuestManager.isSideScrollQuest())
         {
            param2 = 0;
         }
         var _loc7_:Number = Math.atan2(param2,param1);
         _lastMoveAngle = _loc7_;
         var _loc8_:Object = convertToIdle(_lastMoveAngle);
         _lastIdleAnim = _loc8_.anim;
         if(_roomType == 1)
         {
            _lastIdleAnim = getBaseIdle();
         }
         _lastIdleFlip = _loc8_.flip;
         var _loc6_:int = 0;
         var _loc4_:Boolean = false;
         if(_loc7_ >= 5 * 0.6283185307179586 - 0.3141592653589793 || _loc7_ < -5 * 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 2;
            _loc4_ = true;
         }
         else if(_loc7_ >= -4 * 0.6283185307179586 - 0.3141592653589793 && _loc7_ < -4 * 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 1;
            _loc4_ = true;
         }
         else if(_loc7_ >= -3 * 0.6283185307179586 - 0.3141592653589793 && _loc7_ < -3 * 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 0;
            _loc4_ = true;
         }
         else if(_loc7_ >= -2 * 0.6283185307179586 - 0.3141592653589793 && _loc7_ < -2 * 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 0;
         }
         else if(_loc7_ >= -0.6283185307179586 - 0.3141592653589793 && _loc7_ < -0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 1;
         }
         else if(_loc7_ >= -0.3141592653589793 && _loc7_ < 0.3141592653589793)
         {
            _loc6_ = 2;
         }
         else if(_loc7_ >= 0.6283185307179586 - 0.3141592653589793 && _loc7_ < 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 3;
         }
         else if(_loc7_ >= 2 * 0.6283185307179586 - 0.3141592653589793 && _loc7_ < 2 * 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 4;
         }
         else if(_loc7_ >= 3 * 0.6283185307179586 - 0.3141592653589793 && _loc7_ < 3 * 0.6283185307179586 + 0.3141592653589793)
         {
            _loc6_ = 4;
            _loc4_ = true;
         }
         else
         {
            _loc6_ = 3;
            _loc4_ = true;
         }
         var _loc9_:int = 7 + _loc6_;
         if(!param3)
         {
            switch(_loc6_)
            {
               case 0:
               case 1:
                  _loc9_ = 16;
                  break;
               case 2:
               case 3:
               case 4:
                  _loc9_ = 14;
            }
         }
         if(_roomType == 1)
         {
            _loc9_ = 29;
         }
         if(_layerAnim.bounceEnabled)
         {
            _loc9_ = 17;
         }
         playAnim(_loc9_,_loc4_,2);
         if(_avSwitchedNPC != null)
         {
            if(param3)
            {
               _avSwitchedNPC.setNpcState(1,!_loc4_ ? 90 : 270);
            }
            else
            {
               _avSwitchedNPC.setNpcState(0,!_loc4_ ? 90 : 270);
            }
         }
      }
      
      public function updateNameBarName() : void
      {
         if(_namebar)
         {
            _namebar.setAvName(_avatar,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName));
         }
      }
      
      override protected function avatarChanged(param1:AvatarEvent) : void
      {
         var _loc2_:UserInfo = null;
         super.avatarChanged(param1);
         if(_namebar)
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_avatar.userName);
            if(_loc2_ != null)
            {
               toggleNamebarSelNub(_loc2_.nameBarData);
            }
            if(_loc2_ && !_isGuide && !_shouldShowPetOnly)
            {
               _namebar.setColorAndBadge(_loc2_.nameBarData);
               _namebar.setColorBadgeAndXp(_loc2_.nameBarData,gMainFrame.userInfo.getAvatarInfoByUserName(_avatar.userName).questLevel,_isMember,(gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8) && !QuestManager.isQuestLikeNormalRoom());
               _namebar.setAvName(_avatar,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc2_);
            }
            else
            {
               _namebar.setColorAndBadge(0);
               _namebar.setColorBadgeAndXp(0,0,_isMember);
               if(_shouldShowPetOnly && _currPetName)
               {
                  _namebar.setAvName(_currPetName);
               }
               else
               {
                  _namebar.setAvName(_avatar.avName);
               }
            }
            _chatBalloon.avType = _avatar.avTypeId;
         }
         if(_particleIdling)
         {
            updateSpecialPatternColorsAndApply();
         }
      }
      
      public function overHandler(param1:MouseEvent) : void
      {
         _namebar["selnub"].visible = true;
      }
      
      public function outHandler(param1:MouseEvent) : void
      {
         if(_namebar["m"].visible)
         {
            return;
         }
         if(param1 && param1.relatedObject && param1.relatedObject is DisplayObject && _namebar.contains(DisplayObject(param1.relatedObject)))
         {
            return;
         }
         _namebar["selnub"].visible = false;
      }
      
      public function preload(param1:Function) : void
      {
         var _loc2_:Array = [];
         if(_roomType == 1)
         {
            _loc2_.push(29);
            _loc2_.push(32);
         }
         else
         {
            _loc2_.push(7);
            _loc2_.push(8);
            _loc2_.push(9);
            _loc2_.push(10);
            _loc2_.push(11);
            _loc2_.push(14);
         }
         _layerAnim.preload(_loc2_,param1);
      }
      
      public function handleOffScreenSleep(param1:Boolean = false) : void
      {
         if(isOffScreen && _hudViewHolder != null)
         {
            if(param1)
            {
               if(_hudViewHolder.mouse.currentFrameLabel == "sleeping")
               {
                  _hudViewHolder.zzz.visible = false;
                  _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
               }
               return;
            }
            if(_hudViewHolder.mouse.currentFrameLabel != "sleeping")
            {
               _hudViewHolder.mouse.gotoAndStop("sleeping");
               if(_hudViewHolder.mouse.rotation == 180 && _hudViewHolder.zzz.rotation != 180)
               {
                  _hudViewHolder.zzz.rotation = 180;
                  _hudViewHolder.zzz.x = 0.1;
                  _hudViewHolder.zzz.y = 9.2;
               }
               else if(_hudViewHolder.zzz.rotation != 0)
               {
                  _hudViewHolder.zzz.rotation = 0;
                  _hudViewHolder.zzz.x = 0.1;
                  _hudViewHolder.zzz.y = 0.2;
               }
            }
         }
      }
      
      public function handleOffScreenHit() : void
      {
         if(isOffScreen && _hudViewHolder != null)
         {
            if(_flashTimer)
            {
               _flashTimer.reset();
               _flashTimer.start();
            }
            if(_hudViewHolder.mouse.currentFrameLabel != "flash")
            {
               _hudViewHolder.mouse.gotoAndStop("flash");
            }
         }
      }
      
      private function onFlashTimer(param1:TimerEvent) : void
      {
         if(_flashTimer)
         {
            _flashTimer.reset();
         }
         if(_hudViewHolder)
         {
            _hudViewHolder.mouse.gotoAndStop(offScreenDefaultMouseFrameLabel());
         }
      }
      
      private function ownNamebarDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_guiMgr)
         {
            _guiMgr.openAvatarEditor();
         }
      }
      
      private function onChatBallonAdventureDown(param1:int) : void
      {
         var _loc2_:Object = null;
         if(!RoomXtCommManager.isSwitching)
         {
            _loc2_ = QuestXtCommManager.getScriptDef(param1);
            if(_loc2_.membersOnly && !gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("adventures","adventure/" + param1);
               return;
            }
            QuestXtCommManager.sendQuestJoinPrivate(userName);
         }
      }
      
      private function onChatBalloonPVPDown(param1:int) : void
      {
         var _loc2_:Object = null;
         if(!RoomXtCommManager.isSwitching)
         {
            QuestManager.privateAdventureJoinClose(true);
            if(MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               DarkenManager.showLoadingSpiral(true);
               UserCommXtCommManager.sendCustomPVPMessage(false,0,onChatBalloonPVPDown,param1);
               MinigameManager.readySelfForCustomPVPGame(-1,"");
               return;
            }
            DarkenManager.showLoadingSpiral(false);
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(param1);
            if(_loc2_)
            {
               if(_loc2_.readyForPVP)
               {
                  MinigameManager.readySelfForPvpGame({"typeDefId":param1},userName,true,true);
                  MinigameXtCommManager.sendMinigameCustomPvpJoinMsg(param1,0,userName);
               }
               else
               {
                  MinigameManager.readySelfForQuickMinigame({"typeDefId":param1},true,true);
                  MinigameXtCommManager.sendMinigameJoinRequest(param1,false,true,0,userId);
               }
               GuiManager.grayOutHudItemsForPrivateLobby(true,true);
            }
         }
      }
      
      private function namebarAndAvatarDownHandler(param1:MouseEvent) : void
      {
         var pt:Point;
         var vo:Object;
         var m:MouseEvent = param1;
         m.stopPropagation();
         if(gMainFrame.clientInfo.roomType != 7 || QuestManager.isQuestLikeNormalRoom())
         {
            pt = RoomManagerWorld.instance.convertScreenToWorldSpace(m.stageX,m.stageY);
            vo = RoomManagerWorld.instance.volumeManager.testMouseVolumes(pt,true,function(param1:String):Boolean
            {
               return false;
            });
            if(vo == null || vo.name == "dark")
            {
               BuddyManager.showBuddyCard({
                  "userName":userName,
                  "onlineStatus":1
               });
            }
         }
      }
      
      private function namebarAndAvatarOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.mouse.currentFrameLabel != "over")
         {
            AJAudio.playExitBtnRollover();
            param1.currentTarget.mouse.gotoAndStop("over");
         }
      }
      
      private function namebarAndAvatarOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.mouse.currentFrameLabel != "up")
         {
            param1.currentTarget.mouse.gotoAndStop("up");
         }
      }
      
      private function attachmentMouseDownHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.parent.getChildAt(0).play();
         param1.stopPropagation();
      }
      
      public function startSlide(param1:Array) : void
      {
         _moving = 0;
         _slidePositions = param1;
         _slideSpinCurrentDirection = 0;
         _slideSpinTimer = 0;
         _slideCurrentPosition = 0;
         _slideFrameTime = 0;
         _followPath = null;
      }
      
      public function updateSlide(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(_slideCurrentPosition >= 0)
         {
            while(param1 > 0)
            {
               if(_slideCurrentPosition >= _slidePositions.length - 1)
               {
                  if(_avatar.userName.toLowerCase() == gMainFrame.server.userName.toLowerCase())
                  {
                     AchievementXtCommManager.requestSetUserVar(96,1);
                  }
                  _slideCurrentPosition = -1;
                  playAnim(getBaseIdle());
                  _moving = !!_followPath ? 1 : 0;
                  break;
               }
               if(_slideFrameTime + param1 < 41.666666666666664)
               {
                  _slideFrameTime += param1;
                  param1 = 0;
               }
               else
               {
                  param1 -= 41.666666666666664 - _slideFrameTime;
                  _slideFrameTime = 41.666666666666664;
               }
               setPos(_slidePositions[_slideCurrentPosition].x + (_slidePositions[_slideCurrentPosition + 1].x - _slidePositions[_slideCurrentPosition].x) * _slideFrameTime / 41.666666666666664,_slidePositions[_slideCurrentPosition].y + (_slidePositions[_slideCurrentPosition + 1].y - _slidePositions[_slideCurrentPosition].y) * _slideFrameTime / 41.666666666666664,false,false);
               if(param1 > 0)
               {
                  _slideFrameTime = 0;
                  _slideCurrentPosition++;
               }
            }
            if(_roomType != 1)
            {
               if(_slideCurrentPosition >= 0 && (_slideSpinTimer == 0 || _slideSpinTimer < getTimer()))
               {
                  _slideSpinCurrentDirection++;
                  if(_slideSpinCurrentDirection > 9)
                  {
                     _slideSpinCurrentDirection = 0;
                  }
                  _loc2_ = 0;
                  _loc3_ = _slideSpinCurrentDirection > 4 ? true : false;
                  switch(_slideSpinCurrentDirection)
                  {
                     case 0:
                        _loc2_ = 0;
                        break;
                     case 1:
                        _loc2_ = 1;
                        break;
                     case 2:
                        _loc2_ = 2;
                        break;
                     case 3:
                        _loc2_ = 3;
                        break;
                     case 4:
                        _loc2_ = 4;
                        break;
                     case 5:
                        _loc2_ = 4;
                        break;
                     case 6:
                        _loc2_ = 3;
                        break;
                     case 7:
                        _loc2_ = 2;
                        break;
                     case 8:
                        _loc2_ = 1;
                        break;
                     case 9:
                        _loc2_ = 0;
                  }
                  _slideSpinTimer = getTimer() + 100;
                  playAnim(1 + _loc2_,_loc3_,2);
               }
            }
         }
      }
      
      public function setBounce(param1:Boolean) : void
      {
         _layerAnim.bounceEnabled = param1;
         if(param1 && _layerAnim.animId != 17 && (_dirX != 0 || _dirY != 0 || _layerAnim.animId == 14 || _layerAnim.animId == 16))
         {
            faceAnim(_dirX,_dirY,true);
         }
      }
      
      public function getJumpLandFX() : MovieClip
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Loader = null;
         var _loc3_:Vector.<MovieClip> = _jumpLandFXPool;
         if(_loc3_.length > 3)
         {
            _loc1_ = _loc3_.shift();
            _loc2_ = _loc1_.getChildAt(0) as Loader;
            if(_loc2_.content && !(_loc2_.content as MovieClip).readyToUse)
            {
               _loc1_ = new JumpLandFX();
            }
         }
         else
         {
            _loc1_ = new JumpLandFX();
         }
         _loc1_.visible = true;
         _loc3_.push(_loc1_);
         if(_loc1_.parent)
         {
            _loc1_.parent.removeChild(_loc1_);
         }
         RoomManagerWorld.instance.layerManager.room_avatars.addChild(_loc1_);
         return _loc1_;
      }
      
      public function jumpLand() : void
      {
         var _loc2_:Object = null;
         var _loc1_:MovieClip = null;
         var _loc3_:Loader = null;
         if(RoomManagerWorld.instance.volumeManager.hasSplashVolume)
         {
            _loc2_ = RoomManagerWorld.instance.volumeManager.testSplashVolumes(new Point(x,y));
            if(_loc2_)
            {
               switch(_loc2_.message)
               {
                  case "treeleaves":
                  case "phntmtreeleaves":
                     _loc1_ = getJumpLandFX();
                     if(_loc1_)
                     {
                        _loc1_.x = x - 30;
                        _loc1_.y = y + 20;
                        _loc3_ = _loc1_.getChildAt(0) as Loader;
                        if(_loc3_.content)
                        {
                           setupJumpLand(_loc3_.content as MovieClip,_loc2_.message);
                           break;
                        }
                        _jumpLandType = _loc2_.message;
                        _loc3_.contentLoaderInfo.addEventListener("complete",jumpLandLoaderComplete);
                        break;
                     }
               }
            }
         }
      }
      
      public function queueCommand(param1:Object) : void
      {
         _commandQueue.push(param1);
      }
      
      private function jump() : void
      {
         if(!_bJumping && (!_bFalling || _jumpTimer < 0.25) || _doBounce)
         {
            _jumpVel = -JUMP_SPEED;
            _bJumping = true;
            _bFalling = false;
            _jumpTimer = 0;
            playJumpAnim();
            if(!_doBounce)
            {
               QuestManager.playSound("ajq_jump");
            }
         }
      }
      
      private function setJumpAnimFrame(param1:int) : void
      {
         switch(avTypeId)
         {
            case 4:
            case 28:
            case 1:
            case 33:
            case 40:
            case 8:
            case 31:
            case 15:
            case 3:
            case 16:
            case 25:
            case 26:
            case 34:
            case 23:
            case 41:
            case 42:
            case 43:
            case 9:
            case 27:
            case 5:
            case 17:
            case 14:
            case 32:
            case 6:
            case 24:
            case 7:
            case 10:
            case 36:
            case 11:
            case 30:
            case 13:
            case 18:
            case 37:
            case 29:
               _leapState = 0;
               _layerAnim.frame = _leapState;
               _leapFrameCounter = 0;
               break;
            default:
               _layerAnim.frame = param1 * 0.2;
         }
      }
      
      private function setFallAnimFrame(param1:int) : void
      {
         switch(avTypeId)
         {
            case 4:
            case 28:
            case 1:
            case 33:
            case 40:
            case 8:
            case 31:
            case 15:
            case 3:
            case 16:
            case 25:
            case 26:
            case 34:
            case 23:
            case 41:
            case 42:
            case 43:
            case 32:
            case 6:
            case 24:
            case 10:
            case 7:
            case 36:
            case 11:
            case 30:
            case 13:
            case 18:
            case 37:
            case 29:
               _layerAnim.frame = _leapState;
               break;
            default:
               _layerAnim.frame = param1 * 0.8;
         }
      }
      
      private function playFallAnim() : void
      {
         switch(avTypeId)
         {
            case 4:
            case 28:
            case 1:
            case 33:
            case 40:
            case 8:
            case 31:
            case 15:
            case 3:
            case 16:
            case 25:
            case 26:
            case 34:
            case 23:
            case 41:
            case 42:
            case 43:
            case 9:
            case 27:
            case 5:
            case 17:
            case 14:
            case 32:
            case 6:
            case 24:
            case 7:
            case 10:
            case 36:
            case 11:
            case 30:
            case 13:
            case 18:
            case 37:
            case 29:
               if(_leapState < 0 || _leapState > 6)
               {
                  _leapState = 4;
                  _leapFrameCounter = 0;
                  playAnim(34,flip,3,setFallAnimFrame);
               }
               break;
            default:
               playAnim(17,flip,3,setFallAnimFrame);
         }
      }
      
      private function playJumpAnim() : void
      {
         switch(avTypeId)
         {
            case 4:
            case 28:
            case 1:
            case 33:
            case 40:
            case 8:
            case 31:
            case 15:
            case 3:
            case 16:
            case 25:
            case 26:
            case 34:
            case 23:
            case 41:
            case 42:
            case 43:
            case 9:
            case 27:
            case 5:
            case 17:
            case 14:
            case 32:
            case 6:
            case 24:
            case 10:
            case 7:
            case 36:
            case 11:
            case 30:
            case 13:
            case 18:
            case 37:
            case 29:
               playAnim(34,flip,3,setJumpAnimFrame);
               break;
            default:
               playAnim(17,flip,3,setJumpAnimFrame);
         }
      }
      
      private function resetJump() : void
      {
         if(_jumpTimer > 0.25)
         {
            _jumpEnableTimer = 1;
         }
         _jumpVel = 0;
         _jumpTimer = 0;
         _bJumping = false;
         _bFalling = false;
      }
      
      public function doBounce() : void
      {
         _doBounce = true;
      }
      
      public function sideScrollMovement(param1:Point, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Point = null, param7:Boolean = false, param8:int = 0) : void
      {
         var _loc28_:Point = null;
         var _loc26_:int = 0;
         var _loc21_:Number = NaN;
         var _loc14_:int = 0;
         var _loc12_:* = NaN;
         var _loc13_:* = NaN;
         var _loc23_:Object = null;
         var _loc19_:int = 0;
         var _loc22_:* = NaN;
         var _loc20_:* = NaN;
         var _loc11_:* = false;
         var _loc9_:* = 0;
         var _loc27_:Object = null;
         var _loc15_:int = 0;
         var _loc18_:int = 0;
         var _loc10_:Point = new Point();
         var _loc17_:Number = y;
         if(_sideScrollArrow == null && _bArrowEnabled)
         {
            _bMouseMovement = param7 = false;
         }
         if(param7 && !_bMouseMovement)
         {
            _bMouseMovement = true;
            if(_bArrowEnabled)
            {
               _sideScrollArrow.visible = true;
            }
         }
         else if(_bMouseMovement && (param2 || param3 || param4 || param5 || animId == 22))
         {
            _bMouseMovement = false;
            if(_bArrowEnabled)
            {
               _sideScrollArrow.visible = false;
            }
         }
         if(!_bArrowEnabled && _sideScrollArrow)
         {
            _sideScrollArrow.visible = false;
         }
         if(_bOnLadder && (param5 || param4 || param7 && Math.abs(param6.x - x) > 50))
         {
            _bFalling = true;
            _bJumpEnabled = true;
            _bOnLadder = false;
            _jumpVel = 0;
            _jumpTimer = 0;
            pauseAnim(false);
         }
         if(_splashTimer > 0)
         {
            _splashTimer -= _frameTime;
            if(_splashTimer <= 0)
            {
               AvatarManager.clearPlayerSplashColor();
               setBlendColor();
            }
         }
         _loc26_ = 1;
         if(_bMouseMovement)
         {
            if(param6.y < y - 175 || _bJumping || _bFalling && _jumpTimer > 0.25)
            {
               _loc26_ = 2;
               if(_bArrowEnabled)
               {
                  _sideScrollArrow.visible = true;
               }
               _sideScrollArrow.arrowType(_loc26_);
               _sideScrollArrow.arrowAngle(Math.atan2(param6.y - y,param6.x - x) * 57.295779513);
               if(param7)
               {
                  _loc10_.x = param6.x - x;
                  _loc10_.y = param6.y - y;
                  if(Math.abs(_loc10_.x) < 70)
                  {
                     _loc10_.x = 0;
                  }
                  _loc10_.normalize(1);
                  _prevXDir = _loc10_.x >= 0 ? Math.min(_loc10_.x * 1.5,1) : Math.max(_loc10_.x * 1.5,-1);
               }
            }
            else
            {
               _loc26_ = 1;
               if(_bArrowEnabled)
               {
                  _sideScrollArrow.arrowType(_loc26_);
               }
            }
         }
         if((!_bFalling || _jumpTimer < 0.25) && !_bFallDisableCollision && !_bJumping)
         {
            if(_jumpEnableTimer > 0)
            {
               _jumpEnableTimer -= _frameTime;
               if(!_bJumpEnabled && _jumpEnableTimer <= 0)
               {
                  _bJumpEnabled = true;
               }
            }
         }
         _loc10_.x = x;
         _loc10_.y = y;
         if(_bMouseMovement && (!param7 || _doBounce))
         {
            _bJumpEnabled = true;
         }
         if(param2 || param7 && param6.y < y - 175)
         {
            if(!_bOnLadder && (_bJumpEnabled || param8 == 1 || _doBounce))
            {
               _bJumpEnabled = false;
               jump();
               if(_doBounce)
               {
                  _leapFrameCounter = 0;
                  resetJump();
                  jump();
                  _jumpVel = -BOUNCE_SPEED;
                  _doBounce = false;
               }
            }
         }
         else if(!_bOnLadder)
         {
            _bJumpEnabled = true;
            if(_doBounce)
            {
               _leapFrameCounter = 0;
               resetJump();
               jump();
               _jumpVel = -BOUNCE_SPEED;
               _doBounce = false;
            }
         }
         if(param7)
         {
            if(param6.y > y + 50)
            {
               param3 = true;
            }
         }
         if(param3)
         {
            if(!_bFalling && !_bJumping && !_bOnLadder && RoomManagerWorld.instance.checkCollisionThickness(x,y,2))
            {
               _bFallDisableCollision = true;
               _bOnPlatform = false;
            }
         }
         if(_currentCommand && param1 == null)
         {
            param1 = new Point(x < _currentCommand[3] ? 1 : -1,0);
         }
         var _loc16_:Number = 0;
         var _loc25_:Number = 0;
         if(_bMouseMovement)
         {
            if(param6.x - x > 50)
            {
               if(param7)
               {
                  param1.x = 1;
                  _xTarget = param6.x;
                  _xState = 1;
               }
               else
               {
                  param1.x = 0;
               }
               if(_bArrowEnabled)
               {
                  if(_loc26_ == 1)
                  {
                     _sideScrollArrow.arrowAngle(0);
                  }
                  _loc16_ = param6.x - x;
                  _loc25_ = param6.y - y;
                  _sideScrollArrow.visible = true;
               }
            }
            else if(x - param6.x > 50)
            {
               if(param7)
               {
                  param1.x = -1;
                  _xTarget = param6.x;
                  _xState = 1;
               }
               else
               {
                  param1.x = 0;
               }
               if(_loc26_ == 1)
               {
                  _sideScrollArrow.arrowAngle(180);
               }
               _loc16_ = param6.x - x;
               _loc25_ = param6.y - y;
               if(_bArrowEnabled)
               {
                  _sideScrollArrow.visible = true;
               }
            }
            else if(Math.abs(param6.x - x) < 30)
            {
               param1.x = 0;
               if(param7)
               {
                  _xState = 0;
               }
               if(_loc26_ == 1)
               {
                  _sideScrollArrow.visible = false;
               }
               _loc16_ = param6.x - x;
               _loc25_ = param6.y - y;
            }
            else
            {
               param1.x = 0;
               if(_loc26_ == 1)
               {
                  _sideScrollArrow.visible = false;
               }
               _loc16_ = param6.x - x;
               _loc25_ = param6.y - y;
            }
            if(_bJumping && _bMouseMovement)
            {
               param1.x = _prevXDir;
            }
            if(_bJumping)
            {
               _xState = 0;
            }
            if(_xState == 1)
            {
               if(Math.abs(x - _xTarget) > 30)
               {
                  param1.x = _xTarget > x ? 1 : -1;
               }
               else
               {
                  _xState = 0;
               }
            }
         }
         if(param1.x != 0 || _platformingCurVel != 0 || _bJumping || _bFalling || _bFallDisableCollision || _bOnLadder || _bOnPlatform)
         {
            setMoving(1);
            if(_frameTime >= 0.105)
            {
               _frameTime = 0.105;
            }
            if(_bJumping || _bFalling || _bFallDisableCollision)
            {
               _jumpTimer += _frameTime;
               _jumpVel += GRAVITY * _frameTime;
               if(_jumpVel > 1000)
               {
                  _jumpVel = 1000;
               }
               if(_jumpVel < 0)
               {
                  if(_leapState == 0)
                  {
                     _leapFrameCounter++;
                     if(_leapFrameCounter > 3)
                     {
                        _leapFrameCounter = 0;
                        _leapState++;
                        _layerAnim.frame++;
                     }
                  }
               }
               else if(_leapState == 1 || _leapState == 2 || _leapState == 3)
               {
                  _leapFrameCounter++;
                  if(_leapFrameCounter > 1)
                  {
                     _leapFrameCounter = 0;
                     _leapState++;
                     _layerAnim.frame++;
                  }
               }
            }
            else
            {
               _prevXDir = 0;
            }
            _loc28_ = new Point(x,y);
            if(param1.x == 0)
            {
               if(_platformingCurVel > 0)
               {
                  _platformingCurVel -= 150 * _frameTime;
                  if(_platformingCurVel < 0)
                  {
                     _platformingCurVel = 0;
                  }
               }
               else if(_platformingCurVel < 0)
               {
                  _platformingCurVel += 150 * _frameTime;
                  if(_platformingCurVel > 0)
                  {
                     _platformingCurVel = 0;
                  }
               }
            }
            else
            {
               _platformingCurVel += param1.x * 150 * _frameTime;
            }
            _loc21_ = 32;
            if(_bInSplashVolume || _splashTimer > 0)
            {
               if(_splashLiquid == "acid" || _splashTimer > 0)
               {
                  if(QuestManager.getQuestActorState(_splashVol.name) == 0)
                  {
                     _loc21_ = 16;
                     if(_bInSplashVolume)
                     {
                        _splashTimer = 1.5;
                     }
                     if(_bJumping && _jumpVel > -600 && _jumpVel < 0)
                     {
                        _bFalling = true;
                        _jumpVel = 0;
                        _jumpTimer = 0;
                     }
                  }
                  else
                  {
                     _splashVol.message = "water";
                  }
               }
            }
            if(Math.abs(_platformingCurVel) > _loc21_)
            {
               _platformingCurVel = param1.x * _loc21_;
            }
            _loc14_ = _platformingCurVel * _frameTime / 0.07;
            _loc12_ = Number(_bFallDisableCollision ? 0 : _loc14_);
            _loc13_ = _jumpVel * _frameTime;
            _loc10_.x = x;
            _loc10_.y = y;
            _loc23_ = RoomManagerWorld.instance.volumeManager.testLadderVolumes(_loc10_);
            if(_loc23_ != null)
            {
               if(!_bOnLadder && (_bJumping || _bFallDisableCollision || _bFalling && (param2 || param7 && param6.y < y - 175)))
               {
                  _bOnLadder = true;
                  _bJumping = _bFallDisableCollision = false;
                  resetJump();
                  playAnim(7,false,2);
               }
            }
            else
            {
               _bOnLadder = false;
            }
            _loc19_ = RoomManagerWorld.instance.getCellDiameter() - 1;
            _loc22_ = _loc13_;
            _loc20_ = _loc12_;
            _loc11_ = Math.abs(_loc12_) > Math.abs(_loc13_);
            if(_loc11_)
            {
               if(Math.abs(_loc12_) > _loc19_)
               {
                  _loc12_ = Number(_loc12_ > 0 ? _loc19_ : -_loc19_);
                  _loc13_ *= _loc12_ / _loc20_;
               }
            }
            else if(Math.abs(_loc13_) > _loc19_)
            {
               _loc13_ = Number(_loc13_ > 0 ? _loc19_ : -_loc19_);
               _loc12_ *= _loc13_ / _loc22_;
            }
            if(_bOnLadder)
            {
               if(param7)
               {
                  if(param6.y < y - 50)
                  {
                     param2 = true;
                  }
                  else if(param6.y > y + 50)
                  {
                     param3 = true;
                  }
               }
               if(param2)
               {
                  _loc13_ = -450 * _frameTime;
                  playAnim(7,false,2);
                  pauseAnim(false);
               }
               else if(param3)
               {
                  _loc13_ = 450 * _frameTime;
                  playAnim(11,false,2);
                  pauseAnim(false);
               }
               else
               {
                  _loc13_ = 0;
                  pauseAnim(true);
               }
               _loc28_.x = _loc10_.x;
               _loc28_.y = _loc10_.y + _loc13_;
               if(userId == AvatarManager.playerSfsUserId)
               {
                  AvatarManager.movePlayer(_loc28_.x,_loc28_.y,false);
               }
               _pos.x = _loc28_.x;
               _pos.y = _loc28_.y;
            }
            else
            {
               while(Math.abs(_loc13_) <= Math.abs(_loc22_) && Math.abs(_loc12_) <= Math.abs(_loc20_))
               {
                  _loc9_ = RoomManagerWorld.instance.collisionTestGrid(_loc10_.x + _loc12_,_loc10_.y + _loc13_);
                  _loc27_ = RoomManagerWorld.instance.getGridXY(_loc10_.x,_loc10_.y);
                  if(_bFallDisableCollision && _loc9_ == 0 && _jumpTimer > 0.25)
                  {
                     _bFallDisableCollision = false;
                  }
                  if(_loc9_ != 0 && !_bFallDisableCollision)
                  {
                     if(_loc13_ < 0)
                     {
                        if(RoomManagerWorld.instance.checkVerticalThickness(_loc10_.x + _loc12_,_loc10_.y + _loc13_,3))
                        {
                           if(RoomManagerWorld.instance.collisionTestGrid(_loc10_.x,_loc10_.y + _loc13_) != 0 && RoomManagerWorld.instance.checkVerticalThickness(_loc10_.x,_loc10_.y + _loc13_,3))
                           {
                              _bFalling = true;
                              _jumpVel = 0;
                              _jumpTimer = 0;
                              break;
                           }
                           _loc28_.x = _loc10_.x;
                           _loc28_.y = _loc10_.y + _loc13_;
                        }
                        else
                        {
                           _loc28_.x = _loc10_.x + _loc12_;
                           _loc28_.y = _loc10_.y + _loc13_;
                        }
                     }
                     else
                     {
                        RoomManagerWorld.instance.resolveCollisionUp(_loc10_.x + _loc12_,_loc10_.y + _loc13_,_resolveUpResult);
                        if(_resolveUpResult.gridY >= 0 && _loc27_.y - _resolveUpResult.gridY <= 2)
                        {
                           if(_bJumping || _bFalling && _jumpTimer > 0.25)
                           {
                              jumpLand();
                           }
                           if(_bJumping || _bFalling)
                           {
                              if(_leapState == 4 || _leapState == 5)
                              {
                                 _leapState = 6;
                                 _layerAnim.frame = 6;
                                 _leapFrameCounter = 0;
                              }
                           }
                           _loc28_.x = _loc10_.x + _loc12_;
                           _loc28_.y = _resolveUpResult.yPos;
                           resetJump();
                           _loc22_ -= _loc10_.y + _loc13_ - _resolveUpResult.yPos;
                           _loc13_ -= _loc10_.y + _loc13_ - _resolveUpResult.yPos;
                        }
                        else if(_loc12_ != 0 && (_bFalling || _bJumping) && RoomManagerWorld.instance.collisionTestGrid(_loc10_.x,_loc10_.y + _loc13_) == 0)
                        {
                           _loc28_.x = _loc10_.x;
                           _loc28_.y = _loc10_.y + _loc13_;
                        }
                        else
                        {
                           _resolveUpResult.gridY = -1;
                           if(_loc12_ != 0 && RoomManagerWorld.instance.collisionTestGrid(_loc10_.x,_loc10_.y + _loc13_) != 0)
                           {
                              RoomManagerWorld.instance.resolveCollisionUp(_loc10_.x,_loc10_.y + _loc13_,_resolveUpResult);
                           }
                           if(_resolveUpResult.gridY >= 0 && _loc27_.y - _resolveUpResult.gridY <= 2)
                           {
                              if(_bJumping || _bFalling && _jumpTimer > 0.25)
                              {
                                 jumpLand();
                              }
                              if(_bJumping || _bFalling)
                              {
                                 if(_leapState == 4 || _leapState == 5)
                                 {
                                    _leapState = 6;
                                    _layerAnim.frame = 6;
                                    _leapFrameCounter = 0;
                                 }
                              }
                              _loc28_.x = _loc10_.x;
                              _loc28_.y = _resolveUpResult.yPos;
                              resetJump();
                              _loc22_ -= _loc10_.y + _loc13_ - _resolveUpResult.yPos;
                              _loc13_ -= _loc10_.y + _loc13_ - _resolveUpResult.yPos;
                           }
                           else
                           {
                              _resolveUpResult = RoomManagerWorld.instance.findClosestOpenGridCell(_loc10_.x + _loc12_,_loc10_.y + _loc13_,_loc12_ <= 0);
                              _loc15_ = _resolveUpResult.x + (_loc12_ > 0 ? (_loc19_ + 1) * 0.5 - 1 : -(_loc19_ + 1) * 0.5 + 1);
                              _loc18_ = _resolveUpResult.y + (_loc19_ + 1) * 0.5;
                              if(_loc18_ > _loc10_.y + _loc13_)
                              {
                                 _loc18_ = _loc10_.y + _loc13_;
                              }
                              _loc28_.x = _loc15_;
                              _loc28_.y = _loc18_;
                              if(_loc28_.y == _loc10_.y)
                              {
                                 resetJump();
                              }
                           }
                        }
                     }
                  }
                  else
                  {
                     if(!_bFalling && !_bJumping && !_bOnPlatform)
                     {
                        _bFalling = true;
                        _jumpVel = 0;
                        _jumpTimer = 0;
                     }
                     _loc28_.x = _loc10_.x + _loc12_;
                     _loc28_.y = _loc10_.y + _loc13_;
                     if(_bOnPlatform)
                     {
                        _loc28_.x += 0;
                        _loc28_.y = _loc10_.y;
                     }
                  }
                  if(_loc11_)
                  {
                     if(Math.abs(_loc12_) >= Math.abs(_loc20_))
                     {
                        break;
                     }
                     _loc12_ += _loc12_ > 0 ? _loc19_ : -_loc19_;
                     if(Math.abs(_loc12_) > Math.abs(_loc20_))
                     {
                        _loc12_ = _loc20_;
                     }
                     _loc13_ = _jumpVel * _frameTime * (_loc12_ / _loc20_);
                  }
                  else
                  {
                     if(Math.abs(_loc13_) >= Math.abs(_loc22_))
                     {
                        break;
                     }
                     _loc13_ += _loc13_ > 0 ? _loc19_ : -_loc19_;
                     if(Math.abs(_loc13_) > Math.abs(_loc22_))
                     {
                        _loc13_ = _loc22_;
                     }
                     _loc12_ = _loc14_ * (_loc13_ / _loc22_);
                  }
               }
               if(userId == AvatarManager.playerSfsUserId)
               {
                  if(Math.abs(_loc28_.x - _loc10_.x) > 200 || Math.abs(_loc28_.y - _loc10_.y) > 200)
                  {
                     RoomManagerWorld.instance.resolveCollisionUp(_loc10_.x + _loc12_,_loc10_.y + _loc13_,_resolveUpResult);
                  }
                  AvatarManager.movePlayer(_loc28_.x,_loc28_.y,false);
               }
               _pos.x = _loc28_.x;
               _pos.y = _loc28_.y;
               _loc28_.x = int(_loc28_.x);
               _loc28_.y = int(_loc28_.y);
               if(!_bFallDisableCollision && !_bJumping && RoomManagerWorld.instance.collisionCheckCorner(_loc28_))
               {
                  _bFalling = false;
                  resetJump();
                  if(userId == AvatarManager.playerSfsUserId)
                  {
                     if(Math.abs(_loc28_.x - _loc10_.x) > 200 || Math.abs(_loc28_.y - _loc10_.y) > 200)
                     {
                        RoomManagerWorld.instance.resolveCollisionUp(_loc10_.x + _loc12_,_loc10_.y + _loc13_,_resolveUpResult);
                     }
                     AvatarManager.movePlayer(_loc28_.x,_loc28_.y,false);
                  }
                  _pos.x = _loc28_.x;
                  _pos.y = _loc28_.y;
               }
               if((_bFallDisableCollision || _bFalling) && _jumpTimer > 0.25)
               {
                  playFallAnim();
               }
               else if(!_bJumping)
               {
                  if(_loc10_.x == _loc28_.x)
                  {
                     if(_leapState == 6)
                     {
                        _leapFrameCounter++;
                        if(_leapFrameCounter > 1)
                        {
                           _leapState++;
                           _leapFrameCounter = 0;
                        }
                     }
                     else
                     {
                        playAnim(14,flip,2);
                        _platformingCurVel = 0;
                     }
                  }
                  else if(_loc12_ < 0)
                  {
                     playAnim(9,true,2);
                     if(_currentCommand && _pos.x < _currentCommand[3])
                     {
                        _pos.x = _currentCommand[3];
                        _pos.y = _currentCommand[4];
                        _currentCommand = null;
                     }
                     _leapState = -1;
                  }
                  else if(_loc12_ > 0)
                  {
                     playAnim(9,false,2);
                     if(_currentCommand && _pos.x > _currentCommand[3])
                     {
                        _pos.x = _currentCommand[3];
                        _pos.y = _currentCommand[4];
                        _currentCommand = null;
                     }
                     _leapState = -1;
                  }
               }
               else
               {
                  if(_loc12_ < 0)
                  {
                     _layerAnim.hFlip = true;
                  }
                  else if(_loc12_ > 0)
                  {
                     _layerAnim.hFlip = false;
                  }
                  if(_loc13_ > 0)
                  {
                     playFallAnim();
                  }
               }
            }
         }
         else
         {
            setMoving(0);
            if(_leapState == 6)
            {
               _leapFrameCounter++;
               if(_leapFrameCounter > 4)
               {
                  _leapState++;
                  _leapFrameCounter = 0;
               }
            }
            else
            {
               playAnim(14,flip,2);
               if(!_bFalling && !_bJumping)
               {
                  _bFalling = true;
                  _jumpVel = 0;
                  _jumpTimer = 0;
               }
            }
         }
         if(platform)
         {
            if(!_bOnPlatform)
            {
               if(_loc17_ < y)
               {
                  if(x > platform.x && x < platform.x + platform.width)
                  {
                     if(_loc17_ < platform.y && y >= platform.y)
                     {
                        y = platform.y;
                        _bOnPlatform = true;
                        _leapState = 6;
                        _layerAnim.frame = 6;
                        _leapFrameCounter = 0;
                        resetJump();
                        if(platformQA)
                        {
                           if(platformQA._actorData.type == 21)
                           {
                              platformQA.playerJumpLand();
                           }
                           else if(platformQA._actorData.type == 30)
                           {
                              platformQA.trigger();
                           }
                        }
                     }
                  }
               }
            }
            else if(x < platform.x || x > platform.x + platform.width || _bJumping)
            {
               _bOnPlatform = false;
            }
         }
         if(_bMouseMovement && _bArrowEnabled)
         {
            _sideScrollArrow.x = x + _loc16_ * 0.35 - parent.x - parent.parent.x + _sideScrollArrow.parent.x;
            _sideScrollArrow.y = y + (_loc25_ < 0 ? _loc25_ * 0.35 : 0) - parent.y - parent.parent.y + _sideScrollArrow.parent.y;
         }
      }
      
      public function float(param1:Boolean) : void
      {
         _float = param1;
      }
      
      public function setPlatform(param1:MovieClip, param2:QuestActor, param3:Boolean) : void
      {
         if(platform == null)
         {
            platform = new Rectangle();
         }
         if(param3)
         {
            platformQA = param2;
            platform.x = param1.x + param1.parent.x + param1.parent.parent.x + param1.parent.parent.parent.x;
            platform.y = param1.y + param1.parent.y + param1.parent.parent.y + param1.parent.parent.parent.y;
            platform.width = param1.width;
         }
         else if(platformQA == param2)
         {
            _bOnPlatform = false;
            platform = null;
            platformQA = null;
         }
      }
      
      public function getPlatform() : QuestActor
      {
         return platformQA;
      }
   }
}

