package game.artStudioPainting
{
   import collection.DenItemCollection;
   import com.adobe.images.PNGEncoder;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.JPEGAsyncCompleteEvent;
   import com.sbi.graphics.JpegAsynchEncoder;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.SoundChannel;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.net.SharedObject;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.ui.Mouse;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import gui.DarkenManager;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import gui.GuiSoundButton;
   import gui.ItemReceivedPopup;
   import gui.LoadingSpiral;
   import gui.MasterpiecePreview;
   import gui.RecycleItems;
   import gui.SubmissionRulesPopup;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import shop.ShopManager;
   
   public class ArtStudioPainting extends GameBase implements IMinigame
   {
      private static const TYPE_ARTSTUDIO:int = 14;
      
      private static const TYPE_ARTSTUDIO_MASTERPIECE:int = 20;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const CHOOSE_MASTERPIECE_POPUP_ID:int = 4811;
      
      private static const ITEMS_PER_SCREEN:int = 4;
      
      private const FRAME_SELECT_FILTER_DARKER:GlowFilter = new GlowFilter(3047612,1,5,5,15);
      
      private const FRAME_SELECT_FILTER_LIGHTER:GlowFilter = new GlowFilter(3648190,1,7,7,15);
      
      private const FRAME_SELECT_FILTER_MOUSE_OVER:GlowFilter = new GlowFilter(16777215,1,10,10,15);
      
      private var _myId:uint;
      
      private var _pIDs:Array;
      
      private var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _exitConfirmationActive:Boolean;
      
      private var _interfaceObject:Object;
      
      private var _brush:Object;
      
      private var _layerBackground:Sprite;
      
      private var _layerInterface:Sprite;
      
      private var _layerMouse:Sprite;
      
      private var _submitButton:MovieClip;
      
      private var _clearAllButton:MovieClip;
      
      private var _printBtn:MovieClip;
      
      private var _masterpieceSubmitBtn:MovieClip;
      
      private var _storageButton:MovieClip;
      
      private var _jpgEncoder:JpegAsynchEncoder;
      
      private var _selectBackground:Object;
      
      private var _drawBitmapUndoSnapShot:BitmapData;
      
      private var _drawBitmapUndo:Bitmap;
      
      private var _defaultBitmapData:BitmapData;
      
      private var _drawBitmapDataSnapShot:BitmapData;
      
      private var _drawBitmapSnapShot:Bitmap;
      
      private var _drawBitmapData:BitmapData;
      
      private var _drawBitmap:Bitmap;
      
      private var _drawGraphics:Sprite;
      
      private var _drawCanvas:Sprite;
      
      private var _drawSize:Number;
      
      private var _activeBrush:Object;
      
      private var _drawing:Boolean;
      
      private var _drawStartX:Number;
      
      private var _drawStartY:Number;
      
      private var _currentTool:int;
      
      private var _drawBitmapDataRect:Rectangle;
      
      private var _drawPoint_0_0:Point;
      
      private var _undoable:Boolean;
      
      private var _airbrushes:Array;
      
      private var _drawSizes:Array;
      
      private var _printBackground:Object;
      
      private var _smudges:Array;
      
      private var _activeSmudge:Object;
      
      private var _hasDrawn:Boolean;
      
      private var _needsSave:Boolean;
      
      private var _frameTime:Number;
      
      private var _lastTime:Number;
      
      private var _timeSinceErase:Number;
      
      private var _sharedObject:SharedObject;
      
      private var _musicLoop:SoundChannel;
      
      private var _keepAliveTimer:Number;
      
      private var _mediaHelper:MediaHelper;
      
      private var _chooseMasterpiecePopup:MovieClip;
      
      private var _masterpiecePreviewIconIds:Array;
      
      private var _masterpiecePreviewIcons:Array;
      
      private var _masterpiecePreviewIconIdsOrdered:Array;
      
      private var _iconMediaHelpers:Array;
      
      private var _masterpiecePreviewPopup:MasterpiecePreview;
      
      private var _masterpiecePreviewIconStrIds:Array;
      
      private var _currPreviewIndex:int;
      
      private var _currItemVersion:int;
      
      private var _denPreviewInvId:int;
      
      private var _recyclePopup:RecycleItems;
      
      private var _submissionRules:SubmissionRulesPopup;
      
      private var _itemReceivedPopup:ItemReceivedPopup;
      
      private var _isMasterpieceSubmit:Boolean;
      
      private var _exitAfterSave:Boolean;
      
      private var _itemOffset:int;
      
      private var _URLStatus:int;
      
      private var _mediaLoader:MediaHelper;
      
      private var _mediaObject:MovieClip;
      
      private var _numMasterpieceTokens:int;
      
      private var _isUsingTokens:Boolean;
      
      private var _masterPieceSubmissionToken:String;
      
      private var _masterpieceUuid:String;
      
      private var _fileRef:FileReference;
      
      public function ArtStudioPainting()
      {
         super();
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         _myId = param1;
         _pIDs = param2;
         DarkenManager.checkParentForPosition = false;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_sharedObject != null && _interfaceObject != null && _interfaceObject.loader != null && _interfaceObject.loader.content != null)
         {
            _sharedObject.data.userColors = _interfaceObject.loader.content.saveColors();
            try
            {
               _sharedObject.flush();
            }
            catch(e:Error)
            {
            }
         }
         DarkenManager.checkParentForPosition = true;
         Mouse.show();
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         _chooseMasterpiecePopup = null;
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("mouseMove",moveMouse);
         stage.removeEventListener("mouseUp",endDraw);
         _drawCanvas.removeEventListener("mouseDown",startDraw);
         _drawCanvas.removeEventListener("mouseOver",drawCanvasMouseOver);
         _drawCanvas.removeEventListener("mouseOut",drawCanvasMouseOut);
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_layerInterface);
         removeLayer(_layerMouse);
         removeLayer(_guiLayer);
         _drawBitmapUndoSnapShot.dispose();
         _drawBitmapUndo = null;
         _defaultBitmapData.dispose();
         _drawBitmapDataSnapShot.dispose();
         _drawBitmapSnapShot = null;
         _drawBitmapData.dispose();
         _drawBitmap = null;
         _layerBackground = null;
         _layerInterface = null;
         _layerMouse = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         _mediaObject = param1;
      }
      
      private function init() : void
      {
         var _loc9_:int = 0;
         var _loc1_:Shape = null;
         var _loc11_:BitmapData = null;
         var _loc8_:* = undefined;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc12_:Shape = null;
         var _loc4_:Matrix = null;
         _mediaLoader = new MediaHelper();
         _mediaLoader.init(5556,onMediaLoaded);
         try
         {
            _sharedObject = SharedObject.getLocal(gMainFrame.userInfo.myUserName);
            if(_sharedObject.data.userSubmits == null)
            {
               _sharedObject.data.userSubmits = [];
               _sharedObject.flush();
            }
         }
         catch(e:Error)
         {
            _sharedObject = null;
         }
         _lastTime = getTimer();
         _frameTime = 0;
         _timeSinceErase = 0;
         _keepAliveTimer = 0;
         _drawGraphics = new Sprite();
         _drawSizes = new Array(2,5,10,20,35,50);
         var _loc7_:Array = new Array(3,4,5,6,7,8);
         _airbrushes = [];
         _smudges = [];
         _masterpiecePreviewIconIds = [];
         _masterpiecePreviewIcons = [];
         _iconMediaHelpers = [];
         _masterpiecePreviewIconStrIds = [];
         var _loc10_:Matrix = new Matrix();
         _loc9_ = 0;
         while(_loc9_ < _drawSizes.length)
         {
            _smudges[_loc9_] = {};
            _smudges[_loc9_].radius = _loc7_[_loc9_];
            _smudges[_loc9_].weightVector = new Vector.<Number>(_smudges[_loc9_].radius * 2 * _smudges[_loc9_].radius * 2,true);
            _loc1_ = new Shape();
            _loc11_ = new BitmapData(_smudges[_loc9_].radius * 2,_smudges[_loc9_].radius * 2,true,0);
            _loc10_.createGradientBox(_smudges[_loc9_].radius * 2,_smudges[_loc9_].radius * 2,0,0,0);
            _loc1_.graphics.beginGradientFill("radial",[16777215,16777215],[0.75,0],[0,255],_loc10_,"pad");
            _loc1_.graphics.drawCircle(_smudges[_loc9_].radius,_smudges[_loc9_].radius,_smudges[_loc9_].radius);
            _loc11_.draw(_loc1_);
            _loc8_ = _loc11_.getVector(new Rectangle(0,0,_smudges[_loc9_].radius * 2,_smudges[_loc9_].radius * 2));
            _loc2_ = 0;
            while(_loc2_ < _smudges[_loc9_].radius * 2)
            {
               _loc3_ = 0;
               while(_loc3_ < _smudges[_loc9_].radius * 2)
               {
                  _loc5_ = _loc8_[_loc2_ * _smudges[_loc9_].radius * 2 + _loc3_];
                  _loc6_ = _loc5_ >> 24 & 0xFF;
                  _smudges[_loc9_].weightVector[_loc2_ * _smudges[_loc9_].radius * 2 + _loc3_] = (255 - _loc6_) / 255;
                  _loc3_++;
               }
               _loc2_++;
            }
            _airbrushes[_loc9_] = {};
            _airbrushes[_loc9_].diameter = _drawSizes[_loc9_];
            _airbrushes[_loc9_]._drawOffSet = Math.floor(_drawSizes[_loc9_] / 2);
            _airbrushes[_loc9_]._drawTranslateMatrix = new Matrix();
            _loc12_ = new Shape();
            _loc12_.graphics.beginFill(2013265919,0.15);
            _loc12_.graphics.drawCircle(0,0,_drawSizes[_loc9_] / 2);
            _loc12_.graphics.endFill();
            _loc4_ = new Matrix();
            _loc4_.tx = _loc12_.width / 2;
            _loc4_.ty = _loc12_.height / 2;
            _airbrushes[_loc9_]._drawBrushData = new BitmapData(_loc12_.width,_loc12_.height,true,16711680);
            _airbrushes[_loc9_]._drawBrushData.draw(_loc12_,_loc4_);
            _loc9_++;
         }
         if(!_bInit)
         {
            _layerBackground = new Sprite();
            _layerInterface = new Sprite();
            _layerMouse = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerInterface);
            addChild(_layerBackground);
            addChild(_guiLayer);
            addChild(_layerMouse);
            loadScene("ArtStudioPaint/room_main.xroom");
            _bInit = true;
            _exitConfirmationActive = false;
         }
         else
         {
            startGame();
         }
      }
      
      private function startDraw(param1:MouseEvent) : void
      {
         var _loc2_:* = 0;
         if(!_pauseGame && _brush && _brush.loader.content)
         {
            if(_interfaceObject.loader.content.brushSize >= 1 && _interfaceObject.loader.content.brushSize <= _drawSizes.length)
            {
               _drawSize = _drawSizes[_interfaceObject.loader.content.brushSize - 1];
            }
            else
            {
               _drawSize = _drawSizes[0];
            }
            _currentTool = _interfaceObject.loader.content.currentTool;
            _drawBitmapUndoSnapShot.copyPixels(_drawBitmapData,_drawBitmapDataRect,_drawPoint_0_0);
            _interfaceObject.loader.content.setUndoState(1);
            _undoable = true;
            _interfaceObject.loader.content.newHistory(_interfaceObject.loader.content.red,_interfaceObject.loader.content.green,_interfaceObject.loader.content.blue);
            switch(_currentTool - 1)
            {
               case 0:
                  _drawGraphics.graphics.clear();
                  _drawBitmapDataSnapShot.copyPixels(_drawBitmapData,_drawBitmapDataRect,_drawPoint_0_0);
                  _drawGraphics.graphics.lineStyle(_drawSize,_interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue,1,true);
                  _drawGraphics.graphics.moveTo(_drawCanvas.mouseX - 1,_drawCanvas.mouseY - 1);
                  _drawGraphics.graphics.lineTo(_drawCanvas.mouseX,_drawCanvas.mouseY);
                  _drawing = true;
                  moveMouse(param1);
                  break;
               case 1:
               case 3:
               case 5:
               case 7:
                  _drawGraphics.graphics.clear();
                  _drawBitmapDataSnapShot.fillRect(_drawBitmapDataRect,0);
                  _drawCanvas.addChild(_drawBitmapSnapShot);
                  _drawStartX = _drawCanvas.mouseX;
                  _drawStartY = _drawCanvas.mouseY;
                  _drawing = true;
                  break;
               case 2:
                  if(_interfaceObject.loader.content.brushSize >= 1 && _interfaceObject.loader.content.brushSize <= _drawSizes.length)
                  {
                     _activeBrush = _airbrushes[_interfaceObject.loader.content.brushSize - 1];
                  }
                  else
                  {
                     _activeBrush = _airbrushes[0];
                  }
                  _drawing = true;
                  moveMouse(param1);
                  break;
               case 4:
                  _loc2_ = uint(-16777216 | _interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue);
                  _drawBitmapData.floodFill(_drawCanvas.mouseX,_drawCanvas.mouseY,_loc2_);
                  break;
               case 6:
                  if(_interfaceObject.loader.content.brushSize >= 1 && _interfaceObject.loader.content.brushSize <= _drawSizes.length)
                  {
                     _activeSmudge = _smudges[_interfaceObject.loader.content.brushSize - 1];
                  }
                  else
                  {
                     _activeSmudge = _smudges[_drawSizes.length - 1];
                  }
                  _drawStartX = _drawCanvas.mouseX;
                  _drawStartY = _drawCanvas.mouseY;
                  _drawing = true;
            }
         }
      }
      
      private function endDraw(param1:MouseEvent) : void
      {
         var _loc4_:Object = null;
         var _loc3_:* = 0;
         var _loc2_:BitmapData = null;
         if(_drawing)
         {
            _drawing = false;
            if(!_hasDrawn)
            {
               _masterpieceSubmitBtn.guiBtn.setGrayState(false);
               if(_submitButton != null)
               {
                  _submitButton.guiBtn.setGrayState(false);
               }
               _printBtn.guiBtn.setGrayState(false);
               _clearAllButton.guiBtn.setGrayState(false);
            }
            _needsSave = true;
            _hasDrawn = true;
            switch(_currentTool - 2)
            {
               case 0:
               case 2:
               case 4:
               case 6:
                  _drawBitmapSnapShot.parent.removeChild(_drawBitmapSnapShot);
                  _drawBitmapDataSnapShot.copyPixels(_drawBitmapData,_drawBitmapDataRect,_drawPoint_0_0);
                  _drawBitmapData.draw(_drawGraphics);
            }
            switch(_currentTool - 1)
            {
               case 0:
               case 1:
               case 3:
               case 5:
               case 7:
                  _loc4_ = _drawBitmapDataSnapShot.compare(_drawBitmapData);
                  if(_loc4_)
                  {
                     _loc3_ = uint(-16777216 | _interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue);
                     _loc2_ = BitmapData(_loc4_);
                     _drawBitmapData.threshold(_loc2_,_drawBitmapDataRect,_drawPoint_0_0,"!=",0,_loc3_);
                     break;
                  }
            }
         }
      }
      
      private function moveMouse(param1:Event) : void
      {
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:* = NaN;
         var _loc7_:* = NaN;
         var _loc5_:* = NaN;
         var _loc3_:* = NaN;
         var _loc2_:int = 0;
         var _loc6_:* = undefined;
         if(_sceneLoaded && _brush)
         {
            _brush.loader.x = mouseX;
            _brush.loader.y = mouseY;
            if(_drawing)
            {
               switch(_currentTool - 1)
               {
                  case 0:
                     _drawGraphics.graphics.lineTo(_drawCanvas.mouseX,_drawCanvas.mouseY);
                     _drawGraphics.graphics.moveTo(_drawCanvas.mouseX,_drawCanvas.mouseY);
                     _drawGraphics.graphics.endFill();
                     _drawBitmapData.draw(_drawGraphics);
                     break;
                  case 1:
                     _drawGraphics.graphics.clear();
                     _drawBitmapDataSnapShot.fillRect(_drawBitmapDataRect,0);
                     _drawGraphics.graphics.lineStyle(_drawSize,-16777216 | _interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue,1,false,"normal","square","miter");
                     _drawGraphics.graphics.moveTo(_drawStartX,_drawStartY);
                     _drawGraphics.graphics.lineTo(_drawCanvas.mouseX,_drawCanvas.mouseY);
                     _drawGraphics.graphics.endFill();
                     _drawBitmapDataSnapShot.draw(_drawGraphics);
                     break;
                  case 2:
                     _activeBrush._drawTranslateMatrix.tx = _drawCanvas.mouseX - _activeBrush._drawOffSet;
                     _activeBrush._drawTranslateMatrix.ty = _drawCanvas.mouseY - _activeBrush._drawOffSet;
                     _drawBitmapData.lock();
                     _drawBitmapData.draw(_activeBrush._drawBrushData,_activeBrush._drawTranslateMatrix,_brush.loader.content.brushTip.transform.colorTransform);
                     _drawBitmapData.unlock(new Rectangle(_activeBrush._drawTranslateMatrix.tx,_activeBrush._drawTranslateMatrix.ty,_activeBrush.diameter,_activeBrush.diameter));
                     break;
                  case 3:
                     _drawGraphics.graphics.clear();
                     _drawBitmapDataSnapShot.fillRect(_drawBitmapDataRect,0);
                     _drawGraphics.graphics.lineStyle(_drawSize,-16777216 | _interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue,1,false,"normal","square","miter");
                     _drawGraphics.graphics.drawRect(Math.min(_drawStartX,_drawCanvas.mouseX),Math.min(_drawStartY,_drawCanvas.mouseY),Math.abs(_drawCanvas.mouseX - _drawStartX),Math.abs(_drawCanvas.mouseY - _drawStartY));
                     _drawGraphics.graphics.endFill();
                     _drawBitmapDataSnapShot.draw(_drawGraphics);
                     break;
                  case 5:
                     _drawGraphics.graphics.clear();
                     _drawBitmapDataSnapShot.fillRect(_drawBitmapDataRect,0);
                     _drawGraphics.graphics.lineStyle(_drawSize,-16777216 | _interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue);
                     _drawGraphics.graphics.drawEllipse(_drawStartX - Math.abs(_drawCanvas.mouseX - _drawStartX),_drawStartY - Math.abs(_drawCanvas.mouseY - _drawStartY),Math.abs(_drawCanvas.mouseX - _drawStartX) * 2,Math.abs(_drawCanvas.mouseY - _drawStartY) * 2);
                     _drawGraphics.graphics.endFill();
                     _drawBitmapDataSnapShot.draw(_drawGraphics);
                     break;
                  case 6:
                     _loc8_ = _drawStartX;
                     _loc7_ = _drawStartY;
                     _loc5_ = _loc8_;
                     _loc3_ = _loc7_;
                     _loc2_ = 1;
                     _loc6_ = _drawBitmapData.getVector(_drawBitmapDataRect);
                     if(_drawCanvas.mouseX != _drawStartX)
                     {
                        _loc4_ = (_drawCanvas.mouseY - _drawStartY) / (_drawCanvas.mouseX - _drawStartX);
                     }
                     else
                     {
                        _loc4_ = 1;
                     }
                     _loc9_ = _drawStartY - _loc4_ * _drawStartX;
                     while(_loc5_ != _drawCanvas.mouseX || _loc3_ != _drawCanvas.mouseY)
                     {
                        if(_loc4_ < 1 && _loc4_ > -1)
                        {
                           if(_loc5_ < _drawCanvas.mouseX)
                           {
                              _loc5_ += _loc2_;
                              if(_loc5_ >= _drawCanvas.mouseX)
                              {
                                 _loc5_ = _drawCanvas.mouseX;
                              }
                           }
                           else
                           {
                              _loc5_ -= _loc2_;
                              if(_loc5_ <= _drawCanvas.mouseX)
                              {
                                 _loc5_ = _drawCanvas.mouseX;
                              }
                           }
                           if(_loc5_ != _drawCanvas.mouseX)
                           {
                              _loc3_ = _loc4_ * _loc5_ + _loc9_;
                           }
                           else
                           {
                              _loc3_ = _drawCanvas.mouseY;
                           }
                        }
                        else
                        {
                           if(_loc3_ < _drawCanvas.mouseY)
                           {
                              _loc3_ += _loc2_;
                              if(_loc3_ >= _drawCanvas.mouseY)
                              {
                                 _loc3_ = _drawCanvas.mouseY;
                              }
                           }
                           else
                           {
                              _loc3_ -= _loc2_;
                              if(_loc3_ <= _drawCanvas.mouseY)
                              {
                                 _loc3_ = _drawCanvas.mouseY;
                              }
                           }
                           if(_drawCanvas.mouseX != _drawStartX)
                           {
                              if(_loc3_ != _drawCanvas.mouseY)
                              {
                                 _loc5_ = (_loc3_ - _loc9_) / _loc4_;
                              }
                              else
                              {
                                 _loc5_ = _drawCanvas.mouseX;
                              }
                           }
                           else
                           {
                              _loc5_ = _drawStartX;
                           }
                        }
                        doSmudge(_loc6_,_loc8_,_loc7_,_loc5_,_loc3_);
                        _loc8_ = _loc5_;
                        _loc7_ = _loc3_;
                     }
                     _drawBitmapData.setVector(_drawBitmapDataRect,_loc6_);
                     _drawStartX = _drawCanvas.mouseX;
                     _drawStartY = _drawCanvas.mouseY;
                     break;
                  case 7:
                     _drawGraphics.graphics.clear();
                     _drawBitmapDataSnapShot.fillRect(_drawBitmapDataRect,0);
                     _drawGraphics.graphics.lineStyle(_drawSize,-16777216 | _interfaceObject.loader.content.red << 16 | _interfaceObject.loader.content.green << 8 | _interfaceObject.loader.content.blue,1,false,"normal","square","miter");
                     _drawGraphics.graphics.drawTriangles(Vector.<Number>([(_drawCanvas.mouseX - _drawStartX) / 2 + _drawStartX,_drawCanvas.mouseY,_drawCanvas.mouseX,_drawStartY,_drawStartX,_drawStartY]));
                     _drawGraphics.graphics.endFill();
                     _drawBitmapDataSnapShot.draw(_drawGraphics);
               }
            }
         }
      }
      
      protected function doSmudge(param1:Vector.<uint>, param2:Number, param3:Number, param4:Number, param5:Number) : void
      {
         var _loc6_:int = 0;
         var _loc18_:int = 0;
         var _loc23_:int = 0;
         var _loc25_:int = 0;
         var _loc15_:int = 0;
         var _loc14_:int = 0;
         var _loc8_:* = 0;
         var _loc10_:* = 0;
         var _loc11_:* = 0;
         var _loc13_:* = 0;
         var _loc12_:* = 0;
         var _loc21_:* = 0;
         var _loc7_:* = 0;
         var _loc19_:* = 0;
         var _loc9_:* = 0;
         var _loc22_:* = 0;
         var _loc17_:* = 0;
         var _loc20_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc16_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < _activeSmudge.radius * 2)
         {
            _loc18_ = 0;
            while(_loc18_ < _activeSmudge.radius * 2)
            {
               _loc23_ = param4 - _activeSmudge.radius + _loc18_;
               _loc25_ = param5 - _activeSmudge.radius + _loc6_;
               if(_loc23_ >= 0 && _loc23_ < _drawBitmapDataRect.width && _loc25_ >= 0 && _loc25_ < _drawBitmapDataRect.height)
               {
                  _loc15_ = param2 - _activeSmudge.radius + _loc18_;
                  _loc14_ = param3 - _activeSmudge.radius + _loc6_;
                  _loc8_ = param1[_loc25_ * _drawBitmapDataRect.width + _loc23_];
                  if(_loc15_ >= 0 && _loc15_ < _drawBitmapDataRect.width && _loc14_ >= 0 && _loc14_ < _drawBitmapDataRect.height)
                  {
                     _loc10_ = param1[_loc14_ * _drawBitmapDataRect.width + _loc15_];
                     _loc13_ = _loc10_ >> 16 & 0xFF;
                     _loc12_ = _loc10_ >> 8 & 0xFF;
                     _loc21_ = _loc10_ & 0xFF;
                     _loc7_ = _loc10_ >> 24 & 0xFF;
                     _loc19_ = _loc8_ >> 16 & 0xFF;
                     _loc9_ = _loc8_ >> 8 & 0xFF;
                     _loc22_ = _loc8_ & 0xFF;
                     _loc17_ = _loc8_ >> 24 & 0xFF;
                     _loc20_ = Number(_activeSmudge.weightVector[_loc16_]);
                     _loc24_ = (_loc19_ - _loc13_) * _loc20_;
                     _loc19_ = _loc13_ + Math.ceil(_loc24_);
                     _loc24_ = (_loc9_ - _loc12_) * _loc20_;
                     _loc9_ = _loc12_ + Math.ceil(_loc24_);
                     _loc24_ = (_loc22_ - _loc21_) * _loc20_;
                     _loc22_ = _loc21_ + Math.ceil(_loc24_);
                     _loc24_ = (_loc17_ - _loc7_) * _loc20_;
                     _loc17_ = _loc7_ + Math.ceil(_loc24_);
                     _loc11_ = uint(_loc17_ << 24 | _loc19_ << 16 | _loc9_ << 8 | _loc22_);
                     param1[_loc25_ * _drawBitmapDataRect.width + _loc23_] = _loc11_;
                  }
               }
               _loc16_++;
               _loc18_++;
            }
            _loc6_++;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         _loc4_ = _scene.getLayer("closeButton");
         addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _interfaceObject = _scene.getLayer("interface");
         if(_sharedObject != null)
         {
            _submitButton = addBtn("artStudioPaint_submitButton",502,519,onSubmitButton);
            _submitButton.guiBtn.setGrayState(true);
            if(_sharedObject.data.userColors != null)
            {
               _interfaceObject.loader.content.loadColors(_sharedObject.data.userColors);
            }
         }
         _clearAllButton = addBtn("artStudioPaint_clearButton",290,519,onClearAllButton);
         _clearAllButton.guiBtn.setGrayState(true);
         _printBackground = _scene.getLayer("template");
         _printBackground.loader.x = 10000;
         _printBackground.loader.y = 10000;
         _printBtn = addBtn("artStudioPaint_printButton",230,519,onPrintButton);
         _printBtn.guiBtn.setGrayState(true);
         addBtn("artStudioPaint_sketchButton",170,519,onSketchButton);
         _masterpieceSubmitBtn = addBtn("artStudioPaint_createMasterpiece",740,519,onCreateMasterpieceBtn);
         _masterpieceSubmitBtn.guiBtn.setGrayState(true);
         _storageButton = addBtn("artStudioPaint_storageBtn",350,519,onStorageButton);
         _storageButton.guiBtn.setUsePressedState();
         _brush = _scene.getLayer("brush");
         _brush.loader.mouseEnabled = false;
         _brush.loader.mouseChildren = false;
         _brush.loader.content.mouseEnabled = false;
         _brush.loader.content.mouseChildren = false;
         _brush.loader.content.brushTip.mouseEnabled = false;
         _brush.loader.content.brushTip.mouseChildren = false;
         _brush.loader.x = mouseX;
         _brush.loader.y = mouseY;
         _interfaceObject.loader.content.initBrush(_brush.loader.content);
         _exitConfirmationActive = false;
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseMove",moveMouse);
         stage.addEventListener("mouseUp",endDraw);
         startGame();
         _layerMouse.visible = false;
         _layerInterface.addChild(_interfaceObject.loader);
         _layerMouse.addChild(_brush.loader);
         _layerMouse.mouseEnabled = false;
         _layerMouse.mouseChildren = false;
         _drawBitmapData = new BitmapData(_interfaceObject.loader.content.canvas.width,_interfaceObject.loader.content.canvas.height,true,4294967295);
         _drawBitmap = new Bitmap(_drawBitmapData,"auto",false);
         _drawCanvas = new Sprite();
         _drawCanvas.addEventListener("mouseDown",startDraw);
         _drawCanvas.addEventListener("mouseOver",drawCanvasMouseOver);
         _drawCanvas.addEventListener("mouseOut",drawCanvasMouseOut);
         _drawCanvas.addChild(_drawBitmap);
         _drawCanvas.x = 0;
         _drawCanvas.y = 0;
         _drawing = false;
         _drawBitmapDataSnapShot = new BitmapData(_interfaceObject.loader.content.canvas.width,_interfaceObject.loader.content.canvas.height,true,4294967295);
         _drawBitmapSnapShot = new Bitmap(_drawBitmapDataSnapShot,"auto",false);
         _defaultBitmapData = new BitmapData(_interfaceObject.loader.content.canvas.width,_interfaceObject.loader.content.canvas.height,true,4294967295);
         _drawBitmapUndoSnapShot = new BitmapData(_interfaceObject.loader.content.canvas.width,_interfaceObject.loader.content.canvas.height,true,4294967295);
         _drawBitmapUndo = new Bitmap(_drawBitmapUndoSnapShot,"auto",false);
         _drawBitmapDataRect = _drawBitmapData.rect;
         _drawPoint_0_0 = new Point(0,0);
         _interfaceObject.loader.content.canvas.addChild(_drawCanvas);
         _undoable = false;
         super.sceneLoaded(param1);
      }
      
      private function drawCanvasMouseOver(param1:MouseEvent) : void
      {
         Mouse.hide();
         _layerMouse.visible = true;
      }
      
      private function drawCanvasMouseOut(param1:MouseEvent) : void
      {
         Mouse.show();
         _layerMouse.visible = false;
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
               if(param1[2] == "tkn")
               {
                  handleMasterpieceTokenReply(param1[3] == "1",param1[5],parseInt(param1[7]));
               }
            }
         }
      }
      
      public function handleMasterpieceTokenReply(param1:Boolean, param2:String, param3:int) : void
      {
         if(param1)
         {
            _masterPieceSubmissionToken = param2;
         }
         else
         {
            onSendError(null);
         }
         switch(param3 - 1)
         {
            case 0:
               if(param1)
               {
                  setupRequest(onSendComplete,onSendError,20,_denPreviewInvId,false,0);
                  break;
               }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:Bitmap = null;
         var _loc2_:BitmapData = null;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            _lastTime = getTimer();
            _timeSinceErase += _frameTime;
            _gameIdleTimer = 0;
            _keepAliveTimer++;
            if(_keepAliveTimer >= 60)
            {
               MinigameManager.keepAlive();
               _keepAliveTimer = 0;
            }
            if(_interfaceObject.loader.content.undo)
            {
               _interfaceObject.loader.content.undo = false;
               if(_drawBitmapUndoSnapShot.compare(_defaultBitmapData) == 0)
               {
                  _hasDrawn = false;
               }
               else
               {
                  _hasDrawn = true;
               }
               _masterpieceSubmitBtn.guiBtn.setGrayState(!_hasDrawn);
               if(_submitButton != null)
               {
                  _submitButton.guiBtn.setGrayState(!_hasDrawn);
               }
               _printBtn.guiBtn.setGrayState(!_hasDrawn);
               _clearAllButton.guiBtn.setGrayState(!_hasDrawn);
               _drawBitmap.parent.removeChild(_drawBitmap);
               _drawCanvas.addChild(_drawBitmapUndo);
               _loc3_ = _drawBitmap;
               _loc2_ = _drawBitmapData;
               _drawBitmap = _drawBitmapUndo;
               _drawBitmapData = _drawBitmapUndoSnapShot;
               _drawBitmapUndoSnapShot = _loc2_;
               _drawBitmapUndo = _loc3_;
               _undoable = !_undoable;
               _interfaceObject.loader.content.setUndoState(_undoable ? 1 : 2);
            }
            if(_interfaceObject.loader.content.clickSound)
            {
               AJAudio.playHudBtnClick();
               _interfaceObject.loader.content.clickSound = false;
            }
         }
      }
      
      public function startGame() : void
      {
         if(_sceneLoaded)
         {
         }
      }
      
      private function onStorage_Close() : void
      {
         hideDlg();
         _storageButton.guiBtn.setPressedState(false);
      }
      
      private function onStorage_Save() : void
      {
         onSaveButton();
      }
      
      private function onStorage_Load() : void
      {
         onLoadButton();
      }
      
      private function onStorageButton() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive)
         {
            _exitAfterSave = false;
            _loc1_ = showDlg("ArtStudioColor_StorageDlg",[{
               "name":"button_close",
               "f":onStorage_Close
            },{
               "name":"button_save",
               "f":onStorage_Save,
               "grayed":(_needsSave ? "no" : "yes")
            },{
               "name":"button_load",
               "f":onStorage_Load
            }],353,401,true,true);
         }
      }
      
      private function onSketchButton() : void
      {
         if(!_exitConfirmationActive)
         {
            DarkenManager.showLoadingSpiral(true);
            GenericListGuiManager.genericListVolumeClicked(77,{
               "msg":"biggerFrame",
               "width":768,
               "height":432,
               "shouldRepeat":false
            });
         }
      }
      
      private function onPrintButton() : void
      {
         var _loc6_:Sprite = null;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc1_:Object = null;
         if(!_exitConfirmationActive && _hasDrawn)
         {
            _loc6_ = _drawCanvas;
            _loc5_ = _loc6_.x;
            _loc4_ = _loc6_.y;
            _loc2_ = _loc6_.scaleX;
            _loc3_ = _loc6_.scaleY;
            _loc1_ = _loc6_.parent;
            _loc1_.removeChild(_loc6_);
            _loc6_.x = 170;
            _loc6_.y = 240;
            super.printOnePerPage(_loc6_,20,20,_printBackground,"portrait");
            _loc1_.addChild(_loc6_);
            _loc6_.x = _loc5_;
            _loc6_.y = _loc4_;
            _loc6_.scaleX = _loc2_;
            _loc6_.scaleY = _loc3_;
         }
      }
      
      private function onCloseButton() : void
      {
         if(!_exitConfirmationActive)
         {
            _exitConfirmationActive = true;
            if(_needsSave)
            {
               _exitAfterSave = true;
               showDlg("ArtStudioColor_SaveExitDlg",[{
                  "name":"button_close",
                  "f":onExit_No
               },{
                  "name":"button_save",
                  "f":onExit_Save
               },{
                  "name":"button_exit",
                  "f":onExit_Yes
               }],450,275,true,true);
            }
            else
            {
               showDlg("ArtStudioColor_ExitDlg",[{
                  "name":"button_yes",
                  "f":onExit_Yes
               },{
                  "name":"button_no",
                  "f":onExit_No
               }],450,275,true,true);
            }
         }
      }
      
      private function onSubmitButton() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive && _hasDrawn)
         {
            _exitConfirmationActive = true;
            _loc1_ = showDlg("ArtStudioColor_SubmitDlg",[{
               "name":"button_yes",
               "f":onSubmit_Yes
            },{
               "name":"button_no",
               "f":onExit_No
            }],450,275,true,true);
         }
      }
      
      private function onCreateMasterpieceBtn() : void
      {
         if(!_exitConfirmationActive && _hasDrawn)
         {
            if(_chooseMasterpiecePopup)
            {
               onChooseMasterpiecePopupLoaded(null);
            }
            else
            {
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(4811,onChooseMasterpiecePopupLoaded);
            }
         }
      }
      
      private function onClearAllButton() : void
      {
         var _loc1_:MovieClip = null;
         if(!_exitConfirmationActive && _hasDrawn)
         {
            _exitConfirmationActive = true;
            _loc1_ = showDlg("ArtStudioColor_ClearDlg",[{
               "name":"button_yes",
               "f":onClear_Yes
            },{
               "name":"button_no",
               "f":onExit_No
            }],450,275,true,true);
         }
      }
      
      private function setNumMasterpieceIcons() : void
      {
         var _loc2_:int = 0;
         var _loc1_:DenItemCollection = gMainFrame.userInfo.playerAvatarInfo.denItems;
         _numMasterpieceTokens = 0;
         if(_loc1_ && _loc1_.length > 0)
         {
            _loc1_ = Utility.discardDefaultAudioItem(_loc1_);
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_.getDenItem(_loc2_).defId == 2947)
               {
                  _numMasterpieceTokens++;
               }
               _loc2_++;
            }
         }
      }
      
      private function onChooseMasterpiecePopupLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _chooseMasterpiecePopup = param1.getChildAt(0) as MovieClip;
            _chooseMasterpiecePopup.x = 450;
            _chooseMasterpiecePopup.y = 275;
            _chooseMasterpiecePopup.bx.addEventListener("mouseDown",onChooseMasterpiecePopupClose,false,0,true);
            _chooseMasterpiecePopup.arrowLBtn.addEventListener("mouseDown",onLeftRightMasterpiece,false,0,true);
            _chooseMasterpiecePopup.arrowRBtn.addEventListener("mouseDown",onLeftRightMasterpiece,false,0,true);
            _masterpiecePreviewIconStrIds = MasterpiecePreview.masterpiecePreviewIconStrIds;
            _masterpiecePreviewIconIdsOrdered = MasterpiecePreview.masterpiecePreviewIconIdsOrdered;
            if(_masterpiecePreviewIconIds == null || _masterpiecePreviewIconIds.length == 0)
            {
               GenericListXtCommManager.requestGenericList(416,onMasterpieceIconList);
            }
         }
         setupMasterpieceWindows();
         _guiLayer.addChild(_chooseMasterpiecePopup);
         DarkenManager.darken(_chooseMasterpiecePopup);
      }
      
      private function onMasterpieceIconList(param1:int, param2:Array, param3:Array) : void
      {
         _masterpiecePreviewIconIds = param2;
         _masterpiecePreviewIconStrIds = param3;
         MasterpiecePreview.masterpiecePreviewIconStrIds = param3;
         if(_masterpiecePreviewIconIdsOrdered == null || _masterpiecePreviewIconIdsOrdered.length == 0)
         {
            GenericListXtCommManager.requestGenericList(424,onMasterpieceIconOrderListLoaded);
         }
         else
         {
            setupMasterpieceWindows();
         }
      }
      
      private function onMasterpieceIconOrderListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _masterpiecePreviewIconIdsOrdered = param2;
         MasterpiecePreview.masterpiecePreviewIconIdsOrdered = param2;
         setupMasterpieceWindows();
      }
      
      private function setupMasterpieceWindows() : void
      {
         var _loc1_:int = 0;
         setNumMasterpieceIcons();
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            clearOutItemLayer(_chooseMasterpiecePopup["iw" + _loc1_]);
            _chooseMasterpiecePopup["iw" + _loc1_].tag.visible = false;
            _chooseMasterpiecePopup["iw" + _loc1_].frameNameCont.visible = false;
            _chooseMasterpiecePopup["iw" + _loc1_].newTag.visible = false;
            if(_masterpiecePreviewIconIds)
            {
               if(_masterpiecePreviewIconIds[_loc1_ + _itemOffset])
               {
                  if(_masterpiecePreviewIcons && _masterpiecePreviewIcons[_loc1_ + _itemOffset])
                  {
                     setupCurrIconAndBitmap(_loc1_);
                  }
                  else
                  {
                     new LoadingSpiral(_chooseMasterpiecePopup["iw" + _loc1_].itemLayer);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_masterpiecePreviewIconIds[_loc1_ + _itemOffset],onMasterpieceIconLoaded,{
                        "index":_loc1_,
                        "offset":_itemOffset
                     });
                     _iconMediaHelpers[_loc1_ + _itemOffset] = _mediaHelper;
                  }
               }
            }
            else
            {
               new LoadingSpiral(_chooseMasterpiecePopup["iw" + _loc1_].itemLayer);
            }
            _loc1_++;
         }
      }
      
      private function clearOutItemLayer(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            while(param1.itemLayer.numChildren > 0)
            {
               _loc2_ = param1.itemLayer.getChildAt(param1.itemLayer.numChildren - 1);
               if(_loc2_ is LoadingSpiral)
               {
                  (_loc2_ as LoadingSpiral).destroy();
               }
               while(param1.itemLayer.numChildren > 0)
               {
                  param1.itemLayer.removeChildAt(param1.itemLayer.numChildren - 1);
               }
            }
         }
      }
      
      private function setupCurrIconAndBitmap(param1:int) : void
      {
         var _loc4_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc5_:Bitmap = null;
         var _loc2_:Object = null;
         var _loc3_:Boolean = false;
         if(_masterpiecePreviewIcons[param1 + _itemOffset])
         {
            _loc4_ = _masterpiecePreviewIcons[param1 + _itemOffset];
            while(_loc4_.itemWindow.numChildren > 1)
            {
               _loc4_.itemWindow.removeChildAt(_loc4_.itemWindow.numChildren - 1);
            }
            _loc6_ = _chooseMasterpiecePopup["iw" + param1];
            _loc5_ = new Bitmap(Utility.resizeImage(_drawBitmapData.clone(),_loc4_.itemWindow.width,_loc4_.itemWindow.height,true),"auto",true);
            _loc5_.x = -_loc5_.width * 0.5;
            _loc5_.y = -_loc5_.height * 0.5;
            _loc4_.itemWindow.addChild(_loc5_);
            (_loc4_.nameBar as GuiSoundButton).setTextInLayer(gMainFrame.userInfo.myUserName,"name_txt");
            _loc4_.nameBar.mouseChildren = false;
            _loc4_.nameBar.mouseEnabled = false;
            _loc4_.report_btn.visible = false;
            _loc4_.likeBtn.visible = false;
            _loc6_.frameNameCont.visible = true;
            _loc6_.tag.visible = true;
            _loc6_.newTag.visible = _itemOffset == 0 && (param1 == 0 || param1 == 1);
            LocalizationManager.translateId(_loc6_.frameNameCont.frameTxt,_masterpiecePreviewIconStrIds[param1 + _itemOffset]);
            _loc2_ = DiamondXtCommManager.getDiamondDef(221);
            _loc3_ = UserCurrency.hasEnoughCurrency(3,_loc2_.value) || _numMasterpieceTokens > 0;
            if(!_loc3_)
            {
               if(_loc6_.tag.currentFrameLabel != "diamondred")
               {
                  _loc6_.tag.gotoAndPlay("diamondred");
               }
               _loc6_.tag.txt.textColor = "0x800000";
            }
            else
            {
               if(_loc6_.tag.currentFrameLabel != "diamondgreen")
               {
                  _loc6_.tag.gotoAndPlay("diamondgreen");
               }
               _loc6_.tag.txt.textColor = "0x386630";
            }
            _loc6_.tag.txt.text = Utility.convertNumberToString(_loc2_.value);
            clearOutItemLayer(_loc6_);
            if("frame" in _loc4_)
            {
               _loc4_.frame.filters = [FRAME_SELECT_FILTER_DARKER,FRAME_SELECT_FILTER_LIGHTER];
               _loc6_.itemLayer.filters = null;
            }
            else if(_loc6_.itemLayer.filters == null || _loc6_.itemLayer.filters.length == 0)
            {
               _loc6_.itemLayer.filters = [FRAME_SELECT_FILTER_DARKER,FRAME_SELECT_FILTER_LIGHTER];
            }
            _loc6_.itemLayer.addChild(_loc4_);
            _loc6_.currIcon = _loc4_;
            _loc6_.index = param1;
            _loc6_.addEventListener("mouseDown",onPreviewIcon,false,0,true);
            _loc6_.addEventListener("mouseOver",onPreviewIconOver,false,0,true);
            _loc6_.addEventListener("mouseOut",onPreviewIconOut,false,0,true);
         }
      }
      
      private function onPreviewIcon(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         _currPreviewIndex = param1.currentTarget.index;
         _loc2_ = 0;
         while(_loc2_ < _masterpiecePreviewIconIdsOrdered.length)
         {
            if(_masterpiecePreviewIconIdsOrdered[_loc2_] == _masterpiecePreviewIconIds[_currPreviewIndex + _itemOffset])
            {
               _currItemVersion = _loc2_;
               break;
            }
            _loc2_++;
         }
         _masterpiecePreviewPopup = new MasterpiecePreview(_guiLayer,_numMasterpieceTokens,"",gMainFrame.userInfo.myUserName,gMainFrame.clientInfo.dbUserId,gMainFrame.userInfo.myUUID,_currItemVersion,onPreviewClose,gMainFrame.userInfo.myUserName,null,new Bitmap(_drawBitmapData.clone(),"auto",true),true);
         onPreviewIconOut(param1);
      }
      
      private function onPreviewIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if("frame" in param1.currentTarget.currIcon && param1.currentTarget.currIcon.frame.filters.length > 0)
         {
            param1.currentTarget.currIcon.frame.filters = null;
         }
         param1.currentTarget.itemLayer.filters = [FRAME_SELECT_FILTER_MOUSE_OVER];
         if(param1.currentTarget.currentFrameLabel != "mouse")
         {
            param1.currentTarget.gotoAndPlay("mouse");
         }
         param1.currentTarget.currIcon.nameBar.visible = false;
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onPreviewIconOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.currentFrameLabel != "out")
         {
            param1.currentTarget.gotoAndPlay("out");
         }
         if("frame" in param1.currentTarget.currIcon)
         {
            param1.currentTarget.currIcon.frame.filters = [FRAME_SELECT_FILTER_DARKER,FRAME_SELECT_FILTER_LIGHTER];
            param1.currentTarget.itemLayer.filters = null;
         }
         else
         {
            param1.currentTarget.itemLayer.filters = [FRAME_SELECT_FILTER_DARKER,FRAME_SELECT_FILTER_LIGHTER];
         }
         param1.currentTarget.currIcon.nameBar.visible = true;
      }
      
      private function onPreviewClose(param1:Boolean) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            if(Utility.numDenItemsInList(gMainFrame.userInfo.playerUserInfo.denItemsFull,0) < ShopManager.maxDenItems)
            {
               _isMasterpieceSubmit = true;
               encodeImage();
            }
            else
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,4);
            }
         }
         else
         {
            if(_masterpiecePreviewPopup)
            {
               _masterpiecePreviewPopup.destroy();
               _masterpiecePreviewPopup = null;
            }
            clearOutItemLayer(_chooseMasterpiecePopup["iw" + _currPreviewIndex]);
            _loc2_ = _masterpiecePreviewIcons[_currPreviewIndex + _itemOffset];
            _chooseMasterpiecePopup["iw" + _currPreviewIndex].itemLayer.addChild(_loc2_);
            if("frame" in _loc2_)
            {
               _loc2_.frame.filters = [FRAME_SELECT_FILTER_DARKER,FRAME_SELECT_FILTER_LIGHTER];
            }
         }
      }
      
      private function onSubmissionRulesClose(param1:Boolean, param2:Boolean) : void
      {
         _submissionRules.destroy();
         _submissionRules = null;
         _isUsingTokens = param2;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(true);
            DenXtCommManager.requestBuy(true,0,221,onPreviewItemBuy,onPreviewBuyInventoryResponse,0,null,_currItemVersion,1,true,_isUsingTokens,_masterpieceUuid);
         }
         else if(param2)
         {
            setupRequest(null,null,20,0,param2,1,false);
         }
         onPreviewClose(false);
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         var _loc2_:int = int(param1.passback);
         if(param1.status)
         {
            _recyclePopup = new RecycleItems();
            _recyclePopup.init(_loc2_,_guiLayer,true,onRecycleClose,900 * 0.5,550 * 0.5,true);
         }
         else if(_masterpiecePreviewPopup)
         {
            _masterpiecePreviewPopup.closeCallback = onPreviewClose;
         }
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recyclePopup)
         {
            _recyclePopup.destroy();
            _recyclePopup = null;
         }
         if(param1)
         {
            setNumMasterpieceIcons();
            onPreviewClose(true);
         }
         else if(_masterpiecePreviewPopup)
         {
            _masterpiecePreviewPopup.closeCallback = onPreviewClose;
         }
      }
      
      private function onPreviewItemBuy(param1:int, param2:int, param3:int) : void
      {
         if(param1 == 1)
         {
            onChooseMasterpiecePopupClose(null);
            UserCurrency.setCurrency(param2,3);
            _denPreviewInvId = param3;
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14798));
            ItemXtCommManager.setItemBuyIlCallback(null);
            _denPreviewInvId = 0;
         }
      }
      
      private function onPreviewBuyInventoryResponse() : void
      {
         var _loc3_:DenItem = null;
         var _loc2_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         var _loc1_:DenItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsFull;
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_.getDenItem(_loc2_).invIdx == _denPreviewInvId)
            {
               _loc3_ = _loc1_.getDenItem(_loc2_);
            }
            _loc2_++;
         }
         if(_loc3_)
         {
            _loc3_ = _loc3_.clone() as DenItem;
            _loc3_.initShopItem(_loc3_.defId,_loc3_.version);
            _itemReceivedPopup = new ItemReceivedPopup(_loc3_,_guiLayer,onItemReceivedClose);
         }
         _denPreviewInvId = 0;
         DenXtCommManager.denEditorDIResponseCallback = null;
      }
      
      private function onItemReceivedClose() : void
      {
         _itemReceivedPopup.destroy();
         _itemReceivedPopup = null;
         onPreviewClose(false);
         finishFeedbackSend();
      }
      
      private function onMasterpieceIconLoaded(param1:MovieClip) : void
      {
         if(_masterpiecePreviewIcons == null)
         {
            _masterpiecePreviewIcons = [];
         }
         _masterpiecePreviewIcons[param1.passback.index + param1.passback.offset] = param1.getChildAt(0) as MovieClip;
         setupCurrIconAndBitmap(param1.passback.index);
      }
      
      private function onChooseMasterpiecePopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(_chooseMasterpiecePopup);
         _guiLayer.removeChild(_chooseMasterpiecePopup);
      }
      
      private function onLeftRightMasterpiece(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget == _chooseMasterpiecePopup.arrowLBtn)
            {
               if(_itemOffset == 0)
               {
                  _loc2_ = _masterpiecePreviewIconIds.length % 4;
                  if(_loc2_ != 0)
                  {
                     _itemOffset = _masterpiecePreviewIconIds.length - _loc2_;
                  }
                  else
                  {
                     _itemOffset = _masterpiecePreviewIconIds.length - 4;
                  }
               }
               else
               {
                  _itemOffset -= 4;
               }
            }
            else if(_itemOffset + 4 < _masterpiecePreviewIconIds.length)
            {
               _itemOffset += 4;
            }
            else
            {
               _itemOffset = 0;
            }
            setupMasterpieceWindows();
         }
      }
      
      private function encodeImage() : void
      {
         DarkenManager.showLoadingSpiral(true,true);
         _jpgEncoder = new JpegAsynchEncoder();
         _jpgEncoder.addEventListener("JPEGAsyncComplete",asyncEncodingComplete,false,0,true);
         _jpgEncoder.addEventListener("progress",onEncodingProgress,false,0,true);
         _jpgEncoder.PixelsPerIteration = 128;
         _jpgEncoder.JPEGAsyncEncoder(90);
         _jpgEncoder.encode(_drawBitmapData);
      }
      
      private function onSubmit_Yes() : void
      {
         _isMasterpieceSubmit = false;
         encodeImage();
      }
      
      private function asyncEncodingComplete(param1:JPEGAsyncCompleteEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:* = false;
         var _loc4_:Date = null;
         var _loc5_:Number = NaN;
         _jpgEncoder.removeEventListener("JPEGAsyncComplete",asyncEncodingComplete);
         _jpgEncoder.removeEventListener("progress",onEncodingProgress);
         if(_isMasterpieceSubmit)
         {
            _loc2_ = [];
            _loc2_[0] = "gmtkn";
            _loc2_[1] = "0";
            _loc2_[2] = "1";
            MinigameManager.msg(_loc2_);
         }
         else
         {
            _loc3_ = false;
            if(_sharedObject != null)
            {
               if(_sharedObject.data.userSubmits.length == 5)
               {
                  _loc4_ = new Date();
                  _loc5_ = Number(_loc4_.getTime());
                  _loc5_ = _loc5_ - _sharedObject.data.userSubmits[0];
                  _loc5_ = _loc5_ / 1000 / 60 / 60;
                  _loc3_ = _loc5_ >= 24;
               }
               else
               {
                  _loc3_ = true;
               }
            }
            if(_loc3_)
            {
               setupRequest(onSendComplete,onSendError,14,0,false,0);
            }
            else
            {
               SBTracker.trackPageview("/game/play/miniGame/#ColoringSendFiltered");
               finishFeedbackSend();
            }
         }
      }
      
      private function onEncodingProgress(param1:ProgressEvent) : void
      {
         DarkenManager.updateLoadingSpiralPercentage(Math.round(param1.bytesLoaded / param1.bytesTotal * 100) + "%");
      }
      
      private function onClear_Yes() : void
      {
         handleClear();
         hideDlg();
         _exitConfirmationActive = false;
      }
      
      private function handleClear() : void
      {
         _drawBitmapUndoSnapShot.copyPixels(_drawBitmapData,_drawBitmapDataRect,_drawPoint_0_0);
         _drawBitmapData.fillRect(_drawBitmapDataRect,4294967295);
         _interfaceObject.loader.content.setUndoState(1);
         _undoable = true;
         _timeSinceErase = 0;
         _hasDrawn = false;
         _needsSave = false;
         _masterpieceSubmitBtn.guiBtn.setGrayState(true);
         if(_submitButton != null)
         {
            _submitButton.guiBtn.setGrayState(true);
         }
         _printBtn.guiBtn.setGrayState(true);
         _clearAllButton.guiBtn.setGrayState(true);
      }
      
      private function onExit_Save() : void
      {
         onSaveButton();
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
      
      public function setupRequest(param1:Function, param2:Function, param3:int, param4:int, param5:Boolean, param6:int, param7:Boolean = true) : void
      {
         var _loc11_:Object = null;
         var _loc9_:URLRequest = null;
         var _loc8_:String = "---------------------------" + Math.floor(Math.random() * 100000000000000);
         if(param3 == 14)
         {
            _loc11_ = {
               "avatarName":gMainFrame.userInfo.playerAvatarInfo.unlocalizedAvName,
               "type":param3,
               "message":_timeSinceErase,
               "languageId":LocalizationManager.currentLanguage,
               "previewItemInvIndex":param4,
               "secondaryType":(param5 ? "1" : "0"),
               "tag":(param6 == 0 ? "" : param6),
               "userName":gMainFrame.userInfo.myUserName
            };
            _loc9_ = new URLRequest(gMainFrame.clientInfo.mdUrl + "fb");
         }
         else
         {
            _loc11_ = {"authToken":(_masterPieceSubmissionToken == null ? "" : _masterPieceSubmissionToken)};
            _loc9_ = new URLRequest(gMainFrame.clientInfo.mdUrl + "mp");
         }
         _loc9_.requestHeaders.push(new URLRequestHeader("Cache-Control","no-cache"));
         _loc9_.requestHeaders.push(new URLRequestHeader("Content-Type","multipart/form-data; boundary=" + _loc8_));
         _loc9_.method = "POST";
         _loc9_.data = createPostData("ArtStudioImage",param7 ? _jpgEncoder.ImageData : null,_loc8_,_loc11_);
         var _loc10_:URLLoader = new URLLoader();
         _loc10_.dataFormat = "binary";
         if(param1 != null)
         {
            _loc10_.addEventListener("complete",param1);
         }
         if(param2 != null)
         {
            _loc10_.addEventListener("ioError",param2);
            _loc10_.addEventListener("securityError",param2);
            _loc10_.addEventListener("httpStatus",httpStatusHandler);
         }
         try
         {
            _loc10_.load(_loc9_);
         }
         catch(e:Error)
         {
            DarkenManager.showLoadingSpiral(false);
            DebugUtility.debugTrace(e.message);
            if(_isMasterpieceSubmit)
            {
               displayMasterpieceFailedPopup();
            }
            else
            {
               finishFeedbackSend();
            }
         }
      }
      
      public function createPostData(param1:String, param2:ByteArray, param3:String, param4:Object = null) : ByteArray
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
            _loc8_.writeBytes(param2);
            writeLineBreak(_loc8_);
         }
         writeBoundary(_loc8_,param3);
         writeDoubleDash(_loc8_);
         writeLineBreak(_loc8_);
         return _loc8_;
      }
      
      private function writeLineBreak(param1:ByteArray) : void
      {
         param1.writeShort(3338);
      }
      
      private function writeDoubleDash(param1:ByteArray) : void
      {
         param1.writeShort(11565);
      }
      
      private function writeBoundary(param1:ByteArray, param2:String) : void
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
      
      private function onSendComplete(param1:Event) : void
      {
         var _loc4_:ByteArray = null;
         var _loc3_:Object = null;
         var _loc2_:Date = null;
         if(_isMasterpieceSubmit)
         {
            param1.currentTarget.data.position = 0;
            _loc4_ = param1.currentTarget.data;
            if(_loc4_ && _loc4_.length > 0)
            {
               _loc3_ = JSON.parse(_loc4_.readMultiByte(_loc4_.bytesAvailable,"utf-8"));
               if(_loc3_ && _loc3_.success)
               {
                  _masterpieceUuid = _loc3_.uuid;
                  setNumMasterpieceIcons();
                  _submissionRules = new SubmissionRulesPopup(DiamondXtCommManager.getDiamondDef(221).value,_numMasterpieceTokens,_guiLayer,onSubmissionRulesClose);
                  SBTracker.trackPageview("/game/play/miniGame/#MasterpiceSubmitted");
                  return;
               }
            }
            displayMasterpieceFailedPopup();
            SBTracker.trackPageview("/game/play/miniGame/#ColoringMasterpieceSendError");
         }
         else
         {
            if(_sharedObject != null)
            {
               _loc2_ = new Date();
               _sharedObject.data.userSubmits.push(_loc2_.getTime());
               while(_sharedObject.data.userSubmits.length > 5)
               {
                  _sharedObject.data.userSubmits.shift();
               }
               try
               {
                  _sharedObject.flush();
               }
               catch(e:Error)
               {
               }
            }
            SBTracker.trackPageview("/game/play/miniGame/#ColoringSubmitted");
            finishFeedbackSend();
         }
      }
      
      private function finishFeedbackSend() : void
      {
         handleClear();
         DarkenManager.showLoadingSpiral(false);
         hideDlg();
         var _loc1_:MovieClip = showDlg("ArtStudioColor_SubmitConfirmDlg",[{
            "name":"button_yes",
            "f":onExit_No
         }],450,275,true,true);
      }
      
      private function displayMasterpieceFailedPopup() : void
      {
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(25198));
         if(_masterpiecePreviewPopup)
         {
            _masterpiecePreviewPopup.closeCallback = onPreviewClose;
         }
      }
      
      private function httpStatusHandler(param1:HTTPStatusEvent) : void
      {
         _URLStatus = param1.status;
      }
      
      private function onSendError(param1:Event) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_isMasterpieceSubmit)
         {
            if(_URLStatus == 403)
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(28329));
               SBTracker.trackPageview("/game/play/miniGame/#ColoringMasterpieceSendErrorBanned");
            }
            else
            {
               displayMasterpieceFailedPopup();
               SBTracker.trackPageview("/game/play/miniGame/#ColoringMasterpieceSendError");
            }
         }
         else
         {
            SBTracker.trackPageview("/game/play/miniGame/#ColoringSendError");
            finishFeedbackSend();
         }
      }
      
      private function handleSaveComplete(param1:Event) : void
      {
         _needsSave = false;
         if(_exitAfterSave)
         {
            onExit_Yes();
         }
         else
         {
            _storageButton.guiBtn.setPressedState(false);
            hideDlg();
         }
      }
      
      private function onSaveButton() : void
      {
         var _loc1_:FileReference = null;
         var _loc2_:ByteArray = null;
         try
         {
            _loc1_ = new FileReference();
            _loc2_ = PNGEncoder.encode(_drawBitmapData);
            _loc2_ = _mediaObject["%&"](gMainFrame.userInfo.myUUID,_loc2_,true);
            _loc1_.addEventListener("complete",handleSaveComplete);
            _loc1_.save(_loc2_,"painting.ajart");
         }
         catch(e:Error)
         {
         }
      }
      
      private function handleLoadError(param1:int) : void
      {
         hideDlg();
         _storageButton.guiBtn.setPressedState(false);
         new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(param1),true);
      }
      
      private function handleLoad(param1:Event) : void
      {
         var _loc2_:BitmapData = null;
         try
         {
            _loc2_ = param1.target.content.bitmapData;
            _drawPoint_0_0 = new Point(0,0);
            _drawBitmapData.copyPixels(_loc2_,_loc2_.rect,_drawPoint_0_0);
            _masterpieceSubmitBtn.guiBtn.setGrayState(false);
            if(_submitButton != null)
            {
               _submitButton.guiBtn.setGrayState(false);
            }
            _printBtn.guiBtn.setGrayState(false);
            _clearAllButton.guiBtn.setGrayState(false);
            _hasDrawn = true;
            _needsSave = false;
            _undoable = false;
            hideDlg();
            _storageButton.guiBtn.setPressedState(false);
         }
         catch(e:Error)
         {
            handleLoadError(25320);
         }
      }
      
      private function onFileLoaded(param1:Event) : void
      {
         var _loc5_:FileReference = null;
         var _loc2_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc4_:Loader = null;
         try
         {
            _loc5_ = param1.target as FileReference;
            _loc2_ = _loc5_["data"];
            _loc3_ = new ByteArray();
            _loc3_.writeObject(_loc2_);
            try
            {
               _loc2_ = _mediaObject["%&"](gMainFrame.userInfo.myUUID,_loc2_,false);
            }
            catch(e:Error)
            {
               _loc2_ = null;
            }
            if(_loc2_ == null)
            {
               handleLoadError(25320);
            }
            if(_loc2_ != null)
            {
               _loc4_ = new Loader();
               _loc4_.contentLoaderInfo.addEventListener("complete",handleLoad);
               _loc4_.loadBytes(_loc2_);
            }
         }
         catch(e:Error)
         {
            handleLoadError(25320);
         }
      }
      
      private function selectHandler(param1:Event) : void
      {
         try
         {
            _fileRef.addEventListener("complete",onFileLoaded);
            _fileRef.load();
         }
         catch(e:Error)
         {
            handleLoadError(25320);
         }
      }
      
      private function onLoadButton() : void
      {
         var _loc2_:Array = null;
         var _loc1_:FileFilter = null;
         try
         {
            _fileRef = new FileReference();
            _fileRef.addEventListener("select",selectHandler);
            _loc2_ = [];
            _loc1_ = new FileFilter("AJArt Files (*.ajart)","*.*");
            _loc2_.push(_loc1_);
            _fileRef.browse(_loc2_);
         }
         catch(e:Error)
         {
         }
      }
   }
}

