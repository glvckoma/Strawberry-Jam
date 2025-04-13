package game.artStudioPottery
{
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.media.SoundChannel;
   import flash.ui.Mouse;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import loader.MediaHelper;
   
   public class ArtStudioPottery extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var _soundMan:SoundManager;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _activeImageMediaHelper:MediaHelper;
      
      private var _exitConfirmationActive:Boolean;
      
      private var _activeImageIndex:int;
      
      private var _imageIDs:Array;
      
      private var _previewIDs:Array;
      
      private var _loadingImage:Boolean;
      
      private var _interfaceObject:Object;
      
      private var _brush:Object;
      
      private var _activeImage:MovieClip;
      
      public var _layerBackground:Sprite;
      
      public var _layerForeground:Sprite;
      
      public var _layerInterface:Sprite;
      
      public var _layerMouse:Sprite;
      
      public var _selectBackground:Object;
      
      protected var _buttonLeft:MovieClip;
      
      protected var _buttonRight:MovieClip;
      
      protected var _buttonColor:MovieClip;
      
      protected var _buttonPrint:MovieClip;
      
      protected var _buttonClose:MovieClip;
      
      private var _printBackground:Object;
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function ArtStudioPottery()
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
      
      private function drawCanvasMouseOver(param1:MouseEvent) : void
      {
         Mouse.show();
         _layerMouse.visible = false;
      }
      
      private function drawCanvasMouseOut(param1:MouseEvent) : void
      {
         Mouse.hide();
         _layerMouse.visible = true;
      }
      
      public function end(param1:Array) : void
      {
         Mouse.show();
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",keyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("mouseMove",moveMouse);
         _buttonPrint.removeEventListener("mouseOver",drawCanvasMouseOver);
         _buttonPrint.removeEventListener("mouseOut",drawCanvasMouseOut);
         _buttonClose.removeEventListener("mouseOver",drawCanvasMouseOver);
         _buttonClose.removeEventListener("mouseOut",drawCanvasMouseOut);
         _bInit = false;
         removeLayer(_layerForeground);
         removeLayer(_layerBackground);
         removeLayer(_layerInterface);
         removeLayer(_layerMouse);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerInterface = null;
         _layerMouse = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerBackground = new Sprite();
            _layerInterface = new Sprite();
            _layerMouse = new Sprite();
            _layerForeground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerInterface);
            addChild(_layerBackground);
            addChild(_layerForeground);
            addChild(_guiLayer);
            addChild(_layerMouse);
            loadScene("ArtStudioPottery/room_main.xroom");
            _bInit = true;
            _exitConfirmationActive = false;
         }
         else
         {
            startGame();
         }
      }
      
      private function moveMouse(param1:Event) : void
      {
         if(_sceneLoaded && _brush)
         {
            _brush.loader.x = mouseX;
            _brush.loader.y = mouseY;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closeButton");
         _buttonClose = addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _printBackground = _scene.getLayer("template");
         _printBackground.loader.x = 10000;
         _printBackground.loader.y = 10000;
         _brush = _scene.getLayer("brush");
         _brush.loader.content.mouseEnabled = false;
         _brush.loader.content.mouseChildren = false;
         _brush.loader.content.brushTip.mouseEnabled = false;
         _brush.loader.content.brushTip.mouseChildren = false;
         _brush.loader.x = mouseX;
         _brush.loader.y = mouseY;
         _interfaceObject = _scene.getLayer("interface");
         _interfaceObject.loader.content.activeCursor = _brush.loader.content;
         _selectBackground = _scene.getLayer("selectBackground");
         _selectBackground.loader.x = 0;
         _selectBackground.loader.y = 0;
         _layerInterface.addChild(_selectBackground.loader);
         _loc4_ = _scene.getLayer("buttonLeft");
         _buttonLeft = addBtn("arrowL_button",_loc4_.x - _selectBackground.x,_loc4_.y - _selectBackground.y,onButtonLeft);
         _loc4_ = _scene.getLayer("buttonRight");
         _buttonRight = addBtn("arrowR_button",_loc4_.x - _selectBackground.x,_loc4_.y - _selectBackground.y,onButtonRight);
         _loc4_ = _scene.getLayer("buttonColor");
         _buttonColor = addBtn("color_button",_loc4_.x - _selectBackground.x,_loc4_.y - _selectBackground.y,onButtonColor);
         _loc4_ = _scene.getLayer("buttonPrint");
         _buttonPrint = addBtn("createPrint_button",_loc4_.x,_loc4_.y,onButtonPrint);
         _buttonPrint.visible = false;
         _exitConfirmationActive = false;
         _sceneLoaded = true;
         stage.addEventListener("keyDown",keyDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseMove",moveMouse);
         startGame();
         _layerForeground.addChild(_scene.getLayer("insideframe").loader);
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
            _activeImageIndex = 0;
            _previewIDs = [77,105,106,107,108,109];
            _imageIDs = [76,98,99,100,101,102];
            loadImage(0,true);
         }
      }
      
      private function loadImage(param1:int, param2:Boolean) : void
      {
         if(!_loadingImage)
         {
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
            _loadingImage = true;
            _activeImageMediaHelper = new MediaHelper();
            if(param2)
            {
               _activeImageMediaHelper.init(_previewIDs[_activeImageIndex],artStudioImageMediaHandler,param2);
            }
            else
            {
               _activeImageMediaHelper.init(_imageIDs[_activeImageIndex],artStudioImageMediaHandler,param2);
            }
         }
      }
      
      private function artStudioImageMediaHandler(param1:MovieClip) : void
      {
         if(_activeImage != null && _activeImage.parent)
         {
            _activeImage.parent.removeChild(_activeImage);
         }
         _activeImage = param1;
         if(param1.passback)
         {
            param1.x = 115;
            param1.y = 102;
         }
         else
         {
            _interfaceObject.loader.content.activeImage = _activeImage;
            _interfaceObject.loader.content.newColor(10,_interfaceObject.loader.content._10.transform.colorTransform);
            param1.x = 138;
            param1.y = 84;
         }
         _layerBackground.addChild(_activeImage);
         _layerBackground.addChild(_printBackground.loader);
         _loadingImage = false;
      }
      
      private function onCloseButton() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive)
         {
            _exitConfirmationActive = true;
            _loc1_ = showDlg("ArtStudioPottery_ExitDlg",[{
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
      
      private function keyDown(param1:KeyboardEvent) : void
      {
         if(_buttonPrint.visible == false)
         {
            switch(param1.keyCode)
            {
               case 13:
               case 32:
                  if(_buttonColor && _buttonColor.visible)
                  {
                     onButtonColor();
                  }
                  break;
               case 39:
                  if(_buttonRight && _buttonRight.visible)
                  {
                     onButtonRight();
                  }
                  break;
               case 37:
                  if(_buttonLeft && _buttonLeft.visible)
                  {
                     onButtonLeft();
                     break;
                  }
            }
         }
      }
      
      private function onButtonLeft() : void
      {
         if(!_exitConfirmationActive)
         {
            loadImage(-1,true);
         }
      }
      
      private function onButtonRight() : void
      {
         if(!_exitConfirmationActive)
         {
            loadImage(1,true);
         }
      }
      
      private function onButtonColor() : void
      {
         if(!_exitConfirmationActive && !_loadingImage)
         {
            if(_activeImage != null && _activeImage.parent)
            {
               _activeImage.parent.removeChild(_activeImage);
               _activeImage = null;
            }
            loadImage(0,false);
            Mouse.hide();
            _buttonColor.visible = false;
            _buttonLeft.visible = false;
            _buttonRight.visible = false;
            _buttonPrint.visible = true;
            _buttonPrint.addEventListener("mouseOver",drawCanvasMouseOver);
            _buttonPrint.addEventListener("mouseOut",drawCanvasMouseOut);
            _buttonClose.addEventListener("mouseOver",drawCanvasMouseOver);
            _buttonClose.addEventListener("mouseOut",drawCanvasMouseOut);
            _selectBackground.loader.parent.removeChild(_selectBackground.loader);
            _layerInterface.addChild(_interfaceObject.loader);
            _layerMouse.addChild(_brush.loader);
            _layerForeground.removeChildAt(0);
            _layerForeground.addChild(_scene.getLayer("paintframe").loader);
         }
      }
      
      private function onExit_Yes() : void
      {
         Mouse.show();
         hideDlg();
         _exitConfirmationActive = false;
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
      }
      
      private function onButtonPrint() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive && !_loadingImage)
         {
            _exitConfirmationActive = true;
            _loc1_ = showDlg("ArtStudioPottery_PrintDlg",[{
               "name":"button_yes",
               "f":onPrint_Yes
            },{
               "name":"button_no",
               "f":onPrint_No
            }]);
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function onPrint_Yes() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
         printOnePerPage(_activeImage,0,0,_printBackground,"portrait");
      }
      
      private function onPrint_No() : void
      {
         hideDlg();
         _exitConfirmationActive = false;
      }
      
      override protected function printOnePerPage(param1:DisplayObject, param2:int, param3:int, param4:Object, param5:String) : void
      {
         var _loc6_:Object = _activeImage.parent;
         super.printOnePerPage(param1,param2,param3,param4,param5);
         _loc6_.addChild(_activeImage);
      }
   }
}

