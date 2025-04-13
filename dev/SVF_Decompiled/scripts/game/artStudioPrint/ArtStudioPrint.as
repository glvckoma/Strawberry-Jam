package game.artStudioPrint
{
   import buddy.ReferAFriend;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ArtStudioPrint extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var _soundMan:SoundManager;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _printMediaHelper:MediaHelper;
      
      private var _exitConfirmationActive:Boolean;
      
      private var _printImage:MovieClip;
      
      private var _imageToPrint:MovieClip;
      
      private var _activeImageIndex:int;
      
      private var _imageIDs:Array;
      
      private var _printIDs:Array;
      
      private var _printOffsets:Array;
      
      private var _loadingImage:Boolean;
      
      private var _printBackground:Object;
      
      private var _isForCode:Boolean;
      
      public var _layerBackground:Sprite;
      
      public var _layerForeground:Sprite;
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function ArtStudioPrint()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",keyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         removeLayer(_layerForeground);
         removeLayer(_layerBackground);
         removeLayer(_guiLayer);
         _layerForeground = null;
         _layerBackground = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerBackground = new Sprite();
            _layerForeground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_layerForeground);
            addChild(_guiLayer);
            loadScene("ArtStudioPrint/room_main.xroom");
            _bInit = true;
            _exitConfirmationActive = false;
            pixelsPerIteration = 1000;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc6_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         var _loc4_:String = "template";
         var _loc5_:Boolean = true;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId)
            {
               case 89:
                  _loc4_ = "notemplate";
                  _loc5_ = false;
                  break;
               case 152:
                  _loc4_ = "notemplate";
                  _isForCode = true;
            }
         }
         _printBackground = _scene.getLayer(_loc4_);
         _printBackground.loader.x = 10000;
         _printBackground.loader.y = 10000;
         setupInitialStates();
         if(_imageIDs.length == 1)
         {
            _loc5_ = false;
         }
         _loc6_ = _scene.getLayer("closeButton");
         addBtn("CloseButton",_loc6_.x,_loc6_.y,onCloseButton);
         _layerBackground.addChild(_scene.getLayer("background").loader);
         if(_loc5_)
         {
            _loc6_ = _scene.getLayer("buttonLeft");
            addBtn("arrowPrintL_button",_loc6_.x,_loc6_.y,onButtonLeft);
            _loc6_ = _scene.getLayer("buttonRight");
            addBtn("arrowPrintR_button",_loc6_.x,_loc6_.y,onButtonRight);
         }
         _loc6_ = _scene.getLayer("buttonCreate");
         addBtn("createPrint_button",_loc6_.x,_loc6_.y,onButtonPrint);
         _loc6_ = _scene.getLayer("buttonPrint");
         _exitConfirmationActive = false;
         _sceneLoaded = true;
         stage.addEventListener("keyDown",keyDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         startGame();
         _layerForeground.addChild(_scene.getLayer("topLayer1").loader);
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] != "ml")
         {
            if(param1[0] == "ms")
            {
               _dbIDs = [];
               _loc2_ = 0;
               while(_loc2_ < _pIDs.length)
               {
                  _dbIDs[_loc2_] = param1[_loc2_ + 1];
                  _loc2_++;
               }
            }
            else if(param1[0] == "mm")
            {
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
         }
      }
      
      public function startGame() : void
      {
         if(_sceneLoaded)
         {
            loadImage(0);
         }
      }
      
      private function setupInitialStates() : void
      {
         _activeImageIndex = 0;
         _imageIDs = new Array(434,422,394,67,68,88,89,90,2379,2381);
         _printIDs = new Array(435,423,395,112,113,114,115,116,2380,2382);
         _printOffsets = new Array(new Point(20,20),new Point(20,20),new Point(20,20),new Point(20,-50),new Point(20,-50),new Point(20,20),new Point(20,20),new Point(20,-50),new Point(20,20),new Point(20,20));
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId)
            {
               case 89:
                  _imageIDs = new Array(1958,1958,1958);
                  _printIDs = new Array(1957,1957,1957);
                  _printOffsets = new Array(new Point(-67,-69));
                  break;
               case 152:
                  _imageIDs = [7141];
                  _printIDs = [7140];
                  _printOffsets = [new Point(0,0)];
            }
         }
      }
      
      private function loadPrintImage() : void
      {
         _loadingImage = true;
         _printMediaHelper = new MediaHelper();
         _printMediaHelper.init(_printIDs[_activeImageIndex],printImageMediaHandler);
      }
      
      private function printImageMediaHandler(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         _imageToPrint = param1;
         if(_isForCode)
         {
            _loc2_ = MovieClip(param1.getChildAt(0));
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               LocalizationManager.translateIdAndInsert(_loc2_["txt_" + _loc3_],32411,gMainFrame.userInfo.myUserName);
               LocalizationManager.updateToFit(_loc2_["codeTxt_" + _loc3_],ReferAFriend.code);
               _loc3_++;
            }
         }
         _loadingImage = false;
         printOnePerPage(_imageToPrint,_printOffsets[_activeImageIndex].x,_printOffsets[_activeImageIndex].y,_printBackground,"portrait");
      }
      
      private function loadImage(param1:int) : void
      {
         var _loc2_:int = 0;
         if(!_loadingImage)
         {
            _loc2_ = _activeImageIndex;
            if(param1 > 0)
            {
               _activeImageIndex++;
               if(_activeImageIndex >= _imageIDs.length)
               {
                  _activeImageIndex = 0;
               }
            }
            else if(param1 < 0)
            {
               _activeImageIndex--;
               if(_activeImageIndex < 0)
               {
                  _activeImageIndex = _imageIDs.length - 1;
               }
            }
            if(param1 == 0 || _loc2_ != _activeImageIndex)
            {
               _loadingImage = true;
               _printMediaHelper = new MediaHelper();
               _printMediaHelper.init(_imageIDs[_activeImageIndex],printMediaHandler);
            }
         }
      }
      
      private function printMediaHandler(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(_printImage != null)
         {
            _printImage.parent.removeChild(_printImage);
         }
         param1.x = 114;
         param1.y = 104;
         _printImage = param1;
         if(_isForCode)
         {
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               LocalizationManager.translateIdAndInsert(param1["txt_" + _loc2_],32411,gMainFrame.userInfo.myUserName);
               LocalizationManager.updateToFit(param1["codeTxt_" + _loc2_],ReferAFriend.code);
               _loc2_++;
            }
         }
         _layerBackground.addChild(_printImage);
         if(_printBackground)
         {
            _layerBackground.addChild(_printBackground.loader);
         }
         _loadingImage = false;
      }
      
      private function keyDown(param1:KeyboardEvent) : void
      {
         if(!_loadingImage)
         {
            switch(param1.keyCode)
            {
               case 13:
               case 32:
                  onButtonPrint();
                  break;
               case 39:
                  onButtonRight();
                  break;
               case 37:
                  onButtonLeft();
            }
         }
      }
      
      private function onButtonLeft() : void
      {
         if(!_exitConfirmationActive)
         {
            loadImage(-1);
         }
      }
      
      private function onButtonRight() : void
      {
         if(!_exitConfirmationActive)
         {
            loadImage(1);
         }
      }
      
      private function onButtonPrint() : void
      {
         if(!_exitConfirmationActive && !_loadingImage)
         {
            loadPrintImage();
         }
      }
      
      private function onCloseButton() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive)
         {
            _exitConfirmationActive = true;
            _loc1_ = showDlg("ArtStudioPrint_ExitDlg",[{
               "name":"button_yes",
               "f":onExit_Yes
            },{
               "name":"button_no",
               "f":onExit_No
            }]);
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
      }
      
      override protected function printOnePerPage(param1:DisplayObject, param2:int, param3:int, param4:Object, param5:String) : void
      {
         if(_imageToPrint)
         {
            stage.removeEventListener("keyDown",keyDown);
            super.printOnePerPage(param1,param2,param3,param4,param5);
            stage.addEventListener("keyDown",keyDown);
         }
      }
   }
}

